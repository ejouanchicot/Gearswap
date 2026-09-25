# Core bootstrap and lifecycle

This page covers how a job file comes up inside GearSwap, what `INIT_SYSTEMS.lua` starts and in which order, and the modules that keep a job environment consistent across job changes, subjob changes and reloads: `JobChangeManager` (debounced reload on subjob change), `JobSyncWatchdog` (reload when the loaded file no longer matches the client's job), `MidcastWatchdog` (recovery from a lost aftercast), `ModuleCache` (makes `require` cache), `LifecycleManager` (the shared `job_status_change` / `job_buff_change` / `job_aftercast` / `job_state_change` builders), and the two small command helpers `CycleHandler` and `WatchdogCommands`.

Everything here runs inside the GearSwap sandbox. The single most important fact for maintaining this area is that GearSwap throws the whole sandbox away and builds a new one on every main job change, every `gs reload` and every zone-in on a different job, while Windower coroutines scheduled by the old sandbox keep running. Most of the design (and most of the defects listed at the end) follow from that.

## Files

| Path | Lines | Role |
|---|---|---|
| `shared/utils/core/INIT_SYSTEMS.lua` | 344 | Included by every entry point's `get_sets()`. Installs the module cache, applies HP priorities, starts the universal systems (some synchronously, some on 0.5 s / 2 s / 3 s / 5 s timers) |
| `shared/utils/core/job_change_manager.lua` | 235 | Debounced `gs reload` on subjob change, cleanup before it, lockstyle-cancel registry |
| `shared/utils/core/job_sync_watchdog.lua` | 165 | Compares the job the file was loaded for with the client's job every 5 s, forces `gs reload` after two mismatches |
| `shared/utils/core/midcast_watchdog.lua` | 479 | Tracks the spell/item in midcast; if no aftercast arrives within cast time + buffer, sends `gs c update` |
| `shared/utils/core/module_cache.lua` | 106 | Replaces the sandbox `require` with a caching wrapper, once per sandbox |
| `shared/utils/core/lifecycle_manager.lua` | 108 | Factory for the four Mote hooks every job used to copy |
| `shared/utils/core/state_display_override.lua` | 46 | Replaces Mote's `display_current_state` (silent while the HUD is enabled; see Known issues) |
| `shared/utils/core/keybind_guard.lua` | 98 | Re-sends the job's binds 2 s after a load |
| `shared/utils/core/WATCHDOG_COMMANDS.lua` | 106 | `//gs c watchdog ...` handler, called from each job's `<JOB>_COMMANDS.lua` |
| `shared/utils/core/CYCLE_HANDLER.lua` | 136 | `//gs c cyclestate <State> [reverse]`: Mote's cycle without the chat line when the keybind HUD is visible, Mote `cycle` otherwise |

Engine files referenced (outside the repo, read-only): `addons/GearSwap/refresh.lua`, `user_functions.lua`, `packet_parsing.lua`, `gearswap.lua`, `flow.lua`, `libs/Mote-Include.lua`, `libs/Mote-SelfCommands.lua`, `libs/Modes.lua`.

## The GearSwap environment model

What GearSwap does every time it loads a job file (`load_user_files`, `refresh.lua:62-181`):

1. Calls the current file's `file_unload` through `user_pcall2` (`refresh.lua:66`). Errors are printed, not raised (`flow.lua:339-348`).
2. Unregisters every event registered through the sandbox `windower.register_event` / `raw_register_event` (`refresh.lua:69-71`; the registry is filled by `register_event_user`, `user_functions.lua:254-274`).
3. Deletes every text and prim object created since the addon loaded (`refresh.lua:73-79`; GearSwap wraps `windower.text.create` to track them, `gearswap.lua:38-60`).
4. Drops the sandbox: `user_env = nil` (`refresh.lua:83`).
5. Forces `player.main_job_id` to the requested job (`refresh.lua:91-94`), searches the file (`Tetsouo_WAR.lua`, then fallbacks down to default.lua, `refresh.lua:97-110`). If nothing is found it returns here: no file, no sandbox.
6. Builds a brand-new `user_env` (`refresh.lua:114-149`). Notable entries: `require = include_user` (`:132`), `windower = user_windower` (`:118`), `gearswap = <GearSwap's own _G>`, `_G = user_env` (`:149`). `player`, `buffactive`, `world`, `pet`, `party` are GearSwap's live tables, shared by every sandbox.
7. Runs the file's top level, then `get_sets()` (`refresh.lua:165-180`).

Consequences that the rest of this page relies on:

- `_G` inside project code is the sandbox. Everything written to `_G.*` or to module-local variables dies with it.
- `windower` inside project code is GearSwap's `user_windower` proxy (`user_functions.lua:418-423`): a plain table with `__index = windower` and no `__newindex`. `windower._foo = x` therefore stores `_foo` in that proxy table, which GearSwap creates once when the addon loads. It survives every sandbox rebuild and dies only with `//lua reload gearswap` / `//lua unload gearswap`.
- Coroutines scheduled with `coroutine.schedule` are not tracked by GearSwap. A callback scheduled by an old sandbox still runs after the rebuild, with the old sandbox as its environment (it keeps that sandbox reachable in memory while pending).
- `include_user` binds every file it loads to whatever `user_env` is current at call time (`setfenv(f,user_env)`, `user_functions.lua:327`), not to the caller's sandbox. A `require` issued by a callback of a dead sandbox loads the module into the live one.
- Keybinds (`send_command('bind ...')`) are not tracked: each entry's `file_unload` unbinds them.

When is `load_user_files` called:

| Trigger | Path |
|---|---|
| Main job change request (outgoing 0x100) | `packet_parsing.lua:733-751`: sets `player.main_job_id` from the request and sends `lua i gearswap load_user_files <id>`. The server's answer (0x061, `packet_parsing.lua:376-381`) corrects `main_job_id` but never reloads the file |
| Zone-in on a different job (0x00A) | `packet_parsing.lua:32-41` |
| `//gs reload` / `//gs r` | `gearswap.lua:209-210` -> `refresh_user_env()` (`refresh.lua:657-666`), which reads the job from `windower.ffxi.get_player()` |
| `//gs load <file>` | `gearswap.lua:189-206` |
| Addon load / login | `gearswap.lua:136-144`, `:331-335` |

A subjob change does not reload anything: 0x061 with a new subjob id fires the `sub_job_change` user event in the current sandbox (`packet_parsing.lua:421-428`). Mote turns that into `user_setup()` then `job_sub_job_change()` then `send_command('gs c update')` (`Mote-Include.lua:981-990`). The project then asks for a reload itself through `JobChangeManager`.

## How a job file boots

Example: `_master/entry/Tetsouo_WAR.lua`. The other templates, the Kaories overlay and the live files follow the same shape: every one includes INIT_SYSTEMS one to three lines after Mote-Include, with only `Profiler.mark` calls in between (COR included: `_master/entry/Tetsouo_COR.lua:151` Mote, `:153` INIT_SYSTEMS, `:197` facade). What differs is the work done before Mote-Include (WAR `WARWSConfig`; BRD, BST, PUP config globals; COR event and RollTracker cleanup) and between INIT_SYSTEMS and the facade.

```mermaid
sequenceDiagram
    participant GS as GearSwap load_user_files
    participant Entry as Tetsouo_WAR.lua
    participant Mote as Mote-Include
    participant Init as INIT_SYSTEMS.lua
    participant Facade as war_functions.lua
    GS->>GS: file_unload(old), unregister events, delete texts, drop user_env
    GS->>Entry: run top level (require JCM, UI_MANAGER, configs)
    GS->>Entry: get_sets()
    Entry->>Mote: include Mote-Include.lua
    Mote->>Mote: init_include() creates state, classes, sets skeleton, Mote-Globals
    Mote->>Entry: user_setup() states, keybinds, HUD smart_init, JCM.initialize()
    Mote->>Entry: init_gear_sets() includes the set file
    Entry->>Init: include INIT_SYSTEMS.lua
    Init->>Init: ModuleCache.install, HP priority, AutoMedicine, JobSyncWatchdog.start, SyncIPC, KeybindGuard, custom states hooks
    Init-->>Init: schedule the +0.5 s, +2.0 s, +3.0 s and +5.0 s blocks
    Entry->>Entry: data_loader, message hooks, config globals, JCM.cancel_all()
    Entry->>Facade: include facade (WAR hook modules, lockstyle and macrobook wrappers)
    Entry->>Entry: JCM.register_lockstyle_cancel WAR
```

Step by step, with the WAR template:

| # | Where | What |
|---|---|---|
| 1 | `_master/entry/Tetsouo_WAR.lua:35-59` | File top level: `LOCKSTYLE_CONFIG`, `REGION_CONFIG` (set before `config_loader` so message colours see the region), `job_change_manager`, `UI_MANAGER`, `config_loader`. These `require`s run before the module cache exists, so each one executes its file. |
| 2 | `_master/entry/Tetsouo_WAR.lua:79` | `_G.WARWSConfig` set before Mote, because `user_setup()` needs it. |
| 3 | `_master/entry/Tetsouo_WAR.lua:82` | `include('Mote-Include.lua')`. Mote runs `init_include()` at the end of its own load (`Mote-Include.lua:188`): creates `state`, `classes`, `sets.*` skeletons, includes Mote-Utility / Mote-SelfCommands / Mote-Globals, calls `job_setup()` then `user_setup()` (`:165-172`) then `init_gear_sets()` (`:175`). So `user_setup()` runs in the middle of this line, before INIT_SYSTEMS and before the job facade. |
| 4 | `_master/entry/Tetsouo_WAR.lua:200-254` | `user_setup()`: `WARStates.configure()`, the Ampulla lock re-applied to the default stance, keybinds `bind_all()`, `KeybindUI.smart_init`, `JobChangeManager.initialize()` (seeds the reference job), the "initial macrobook/lockstyle" block, `require` of `dualbox_manager`. The block's gate passes on this first call only because `bind_all()` calls `show_intro()` when it bound at least one key, and `KeybindManager`'s `show_intro` (`shared/utils/keybinds/keybind_manager.lua` `show_intro`) `require`s the job's `<JOB>_MACROBOOK` / `<JOB>_LOCKSTYLE` wrappers, whose bodies define the two globals. This holds for every job, since every keybind file goes through `KeybindManager`. RUN defers its keybinds by 0.5 s and runs the block 0.2 s later, once `get_sets()` has finished (`_master/entry/Tetsouo_RUN.lua:204-209`); BRD, BST and PUP also retry it after 0.2 s. |
| 5 | `Mote-Include.lua:193-201` | Mote defines a default `file_unload` only if the entry file has not defined one. Every entry defines its own, so Mote's default (and its `global_on_unload`) never runs. |
| 6 | `_master/entry/Tetsouo_WAR.lua:85` | `include('../shared/utils/core/INIT_SYSTEMS.lua')`, detailed below. |
| 7 | `_master/entry/Tetsouo_WAR.lua:91-121` | `data_loader`, the three `init_*_messages` hook files, config globals. |
| 8 | `_master/entry/Tetsouo_WAR.lua:124-126` | `JobChangeManager.cancel_all()`. In a fresh sandbox this only bumps a brand-new counter and walks an empty registry (see Known issues). |
| 9 | `_master/entry/Tetsouo_WAR.lua:129` | Facade `war_functions.lua`: includes every `WAR_*.lua` hook module, defines `select_default_lockstyle` / `cancel_war_lockstyle_operations` (lazy `LockstyleManager.create`), requires `dualbox_manager`. |
| 10 | `_master/entry/Tetsouo_WAR.lua:133-135` | `register_lockstyle_cancel("WAR", cancel_war_lockstyle_operations)`. |

`INIT_SYSTEMS.lua` itself, in execution order:

| Line | When | What | State touched |
|---|---|---|---|
| 35-41 | sync | Restore `_G.UPDATE_DEBUG`, `_G.AUTOMOVE_DEBUG`, `_G.WARP_DEBUG`, `_G.PrecastDebugState`, `_G.JOBCHANGE_DEBUG`, each from its own `windower._gs_debug.*` field | reads `windower._gs_debug` |
| 44 | sync | `windower._gs_reload_count += 1` (counts INIT runs, i.e. sandboxes that got this far) | `windower._gs_reload_count` |
| 53-58 | sync | `ModuleCache.install()` | replaces `_G.require` |
| 65-70 | sync | `HPPriority.apply()`: every HP piece of the loaded sets gets `priority` = its HP (Mote has already run `init_gear_sets`), see [equipment-and-inventory.md](equipment-and-inventory.md) | `sets` entries |
| 78-87 | sync | Load `LagDebugger` if absent, `on_reload_complete(job, sub, windower._automove_seq)` | `_G.LagDebugger` |
| 126-136 | +2.0 s | `require midcast_watchdog`, `_G.MidcastWatchdog = ...`, `start()` | `_G.MidcastWatchdog`, `_G.MIDCAST_WATCHDOG_TIMER`, `windower._midcast_wd_seq` |
| 150-155 | sync | `AutoMedicine.ensure()` (creates `state.AutoMedicine` if the job's states config did not) | `state.AutoMedicine` |
| 164-169 | sync | `JobSyncWatchdog.start(player.main_job)` | `windower._job_sync_seq` |
| 184-202 | sync | DualBox sync IPC: hooks `ls`, `lockstyle`, `rf`, `refill`, then `init_listener()` | see dualbox page |
| 208-257 | +0.5 s | `WarpInit.init()`; AutoMove `include` + `start()` unless `_G.DISABLE_AUTOMOVE == true`; `StateDisplayOverride.init()` | `_G.AutoMove`, `_G.display_current_state` |
| 277-282 | sync (fires +2.0 s) | `KeybindGuard.schedule()` re-sends the job's binds once the console is quiet | `windower._keybind_guard_seq` |
| 291-296 | sync | `CustomStates.install_hooks()`: hooks the player's `<JOB>_CUSTOM.lua` gear rules on Mote's functions. Here and not in `user_setup()` because Mote defines `handle_equipping_gear` and `cleanup_precast/midcast` after `user_setup()` runs, and those definitions would replace the hook; see [keybinds-and-custom.md](keybinds-and-custom.md) | Mote globals |
| 315-327 | +3.0 s | Confirm `PrecastGuard`, `CooldownChecker` and `WSPrecastHandler` load; report the ones that do not | none |
| 339-344 | +5.0 s | `GlobalProbe.snapshot()` (baseline for `//gs c syscheck` leak report) | `_G.__global_baseline` |

A module that fails to load is reported through `MessageInit.show_module_load_failed` (`shared/utils/messages/formatters/system/message_init.lua:23`), loaded lazily by `ensure_message_init()` (`INIT_SYSTEMS.lua:105-120`). When `message_init` itself cannot be loaded the helper falls back to writing straight to chat, so the unguarded `ensure_message_init().show_*` call sites - several of them inside `coroutine.schedule` blocks - can no longer raise and take the rest of their block down with them.

The header of `INIT_SYSTEMS.lua` (lines 11-20) lists this order and is up to date.

### Keybind guard

`KeybindGuard.schedule()` (`shared/utils/core/keybind_guard.lua`) re-sends the
current job's binds 2 s after the load. Mote has already run `user_setup()` by
the time INIT_SYSTEMS is included, so `bind_all()` has fired; this is a second,
silent pass for the case where it did not stick.

It exists because a bind that never lands is invisible: the job loads, `//gs c`
answers, the HUD shows the row, and only the key is dead. Confirmed on PLD -
with `^numpad9` unbound, `//gs c cyclestate HybridMode` still cycled the state,
so GearSwap was healthy and the bind alone was missing. `^numpad9` carries no
`subjob`, `exclude_subjob` or `visible`, so `get_active_binds()` always returns
it and the bind is always sent.

The race is not ours to win: a load fires the whole bind list as console
commands while the outgoing job file has just queued its own unbind burst from
`file_unload`, and the order in which a dying sandbox's commands and a new
one's reach Windower is decided in `Hook.dll`. Binding an already-bound key
overwrites it, so a load where nothing was lost pays a few silent commands.

The other half of the fix is in `KeybindManager.bind_all()`, which every job's
keybind file now uses: it unbinds only the keys that will *not* be bound back
(`clear_unwanted`: the conditional binds of another subjob, `retired_keys`,
and keys this manager left down, tracked in `windower._keybind_manager_bound`),
so no key is ever unbound and rebound in the same burst.

### What a key runs, and the common keys

`KeybindManager.bind_line(bind)` (`shared/utils/keybinds/keybind_manager.lua`) turns an entry into
the console line bound to the key; `bind_all`, `refresh` and `KeybindGuard` all go through it
(full rules, custom states and `//gs c tb` in [keybinds-and-custom.md](keybinds-and-custom.md)):

| `command` | Bound as |
|---|---|
| `"//sm mirror"` | `sm mirror` - console command of any addon |
| `"/p ready"` | `input /p ready` - game command |
| `raw = true` | the command exactly as written |
| anything else | `gs c <command>` |

`KeybindManager.create()` appends the character's common keys after the job's (and after the
`<JOB>_CUSTOM.lua` ones): `shared/utils/keybinds/common_keybinds.lua` reads
`<Character>/config/COMMON_KEYBINDS.lua` (template `_master/config_global/`, Kaories overlay in
`_master/Kaories/config_global/`) and skips any key the job already uses, so the job wins. A marker
on the list stops a second `create()` from appending twice. `AutoMedicine` (`#numpad0`) moved there
from the 15 job files; the file also carries `!numpad7`-`!numpad9` for `//gs c alts`.
`//gs c tb` sees the merged list, so it never hands out a common key.

## Job and subjob changes

### Subjob change (the path JobChangeManager owns)

```mermaid
sequenceDiagram
    participant Srv as 0x061 new subjob
    participant Mote as Mote sub_job_change
    participant Entry as entry job_sub_job_change
    participant JCM as JobChangeManager
    participant GS as GearSwap
    Srv->>Mote: sub_job_change(new, old)
    Mote->>Entry: user_setup() again, same sandbox
    Mote->>Entry: job_sub_job_change(new, old)
    Entry->>JCM: on_job_change(player.main_job, new)
    JCM->>JCM: cleanup_all_systems() stops AutoMove and MidcastWatchdog, destroys HUD
    JCM-->>JCM: counter + 1, schedule reload after 0.5 s or 3.0 s
    Mote->>GS: send_command gs c update
    JCM->>GS: after the delay, if the counter is unchanged, gs reload
    GS->>GS: file_unload runs JCM.cancel_all() and unbinds keys, then a new sandbox
```

`JobChangeManager.on_job_change(main_job, sub_job)` (`job_change_manager.lua:134-191`):

1. Returns if either argument is nil (`:135-137`).
2. `cleanup_all_systems()` (`:69-105`) immediately, before any delay: `AutoMove.stop()`, `_G.MidcastWatchdog.stop()`, `KeybindUI.destroy()`, clears `_G.keybind_ui_display`, `_G.keybind_ui_visible`, resets `_G.ui_manager_state` job fields and bumps `smart_init_id` so a pending UI init aborts, `LagDebugger.on_cleanup()`.
3. Stores `target_main_job` / `target_sub_job` (only read by debug displays).
4. `debounce_counter += 1`, captures `my_counter` (`:154-155`).
5. Delay: 0.5 s when `STATE.current_main_job == main_job`, else 3.0 s (`:162-165`). `current_main_job` is the job seeded when this sandbox ran `user_setup()` the first time.
6. Schedules the reload (`:170-190`). When it fires it aborts if `my_counter ~= debounce_counter`; otherwise it records the new current jobs and sends `gs reload` (`:189`).

Every subjob change inside the debounce window bumps the counter, so only the last one reloads. A round trip (SAM/WAR -> SAM/DNC -> SAM/WAR) still reloads once after 0.5 s: the comment at `:157-161` states this is intended because cleanup has already torn the UI and AutoMove down. (This resolves 2026-09-18 audit P2-3; commit `5223943` keys the delay on the main job only.)

When the 3.0 s branch is reached: only when `player.main_job` at the subjob event differs from the job seeded in this sandbox. A normal main job change never reaches `on_job_change` (GearSwap reloads on the 0x100 request itself), so in practice this branch is taken in a sandbox whose file does not match the client's job (the situation `JobSyncWatchdog` also corrects).

`initialize()` is a seed, not an assignment (`:118-128`). Mote calls `user_setup()` (which calls `initialize()`) before `job_sub_job_change()` in the same sandbox (`Mote-Include.lua:981-988`); overwriting would make `current_sub_job` already equal to the new subjob. Its `config` argument is ignored: since 2026-09-25 no maintained entry passes one or calls `initialize` from `job_sub_job_change`; only the frozen clones (Hysoka, Gabvanstronger) still pass their job modules.

How a pending reload is cancelled: the old sandbox's `file_unload` calls `cancel_all()` (every entry, e.g. `_master/entry/Tetsouo_WAR.lua:276-294`), which bumps the counter of the old `STATE` (`cancel_all_pending`, `:58-65`) and calls each registered lockstyle cancel function (`:219-227`). Clearing `debounce_timer` alone would not stop the queued callback; the comment at `:59-62` records this.

### Main job change

GearSwap reloads on the outgoing request (0x100), so `JobChangeManager` is not involved. The old sandbox gets `file_unload` (JCM `cancel_all`, keybind unbind). AutoMove's and JobSyncWatchdog's old loops die at their next tick because the new sandbox bumps `windower._automove_seq` / `windower._job_sync_seq`; the old `MidcastWatchdog` loop keeps scanning until the new sandbox's `start()`, 2 s into the load, bumps `windower._midcast_wd_seq`, and ends at its next tick.

### Refused or reordered job change: JobSyncWatchdog

Because the file is chosen from the request, a request the server refuses leaves the previous job's file loaded while the client runs another job. `JobSyncWatchdog.start(file_job)` (`job_sync_watchdog.lua:122-157`) is called from INIT with `player.main_job`, which at that moment is the job the file was loaded for (`refresh.lua:91-94`).

```mermaid
flowchart TD
    S["start(file_job): seq += 1, strikes = 0"] --> W["wait 8 s (FIRST_CHECK)"]
    W --> C{"my_seq == windower._job_sync_seq?"}
    C -- no --> X["stop (newer sandbox owns it)"]
    C -- yes --> J{"client job == file_job? (nil counts as equal)"}
    J -- yes --> R["strikes = 0"] --> N["wait 5 s"] --> C
    J -- no --> K["strikes += 1"]
    K --> T{"strikes >= 2?"}
    T -- no --> N
    T -- yes --> L{"last corrective reload < 30 s ago?"}
    L -- yes --> N
    L -- no --> G["warning + gs reload, stop"]
```

- The client job comes from `windower.ffxi.get_player().main_job` (`live_main_job`, `:65-74`), independent of GearSwap's `player` table.
- `windower._job_sync_last_reload` (`force_reload`, `:92-101`) keeps a 30 s floor between corrective reloads across sandboxes. It stays nil until the first correction because `os.clock()` counts from process start (`:53-56`).
- The earliest correction is 13 s after the bad load (8 s + one 5 s confirmation).
- Its debug traces use `JOBCHANGE_DEBUG`, now backed by
  `windower._gs_debug.JOBCHANGE` and restored by `INIT_SYSTEMS.lua:35-41`, so it
  survives the job change it is there to trace.

### Zone change

Zoning on the same job does not rebuild the sandbox, and none of the modules on this page react to it. Zoning in on a different job goes through `load_user_files` like a main job change (`packet_parsing.lua:38-41`).

## MidcastWatchdog

Purpose: when the aftercast packet is lost, GearSwap stays in midcast gear. The watchdog notices and sends `gs c update`.

- Jobs call `_G.MidcastWatchdog.on_midcast_start(spell)` from `job_post_midcast` (BLM, BRD, BST, COR, DNC, DRK, GEO, PLD, PUP, RDM, RUN, SAM, SMN, THF, WHM; not WAR) and `on_aftercast()` from `job_aftercast`, directly or through `LifecycleManager.aftercast` (PLD, PUP, RDM, RUN, SAM, WHM). WAR calls neither, so WAR's subjob spells are not watched.
- Only spell types in `MONITORED_SPELL_TYPES` (`midcast_watchdog.lua:153-162`: WhiteMagic, BlackMagic, BlueMagic, Ninjutsu, SummonerPact, BardSong, Geomancy, Trust) and `spell.type == 'Item'` are tracked; abilities, weaponskills, waltzes etc. return early (`:178-190`).
- Timeout (`calculate_timeout`, `:86-114`): items use `res.items[id].cast_delay` (or `cast_time`) + buffer with no Fast Cast; spells use `res.spells[id].cast_time * (1 - FC/100) + buffer`, where FC is `state.FastCast.value` capped at 80 (`get_fast_cast_percent`, `:71-84`). Unknown id: `WATCHDOG_FALLBACK_TIMEOUT` (5.0 s). Buffer `WATCHDOG_BUFFER` 1.5 s.
- Loop: `start()` (`:450-469`) bumps the generation counter `windower._midcast_wd_seq` (`:439`, `:451-452`), sets `_G.MIDCAST_WATCHDOG_TIMER = true` and schedules a self-rescheduling callback every 0.5 s. A tick whose captured generation is no longer the current one returns without rescheduling (`:456-458`), so every `start()` or `stop()` ends the loops started before it and only the newest keeps running, whichever sandbox or module instance started it. Each tick runs `check_stuck()` under `pcall` (`background_check`, `:442-447`). If `age > timeout`: message, clear, leave test mode, `send_command('gs c update')` (`:253-265`).
- `stop()` (`:472-479`) clears the flag and the tracked cast. It is called only from `JobChangeManager.cleanup_all_systems()`.
- Test mode: `simulate_stuck()` (`:402-431`) fakes an active cast and sets `test_mode_active`, which makes `on_aftercast()` a no-op until `check_stuck()` fires.

Timeouts are only as good as `state.FastCast`. It is a user setting (`_master/config/blm/BLM_STATES.lua:251-258` defaults to 80, BST/COR/DNC to 0). With 80 configured and 50 % real Fast Cast, Teleport-Holla (cast time 20) gets 20 x 0.2 + 1.5 = 5.5 s against a real 10 s cast, and the watchdog would send `gs c update` mid-cast. Nothing stops that update from swapping gear during the cast: GearSwap's `equip_sets()` has no midaction check (`flow.lua:113-172`) and no project code calls `midaction()`, so idle/engaged gear goes on before the spell lands.

With Mote's `state.EquipStop` set to `midcast`, `filter_aftercast` cancels the aftercast (`Mote-Include.lua:362-368`), `job_aftercast` never runs, and the watchdog re-equips gear after the timeout.

## ModuleCache

Inside the sandbox `require` is `include_user` (`refresh.lua:132`). It returns `package.loaded[str]` when that is a table (Windower's own libs) and otherwise loads and executes the file every time (`user_functions.lua:300-327`); it never writes `package.loaded`.

`ModuleCache.install()` (`module_cache.lua:44-88`), called once per sandbox from `INIT_SYSTEMS.lua:53-58`:

- Guard: `rawget(_G, '__require_cache_installed')`, so a second call in the same sandbox returns false.
- Wraps the original `require`. Calls with a second argument (include-into-table form) or a non-string path pass straight through (`:64-66`).
- Key: `path:lower()`, matching `include_user`'s own lowercasing (`user_functions.lua:305`). A module that returns nil is stored as the `CACHED_NIL` sentinel so it is not re-run (`:40`, `:83`). A load that raises is not cached.
- Counters in `_G.__require_cache_stats`; the table itself is `_G.__require_cache`.

Lifetime: the cache lives on the sandbox `_G` and dies with it. The header (`:18-25`) gives the reason: a module is bound to the `user_env` it was loaded in, so a cache that outlived the sandbox would hand the next job modules bound to the old `player`/`sets`/`state`.

`include()` is not cached: set files and `automove.lua` are meant to re-execute.

`package.loaded` never holds a project module. The comments that used to describe it being cleared on reload, or persisting across a job change (in `lockstyle_manager`, `macrobook_manager`, `craft_manager`, `lag_debugger`, `warp_init`, `dualbox_sync_ipc`, `dualbox_manager`), have been rewritten: `grep -rn "package.loaded" shared` now finds only `INIT_SYSTEMS.lua`, `module_cache.lua` and `DEBUG_COMMANDS.lua` (memcheck). What those modules actually get is one instance per sandbox from `_G.__require_cache` (plus a pre-cache instance if they were required before INIT_SYSTEMS), and a new sandbox on every main job change.

Gotcha: everything required before `INIT_SYSTEMS.lua:53` (entry top level, anything `user_setup()` requires, set files) is loaded uncached, and the first `require` after installation loads it again. For those modules there are two instances in the same sandbox. Module state that must be shared between them has to live on `_G` or `windower.*`. `JobChangeManager` does exactly that (`_G.JobChangeManagerSTATE`, `job_change_manager.lua:32-55`): the entry keeps the pre-cache instance as an upvalue while `COMMON_COMMANDS.handle_reload` gets the cached one.

## LifecycleManager

Four builders, each returning a handler; the caller assigns the Mote global (`job_status_change = LifecycleManager.status_change()` etc.). Each takes an optional `extra(...)` callback with the same arguments as the handler.

| Builder | Shared behaviour | `extra` | Used by |
|---|---|---|---|
| `status_change(extra)` (`:38-45`) | `DoomManager.handle_status_change(new, old)` (unlocks Doom slots after death) | always run after | BLM BRD BST COR DNC GEO PLD PUP RDM RUN SAM THF WHM |
| `buff_change(extra)` (`:50-59`) | `DoomManager.handle_buff_change(buff, gain)`; if it returns true the chain stops | skipped when Doom handled it | BLM BRD BST COR DNC PLD PUP RDM RUN SAM WHM (COR passes `retire_lost_roll`) |
| `aftercast(extra)` (`:68-77`) | `_G.MidcastWatchdog.on_aftercast()` if the watchdog is loaded. No `gs c update` (removed 2026-06, comment `:63-65`) | always run after | PLD PUP RDM RUN SAM SMN WHM |
| `state_change(extra)` (`:85-100`) | Returns immediately for `stateField == 'Moving'`; otherwise `KeybindUI.update()` | run after the UI update | BRD BST COR DNC DRK GEO PLD PUP RUN SAM SMN THF (COR, PLD and THF pass `on_state_change`) |

`DoomManager` is required on first use, not at file load (`:28-33`), without `pcall`.

## CycleHandler and state display

`//gs c cyclestate <State> [reverse]` is routed by every job's `<JOB>_COMMANDS.lua` (16 files) to `CycleHandler.handle_cyclestate(cmdParams, eventArgs)` (`CYCLE_HANDLER.lua:90-130`):

- Fewer than two words: error message, handled.
- State name must match `^[%w_]+$` (`:99`).
- A third word `reverse`, `backwards` or `r` (any case) cycles backwards, the words Mote's `handle_cycle` accepts (`:27`, `:104`).
- HUD hidden (`KeybindUI.is_visible()` false): `windower.send_command('gs c cycle <State>[ reverse]')` so Mote's `handle_cycle` does the work and prints its chat line (`delegate_to_mote`, `:69-75`).
- HUD visible: the state is found with Mote's `get_state` (case-insensitive, mode states only; exact key if `get_state` is missing, `find_state` `:36-42`), then `cycle_silently` (`:48-63`) does what `handle_cycle` does minus the chat line: capture the old value, `cycle()`/`cycleback()`, `job_state_change(description or name, new, old)`, `handle_update({'auto'})` (`reset_buff_states`, `job_update`, `handle_equipping_gear`). Then `KeybindUI.update()` (`:126-128`); every `job_update` repaints too, and the HUD diff skips the second paint.

Both paths now pass the same arguments to `job_state_change` and both run `job_update`. The only differences left are deliberate:

| | HUD visible (CycleHandler) | HUD hidden (Mote `handle_cycle`, `Mote-SelfCommands.lua:140-169`) |
|---|---|---|
| `stateField` passed to `job_state_change` | description (`Hybrid Mode`), key when the state has none | same |
| `oldValue` | real previous value | same |
| `reset_buff_states()`, `job_update()`, gear refresh | via `handle_update({'auto'})` | via `handle_update({'auto'})` (`:163`, `:238-258`) |
| chat line | none (the HUD shows the new value) | `add_to_chat(122, ...)` (`:162`) |
| extra HUD repaint | `KeybindUI.update()` | none |

Job handlers still strip spaces from `stateField` (for example `WAR_COMMANDS.lua` `job_state_change`), so a caller passing the key also works. Nothing calls `update_combat_form()` any more: Mote never called it, and `handle_update` already refreshes the gear. BRD's copy, the last one, was removed in commit `951fb12`.

`StateDisplayOverride.init()` (`state_display_override.lua:28-40`), run from the 0.5 s INIT block, replaces the global `display_current_state` with a function taking `(new_value, state_name, old_value)` that stays silent when `_G.ui_display_config.enabled` and otherwise prints `MessageFormatter.show_state_display(...)`. Mote never calls `display_current_state` on a state change: its cycle/set/toggle handlers print directly (`Mote-SelfCommands.lua:70, 104, 162, 198, 226`), and the only caller is `handle_update` when the first argument is `user` (`:255-256`), with no arguments.

## Public API

### JobChangeManager (`shared/utils/core/job_change_manager.lua`, returned table; no `_G` export)

| Function | Params | Returns | Side effects | Callers |
|---|---|---|---|---|
| `initialize(config)` | `config` ignored | nil | Seeds `STATE.current_main_job/sub_job` from `player` if nil | every entry `user_setup` (BST/PUP also from their 0.2 s retry); no longer called from `job_sub_job_change` (removed 2026-09-25) |
| `on_job_change(main_job, sub_job)` | short job names | nil | Cleanup now, debounced `gs reload` | every entry `job_sub_job_change` |
| `force_reload(main_job?, sub_job?)` | defaults to `player` | nil | Bumps counter, sends `gs reload` immediately; error message if no job data | `COMMON_COMMANDS.handle_reload` (`COMMON_COMMANDS.lua:44-56`) |
| `cancel_all()` | | nil | Bumps counter, calls every registered lockstyle cancel under `pcall` | every entry `get_sets` and `file_unload` |
| `register_lockstyle_cancel(job, fn)` | job code, function | nil | Stores in `STATE.lockstyle_cancel_registry` | every entry `get_sets` after the facade |

### JobSyncWatchdog (`_G.JobSyncWatchdog`, returned)

| Function | Params | Side effects | Callers |
|---|---|---|---|
| `start(file_job)` | short job name; ignored if not a non-empty string or `NONE` | Bumps `windower._job_sync_seq`, schedules the check loop | `INIT_SYSTEMS.lua:166` |

### MidcastWatchdog (returned; `_G.MidcastWatchdog` set by INIT)

| Function | Notes | Callers |
|---|---|---|
| `on_midcast_start(spell)` | Records spell/item and its timeout; no-op when disabled | 15 job `<JOB>_MIDCAST.lua` files |
| `on_aftercast()` | Clears tracking unless disabled or in test mode | job `<JOB>_AFTERCAST.lua`, `LifecycleManager.aftercast` |
| `check_stuck()` | One scan; sends `gs c update` when overdue | internal loop |
| `start()` / `stop()` | Both bump `windower._midcast_wd_seq`, which ends every older loop; `start()` then runs a new one. `stop()` also clears the tracked midcast when `_G.MIDCAST_WATCHDOG_TIMER` is set | `INIT_SYSTEMS.lua:132` / `job_change_manager.lua:77` |
| `enable()`, `disable()`, `toggle()` | Message on change | `WATCHDOG_COMMANDS` |
| `toggle_debug()` (`enable_debug`, `disable_debug`) | Verbose per-scan messages | `WATCHDOG_COMMANDS` |
| `set_buffer(s)` | 0..10, else error message | `WATCHDOG_COMMANDS` |
| `set_fallback_timeout(s)` | (0..30], else error message | `WATCHDOG_COMMANDS` |
| `get_stats()` | Table: active, spell_name, ids, cast times, fast_cast, age, enabled, timeout, buffer, fallback_timeout, debug | `WATCHDOG_COMMANDS`, `system_checker.lua` `check_watchdog` |
| `clear_all()` | Clears tracking, sends `gs c update` | `WATCHDOG_COMMANDS` |
| `simulate_stuck(name, id)` | Test mode | `WATCHDOG_COMMANDS` |
| `is_enabled()`, `get_buffer()`, `get_fallback_timeout()`, `is_debug_enabled()` | Getters | none in the repository |

### ModuleCache (`_G.ModuleCache`, returned)

| Function | Returns | Callers |
|---|---|---|
| `install()` | true when installed by this call | `INIT_SYSTEMS.lua:56` |
| `stats()` | `hits, loads, cached_modules` | none (the header says syscheck; `system_checker.lua` does not call it) |

### LifecycleManager (`_G.LifecycleManager`, returned)

`status_change(extra)`, `buff_change(extra)`, `aftercast(extra)`, `state_change(extra)`: see the table above.

### StateDisplayOverride (returned only)

`init()`: assigns `_G.display_current_state`. Caller: `INIT_SYSTEMS.lua:253`.

### WatchdogCommands (returned only)

| Function | Notes |
|---|---|
| `is_watchdog_command(command)` | `command == 'watchdog'` |
| `handle_command(cmdParams, eventArgs)` | Returns false unless `cmdParams[1]:lower() == 'watchdog'`; sets `eventArgs.handled = true` when handled |

Callers: all 16 `shared/jobs/*/functions/*_COMMANDS.lua`, lazily required.

### CycleHandler (returned only)

`handle_cyclestate(cmdParams, eventArgs)`: always returns true. `cmdParams` = `{'cyclestate', State, ['reverse'|'backwards'|'r']}`. Callers: all 16 job `<JOB>_COMMANDS.lua`.

## Commands

| Command | Handler | Effect |
|---|---|---|
| `//gs c reload` | `COMMON_COMMANDS.lua:543-544` -> `handle_reload` (`:44-56`) -> `JobChangeManager.force_reload` | Immediate `gs reload` (no cleanup, no debounce) |
| `//gs c watchdog` | `WATCHDOG_COMMANDS.lua:59-61` | Status (`show_status(get_stats())`) |
| `//gs c watchdog on` / `off` / `toggle` | `:62-67` | Enable / disable / toggle |
| `//gs c watchdog debug` | `:68-69` | Toggle per-scan debug output |
| `//gs c watchdog buffer <s>` | `:70-74` | `set_buffer` (non-numeric argument is ignored silently) |
| `//gs c watchdog fallback <s>` | `:75-79` | `set_fallback_timeout` |
| `//gs c watchdog clear` | `:80-81` | `clear_all()` |
| `//gs c watchdog test [name] [id]` | `:82-88` | `simulate_stuck(name or 'Teleport-Holla', id or 262)` (262 is Warp II, see Known issues) |
| `//gs c watchdog stats` | `:89-91` | Detailed stats |
| `//gs c watchdog <other>` | `:92-93` | Help |
| `//gs c cyclestate <State> [reverse]` | `CYCLE_HANDLER.lua:90` via each job's `<JOB>_COMMANDS.lua` | UI-aware cycle (silent with the HUD visible, Mote's chat line otherwise) |
| `//gs c debugjobchange` / `djc` | `DEBUG_COMMANDS.lua:541-552` | Toggles `windower._gs_debug.JOBCHANGE` (mirrored to `_G.JOBCHANGE_DEBUG`) and prints `JobChangeManagerSTATE` |
| `//gs c debugstate` / `ds` | `DEBUG_COMMANDS.lua:260-283` | Dumps JCM counter and registry size among others |
| `//gs c debugupdate` | `DEBUG_COMMANDS.lua:557-564` | Toggles `windower._gs_debug.UPDATE` (restored by INIT on reload) |

## Configuration

Nothing on this page reads a config file. Tunables are file-level constants:

| Constant | Value | Where |
|---|---|---|
| Subjob / main debounce | 0.5 s / 3.0 s | `job_change_manager.lua:162-165` |
| `CHECK_INTERVAL`, `CONFIRMATIONS`, `RELOAD_COOLDOWN`, `FIRST_CHECK` | 5.0 s, 2, 30.0 s, 8.0 s | `job_sync_watchdog.lua:39-42` |
| `WATCHDOG_BUFFER` | 1.5 s (runtime: `watchdog buffer`) | `midcast_watchdog.lua:34` |
| `WATCHDOG_FALLBACK_TIMEOUT` | 5.0 s (runtime: `watchdog fallback`) | `midcast_watchdog.lua:37` |
| `FAST_CAST_CAP` | 80 | `midcast_watchdog.lua:40` |
| Watchdog scan period | 0.5 s | `midcast_watchdog.lua:462, 468` |
| INIT deferrals | 0.5 s, 2.0 s, 3.0 s, 5.0 s | `INIT_SYSTEMS.lua:257, 136, 327, 344` |
| KeybindGuard delay | 2.0 s | `keybind_guard.lua` `REASSERT_DELAY` |

Runtime inputs read: `state.FastCast` (per job `[JOB]_STATES.lua`), `_G.DISABLE_AUTOMOVE` (read by INIT; no entry sets it since commit 0563ff9), `_G.ui_display_config.enabled` (StateDisplayOverride), `KeybindUI.is_visible()` (CycleHandler), `windower._gs_debug`.

Runtime changes made with `watchdog buffer/fallback/on/off/debug` live in module locals and are lost at the next sandbox rebuild.

## State and lifetime

### Written to the sandbox `_G` (rebuilt on every reload)

| Global | Writer | Readers |
|---|---|---|
| `JobChangeManagerSTATE` | `job_change_manager.lua:36-53` | JCM, `DEBUG_COMMANDS.lua` `handle_debugjobchange` / `handle_debugstate`, `system_checker.lua:121` |
| `MidcastWatchdog` | `INIT_SYSTEMS.lua:131` | jobs, `LifecycleManager`, JCM cleanup, `WATCHDOG_COMMANDS`, `system_checker` |
| `MIDCAST_WATCHDOG_TIMER` | `midcast_watchdog.lua:467` (set), `:475` (cleared) | `stop()` only (clears the tracked midcast when set, `:474-477`); `global_probe.lua:57` lists it as expected. It does not control the loop |
| `JobSyncWatchdog`, `LifecycleManager`, `ModuleCache` | module exports | no reader. All three are in the GlobalProbe expected list (`global_probe.lua:55,58,128`) |
| `require` (replaced), `__require_cache`, `__require_cache_installed`, `__require_cache_stats` | `module_cache.lua:55-57` and the wrapper assignment after it | every `require` |
| `display_current_state` | `state_display_override.lua:29` | Mote `handle_update` |
| `UPDATE_DEBUG`, `AUTOMOVE_DEBUG`, `WARP_DEBUG`, `PrecastDebugState`, `JOBCHANGE_DEBUG` | `INIT_SYSTEMS.lua:35-41` | Mirrors of `windower._gs_debug.*`, re-seeded on every load; DebugLogger users |
| `keybind_ui_display`, `keybind_ui_visible`, `ui_manager_state.*` | cleared by `job_change_manager.lua:87-101` | UI manager |
| `job_status_change`, `job_buff_change`, `job_aftercast`, `job_state_change` | job modules via `LifecycleManager` builders | Mote |

Read only: `JOBCHANGE_DEBUG` (via `DebugLogger.log_if`), `LagDebugger`, `AutoMove`, `state`, `player`, `get_state`, `handle_update`, `job_state_change` (CycleHandler).

### Written to `windower.*` (survives sandbox rebuilds, dies with the addon)

| Field | Owner | Purpose |
|---|---|---|
| `_gs_reload_count` | `INIT_SYSTEMS.lua:44` | Count of INIT runs; read by `system_checker` (hook-chain ratio), `full_test.lua:169`, `dualbox_manager.lua:479` |
| `_gs_debug` | `DEBUG_COMMANDS.lua` `flip_debug` (read by `INIT_SYSTEMS.lua:35-41`) | The five persisted debug toggles |
| `_job_sync_seq` | `job_sync_watchdog.lua:57, 102, 127` | Invalidates older check loops |
| `_job_sync_last_reload` | `job_sync_watchdog.lua:101` | 30 s floor between corrective reloads |
| `_automove_seq` | read at `INIT_SYSTEMS.lua:86` (owned by AutoMove) | passed to LagDebugger |
| `_midcast_wd_seq` | `midcast_watchdog.lua:439, 451, 473` | MidcastWatchdog loop generation: bumped by every `start()` and `stop()`, only the newest loop keeps running |
| `_keybind_guard_seq` | `keybind_guard.lua` `schedule` | Invalidates a pending re-assert when another load starts |
| `_ui_live_state` | `UI_MANAGER.lua:124` | The live load's UI state; older HUD coroutines compare against it (see [ui-overlay.md](ui-overlay.md)) |

### Events, texts, keybinds, coroutines

- No module on this page registers a Windower event, creates a text object or binds a key. INIT_SYSTEMS triggers the DualBox IPC listener (`init_listener`) and AutoMove, which are documented on their own pages. GearSwap unregisters sandbox-registered events and deletes text/prim objects itself on every `load_user_files` (`refresh.lua:69-79`).
- Coroutines scheduled here and how each is invalidated:

| Scheduled by | Callback | Invalidation |
|---|---|---|
| `INIT_SYSTEMS.lua:126` (+2 s), `:208` (+0.5 s), `:315` (+3 s), `:339` (+5 s) | watchdog start, warp/automove/state display, precast chain check, probe snapshot | none: they run even if the sandbox was replaced. A stale watchdog start is harmless: the newer load's own start comes later and supersedes it |
| `keybind_guard.lua` `schedule` (+2 s) | re-send the binds | `windower._keybind_guard_seq` mismatch |
| `job_change_manager.lua:170` | `gs reload` | `debounce_counter` mismatch (bumped by the next `on_job_change`, `force_reload`, `cancel_all`) |
| `job_sync_watchdog.lua:151, 154` | check loop | `windower._job_sync_seq` mismatch; ends after sending a reload |
| `midcast_watchdog.lua:462, 468` | scan loop | `windower._midcast_wd_seq` mismatch (bumped by every `start()` and `stop()`) |

### Behaviour per transition

| Transition | Sandbox | JCM | JobSyncWatchdog | MidcastWatchdog | ModuleCache |
|---|---|---|---|---|---|
| Cold load / `//lua reload gearswap` | new (addon state also new) | fresh STATE, seeded in `user_setup` | starts | starts at +2 s | installed |
| `//gs reload`, `//gs c reload`, JSW correction | new | old reload cancelled by `file_unload` | old loop superseded | old loop superseded by the new `start()` at +2 s | new cache |
| Subjob change | same, then new after 0.5 s | cleanup + debounced reload | superseded after reload | stopped by cleanup, restarted at +2 s | new cache |
| Main job change / zone-in on another job | new | not involved | superseded | superseded at +2 s | new cache |
| Main job change to a job with no file | none | not involved | old loop keeps running and forces one reload | old loop keeps running | none |
| Zone on same job, death, raise | same | nothing | nothing | nothing | same |

## Interactions

- Calls: `DebugLogger` (`shared/utils/debug/debug_logger.lua`), `MessageFormatter` / `MessageInit` / `MessageWatchdog` (see [messages.md](messages.md)), `KeybindUI` (`shared/utils/ui/UI_MANAGER.lua`), `AutoMove` (`shared/utils/movement/automove.lua`), `LagDebugger`, `GlobalProbe`, `AutoMedicine`, `DualBoxSyncIPC`, `WarpInit`, `DoomManager`, `resources`.
- Called by: every entry point (`get_sets`, `user_setup`, `job_sub_job_change`, `file_unload`), every job `<JOB>_MIDCAST.lua` / `<JOB>_AFTERCAST.lua` / `<JOB>_STATUS.lua` / `<JOB>_BUFFS.lua` / `<JOB>_COMMANDS.lua`, `COMMON_COMMANDS.lua`, `system_checker.lua`, `full_test.lua`.
- Midcast set selection itself is on [midcast-and-buffs.md](midcast-and-buffs.md). Per-job wiring is on the pages under [../jobs/](../jobs/).

## Invariants and gotchas

- `user_setup()` runs inside `include('Mote-Include.lua')`, before INIT_SYSTEMS and the job facade. Anything defined by the facade (`select_default_lockstyle`, `select_default_macro_book`, job hooks) is nil during the first call. Mote calls `user_setup()` again on every subjob change (`Mote-Include.lua:981-984`), when everything exists.
- An error in the first `user_setup()` propagates out of `include('Mote-Include.lua')` and aborts the rest of `get_sets()` (`user_pcall` re-raises, `flow.lua:318-327`), including INIT_SYSTEMS and the facade.
- State that must survive a reload goes on `windower.*`, never `_G`. State that must not survive (anything holding functions or tables bound to a sandbox) goes on `_G`. A loop scheduled with `coroutine.schedule` needs a `windower.*` sequence captured at start; a `_G` flag is invisible to the next sandbox (AutoMove learned this, `automove.lua:25-31`).
- A callback from a dead sandbox that calls `require` loads the module into the live sandbox (`user_functions.lua:327`), with its own module state.
- Modules required before `INIT_SYSTEMS.lua:53` get a second instance after the cache is installed. Keep cross-instance state on `_G`.
- Hooks on Mote functions defined after `user_setup()` (`handle_equipping_gear`, `cleanup_precast`, `cleanup_midcast`) must be laid from INIT_SYSTEMS, not from `user_setup()`: Mote's later definitions replace them (`INIT_SYSTEMS.lua:288-296`).
- `JobChangeManager.initialize()` must stay a seed (only when nil).
- `cleanup_all_systems()` runs before the debounce, so any `on_job_change()` must be followed by a reload; aborting without one leaves the sandbox without AutoMove, watchdog and HUD.
- `WAR` does not feed the midcast watchdog.
- `CycleHandler` and Mote pass the same `stateField` (the description, the key when there is none) to `job_state_change`. Handlers still strip spaces so that a caller passing the key also works.

## Extending

Adding a universal system to INIT_SYSTEMS:

1. Decide whether it must exist before the first action (synchronous block, like AutoMedicine at `:150-155`) or can wait (inside the 0.5 s block at `:208-257`).
2. Load with `pcall(require, ...)` and report failure with `ensure_message_init().show_module_load_failed(name, err)`.
3. If it schedules a loop, capture a `windower._<name>_seq` at start and compare it on every tick, as `job_sync_watchdog.lua:127-133` does.
4. If it lives in a deferred block, check that the sandbox is still current before doing anything (the existing blocks do not).
5. Add its globals to the expected list in `shared/utils/debug/global_probe.lua` if they appear after the 5 s snapshot.

Adding a job hook through LifecycleManager: `local LifecycleManager = require('shared/utils/core/lifecycle_manager')`, then `job_buff_change = LifecycleManager.buff_change(function(buff, gain, eventArgs) ... end)` and `_G.job_buff_change = job_buff_change`.

Watching a new job's spells: call `_G.MidcastWatchdog.on_midcast_start(spell)` in `job_post_midcast`, as the 15 existing callers do (guarded by `if _G.MidcastWatchdog`) and use `LifecycleManager.aftercast()` or call `on_aftercast()` in `job_aftercast`. Add `state.FastCast` to the job's states config if the job has meaningful Fast Cast.

## Known issues

Open:

- `StateDisplayOverride` does not silence cycle messages and turns `//gs c update user` into "State: Unknown" or nothing (`state_display_override.lua:29-39`; its header now says so).
- JobSyncWatchdog keeps running after a change to a job with no file and forces one misleading reload (`job_sync_watchdog.lua:131-152`).
- `JobChangeManager.cancel_all()` in `get_sets()` is a no-op in a fresh sandbox (`_master/entry/Tetsouo_WAR.lua:123-126`).
- `watchdog test` defaults to spell id 262 (Warp II, 5 s) while labelling it Teleport-Holla (id 122, 20 s); the comment at `WATCHDOG_COMMANDS.lua:83-85` now says so, the defaults are unchanged (`:86-87`).
- `watchdog clear` during a test leaves test mode on; the next real cast is reported stuck (`midcast_watchdog.lua:387-396`).
- Dead code: `ModuleCache.stats()`, `MidcastWatchdog.is_enabled/get_buffer/get_fallback_timeout/is_debug_enabled`.
- The job intro never shows the macro book or the lockstyle: `KeybindManager`'s `show_intro` looks for `get_<job>_macro_info` and `get_info` on the `<JOB>_MACROBOOK` / `<JOB>_LOCKSTYLE` modules, and the 32 wrappers return nothing, so `show_system_intro_complete` is never reached (`keybind_manager.lua` `show_intro`). Owner decision pending (2026-09-25 audit Z2-09).
- `docs/user/features/job-change-manager.md` and `docs/user/features/watchdog.md` are out of date (see the 2026-09-25 audit).

Fixed:

- `JOBCHANGE_DEBUG` lost on every reload: it lives on `windower._gs_debug.JOBCHANGE` and INIT restores it (`INIT_SYSTEMS.lua:35-41`).
- Out-of-date headers of `INIT_SYSTEMS.lua` and `job_change_manager.lua`: rewritten.
- `JobChangeManager.initialize({...})` called from `job_sub_job_change` with job modules nothing read: the call is gone from every maintained entry (fixed 2026-09-25).

# Factories and helper systems

This page covers the two per-job factories (lockstyle and macrobook) and the shared helper systems that sit next to the job modules: AutoMove (movement-speed gear), craft/fishing mode, the /DRG jump helpers, the DNC waltz tier selector and the WHM cure tier selector. The factories are created lazily by one wrapper file per job (`shared/jobs/<job>/functions/<JOB>_LOCKSTYLE.lua` / `<JOB>_MACROBOOK.lua`) and triggered from each entry's `user_setup()`, from `//gs c ls`, from the dual-box sync hooks and from craft mode. AutoMove is started by `INIT_SYSTEMS.lua` 0.5 s after every load and polls the player position with `coroutine.schedule`. The other helpers run only on demand: `//gs c craft|fish|uncraft|jump|waltz|aoewaltz`, `WAR_PRECAST`/`DNC_PRECAST` (auto-jump before a weaponskill) and `WHM_PRECAST` (cure re-tiering).

Everything described here runs inside the GearSwap sandbox of the current job file. Read [../architecture/job-change-lifecycle.md](../architecture/job-change-lifecycle.md) first if you have not: each job change, subjob change and `gs reload` throws the sandbox away, and most of the lifetime notes below follow from that.

## Files

| Path | Lines | Role |
|---|---|---|
| `shared/utils/lockstyle/lockstyle_manager.lua` | 340 | Lockstyle factory, DressUp toggle, stateless `apply_style` |
| `shared/utils/macrobook/macrobook_manager.lua` | 280 | Macrobook factory (solo and dual-box books) |
| `shared/jobs/<job>/functions/<JOB>_LOCKSTYLE.lua` (16 files) | 40-53 | Lazy wrapper: `select_default_lockstyle`, `cancel_<job>_lockstyle_operations` |
| `shared/jobs/<job>/functions/<JOB>_MACROBOOK.lua` (16 files) | 36-48 | Lazy wrapper: `select_default_macro_book` |
| `<char>/config/<job>/<JOB>_LOCKSTYLE.lua` | ~25-75 | Per-job style numbers (`default`, `by_subjob`, optional `get_style`) |
| `<char>/config/<job>/<JOB>_MACROBOOK.lua` | ~60-110 | Per-job books (`solo`, `dualbox`, `default`) |
| `_master/config_global/LOCKSTYLE_CONFIG.lua` | 60 | Global lockstyle timing, deployed as `<char>/config/LOCKSTYLE_CONFIG.lua` |
| `shared/utils/movement/automove.lua` | 383 | Movement detection loop, `state.Moving`, `gs c update` |
| `shared/utils/craft/craft_commands.lua` | 302 | `//gs c craft/fish/uncraft` handlers, gear diffing, slot locking |
| `shared/utils/craft/craft_manager.lua` | 200 | Craft set file loading/resolution, session flag, unlock; exported as `_G.CraftManager` |
| `_master/config_global/CRAFT_CONFIG.lua` | 24 | Craft/fish lockstyle numbers (19 / 17), deployed as `<char>/config/CRAFT_CONFIG.lua` |
| `_master/Tetsouo/sets/bonecraft_sets.lua` | 117 | Multi-variant craft set (6 variants) |
| `_master/Tetsouo/sets/fishing_sets.lua` | 38 | Single fishing set |
| `shared/utils/drg/auto_jump.lua` | 224 | Jump/High Jump before a WS when TP < 1000 (WAR, DNC) |
| `shared/utils/drg/DRG_JUMP_MANAGER.lua` | 86 | `//gs c jump` (manual Jump chain) |
| `shared/utils/dnc/waltz_manager.lua` | 261 | Curing / Divine Waltz tier selection |
| `shared/utils/whm/cure_manager.lua` | 392 | Cure / Curaga tier selection with recast fallback |
| `shared/utils/whm/whm_message_formatter.lua` | 414 | Cure tier-change and debug messages (read for the calls only) |

The two craft set files are identical to their live copies in `Tetsouo/sets/`. `CRAFT_CONFIG.lua` now has a tracked template, `_master/config_global/CRAFT_CONFIG.lua` (added in `fd34a2c`).

---

## LockstyleManager

### How it works

1. A job wrapper calls `LockstyleManager.create(job_code, config_path, default_lockstyle, default_subjob)` the first time one of its functions runs (`WAR_LOCKSTYLE.lua` `get_lockstyle_module`). `create()` returns the `ctx` already built for that job code, or builds one (`lockstyle_manager.lua:278-296`). The ctxs are kept per job code in the sandbox global `_G.__lockstyle_contexts` (`contexts()`, `:263-270`), not in a module-local, so every copy of the wrapper and every instance of this module in one load share them, and they die with the load. A ctx holds the job code, the defaults, the config returned by `pcall(require, config_path)` or a fallback that always answers `default_lockstyle` (`load_config_or_fallback`, `:234-241`), and a `STATE` table (`enabled`, `is_processing`, `current_coroutines`, `dressup_state`, `last_dressup_command_time`, `operation_id`).
2. Every operation is a module-level function taking `ctx` first, bound with `bind()` (`:298-310`). The API also carries the job-suffixed key `cancel_<jl>_lockstyle_operations`, the name the job wrappers call. `create()` then deletes the globals it registered on its previous call in this module instance (`:318-321`) and writes six job-suffixed globals (`:324-335`).
3. `select_default_lockstyle()` (`:192-196`) returns silently unless `player.main_job == ctx.job_code`, resolves the style (`resolve_style`, `:182-189`: `LockstyleConfig.default or default_lockstyle`, then `LockstyleConfig.get_style(subjob)` if the config defines it; `player.sub_job or default_subjob`) and calls `set_lockstyle_with_delay(style, 2.0)`.
4. `set_lockstyle_with_delay` (`:168-179`) is a debounce: it calls `cancel_pending_operations` (`:121-126`, bumps `STATE.operation_id`), captures the new id and schedules `apply_lockstyle_immediate` after `delay`.
5. `apply_lockstyle_immediate` (`:128-164`) returns if disabled or superseded. Without DressUp management it sends `input /lockstyleset N` at once. With it, it sends `lua unload dressup` unless `dressup_state == 'unloaded'` or the last DressUp command is less than 0.5 s old, then `/lockstyleset` 0.3 s later and `lua load dressup` 3.0 s later; both scheduled steps re-check `operation_id`.

```mermaid
sequenceDiagram
    participant C as "caller (user_setup +8 s, //gs c ls, IPC hook, uncraft)"
    participant F as "factory ctx"
    participant W as "Windower"
    C->>F: select_default_lockstyle()
    F->>F: "main_job guard, resolve_style()"
    F->>F: "set_lockstyle_with_delay(style, 2.0): operation_id + 1"
    Note over F: "+2.0 s: apply_lockstyle_immediate"
    F->>W: "lua unload dressup (DressUp managed only)"
    Note over F: "+0.3 s"
    F->>W: "input /lockstyleset N"
    Note over F: "+3.0 s"
    F->>W: "lua load dressup"
```

`LockstyleManager.apply_style(style)` (`:77-91`) is the stateless variant used by craft mode: same DressUp cycle (unload, +0.3 s lockstyle, +3.0 s load) with no ctx, no operation id and no debounce.

There is no 15 s throttle anywhere in this module; the only rate limits are the per-ctx debounce above and the 0.5 s guard on DressUp commands.

### Public API

| Function | Line | Effect | Callers |
|---|---|---|---|
| `LockstyleManager.create(job_code, config_path, default_lockstyle, default_subjob)` | 278 | Returns the per-job API below and writes the generated globals | the 16 `<JOB>_LOCKSTYLE.lua` wrappers |
| `LockstyleManager.toggle_dressup()` | 56 | Flips `_G.DRESSUP_MANAGEMENT_ENABLED`, persists it as a file, returns the new value | `COMMON_COMMANDS.lua` `handle_dressup` (`//gs c dressup`) |
| `LockstyleManager.is_dressup_enabled()` | 68 | Returns the flag | none |
| `LockstyleManager.apply_style(style)` | 77 | Applies any number now (DressUp-aware); ignores non-numbers | `craft_commands.lua` `apply_lockstyle` |

Per-job API returned by `create()` (`:301-314`): `select_default_lockstyle()`, `set_lockstyle_with_delay(style, delay)`, `get_lockstyle_info()` (alias `get_info`) returning `{job, subjob, style, enabled, manage_dressup}`, `show_lockstyle_config()` (prints through `MessageFormatter.show_info`), `set_lockstyle_enabled(bool)`, `set_dressup_management(bool)` (writes the global flag and the file), `cancel_pending_operations()` (also under the key `cancel_<jl>_lockstyle_operations`, which the wrappers call), `get_state()`. The wrappers do not return this table, so outside the factory only the globals are reachable.

Generated globals (`:324-335`, `jl` = lower-case job code): `select_default_lockstyle`, `cancel_<jl>_lockstyle_operations`, `set_<jl>_lockstyle_enabled`, `set_<jl>_dressup_management`, `get_<jl>_lockstyle_info`, `show_<jl>_lockstyle_config`. `select_default_lockstyle` is called by the entries, `COMMON_COMMANDS.lua` `handle_lockstyle`, the IPC hooks at `INIT_SYSTEMS.lua:186-191` and `craft_commands.lua` `restore_job_lockstyle`; `cancel_<jl>_lockstyle_operations` is read once by each entry's `get_sets()` for the JobChangeManager registration, at a time when it is still the wrapper's function, not the factory's; that wrapper calls the API key of the same name. The other four globals have no reader. `global_probe.lua` `GENERATED` (139-143) whitelists the generated shapes.

### Configuration

Per-job config (`<char>/config/<job>/<JOB>_LOCKSTYLE.lua`, resolved by GearSwap's `pathsearch`, which tries `data/<player.name>/` before `data/`; BLM passes `<char>/config/...` explicitly, `shared/jobs/blm/functions/BLM_LOCKSTYLE.lua:27-29`):

| Key | Read by the factory | Notes |
|---|---|---|
| `default` | yes (`:185`) | wins over the `default_lockstyle` argument |
| `get_style(subjob)` | yes, if present (`:186-188`) | defined by 10 of the 14 template configs (all but RDM, SAM, THF, WHM); it reads `by_subjob` |
| `by_subjob` | **no** | only read through the config's own `get_style`; the RDM, SAM, THF and WHM templates and the Kaories RDM overlay have no `get_style` (see Known issues) |
| `style` | no | "backward compatibility" field, no reader |

`_master/config_global/LOCKSTYLE_CONFIG.lua` (deployed to `<char>/config/`): the entries read `initial_load_delay` (8.0) to schedule `select_default_lockstyle` from `user_setup()` (e.g. `_master/entry/Tetsouo_WAR.lua` `user_setup`), with an inline fallback table (`:35-40`). `job_change_delay` and `cooldown` are defined but have no reader; the file's comments now say so, and its DressUp notes describe the real sequence (comments merged from the live copies 2026-09-25).

DressUp management flag: `_G.DRESSUP_MANAGEMENT_ENABLED`, initialised on each module load from the presence of `windower.addon_path .. 'data/.dressup_disabled'` (file present = off, `read_dressup_state`, `:26-34`, `:50-52`). The file is gitignored (`.gitignore:114`).

### Job wrappers

Each wrapper holds a module-local `lockstyle_module` / `macrobook_module`, defines the global wrapper functions, and returns nothing. Arguments passed to the factories:

| Job | Lockstyle default / subjob | Macrobook subjob / book / page |
|---|---|---|
| WAR | 4 / SAM | SAM / 22 / 1 |
| RDM | 1 / NIN | NIN / 1 / 1 |
| BRD, SMN | 1 / WHM | WHM / 1 / 1 |
| BLM, BST, COR, DNC, DRK, GEO, PLD, PUP, RUN, SAM, THF, WHM | 1 / SAM | SAM / 1 / 1 |

The config's `default` overrides the lockstyle argument (e.g. PLD config default 3 vs argument 1). `_master/config/` has no `pup/` folder, so a deployed PUP runs both factories on their fallbacks (style 1, book 1 page 1); SMN configs exist only in the Tetsouo overlay `_master/Tetsouo/config/smn/` and its live copy.

Each wrapper file is executed twice per sandbox: once by `KeybindManager`'s `show_intro()` `require` during `user_setup()` (which runs inside `include('Mote-Include.lua')`; see [keybinds-and-custom.md](keybinds-and-custom.md)), and once by the facade `include` in `get_sets()` (e.g. `shared/jobs/war/functions/war_functions.lua`). The two executions have separate module-locals, so each calls `create()` once. The `coroutine.schedule(select_default_lockstyle, 8)` in `user_setup()` captures the first wrapper; `JobChangeManager.register_lockstyle_cancel(job, cancel_<job>_lockstyle_operations)` in `get_sets()` captures the second. Both get the same `ctx` from `create()` (one per job code in `_G.__lockstyle_contexts`, `lockstyle_manager.lua:254-296`), so the registered cancel bumps the `operation_id` of the lockstyle the first copy scheduled, whichever module instance each copy reached.

---

## MacrobookManager

### How it works

1. `create(job_code, config_path, default_subjob, default_book, default_page)` (`macrobook_manager.lua:227-278`) normalises the config (`load_macrobooks`, `:56-78`): `{solo, dualbox}` from a config that has `solo`/`dualbox`, or `{solo = macrobooks, dualbox = {}}` from the legacy flat shape; `solo.default` is set to the config's top-level `default` or the factory's `{default_book, default_page}` (this overwrites any `solo['default']` written in the config file). With no config at all it uses `fallback_macrobooks` (`:38-46`). All current configs have a top-level `default` and the `solo` shape.
2. `select_default_macro_book()` (`:146-154`) asks `resolve_config` (`:134-142`, since 2026-09-25 the one resolver for both selection and `get_macro_info`), which picks, in order: the dual-box book `dualbox[alt_job][sub_job]` when `DualBoxManager.is_alt_online()` (alt update seen in the last `DualBoxConfig.timeout`, 30 s by default, `dualbox_manager.lua:346-360`), else `solo[sub_job]`, else `solo.default`, else the factory defaults. There is no main-job guard (unlike lockstyle).
3. `set_macro_with_delay` (`:97-110`) bumps `_G._macrobook_schedule_id` and schedules Mote's `set_macro_page(page, book)` after 1.5 s (0.5 s from `set_macro_book`). Mote sends `input /macro book B; wait 1.1; input /macro set P` and rejects books outside 1-40 and pages outside 1-10 (`libs/Mote-Utility.lua:511-534`).

### Public API

Returned by `create()` (`:267-279`): `select_default_macro_book()`, `set_macro_book(subjob)` (solo table only, error message on unknown subjob), `get_macro_info()` → `{book, page, subjob}` (same resolver as the selection, so it reports the dual-box book when one applies), `show_macro_configs()`, plus legacy keys `set_<jl>_macro_book`, `get_<jl>_macro_info`, `show_<jl>_macro_configs`. Globals (`:254-263`): `select_default_macro_book`, `set_<jl>_macro_book`, `get_<jl>_macro_info`, `show_<jl>_macro_configs`.

Callers: entry `user_setup()` (`select_default_macro_book()` directly, e.g. `_master/entry/Tetsouo_WAR.lua:242`), COR's second block, `dualbox_manager.lua:332-336` (0.5 s after an `altjobupdate` that brings a new job or subjob). `KeybindManager`'s `show_intro` looks for `get_<job>_macro_info` on the value returned by `require` of the wrapper, which returns nothing (see Known issues). The other generated globals have no caller.

### Configuration

`<char>/config/<job>/<JOB>_MACROBOOK.lua`:

```lua
Cfg.solo    = { SAM = { book = 22, page = 1 }, ..., default = { book = 22, page = 1 } }
Cfg.dualbox = { GEO = { SAM = { book = 23, page = 1 } }, ... }   -- [alt_job][subjob]
Cfg.default = { book = 22, page = 1 }                             -- becomes solo.default
```

The config headers say "Book range: 1-40" (e.g. `_master/config/war/WAR_MACROBOOK.lua:21`), which is what Mote accepts.

---

## AutoMove

### How it works

`INIT_SYSTEMS.lua:228-243`, inside the block deferred by 0.5 s, runs `pcall(include, '../shared/utils/movement/automove.lua')` then `AutoMove.start()` unless `_G.DISABLE_AUTOMOVE == true`. No file in the repository sets that flag any more (BST's was removed in commit 0563ff9 because nothing else maintains `state.Moving`); only `system_checker.lua:38` still reads it (and `global_probe.lua:48` lists the name).

Including the file (re)creates `_G.AutoMove` (`automove.lua:48-49`), the module-local position, callback list and counters, `state.Moving = M('false', 'true')` if absent (`:129-131`), seeds `windower._automove_seq` (`:83`) and reads the current position (`init_position`, `:161`).

`AutoMove.start()` (`:312-378`) increments `windower._automove_seq`, captures it as `my_seq`, sets `_G._automove_sequence` and `_G.AUTOMOVE_RUNNING = true`, resets `start_time`, `moving`, `pending_update`, `last_update_time`, re-reads the position and schedules `run`:

```mermaid
flowchart TD
    A["run() tick"] --> B{"my_seq == windower._automove_seq and _G.AUTOMOVE_RUNNING"}
    B -- no --> Z["chain ends"]
    B -- yes --> C{"player.index known"}
    C -- no --> R1["reschedule 0.12 s"]
    C -- yes --> D{"player.status == Engaged"}
    D -- yes --> E["track_while_engaged(): refresh position, force Moving false, reschedule 0.5 s"]
    D -- no --> F["step_distance()"]
    F -- "nil (no position)" --> R1
    F --> G{"dist > 5.0 (jump_threshold)"}
    G -- yes --> H["send gs c update now, reschedule 0.12 s"]
    G -- no --> I{"dist vs 0.3"}
    I -- "dist > 0.3" --> J["handle_moving()"]
    I -- "dist below 0.3" --> K["handle_stopped()"]
    J --> L["reschedule 0.12 s if moving else 0.3 s"]
    K --> L
```

- `handle_moving` (`:263-290`): on the first moving tick sets `state.Moving.value = 'true'` and `pending_update`; `send_update('moving')`; every 2.0 s of continuous movement (`heal_interval`) sends another `gs c update` as a desync backstop; calls every registered callback with `(true, dist, player.status)`.
- `handle_stopped` (`:294-306`): on the transition sets `state.Moving.value = 'false'`, `pending_update`, calls callbacks with `false`; then `send_update('stopping')` while `pending_update` is set.
- `send_update` (`:238-259`) refuses for 2.0 s after `start()` (`job_change_cooldown`) and within 0.3 s of the last update (`update_debounce`); a refused update stays pending and is retried on later ticks. The jump branch (`:357-362`) and the heal branch bypass it.
- The gear itself comes from the job's set builder: `sets.MoveSpeed` is merged into the idle set when `state.Moving.value == 'true'` (e.g. `shared/utils/set_building/base_set_builder.lua:38`, `shared/jobs/bst/functions/logic/set_builder.lua:114`, `shared/jobs/drk/functions/logic/set_builder.lua:138`).

### Public API

| Function | Line | Callers |
|---|---|---|
| `AutoMove.start()` | 312 | `INIT_SYSTEMS.lua:237-239` only |
| `AutoMove.stop()` | 104 | `job_change_manager.lua:71-73` (`cleanup_all_systems`, subjob path only) |
| `AutoMove.register_callback(fn(is_moving, distance, status))` | 93 | `WAR_MOVEMENT.lua:47-54` (Retaliation cancel, registered 0.6 s after load); `THF_MOVEMENT.lua:26-29` (empty placeholder, see Known issues) |
| `AutoMove.is_moving()`, `get_last_distance()`, `get_position()` | 169-181 | the `get_<job>_movement_status()` helpers in BLM/BRD/COR/DNC/GEO/SAM/THF/WAR `<JOB>_MOVEMENT.lua` |
| `AutoMove.clear_callbacks()`, `AutoMove.reinit_position()` | 98, 187 | none |

Callback errors are caught and printed with `MessageCore.show_automove_error` (`trigger_callbacks`, `:116-123`).

### Configuration

Hard-coded in `automove.lua:55-64`: `movement_threshold 0.3`, `check_interval 0.12`, `update_debounce 0.3`, `job_change_cooldown 2.0`, `jump_threshold 5.0`, `heal_interval 2.0`, `idle_interval 0.3`, `engaged_interval 0.5`. Debug output is gated by `_G.AUTOMOVE_DEBUG` (`//gs c automovedebug` or `//gs c debugupdate`; both persist through `windower._gs_debug.AUTOMOVE`, restored at `INIT_SYSTEMS.lua:35-41`).

---

## Craft and fishing mode

### How it works

```mermaid
flowchart TD
    A["//gs c craft [variant] / fish [variant]"] --> B["CraftManager.resolve_set(file, variant)"]
    B -- "error" --> E["MessageFormatter.show_error"]
    B --> C{"session active? (CraftManager.active_gear())"}
    C -- no --> D["enable() all 16 slots synchronously, equip(whole set)"]
    C -- yes --> F["diff_gear(previous, target), enable(changed + released), equip(changed)"]
    D --> H["same call: mark_active(description, gear), apply_style(19 or 17)"]
    F --> H
    H --> G["scheduled: +2.0 s gs disable all (or disable(touched)) and 'ready' line, +2.5 s gs c rf"]
    I["//gs c uncraft / craft off|stop|uncraft"] --> J{"_state.active"}
    J -- no --> K["'No craft set is currently active' (no unlock)"]
    J -- yes --> L["gs enable all, clear state, +0.5 s gs c rf"]
    K --> M["select_default_lockstyle()"]
    L --> M
```

- Set files are loaded with `pcall(require, <player.name>/sets/<name>_sets)` (`load_craft_file`, `craft_manager.lua:70-77`); `craft` always uses `bonecraft`, `fish` always `fishing` (`craft_commands.lua:257`, `:277`).
- Resolution (`resolve`, `craft_manager.lua:84-124`): multi-variant files use `default` when no argument is given, a direct lower-case key lookup, then an alias scan; single-set files return the whole table and ignore the argument.
- Slot names are canonicalised to `player.equipment` names (`ranged`→`range`, `ear1`/`lear`→`left_ear`, `ring2`/`rring`→`right_ring`, ..., `canonical_gear`, `craft_commands.lua:87-96`). `diff_gear` (`:126-143`) keeps a slot untouched only when the running session put the same item there and it is still worn (item names compared case-insensitively); slots the new variant no longer covers are released.
- `equip_craft_gear` (`:188-236`) uses GearSwap's synchronous `enable()` rather than `gs enable all` because the command path lands after `equip()` (commit 362ca25). The lock is applied 2.0 s later (`lock_after_delay`, `:163-175`); the coroutine carries no session check. When a variant switch changes nothing, only the lock is re-asserted.
- While the session flag is set (`CraftManager.is_active()`, read through the `_G.CraftManager` export), `shared/utils/inventory/refill/config_resolver.lua:202` switches refill to `<char>/config/craft/CRAFT_REFILL.lua`, and GEO/RDM `job_update` (e.g. `_master/entry/Tetsouo_GEO.lua:245`), BLM `CombatMode` handling (`BLM_COMMANDS.lua:550`), WHM `Melee ON` handling (`WHM_COMMANDS.lua:203,219`) and the BLM/WHM `file_unload` weapon release (2026-09-25) skip their weapon `enable()`.

### Set file shapes

```lua
-- single set (fishing_sets.lua)
return { description = 'Fishing', gear = { range = 'Ebisu F. Rod +1', ... } }

-- multi-variant (bonecraft_sets.lua)
return {
    default  = 'hq',
    variants = {
        hq   = { description = 'Bonecraft HQ', aliases = { 'hq' }, gear = {...} },
        wood = { description = '...', aliases = { 'wood', 'woodworking', 'carver' }, gear = {...} },
    },
}
```

`bonecraft_sets.lua` defines `hq` (default), `nq`, `success`, `wood`, `smith`, `leather`, built from a shared base with a local `set_with()` helper (`:34-51`). Only Tetsouo has craft set files.

### Public API

`CraftManager`: `resolve_set(file, variant)` → `entry` or `nil, error` (137), `mark_active(name, gear)` (144), `is_active()` (156), `active_name()` (163), `active_gear()` (171), `unequip()` (177); exported as `_G.CraftManager` (198). `CraftCommands`: `handle_craft(variant)` (246), `handle_fish(variant)` (273), `handle_uncraft()` (292), aliased onto `CommonCommands` at `COMMON_COMMANDS.lua:288-290`.

### Configuration

| Source | Keys | Default |
|---|---|---|
| `<char>/config/CRAFT_CONFIG.lua` (template `_master/config_global/CRAFT_CONFIG.lua`) | `craft_lockstyle`, `fish_lockstyle` | 19 / 17 (`DEFAULT_CRAFT_LOCKSTYLE` / `DEFAULT_FISH_LOCKSTYLE` in `craft_commands.lua`) |
| `<char>/sets/bonecraft_sets.lua`, `fishing_sets.lua` | see shapes above | none (error message) |
| `<char>/config/craft/CRAFT_REFILL.lua` | refill list while crafting | job refill list |

Set files and `CRAFT_CONFIG` are cached per sandbox by `ModuleCache`, so an edit needs a reload.

---

## /DRG jumps

Two modules implement the same Jump → High Jump chain (recast ids 158/159, 1000 TP threshold, 1.0 s between steps, Sheol Gaol level-0 check).

### AutoJump (`shared/utils/drg/auto_jump.lua`)

Used by `WAR_PRECAST.lua:113` (before `WSPrecastHandler`) and `DNC_PRECAST.lua:116-137` (inside `job_precast_weaponskill`). Gated by `state.JumpAuto` (`On`/`Off`, default `On`, `_master/config/war/WAR_STATES.lua:83-88`, `_master/config/dnc/DNC_STATES.lua:135-140`; keybinds `cyclestate JumpAuto`).

```mermaid
sequenceDiagram
    participant P as "job_precast (WS)"
    participant J as "AutoJump"
    participant G as "game"
    P->>J: auto_trigger_jump(spell, eventArgs)
    J->>J: "JumpAuto On, no sequence running, /DRG level > 0, TP below 1000, a jump ready"
    J->>P: "eventArgs.cancel = true, _G.AUTO_JUMP_SEQUENCE_ACTIVE = true"
    J->>G: "/ja Jump on current target (else High Jump)"
    Note over J: "+1.0 s"
    J->>G: "other jump if TP still below 1000 and it is ready"
    Note over J: "WS replay at +2.0 s after the first jump (single) or +3.0 s (double)"
    J->>G: "/ws name original_target"
    Note over J: "+0.5 s: _G.AUTO_JUMP_SEQUENCE_ACTIVE = false"
```

The replayed WS goes through precast again while the flag is set, so it cannot start a second sequence (`auto_jump.lua:150`). Readiness uses the global `is_recast_ready` from `RECAST_CONFIG.lua` (tolerance 2.0 s). Diagnostics: `get_tp_threshold()`, `get_animation_delay()`, `get_status()`, `is_drg_subjob()` (no callers outside the module except `should_auto_jump`).

### DRGJumpManager (`shared/utils/drg/DRG_JUMP_MANAGER.lua`)

`execute_jump()` (`:26-84`): error unless `player.sub_job == 'DRG'` and level > 0; "TP ready" message if TP ≥ 1000; otherwise Jump (or High Jump) now and the other one 1.0 s later if TP is still short and it is ready; if both are on recast, a grouped cooldown message via `MessageCooldowns.show_multi_status`. It does not replay anything. Callers: `//gs c jump` (`COMMON_COMMANDS.lua` `handle_jump`) and WAR's subjob TP ability on /DRG (`war/functions/logic/smartbuff_manager.lua:266-269`).

---

## DNC WaltzManager

`//gs c waltz` and `//gs c aoewaltz` go through `handle_waltz_generic` (`COMMON_COMMANDS.lua:80-106`): error unless DNC main or sub, `send_command('cancel Saber Dance')` if Saber Dance is active, then `cast_curing_waltz('<stpc>')` or `cast_divine_waltz()`. `DNC_PRECAST.lua:86` replaces Mote's `refine_waltz` with a no-op.

`cast_curing_waltz(target_type)` (`waltz_manager.lua:189-216`):

1. `effective_level` = DNC main level, else sub level.
2. `resolve_missing_hp()` (`:106-119`) reads the current target `<t>`: self → exact `max_hp - hp`; a party or alliance member (`in_party` / `in_alliance`, fields `get_mob_by_target` does carry) → the estimate `hp / (hpp/100) - hp` (`get_missing_hp`, `:51-86`); a mob → unknown (`nil`); no target → self. Until 2026-09-25 the member branch was gated on `isallymember`, a field GearSwap adds only to its own target tables (`GearSwap/targets.lua:64-73`), so a targeted party member always read as unknown. Not yet tested in game: the tier can come out one lower when the party list's HP lags.
3. `preferred_curing_waltz` (`:129-144`): with HP known, the tier whose band contains it (`CURING_HP_BRACKET`, `:91-97`: I < 200, II 200-600, III 600-1100, IV 1100-1500, V ≥ 1500); with HP unknown, the highest tier the level allows.
4. `curing_priority` (`:150-161`): preferred tier first, then all other castable tiers from highest down. The first one with recast ready (`is_recast_ready`) and enough TP is sent as `/ja "<name>" <stpc>` with `show_waltz_heal`.
5. If none fires, `curing_blockers` (`:168-185`) builds one cooldown line per tier and one TP line, shown with `show_multi_status`.

`cast_divine_waltz()` (`:219-259`) tries Divine Waltz II then I on `<me>` with the same readiness rules and an inline copy of the blocker loop.

`WALTZ_CONFIG` (`:32-46`): TP 800/650/500/350/200 for Curing V-I, 800/400 for Divine II/I; recast ids match `res/job_abilities.lua`; levels 87/70/45/35/15 and 78/40 (the project's own `shared/data/job_abilities/dnc/dnc_waltzes_subjob.lua` lists Curing Waltz II at 30 and Divine Waltz at 25).

---

## WHM CureManager

Loaded lazily by `WHM_PRECAST.ensure_modules_loaded()` (`WHM_PRECAST.lua:58`); called from `retier_cure` (`:77-94`), which runs after PrecastGuard and **before** CooldownChecker (`job_precast`, `:118-151`). When `select_cure_tier` returns a different name, `retier_cure` cancels the cast, sends `input /ma "<new>" <spell.target.raw>` and `job_precast` returns. A `nil` return (same name, not a cure, or every tier on recast) lets the original cast go on to the recast check. So a typed tier on recast is swapped for a ready one before CooldownChecker could cancel it; when every tier is on recast, `select_cure_tier` returns `nil` without a message (`cure_manager.lua:348-353`) and CooldownChecker gives the one cooldown message, cancelling the cast if its recast is over the 2.0 s tolerance.

At module load (`cure_manager.lua:32-42`) the config is `pcall(require, <player.name>/config/whm/WHM_CURE_CONFIG)`; on failure it `print`s an error and uses a table with no `cure_tiers`/`curaga_tiers`.

```mermaid
flowchart TD
    A["select_cure_tier(spell, target)"] --> B{"name contains Cure or Curaga"}
    B -- no --> N["nil"]
    B -- yes --> C["tier_config = curaga_tiers or cure_tiers"]
    C --> D{"state.CureAutoTier == On"}
    D -- no --> F["optimal = spell name"]
    D -- yes --> E["get_hp_missing(target or me)"]
    E -- "0" --> E0["optimal = lowest tier"]
    E -- ">0" --> E1["optimal = tier whose [min,max] contains missing + safety_margin (else highest)"]
    E0 --> G
    E1 --> G
    F --> G["find_available_cure_with_fallback(optimal)"]
    G -- "optimal ready (recast == 0)" --> H
    G -- "optimal on recast" --> I["first ready lower tier, else first ready higher tier"]
    G -- "all on recast" --> X["return nil, no message (recast check follows)"]
    I --> H{"result == spell name"}
    H -- yes --> N
    H -- no --> M["show_cure_tier_change, return new name"]
```

- HP (`get_hp_missing`, `:184-217`): self exact; party member `p0..p5` found by name → `max_hp` taken from `member.max_hp or 2000` and `hpp`; the alliance loop reads keys `a1p1..a3p6`; anything else → `target.hpp` against an assumed 2000 max; no target → `0`.
- Availability (`is_spell_available`, `:81-96`): `get_spell_recasts()[CURE_IDS[name]] / 100 == 0`; unknown names are "available". This does not use `RECAST_CONFIG`.
- Config keys read: `cure_tiers`, `curaga_tiers` (`{min, max, spell}` lists in ascending order), `safety_margin` (default 50), `debug_messages`. `auto_tier_enabled` and `message_color` are defined in `_master/config/whm/WHM_CURE_CONFIG.lua` but never read (`force_max_cure` exists only in CureManager's fallback table); auto-tier is `state.CureAutoTier` (`_master/config/whm/WHM_STATES.lua:96`, default `On`, keybind `cyclestate CureAutoTier`).

---

## Commands

| Command | Args | Effect | Handler |
|---|---|---|---|
| `//gs c lockstyle`, `ls` | - | `select_default_lockstyle()` + `SyncIPC.broadcast('ls')` | `COMMON_COMMANDS.lua` `handle_lockstyle` |
| `//gs c dressup` | - | `LockstyleManager.toggle_dressup()`, persisted | `handle_dressup` |
| `//gs c craft` | `[variant \| off \| stop \| uncraft]` | Equip / switch a bonecraft variant, lock slots, craft lockstyle; `off/stop/uncraft` = uncraft | `craft_commands.lua:246` |
| `//gs c fish`, `fishing` | `[variant]` (ignored for single sets) | Equip fishing set, lock slots, fish lockstyle | `craft_commands.lua:273` |
| `//gs c uncraft` | - | `CraftManager.unequip()` + job lockstyle | `craft_commands.lua:292` |
| `//gs c jump` | - | `DRGJumpManager.execute_jump()` | `handle_jump` |
| `//gs c waltz` | - | Curing Waltz tier selection on `<stpc>` | `handle_waltz` → `handle_waltz_generic` |
| `//gs c aoewaltz` | - | Divine Waltz on `<me>` | `handle_aoewaltz` |
| `//gs c automovedebug`, `amd` | - | Toggle `_G.AUTOMOVE_DEBUG` (persisted) | `DEBUG_COMMANDS.lua:532` |
| `cyclestate JumpAuto` / `CureAutoTier` | - | Mote state cycle (keybinds) | Mote |

Dual-box: `INIT_SYSTEMS.lua:186-191` registers IPC hooks `ls` and `lockstyle` that call the current `select_default_lockstyle`.

## State and lifetime

| Item | Where | Lifetime |
|---|---|---|
| Lockstyle ctx (`STATE`, config, defaults) | `_G.__lockstyle_contexts[job_code]` (`lockstyle_manager.lua:263-270`) | one sandbox; one ctx per job code, shared by both wrapper copies |
| `last_registered_globals` | module local of each factory instance | one sandbox |
| `_G.DRESSUP_MANAGEMENT_ENABLED` | `lockstyle_manager.lua:50-52` | re-read from `data/.dressup_disabled` in every sandbox |
| `_G._macrobook_schedule_id` | `macrobook_manager.lua:103` | one sandbox; a coroutine from a previous sandbox checks its own copy |
| `windower._automove_seq` | `automove.lua:83`, `:106`, `:314` | survives `gs reload` and job change (reset by `lua reload gearswap`); kills old chains at their next tick |
| `_G.AUTOMOVE_RUNNING`, `_G._automove_sequence`, `_G.AutoMove`, `state.Moving` | `automove.lua` | one sandbox |
| `_G.__CraftManagerState {active, active_name, gear}` | `craft_manager.lua:59` | one sandbox; GearSwap's slot locks (`disable_table`, `statics.lua:194`) outlive it |
| `_G.AUTO_JUMP_SEQUENCE_ACTIVE` | `auto_jump.lua:46` | one sandbox |
| CureManager config / formatter | module locals | one sandbox (module cached) |

Scheduled coroutines:

| Coroutine | Delay | Invalidation |
|---|---|---|
| `select_default_lockstyle` from `user_setup()` | `initial_load_delay` (8 s) | none; returns if the main job changed |
| lockstyle apply / DressUp steps | 2.0 s, +0.3 s, +3.0 s | `STATE.operation_id` of the job's ctx |
| `apply_style` steps (craft) | 0.3 s, 3.0 s | none |
| `set_macro_page` | 1.5 s (0.5 s manual) | `_G._macrobook_schedule_id` of the sandbox |
| `select_default_macro_book` retry when `player` is nil | 0.5 s | none (the sandbox `player` table always exists) |
| AutoMove `run` | 0.12 / 0.3 / 0.5 s | `windower._automove_seq`, `_G.AUTOMOVE_RUNNING` |
| craft lock / refill | 2.0 s / 2.5 s | none |
| uncraft refill | 0.5 s | none |
| auto-jump steps | 1.0 s, 1.0 s, 0.5 s | none |
| DRGJumpManager second jump | 1.0 s | none |

No module on this page registers a Windower event, a keybind or a text object.

Transitions:

- **`gs reload` / subjob change**: JobChangeManager's `cleanup_all_systems()` stops AutoMove on the subjob path only (`job_change_manager.lua:71-73`); every path runs `file_unload` → `JobChangeManager.cancel_all()`, whose registered lockstyle cancel stops a lockstyle still waiting in its 2 s delay or DressUp steps (the raw +8 s `coroutine.schedule` itself is not tracked). The new sandbox starts a new AutoMove chain at +0.5 s, a new lockstyle cycle at +8 s, a new macrobook selection at once. A running craft session loses its flag but keeps its slot locks.
- **Main job change**: same, without `cleanup_all_systems()`; the old AutoMove chain dies when the new `start()` bumps the sequence.
- **Zone**: AutoMove sees a jump > 5 yalms and sends `gs c update`. Nothing else here reacts.

## Interactions

- Lifecycle, reload order and the two-executions-per-sandbox effect: [../architecture/job-change-lifecycle.md](../architecture/job-change-lifecycle.md), [core-lifecycle.md](core-lifecycle.md).
- Command router (`is_common_command`, `handle_command`): [commands-and-debug.md](commands-and-debug.md).
- Messages used: `MessageFormatter.show_info/show_success/show_error/show_tp_ready/show_multi_status/show_waltz_heal`, `MessageCommands.show_craft_*`, `show_lockstyle_reapplying`, `show_dressup_toggled`, `WHMMessageFormatter.*`: [messages.md](messages.md).
- Precast order around AutoJump and CureManager: [precast-pipeline.md](precast-pipeline.md).
- Dual-box books and the `ls` IPC hook: [dualbox.md](dualbox.md).
- Refill while crafting: [equipment-and-inventory.md](equipment-and-inventory.md).
- HUD ignores `state.Moving` (`ui_state_tracker.lua:26-28`, `lifecycle_manager.lua:81-89`): [ui-overlay.md](ui-overlay.md).
- `//gs c mount` (`shared/utils/mount/mount_manager.lua`) is documented in [warp.md](warp.md).

## Invariants and gotchas

1. The per-job lockstyle config must define `get_style` for `by_subjob` to have any effect; the factory never reads `by_subjob` itself (`lockstyle_manager.lua:182-189`).
2. `select_default_lockstyle` does nothing when `player.main_job` is not the factory's job; `select_default_macro_book` has no such guard.
3. A lockstyle debounce only covers operations of the same job `ctx` (shared by both wrapper copies of a sandbox); `apply_style` is not debounced against it.
4. `equip()` from a coroutine does nothing; AutoMove and craft use `gs c update` / `gs disable` commands or synchronous `enable()`/`equip()` inside the command handler.
5. AutoMove callbacks must be registered after `automove.lua` has been included, i.e. more than 0.5 s after `INIT_SYSTEMS` (WAR waits 0.6 s). `_G.AutoMove` does not exist while the facade is being included.
6. AutoMove writes `state.Moving.value` directly instead of `state.Moving:set()`; Mote's modes have no `__newindex`, so from then on `.value` is a plain field and `.current` / `:set()` no longer move it.
7. Craft slot locks belong to the GearSwap engine, not to the sandbox; only `//gs enable all` or a successful `//gs c uncraft` releases them.
8. `select_cure_tier` returning `nil` means "cast the original", including when every tier is on recast; it then prints nothing and the recast check that follows in `WHM_PRECAST` reports it.
9. Craft's errors name the file actually read, `<char>/sets/<name>_sets.lua` (`craft_manager.lua:88,122`; the "invalid format" one said `config/craft/<name>.lua` until 2026-09-25).

## Extending

- **New job lockstyle/macrobook**: copy `WAR_LOCKSTYLE.lua` / `WAR_MACROBOOK.lua`, change the job code, config path and defaults, `include` both from the facade, add `<char>/config/<job>/<JOB>_LOCKSTYLE.lua` with `default`, `by_subjob` **and** `get_style`, and `<JOB>_MACROBOOK.lua` with `solo`, `dualbox`, `default`. Register the cancel in the entry's `get_sets()` like the others.
- **New craft**: add `<char>/sets/<name>_sets.lua` in either shape and a command branch that calls `CraftManager.resolve_set('<name>', variant)` through `equip_craft_gear` the way `handle_fish` does.
- **New waltz tier or cure tier**: WaltzManager tiers live in `WALTZ_CONFIG` + `CURING_HP_BRACKET`; cure tiers in the character's `WHM_CURE_CONFIG.lua` (`cure_tiers` / `curaga_tiers`, ascending) plus `CURE_IDS` for the recast lookup.
- **New AutoMove consumer**: read `state.Moving.value` in the set builder, or register a callback from a coroutine scheduled after 0.5 s.

## Known issues

Open:

- `by_subjob` is ignored when a lockstyle config has no `get_style` (RDM, SAM, THF, WHM templates); Kaories RDM always gets its `default` style - `shared/utils/lockstyle/lockstyle_manager.lua:182-189`
- Craft slot locks outlive the session flag (reload, or uncraft within 2 s of craft) and `//gs c uncraft` then refuses to unlock - `shared/utils/craft/craft_manager.lua:177-181`
- Full Cure is re-tiered into a Cure tier when CureAutoTier is On (the name test is `find('Cure')`) - `shared/utils/whm/cure_manager.lua:313`
- CureManager's fallback config has no tier tables; every Cure/Curaga then raises in precast - `shared/utils/whm/cure_manager.lua:34-42`
- `//gs c waltz`/`aoewaltz` cancel Saber Dance before knowing whether any waltz can be used - `shared/utils/core/COMMON_COMMANDS.lua:87-90`
- CureManager treats a spell with any recast left as unavailable, unlike CooldownChecker's 2.0 s tolerance - `shared/utils/whm/cure_manager.lua:95`
- Curing Waltz II and Divine Waltz learn levels (35, 40) disagree with the project's DNC ability database (30, 25) - `shared/utils/dnc/waltz_manager.lua:38`
- DNC prints "Not enough TP" for a weaponskill that AutoJump has just taken over (`job_precast_weaponskill` returns, `job_precast` still calls `WSPrecastHandler.handle`) - `shared/jobs/dnc/functions/DNC_PRECAST.lua:171-179`
- AutoMove assigns `state.Moving.value` directly, desynchronising the Mote mode - `shared/utils/movement/automove.lua:267`
- THF registers an empty placeholder AutoMove callback, and only if `AutoMove` already exists when the facade loads, which it does not (AutoMove loads 0.5 s later) - `shared/jobs/thf/functions/THF_MOVEMENT.lua:25-29`
- The job intro never shows macro/lockstyle info: `KeybindManager`'s `show_intro` looks for `get_<job>_macro_info` / `get_info` on the wrapper modules, which return nothing (owner decision pending, 2026-09-25 audit Z2-09) - `shared/utils/keybinds/keybind_manager.lua` `show_intro`
- Unused factory/AutoMove exports - `shared/utils/lockstyle/lockstyle_manager.lua:324-335`
- LOCKSTYLE_CONFIG keys `job_change_delay`/`cooldown` are unread (the file's comments now say so) - `_master/config_global/LOCKSTYLE_CONFIG.lua:34-41`
- Jump chain implemented twice (AutoJump and DRGJumpManager) - `shared/utils/drg/DRG_JUMP_MANAGER.lua:26-84`
- Craft `apply_style` does not cancel a pending job lockstyle, which can override the craft style - `shared/utils/lockstyle/lockstyle_manager.lua:77-91`
- `WHM_CURE_CONFIG.lua` defines `auto_tier_enabled` and `message_color`, which nothing reads - `_master/config/whm/WHM_CURE_CONFIG.lua:79,96`
- CureManager party HP estimate: the alliance keys it reads (`a1p1..a3p6`) are not the ones `get_party()` returns, and `max_hp` is not a party field, so the 2000 estimate is always used - `shared/utils/whm/cure_manager.lua:147-150`
- Help text misdescribes craft (weapon slots only), jump (High Jump) and waltz (Curing Waltz III) - `shared/utils/messages/formatters/ui/message_commands.lua:641,688-689`
- Waltz tier for a targeted party member (fixed 2026-09-25, below) not yet tested in game.

Fixed:

- Waltz tier was never sized for a targeted party member (`isallymember` is not a Windower mob field): the test is now `in_party or in_alliance` (fixed 2026-09-25).
- Macrobook: the load message could announce the solo book while the dual-box book was selected: `resolve_config` is shared by selection and `get_macro_info` (fixed 2026-09-25).
- Comments claiming cross-reload persistence/invalidation in `macrobook_manager.lua` and `lockstyle_manager.lua`: rewritten (they now say the list and counter live on the sandbox `_G`).
- LOCKSTYLE_CONFIG described a DressUp sequence and a 15 s throttle the code does not have: comments rewritten.
- `DISABLE_AUTOMOVE` documented in `.claude/CODE_QUALITY.md` for BST/PUP: the text now says no entry sets it.
- Craft's "invalid format" error named `config/craft/<name>.lua`: it names the set file actually read (fixed 2026-09-25).
- `lockstyle_manager.lua`: a dead `else` branch and the unused `MessageCore.show_lockstyle_status` were removed (2026-09-25).
- The WAR macrobook header said "Book range: 1-20": it says 1-40.

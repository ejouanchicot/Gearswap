# SAM (Samurai) job

The SAM job is a small job area: 11 hook modules plus 1 logic module under
`shared/jobs/sam/functions/` (934 lines), an entry point template, six config
files and one sets file. There is no live `Tetsouo/Tetsouo_SAM.lua`: SAM exists
only as a template in `_master/` (and in the frozen clones, which are out of
scope). GearSwap loads it when the main job becomes SAM (`<char>_SAM.lua`).

What SAM adds on top of the shared pipeline:

- **Auto-Seigan before Third Eye**: pressing Third Eye without Seigan up cancels
  it, casts Seigan, then Third Eye one second later.
- **Auto-Third Eye before a weaponskill**: a weaponskill pressed while Third Eye
  is not up is cancelled, Third Eye is cast and the weaponskill replayed 1.5 s
  later.
- **WS buff layers** in `job_post_precast`: `sets.buff.Sekkanoki` and
  `sets.buff['Meikyo Shisui']` while `buffactive` says those buffs are up.
- **Set building** by HP (Weak below 50 %, Regen below 80 %), `HybridMode` PDT
  for idle, Seigan/Third Eye for engaged, weapon sets, a bow layer.
- **TP bonus configuration** with Hagakure and Dojikiri Yasutsuna.

SAM has no job-specific `//gs c` command. The auto-Third Eye path no longer
breaks on the missing `res` global: it reads `rawget(_G, 'res') or
windower.res or require('resources')` (`SAM_PRECAST.lua:93`, fixed in
`518e536`). Both automations keep the design limits listed in
[Known issues](#known-issues).

Every file in scope was read in full except the gear content of the sets file
(only structure and set names were read, as gear choice is out of scope). Line
numbers were re-checked against the working tree on 2026-09-25.

## Files

| Path | Lines | Role |
|------|------:|------|
| `_master/entry/Tetsouo_SAM.lua` | 219 | Entry point (template): config preload, `get_sets`, `job_sub_job_change`, `user_setup`, `job_update`, `init_gear_sets`, `file_unload` |
| `shared/jobs/sam/functions/sam_functions.lua` | 49 | Facade: includes the 11 hook files, requires `dualbox_manager` |
| `shared/jobs/sam/functions/SAM_PRECAST.lua` | 209 | `job_precast` (guard, cooldown, auto-Seigan, auto-Third Eye, WS handler) / `job_post_precast` (TP gear, Sekkanoki, Meikyo Shisui by `buffactive`) |
| `shared/jobs/sam/functions/SAM_MIDCAST.lua` | 75 | `job_midcast` (empty) / `job_post_midcast`: watchdog, Healing and Enhancing via `MidcastManager` |
| `shared/jobs/sam/functions/SAM_AFTERCAST.lua` | 22 | `job_aftercast = LifecycleManager.aftercast()` |
| `shared/jobs/sam/functions/SAM_IDLE.lua` | 42 | `customize_idle_set` -> `SetBuilder.build_idle_set` |
| `shared/jobs/sam/functions/SAM_ENGAGED.lua` | 42 | `customize_melee_set` -> `SetBuilder.build_engaged_set` |
| `shared/jobs/sam/functions/SAM_STATUS.lua` | 20 | `job_status_change = LifecycleManager.status_change()` |
| `shared/jobs/sam/functions/SAM_BUFFS.lua` | 19 | `job_buff_change = LifecycleManager.buff_change()` |
| `shared/jobs/sam/functions/SAM_COMMANDS.lua` | 155 | `job_self_command` router (shared commands only), `job_state_change = LifecycleManager.state_change()` |
| `shared/jobs/sam/functions/SAM_MOVEMENT.lua` | 47 | `get_sam_movement_status` (no caller), empty `job_handle_equipping_gear` |
| `shared/jobs/sam/functions/SAM_LOCKSTYLE.lua` | 47 | Lazy `LockstyleManager.create('SAM', ..., 1, 'SAM')` wrappers |
| `shared/jobs/sam/functions/SAM_MACROBOOK.lua` | 42 | Lazy `MacrobookManager.create('SAM', ..., 'SAM', 1, 1)` wrapper |
| `shared/jobs/sam/functions/logic/set_builder.lua` | 165 | Idle (HP, PDT, weapon) and engaged (base from `select_engaged_base`: AM3 or `sets.engaged[HybridMode]`; Seigan, weapon, bow) builders |
| `_master/config/sam/SAM_STATES.lua` | 132 | `SAMStates.configure()` (HybridMode, MainWeapon, `state.Buff`, FastCast, AutoMedicine), unused `validate()` |
| `_master/config/sam/SAM_KEYBINDS.lua` | 37 | Data only: 2 binds handed to `KeybindManager.create('SAM', ...)`, which adds `bind_all` / `show_intro` / `unbind_all` and the character's `COMMON_KEYBINDS.lua` keys |
| `_master/config/sam/SAM_CUSTOM.lua` | 118 | Player modes and gear rules, commented examples only ([keybinds and custom states](../systems/keybinds-and-custom.md)) |
| `_master/config/sam/SAM_TP_CONFIG.lua` | 110 | `_G.SAMTPConfig`: Hagakure JP, pieces, weapons, `get_weapon_bonus`, `get_hagakure_bonus` |
| `_master/config/sam/SAM_LOCKSTYLE.lua` | 32 | `default = 2`, `by_subjob` (no `get_style`) |
| `_master/config/sam/SAM_MACROBOOK.lua` | 62 | `default`, `solo[sub]` (book 2 page 1), empty `dualbox` |
| `_master/sets/sam_sets.lua` | 511 | Template sets (flat) |
| `shared/data/job_abilities/SAM_JA_DATABASE.lua` + `sam/sam_{mainjob,subjob,sp}.lua` | 13 + ... | JA data for the ability message hooks |

Live copies: none. `Tetsouo/` has no SAM entry, no `config/sam/` and no SAM
sets; `Kaories/`, `_master/Kaories/` and `_master/Tetsouo/` contain no SAM
files. The `Tetsouo/...` require paths in the template are replaced by the clone
script ([characters and templates](../architecture/characters-and-templates.md)).

## How it works

### Load sequence

Same order as every job: the entry chunk, then `get_sets()`; Mote-Include runs
`user_setup()` and `init_gear_sets()` from inside `include('Mote-Include.lua')`
(`Mote-Include.lua:170-175`), before `INIT_SYSTEMS` and the hook files.

```mermaid
sequenceDiagram
    participant GS as GearSwap
    participant E as Tetsouo_SAM.lua
    participant M as Mote-Include
    participant F as sam_functions.lua
    GS->>E: run chunk (LOCKSTYLE_CONFIG 15-22, REGION_CONFIG 27-30, UIConfig 36-37)
    GS->>E: get_sets()
    E->>M: include Mote-Include (line 48)
    M->>E: user_setup(): states, keybinds, UI, JCM, macrobook/lockstyle, dualbox
    M->>E: init_gear_sets() -> include sets/sam_sets.lua (line 202)
    E->>E: INIT_SYSTEMS, data_loader, message hooks (50-74)
    E->>E: _G.LockstyleConfig, _G.UIConfig, _G.RECAST_CONFIG (80-82), _G.SAMTPConfig (85)
    E->>E: JobChangeManager.cancel_all() (88-91)
    E->>F: include sam_functions.lua (94)
    E->>E: register_lockstyle_cancel('SAM', ...) (98-100)
```

Differences from the other entries:

- `_G.RECAST_CONFIG` is loaded at the same point as on DRK/WAR (82), which also
  defines the globals `is_recast_ready` / `is_on_cooldown` used by
  `//gs c jump` and `//gs c waltz`. Until 2026-09-19 the SAM entry did not
  load it.
- `REGION_CONFIG` is loaded in the file chunk (`Tetsouo_SAM.lua:27-30`), before
  `INIT_SYSTEMS` loads `message_colors`, which reads `_G.RegionConfig` once per
  load. Until 2026-09-25 SAM loaded it inside `get_sets()` after the message
  system, so the region's warning orange was never applied.

`user_setup()` (`Tetsouo_SAM.lua:124-179`): `SAMStates.configure()`, then
`SAM_KEYBINDS` stored in the global `SAMKeybinds` and `bind_all()` (2 binds plus
the character's common keys, then `show_intro()`, which `require`s
`SAM_MACROBOOK` and `SAM_LOCKSTYLE` and so defines the `select_default_*`
globals as a side effect), `KeybindUI.smart_init`,
`JobChangeManager.initialize()` + macro book now + lockstyle after 8 s, and the
`dualbox_manager` require. A keybind file that fails to load prints
`[SAM] Keybinds failed to load: <error>` (145). `job_sub_job_change`
(110-118) only hands over to `JobChangeManager.on_job_change`; the
`JobChangeManager.initialize({...})` call it used to repeat was removed on
2026-09-25 (`user_setup` already calls `initialize()`).

The facade (`sam_functions.lua`) includes `SAM_LOCKSTYLE`, `SAM_MACROBOOK`
(20-21), then `SAM_PRECAST` .. `SAM_MOVEMENT` (22-38), requires
`dualbox_manager` (42) and prints a debug line (44-45). It does not include
`message_buffs.lua` (nothing in SAM uses it).

### Precast

`job_precast` (`SAM_PRECAST.lua:131-166`):

```mermaid
flowchart TD
    A[job_precast] --> B{PrecastGuard.guard_precast}
    B -- blocked --> Z[return]
    B -- ok --> C[CooldownChecker by action_type]
    C --> D{eventArgs.cancel}
    D -- yes --> Z
    D -- no --> E{Third Eye and Seigan down}
    E -- "yes, first attempt" --> S[cancel; /ja Seigan; wait 1; /ja Third Eye]
    E -- no --> F{WeaponSkill and Third Eye down}
    F -- "recast slot reads 0" --> T[cancel; /ja Third Eye; follow_up replays /ws]
    F -- no --> W[WSPrecastHandler.handle with SAMTPConfig]
```

- `try_seigan_before_third_eye` (57-76) uses the module flag
  `seigan_cast_attempted` (51) as its anti-loop guard: the first Third Eye with
  Seigan down sets it and re-queues; the next Third Eye with Seigan still down
  clears it and lets Third Eye through. After a successful Seigan the flag is
  never cleared, so the next time Seigan is down the first Third Eye goes
  through without Seigan (the behaviour alternates).
- `try_third_eye_ws` (82-120) walks `windower.ffxi.get_abilities().job_abilities`
  (ability ids), finds `Third Eye` (id 62) and reads
  `ability_recasts[res_ability.recast_id]`. `get_ability_recasts()` is indexed
  by **recast id** (Third Eye's is 133, `res/job_abilities.lua`). Before commit
  `0a51c06` it read slot 62, which belongs to Flee, so Third Eye always looked
  ready and every weaponskill was cancelled and resent while it was on recast.
- The replayed `/ja "Third Eye"` itself goes through precast, so with Seigan down
  the WS path also triggers the Seigan path: Hasso is replaced by Seigan.
- Neither path prints its own message: the ability message hook announces
  Seigan and Third Eye when they go out (both are in the SAM JA database). Until
  commit `0a51c06` both called `MessageFormatter.show_auto_ability`, which does
  not exist, and raised a precast error each time they fired.
- `WSPrecastHandler.handle` returns `true` for non-weaponskills; for a
  weaponskill see [precast pipeline](../systems/precast-pipeline.md#weaponskill-chain).
- `job_post_precast` (173-196): TP bonus gear, then for a weaponskill
  `sets.buff.Sekkanoki` if `buffactive['Sekkanoki']` and
  `sets.buff['Meikyo Shisui']` if `buffactive['Meikyo Shisui']` (186-194). It
  reads the buffs, not `state.Buff`: Mote sets `state.Buff[spell.english] = true`
  in its own `precast()` **before** `job_precast` (`Mote-Include.lua:294-297`),
  and only `buff_change` sets it back to false, so a Sekkanoki press cancelled
  by `CooldownChecker` would leave the flag true; and the flags start `false`
  on every load (`SAM_STATES.lua:69-75`) even when the buff is up.

### Midcast

Mote equips its default midcast set first (spell name, map, skill), then
`job_post_midcast` (`SAM_MIDCAST.lua:35-62`) loads `MidcastDeps`, calls
`MidcastWatchdog.on_midcast_start(spell)` and routes Healing Magic and Enhancing
Magic (target and `ENHANCING_MAGIC_DATABASE.get_spell_family`) to
`MidcastManager.select_set`. The sets define neither
`sets.midcast['Healing Magic']` nor `['Enhancing Magic']`, so both calls return
false at once (`midcast_manager.lua` `select_set`, missing base set);
`sets.midcast.Phalanx` still
applies through Mote's name lookup.

### Aftercast, idle, engaged, status, buffs

- `job_aftercast = LifecycleManager.aftercast()` (`SAM_AFTERCAST.lua`):
  watchdog notification only (`lifecycle_manager.lua` `aftercast`).
- `customize_idle_set` -> `SetBuilder.build_idle_set` (`set_builder.lua:35-65`),
  on top of Mote's base (`sets.idle.Normal` through `IdleMode`, or
  `sets.idle.Weak` under the weakness buff, `Mote-Include.lua:495-511`):
  `sets.idle.Weak` if `player.hpp < 50`, else `sets.idle.Regen` if below 80;
  `sets.idle.PDT` when `HybridMode == 'PDT'`; `sets[state.MainWeapon.value]`.
  No town set, no movement layer: `sets.MoveSpeed` is never used.
- `customize_melee_set` -> `build_engaged_set` (84-119): the base is
  re-selected by `select_engaged_base` (135-159): `sets.engaged.AM3` under
  Aftermath: Lv.3 with Masamune or Kogarasumaru (no such set today), else
  `sets.engaged[HybridMode]` (`PDT` or `Normal`), else Mote's base. Then, with
  Seigan up, `sets.thirdeye` when `HybridMode == 'PDT'`, `sets.seigan`
  otherwise; then the weapon set; then `sets.bow` when the range slot holds
  Yoichinoyumi. The re-selection is needed because Mote's base is
  `sets.engaged.Normal`: `OffenseMode` is `Normal` and Mote then looks for
  `HybridMode` **under** `sets.engaged.Normal` (`Mote-Include.lua:569-577`),
  where no `PDT` child exists, so it never reaches the sibling
  `sets.engaged.PDT`.
- `job_status_change` / `job_buff_change` are the shared `LifecycleManager`
  handlers (Doom), see [core lifecycle](../systems/core-lifecycle.md#lifecyclemanager).
  Mote's `buff_change` keeps `state.Buff[...]` in step for the six names SAM
  registers (`Mote-Include.lua:1027-1029`).
- `job_handle_equipping_gear` (`SAM_MOVEMENT.lua:38-39`) is empty.

## Mote states

Created by `SAMStates.configure()` (`_master/config/sam/SAM_STATES.lua:33-98`)
on every load. Keybinds from `SAM_KEYBINDS.lua:19-35`.

| State | Values | Default | Key | Read by |
|-------|--------|---------|-----|---------|
| `HybridMode` (Mote's, options replaced) | PDT, Normal | PDT | `^numpad9` | idle PDT layer, engaged base `sets.engaged[HybridMode]`, Seigan branch (`set_builder.lua:53,93,151-156`) |
| `MainWeapon` | Masamune, Kusanagi, Shining, Dojikiri, Soboro, Norifusa | Masamune | `^numpad1` | `set_builder.lua:60,107,143` |
| `state.Buff.*` | Hasso, Seigan, Third Eye, Sekkanoki, Meikyo Shisui, Sengikori (booleans) | false | none | no reader (`job_post_precast` reads `buffactive`) |
| `FastCast` | 0..80 step 10 | 0 | none | `midcast_watchdog.lua` |
| `AutoMedicine` | shared On/Off | persisted | `#numpad0` (from `config/COMMON_KEYBINDS.lua`) | `AutoMedicine.init` (`SAM_STATES.lua:94-97`) |

`SAMStates.configure()` replaces the whole `state.Buff` table (69). Mote defaults
`OffenseMode`, `IdleMode`, `WeaponskillMode` stay `'Normal'`.

## Commands

`job_self_command` (`SAM_COMMANDS.lua:44-138`): dual-box internals (57-74;
`altjobupdate` forwards the sender name since 2026-09-25), `watchdog` (79-84),
CommonCommands with `table.unpack(args)` (89-100), `ui` (105-109),
`debugmidcast` (114-124), `cyclestate` (133-136). There is no SAM command. The
body is the same as `DRK_COMMANDS.lua` apart from the job name (open
duplication finding).
`job_state_change = LifecycleManager.state_change()` (148): skips `Moving`,
refreshes the UI. It tests no state name except `Moving` (which has no description, so Mote and the UI-aware `cyclestate` both pass `Moving`), so it accepts the state key and the description alike.

Useful shared commands on SAM: `//gs c jump` (/DRG) and `//gs c waltz` (/DNC)
use the `is_recast_ready` global that `RECAST_CONFIG` defines (loaded since 2026-09-19).

## Set names the code looks up

T = `_master/sets/sam_sets.lua` (no live copy).

| Set | Looked up by | T |
|-----|--------------|---|
| `sets['Masamune']`, `['Kusanagi']`, `['Shining']`, `['Dojikiri']`, `['Soboro']`, `['Norifusa']` | `set_builder.lua:60,107` | 25-31 |
| `sets.idle.Normal` | Mote base (`IdleMode`) | 64 |
| `sets.idle.Weak`, `.Regen`, `.PDT` | `set_builder.lua:44-55` | 94, 81, 99 |
| `sets.engaged.Normal` | Mote base, `select_engaged_base` (HybridMode Normal) | 148 |
| `sets.engaged.PDT` | `select_engaged_base` (HybridMode PDT, `set_builder.lua:151-156`) | 176 |
| `sets.engaged.Mid`, `.Acc`, `.Acc.PDT`, `.MDT`, `.SuBlow` | nothing (OffenseMode only `Normal`) | 165-214 |
| `sets.thirdeye` | `set_builder.lua:95` | 487 |
| `sets.seigan`, `sets.bow` | `set_builder.lua:100,113` | **absent** |
| `sets.engaged.AM3` | `select_engaged_base` (Aftermath: Lv.3, `set_builder.lua:137-148`) | **absent** (falls through to the HybridMode set) |
| `sets.buff.Sekkanoki`, `['Meikyo Shisui']` | `SAM_PRECAST.lua:186-194` (by `buffactive`) | 483, 485 |
| `sets.buff.Sengikori` | nothing | 484 |
| `sets.buff.Doom` | `DoomManager` | 506 |
| `sets.MoveSpeed` | nothing (no movement layer) | 496 |
| `sets.defense.PDT`, `.MDT` | Mote defense commands only (no bind) | 115, 125 |
| `sets.precast.JA` Meditate, Hasso, Seigan, Warding Circle, Third Eye, Blade Bash | Mote default precast | 238-260 |
| `sets.precast.FC`, `.Utsusemi` | Mote default precast | 268, 284 |
| `sets.precast.WS` base + Tachi: Fudo, Shoha, Mumei, Jinpu, Goten, Kagero, Koki, Rana, Ageha, Impulse Drive, Aeolian Edge | Mote default precast | 307-447 |
| `.Mid` / `.Acc` WS variants (Shoha, Rana) | nothing (`WeaponskillMode` `Normal`) | 350-423 |
| `sets.midcast['Healing Magic']`, `['Enhancing Magic']` | `SAM_MIDCAST.lua:44,53` | **absent** |
| `sets.midcast.Phalanx` | Mote default midcast by name | 469 |

`sets['Malevolence']`, `['Onion']`, `['Utu']` (29, 32, 33) are not in
`MainWeapon`.

## Configuration

| File / key | Default | Where the default lives | Read by |
|------------|---------|-------------------------|---------|
| `<char>/config/sam/SAM_STATES.lua` | see states | file | entry `user_setup` |
| `<char>/config/sam/SAM_KEYBINDS.lua` | 2 binds (+ `COMMON_KEYBINDS.lua`) | file | entry `user_setup`, `file_unload` |
| `<char>/config/sam/SAM_CUSTOM.lua` | examples only | file | `KeybindManager` via `custom_states` |
| `<char>/config/sam/SAM_TP_CONFIG.lua` | `hagakure_jp_gifts = 0`; Moonshade +250, Mpaca's Cap +200; Dojikiri Yasutsuna +500 | file | `WSPrecastHandler` via `_G.SAMTPConfig`; `get_hagakure_bonus` returns 1000 + 10 x gifts while Hagakure is up |
| `<char>/config/sam/SAM_LOCKSTYLE.lua` `default`, `by_subjob` | 2 | file; factory fallback 1 (`SAM_LOCKSTYLE.lua` wrapper 29) | `LockstyleManager` uses `default` only (no `get_style`) |
| `<char>/config/sam/SAM_MACROBOOK.lua` | book 2 page 1 for every listed subjob | file; factory fallback book 1 page 1 | `MacrobookManager` |
| `Tetsouo/config/LOCKSTYLE_CONFIG.lua`, `REGION_CONFIG.lua`, UI config | - | entry fallbacks 15-22 | entry |
| `Tetsouo/config/RECAST_CONFIG.lua` | tolerance 2.0 | shared | entry line 82; `CooldownChecker`, `is_recast_ready` |

## State & lifetime

- Module state: `seigan_cast_attempted` (`SAM_PRECAST.lua:51`), lazy module
  locals, `MidcastDeps` cache. All die on `gs reload`.
- `_G` written: the Mote hooks (`job_precast`, `job_post_precast`,
  `job_midcast`, `job_post_midcast`, `job_aftercast`, `customize_idle_set`,
  `customize_melee_set`, `job_status_change`, `job_buff_change`,
  `job_self_command`, `job_state_change`, `job_handle_equipping_gear`),
  `get_sam_movement_status`, `select_default_lockstyle`,
  `cancel_sam_lockstyle_operations`, `select_default_macro_book`,
  `SAMKeybinds`, `SAMTPConfig`, `LockstyleConfig`, `UIConfig`, `RegionConfig`,
  `RECAST_CONFIG`, `is_recast_ready`, `is_on_cooldown`,
  `temp_tp_bonus_gear`.
- `windower.*`: nothing. No events, no coroutines of its own besides the 8 s
  lockstyle; the auto-Seigan and auto-Third Eye chains are `wait` chains in the
  Windower command queue and survive a reload.
- Keybinds: bound in `user_setup`, unbound in `file_unload` (208-219).

## Interactions

- `PrecastGuard`, `CooldownChecker`, `WSPrecastHandler`, `TPBonusCalculator`
  ([precast pipeline](../systems/precast-pipeline.md)).
- `LifecycleManager` for aftercast, status, buffs and state change;
  `MidcastManager`, `MidcastWatchdog`
  ([midcast and buffs](../systems/midcast-and-buffs.md),
  [core lifecycle](../systems/core-lifecycle.md)).
- Factories, `JobChangeManager`, `CommonCommands`, `CycleHandler`, UI, dual-box
  ([factories and helpers](../systems/factories-and-helpers.md),
  [commands and debug](../systems/commands-and-debug.md)).
- [WAR](war.md) implements the /SAM side (Hasso/Seigan + Third Eye, Meditate)
  separately; nothing is shared with SAM's own code.

## Invariants & gotchas

- `get_ability_recasts()` is keyed by recast id, `get_abilities().job_abilities`
  by ability id; they are different numbers for every JA.
- `state.Buff[name]` is set true by Mote in precast, before the job can cancel
  the action; gear that must follow a buff reads `buffactive`.
- Mote nests `HybridMode` under the `OffenseMode` node; a `sets.engaged.PDT`
  sibling of `sets.engaged.Normal` is invisible to Mote, which is why
  `build_engaged_set` re-selects its base.
- `sets.idle.Weak` has two meanings here: Mote's weakness scope and SAM's
  HP < 50 % layer.
- Seigan and Hasso are exclusive stances; both automations cast Seigan whenever
  Third Eye fires with Seigan down.
- `MessageFormatter` has no `__index`: calling an unknown `show_*` raises.

## Extending

- New weapon: `MainWeapon` option in `SAM_STATES.lua` and `sets[key]` in the sets
  file.
- New WS buff layer: a `buffactive['<res.buffs name>']` branch in
  `job_post_precast` and the `sets.buff` entry.
- New command: add it in the SAM-specific section of `job_self_command`. A name
  that is also an alt config key (SAM_ALT has `hasso`, `seigan`, `thirdeye`,
  `meditate`, ...) then runs here; the alt's version stays reachable as
  `//gs c alt <name>`.

## Known issues

- Fixed 2026-09-25: `REGION_CONFIG` is now loaded in the file chunk, before
  the message system (`Tetsouo_SAM.lua:27-30`). To check in game on a region
  with a different warning colour.
- Auto-Seigan guard alternates after a successful Seigan (`SAM_PRECAST.lua:62-73`).
- Auto-Third Eye replaces Hasso by Seigan (`SAM_PRECAST.lua:109` -> 57-76).
- No movement speed layer; `sets.MoveSpeed` unreachable (`set_builder.lua:35-65`).
- `recast == 0` strict test in the auto-Third Eye path (`SAM_PRECAST.lua:101`).
- `SAM_LOCKSTYLE.by_subjob` is never read (no `get_style`,
  `_master/config/sam/SAM_LOCKSTYLE.lua:21`).
- Dead code: `get_sam_movement_status`, `job_handle_equipping_gear`,
  `SAMStates.validate`, the six unread `state.Buff` entries,
  `sets.buff.Sengikori`.
- Fixed in `b6c7dc6`: the comments copied from other jobs (`SAM_IDLE`,
  `SAM_ENGAGED`, `SAM_BUFFS`, `SAM_STATES` WHM_BUFFS and Alt keys).
- `SAM_COMMANDS` duplicates `DRK_COMMANDS` (open finding).
- User doc out of date (`docs/user/jobs/sam/states.md`).

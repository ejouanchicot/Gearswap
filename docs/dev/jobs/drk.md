# DRK (Dark Knight) job

The DRK job has 11 hook modules plus 2 logic modules under
`shared/jobs/drk/functions/` (1 272 lines), an entry point template, five config
files and one sets file. There is no live `Tetsouo/Tetsouo_DRK.lua`: DRK exists
as a template in `_master/` (Hysoka's live DRK is a frozen clone, out of scope).
GearSwap loads it when the main job becomes DRK (`<char>_DRK.lua`).

What DRK adds on top of the shared pipeline:

- **Dark Magic midcast routing** by spell: Dread Spikes and Absorb spells get
  their own pseudo-skills in `MidcastManager`, then Dark Seal (head) and Nether
  Void (legs) overlays are equipped while those buffs are up.
- **Engaged set selection** like WAR: Aftermath Lv.3 with Liberator ->
  `sets.engaged.AM3`, `HybridMode` PDT -> `sets.engaged.PDT`, otherwise the
  `sets.engaged` root; then the weapon set and optional Dark Seal / Nether Void
  engaged variants.
- **Pending flags** for Dark Seal and Nether Void, meant to anticipate the buff
  before it shows in `buffactive`.
- **JA precast gear** equipped explicitly in `job_precast` (Last Resort, Weapon
  Bash, Souleater, Arcane Circle) and Fast Cast for spells.
- **TP bonus configuration** (Moonshade, Anguta).

DRK has no job-specific `//gs c` command.

Every file in scope was read in full except the gear content of the sets file
(only structure and set names were read, as gear choice is out of scope). All
line numbers refer to the working tree on 2026-09-19.

## Files

| Path | Lines | Role |
|------|------:|------|
| `_master/entry/Tetsouo_DRK.lua` | 235 | Entry point (template): config preload, `get_sets`, `job_sub_job_change`, `user_setup`, `job_update`, `init_gear_sets`, `file_unload` |
| `shared/jobs/drk/functions/drk_functions.lua` | 98 | Facade: includes `message_buffs.lua` and the 11 hook files, requires `dualbox_manager` |
| `shared/jobs/drk/functions/DRK_PRECAST.lua` | 130 | `job_precast` (guard, cooldown, pending flags, WS handler, JA gear, FC) / `job_post_precast` (TP gear) |
| `shared/jobs/drk/functions/DRK_MIDCAST.lua` | 159 | `job_midcast` (empty) / `job_post_midcast`: watchdog + handler table (Dark, Enfeebling, Elemental) |
| `shared/jobs/drk/functions/DRK_AFTERCAST.lua` | 89 | `job_aftercast` (watchdog, pending flags), empty `job_post_aftercast` |
| `shared/jobs/drk/functions/DRK_IDLE.lua` | 44 | `customize_idle_set` -> `SetBuilder.build_idle_set` |
| `shared/jobs/drk/functions/DRK_ENGAGED.lua` | 48 | `customize_melee_set` -> `SetBuilder.build_engaged_set(weapon, hybrid)` |
| `shared/jobs/drk/functions/DRK_STATUS.lua` | 36 | `job_status_change`: `DoomManager.handle_status_change` |
| `shared/jobs/drk/functions/DRK_BUFFS.lua` | 46 | `job_buff_change`: Doom, Aftermath Lv.3 refresh |
| `shared/jobs/drk/functions/DRK_COMMANDS.lua` | 179 | `job_self_command` router (shared commands only), `job_state_change = LifecycleManager.state_change()` |
| `shared/jobs/drk/functions/DRK_MOVEMENT.lua` | 36 | Comments only, no code |
| `shared/jobs/drk/functions/DRK_LOCKSTYLE.lua` | 47 | Lazy `LockstyleManager.create('DRK', ..., 1, 'SAM')` wrappers |
| `shared/jobs/drk/functions/DRK_MACROBOOK.lua` | 42 | Lazy `MacrobookManager.create('DRK', ..., 'SAM', 1, 1)` wrapper |
| `shared/jobs/drk/functions/logic/set_builder.lua` | 174 | Engaged base (AM3, PDT), weapon layer, buff variants, idle weapon + movement |
| `shared/jobs/drk/functions/logic/drk_buff_anticipation.lua` | 144 | `has_dark_seal`, `has_nether_void`, engaged buff variants, flag initialisation |
| `_master/config/drk/DRK_STATES.lua` | 119 | `DRKStates.configure()` (HybridMode, MainWeapon, FastCast, AutoMedicine), unused `validate()` |
| `_master/config/drk/DRK_KEYBINDS.lua` | 159 | 3 binds, `get_active_binds`, `bind_all`, `unbind_all`, `show_intro`, `show_binds` |
| `_master/config/drk/DRK_TP_CONFIG.lua` | 77 | `_G.DRKTPConfig`: Moonshade +250, Anguta +500, `get_weapon_bonus` |
| `_master/config/drk/DRK_LOCKSTYLE.lua` | 71 | `default = 1`, `by_subjob` (SAM/WAR 1, NIN 2, DNC 3), `get_style` |
| `_master/config/drk/DRK_MACROBOOK.lua` | 77 | `default`, `solo[sub]` (book 1 pages 1-4), `dualbox` RDM/COR/GEO (books 2-4) |
| `_master/sets/drk_sets.lua` | 590 | Template sets (flat) |
| `shared/data/job_abilities/DRK_JA_DATABASE.lua` + `drk/drk_{mainjob,subjob,sp}.lua` | 13 + ... | JA data for the ability message hooks |

Live copies: none in `Tetsouo/`, `Kaories/`, `_master/Kaories/` or
`_master/Tetsouo/`.

## How it works

### Load sequence

```mermaid
sequenceDiagram
    participant GS as GearSwap
    participant E as Tetsouo_DRK.lua
    participant M as Mote-Include
    participant F as drk_functions.lua
    GS->>E: run chunk (LOCKSTYLE_CONFIG, UIConfig, REGION_CONFIG; lines 36-55)
    GS->>E: get_sets()
    E->>M: include Mote-Include (line 63)
    M->>E: user_setup(): states, keybinds, UI, JCM, macrobook/lockstyle, dualbox
    M->>E: init_gear_sets() -> include sets/drk_sets.lua (line 221)
    E->>E: INIT_SYSTEMS, data_loader, message hooks (65-90)
    E->>E: _G.LockstyleConfig, _G.RECAST_CONFIG (92-93), require DRK_TP_CONFIG (97)
    E->>E: JobChangeManager.cancel_all() (100-103)
    E->>F: include drk_functions.lua (106)
    E->>E: register_lockstyle_cancel("DRK", ...) (111-113)
```

- `DRK_TP_CONFIG` sets `_G.DRKTPConfig` itself (`DRK_TP_CONFIG.lua:75`); the
  entry only requires it.
- `ConfigLoader.load_ui_config` already writes `_G.UIConfig`
  (`config_loader.lua:67`); `user_setup` reads `_G.UIConfig.init_delay` with
  a 5.0 fallback (178).
- The comment at 115-116 says the initial macro book and lockstyle are handled by
  `JobChangeManager`; in fact `user_setup()` does it (190-194), like every job.

`user_setup()` (`Tetsouo_DRK.lua:156-204`): `DRKStates.configure()`, the
keybinds stored in the global `DRKKeybinds` and `bind_all()` (which calls
`show_intro()` and so `require`s `DRK_MACROBOOK` / `DRK_LOCKSTYLE`, defining the
`select_default_*` globals), `KeybindUI.smart_init`, `JobChangeManager`
initialisation + macro book + lockstyle after 8 s, the `dualbox_manager` require.

The facade includes `message_buffs.lua` (29, unused by DRK), then
`DRK_PRECAST` .. `DRK_MOVEMENT` (36-70), requires `dualbox_manager` (86) and
prints a debug line (93-94).

### Precast

`job_precast` (`DRK_PRECAST.lua:52-104`):

```mermaid
flowchart TD
    A[job_precast] --> B{PrecastGuard.guard_precast}
    B -- blocked --> Z[return]
    B -- ok --> C{name in cooldown_exclusions}
    C -- no --> D[CooldownChecker by action_type]
    D --> E{eventArgs.cancel}
    E -- yes --> Z
    C -- yes --> F
    E -- no --> F{JobAbility Dark Seal / Nether Void}
    F -- yes --> G[set _G.drk_*_pending = true]
    F -- no --> H
    G --> H[WSPrecastHandler.handle with DRKTPConfig]
    H -- false --> Z
    H -- true --> I[equip sets.precast.JA name for 4 JAs]
    I --> J[equip sets.precast.FC for Magic]
```

- `cooldown_exclusions` (43-45) is empty.
- The explicit `equip` calls (88-103) run before Mote's `default_precast`, which
  equips `get_precast_set` afterwards (`Mote-Include.lua:263-265, 328-330`):
  the same `sets.precast.JA[name]` for the four JAs, and `sets.precast.FC` or a
  more specific FC child for spells. They change nothing except keeping base FC
  slots that a specific FC child does not define.
- `job_post_precast` (111-116) equips the TP bonus gear.
- No AutoJump on DRK; `//gs c jump` (/DRG) works through `DRGJumpManager`
  because the entry loads `RECAST_CONFIG`.

### Dark Magic midcast

Mote equips its default midcast set first, then `job_post_midcast`
(`DRK_MIDCAST.lua:129-145`) loads `MidcastDeps`, calls
`MidcastWatchdog.on_midcast_start(spell)` and dispatches through
`JOB_POST_MIDCAST_HANDLERS[spell.skill]` (118-122):

```mermaid
flowchart TD
    A[job_post_midcast] --> W[MidcastWatchdog.on_midcast_start]
    W --> B{spell.skill}
    B -- Dark Magic --> C{spell name}
    C -- Dread Spikes --> D[select_set skill Dread Spikes]
    C -- "contains Absorb" --> E[select_set skill Absorb]
    C -- other --> F[select_set skill Dark Magic]
    D --> G{Dark Seal up}
    E --> G
    F --> G
    G -- yes --> H[head from sets.buff Dark Seal]
    G --> I{Nether Void up and Absorb/Drain/Aspir}
    I -- yes --> J[legs from sets.buff Nether Void]
    B -- Enfeebling Magic --> K[select_set Enfeebling, database_func = Enhancing DB]
    B -- Elemental Magic --> L[select_set Elemental Magic]
```

- `MidcastManager.select_set` tries the exact spell name first, so `Drain III`,
  `Aspir` and the ten `Absorb-*` aliases (`drk_sets.lua:329-354`) are found by
  name; `Dread Spikes` and `Absorb` resolve to `sets.midcast['Dread Spikes']` /
  `sets.midcast.Absorb` as base sets.
- The overlays read `buffactive` only (ids 345 and 439, `res/buffs.lua`), not
  the pending flags (71, 80). The Nether Void test matches any name containing
  `Absorb`, so Absorb-TP gets the legs although the set comment says it should
  not (`drk_sets.lua:587`).
- Enfeebling passes `ENHANCING_MAGIC_DATABASE.get_spell_family` as
  `database_func` (103); that database only knows enhancing spells, so it returns
  nil and the base `sets.midcast['Enfeebling Magic']` is used.
- Elemental Magic has no `sets.midcast['Elemental Magic']`, so `select_set`
  returns false (`midcast_manager.lua:624-629`).
- Healing and Enhancing (subjob spells) are not routed; only Mote's default
  applies.

### Pending flags

`DRK_PRECAST.lua:74-80` sets `_G.drk_dark_seal_pending` /
`_G.drk_nether_void_pending` to true on the JA press; `DRK_AFTERCAST.lua:55-61`
sets them true again when the JA was not interrupted. The module header
(`drk_buff_anticipation.lua:19-25`) says `job_buff_change` clears them when the
buff appears; no code does (`DRK_BUFFS.lua:27-43`), and
`initialize_flags` (130-138) only turns nil into false. Once set, a flag stays
true until the next `gs reload`, so `has_dark_seal()` / `has_nether_void()`
(44-52) return true long after the buff is gone. The only reader is the engaged
builder below, which needs `sets.engaged[<weapon>][<hybrid>].DarkSeal` style
sets; the template defines none, so today the stale flags have no visible effect.

### Aftercast, idle, engaged, status, buffs

- `job_aftercast` (`DRK_AFTERCAST.lua:46-66`): loads the anticipation module on
  first use, `MidcastWatchdog.on_aftercast()`, the pending-flag confirmation
  above. `job_post_aftercast` (78-80) is empty.
- `customize_idle_set` -> `build_idle_set` (`set_builder.lua:123-142`): Mote's
  base (`sets.idle` through `IdleMode` `Normal`, whose child is `sets.idle`
  itself, or `sets.idle.Town` in cities) + `sets[state.MainWeapon.current]` +
  `sets.MoveSpeed` when `state.Moving.value == 'true'` (inline, not
  `BaseSetBuilder.apply_movement`; also in town). `HybridMode` is not read, so
  `sets.idle.PDT` is never used.
- `customize_melee_set` (`DRK_ENGAGED.lua:29-45`) ignores Mote's `meleeSet` and
  calls `build_engaged_set(MainWeapon, HybridMode)` (`set_builder.lua:157-168`):
  `select_engaged_base` (51-66) -> `sets.engaged.AM3` when `buffactive[272]` and
  the weapon is Liberator, `sets.engaged.PDT` when `HybridMode == 'PDT'`, else
  the `sets.engaged` root (Accu); then the weapon set; then
  `DRKBuffAnticipation.apply_buff_variants` (71-122), which looks up
  `sets.engaged[weapon][hybrid]` (falling back to `.Accu`) and its
  `DarkSealNetherVoid` / `DarkSeal` / `NetherVoid` children.
- `job_status_change` (`DRK_STATUS.lua:22-33`): `DoomManager.handle_status_change`
  after a `pcall` require, without a nil check.
- `job_buff_change` (`DRK_BUFFS.lua:27-43`): Doom; on gain or loss of
  `"Aftermath: Lv.3"` re-equips through `handle_equipping_gear` unless Doom is up.
  Same body as `WAR_BUFFS.job_buff_change` (open duplication finding).
- `DRK_MOVEMENT.lua` holds only comments. They say AutoMove swaps
  `sets.MoveSpeed` and "auto-detects job modules" (21-31); the movement layer is
  in fact `set_builder.lua:137-138`, reading AutoMove's `state.Moving`.

## Mote states

Created by `DRKStates.configure()` (`_master/config/drk/DRK_STATES.lua:34-90`)
on every load. Keybinds from `DRK_KEYBINDS.lua:32-48`.

| State | Values | Default | Key | Read by |
|-------|--------|---------|-----|---------|
| `HybridMode` (Mote's, options replaced) | PDT, Accu | PDT | `^numpad9` | `DRK_ENGAGED.lua:42` -> `select_engaged_base`, `apply_buff_variants` |
| `MainWeapon` | Caladbolg, Liberator, Redemption, Lycurgos, Loxotic (Apocalypse, Foenaria, Naegling commented out) | Caladbolg | `^numpad1` | `set_builder.lua:53,85,131`; `apply_buff_variants` |
| `FastCast` | 0..80 step 10 | 0 | none | `midcast_watchdog.lua` |
| `AutoMedicine` | shared On/Off | persisted | `#numpad0` | `AutoMedicine.init` (`DRK_STATES.lua:86-89`) |

`Accu` has no set of its own: it selects the `sets.engaged` root. Mote's
`OffenseMode`, `IdleMode`, `WeaponskillMode` stay `'Normal'`.

## Commands

`job_self_command` (`DRK_COMMANDS.lua:61-160`): dual-box internals (74-91),
`watchdog` (96-101), CommonCommands with `table.unpack(args)` (106-117), `ui`
(122-126), `debugmidcast` (131-141), `cyclestate` (150-153). No DRK command; the
router ends at a placeholder (159). The body is the same as `SAM_COMMANDS.lua`
apart from the job name (open duplication finding).
`job_state_change = LifecycleManager.state_change()` (170). It tests no state name except `Moving` (which has no description, so Mote and the UI-aware `cyclestate` both pass `Moving`), so it accepts the state key and the description alike.

## Set names the code looks up

T = `_master/sets/drk_sets.lua` (no live copy).

| Set | Looked up by | T |
|-----|--------------|---|
| `sets['Caladbolg']`, `['Liberator']`, `['Redemption']`, `['Lycurgos']`, `['Loxotic']` | `set_builder.lua:85` | 84, 85, 87, 92, 96 |
| `sets.idle` (and `sets.idle.Normal = sets.idle`) | Mote base | 104, 142 |
| `sets.idle.PDT` | nothing reaches it | 121 |
| `sets.idle.Town` (= `sets.MoveSpeed`, legs only) | Mote Town scope | 560 |
| `sets.MoveSpeed` | `set_builder.lua:137` | 555 |
| `sets.engaged`, `.PDT`, `.AM3` | `select_engaged_base` | 149, 175, 189 |
| `sets.engaged[weapon][hybrid].DarkSeal` / `.NetherVoid` / `.DarkSealNetherVoid` | `apply_buff_variants` | **absent** (feature inert) |
| `sets.precast.JA` Jump, High Jump, Diabolic Eye, Arcane Circle, Nether Void, Souleater, Last Resort, Weapon Bash, Blood Weapon, Dark Seal | Mote default precast (+ `DRK_PRECAST.lua:89-96` for four) | 216-230 |
| `sets.precast.FC` | `DRK_PRECAST.lua:101-103`, Mote | 233 |
| `sets.precast.WS` base (the default VIT gear) | Mote default precast for any WS without a named set | 362 |
| `sets.precast.WS.Acc` | nothing: `WeaponskillMode` is `Normal` | 388 |
| `sets.precast.WS` Entropy, Origin, Resolution, Torcleaver, Quietus, Judgment, Savage Blade | Mote default precast | 391-525 |
| `sets.midcast['Dark Magic']`, `['Dread Spikes']`, `.Absorb` (+ 10 aliases), `.Drain`, `['Drain III']`, `.Aspir` | `DRK_MIDCAST.lua:46-59` | 262, 289, 319-338, 341-354 |
| `sets.midcast['Enfeebling Magic']` | `DRK_MIDCAST.lua:100` | 279 |
| `sets.midcast['Elemental Magic']` | `DRK_MIDCAST.lua:111` | **absent** |
| `sets.buff['Dark Seal']`, `['Nether Void']` | `DRK_MIDCAST.lua:72,83` | 580, 588 |
| `sets.buff.Doom` | `DoomManager` | 569 |

`sets['Apocalypse']`, `['Foenaria']`, `['Tokko']`, `['Naegling']` (86-95) are
not reachable while their `MainWeapon` options stay commented out.

Weaponskills of the listed weapons with no named set (Insurgency, Cross Reaper,
Catastrophe, Spinning Slash, Ground Strike, Upheaval, Fell Cleave, Steel
Cyclone, Black Halo, ...) resolve to `sets.precast.WS` itself, which holds the
default VIT gear: Mote's `get_named_set` / `select_specific_set` try the spell
name, the spell map, the skill and the type (`Mote-Include.lua:929-970`), then
use the table. Until 2026-09-19 that gear sat under a child named `'default'`,
which Mote never reads, and the base table was empty.

## Configuration

| File / key | Default | Where the default lives | Read by |
|------------|---------|-------------------------|---------|
| `<char>/config/drk/DRK_STATES.lua` | see states | file | entry `user_setup` |
| `<char>/config/drk/DRK_KEYBINDS.lua` | 3 binds | file | entry `user_setup`, `file_unload` |
| `<char>/config/drk/DRK_TP_CONFIG.lua` | Moonshade ear1 +250; Anguta +500 | file (`pieces` 30, `weapons` 43) | `WSPrecastHandler` via `_G.DRKTPConfig` (captured on first action) |
| `<char>/config/drk/DRK_LOCKSTYLE.lua` | default 1; SAM/WAR 1, NIN 2, DNC 3 | file (28, 33-39); factory fallback 1 | `LockstyleManager` through `get_style` (50-58) |
| `<char>/config/drk/DRK_MACROBOOK.lua` | book 1, page 1 (SAM), 2 (WAR), 3 (NIN), 4 (DNC); dual-box RDM book 2, COR 3, GEO 4 | file (31-70); factory fallback book 1 page 1 | `MacrobookManager` |
| `Tetsouo/config/RECAST_CONFIG.lua` | tolerance 2.0 | shared | entry line 93 |
| `Tetsouo/config/LOCKSTYLE_CONFIG.lua`, `REGION_CONFIG.lua`, UI config | - | entry fallbacks 36-42 | entry chunk |

## State & lifetime

- Module state: lazy module locals (`DRK_PRECAST`, `DRK_AFTERCAST`
  `module_initialized`, set builder), `MidcastDeps` cache. All die on
  `gs reload`.
- `_G` written: the Mote hooks (`job_precast`, `job_post_precast`,
  `job_midcast`, `job_post_midcast`, `job_aftercast`, `job_post_aftercast`,
  `customize_idle_set`, `customize_melee_set`, `job_status_change`,
  `job_buff_change`, `job_self_command`, `job_state_change`),
  `drk_dark_seal_pending`, `drk_nether_void_pending`,
  `select_default_lockstyle`, `cancel_drk_lockstyle_operations`,
  `select_default_macro_book`, `DRKKeybinds`, `DRKTPConfig`, `LockstyleConfig`,
  `RECAST_CONFIG`, `RegionConfig`, `temp_tp_bonus_gear`.
- `windower.*`: nothing. No events, no job coroutines besides the 8 s lockstyle.
- Keybinds: bound in `user_setup`, unbound in `file_unload` (224-235).
- The pending flags live in the sandbox `_G`, so a `gs reload` (every subjob
  change ends in one) is the only thing that resets them.

## Interactions

- `PrecastGuard`, `CooldownChecker`, `WSPrecastHandler`, `TPBonusCalculator`
  ([precast pipeline](../systems/precast-pipeline.md)).
- `MidcastManager` (pseudo-skills `Dread Spikes`, `Absorb`), `MidcastWatchdog`
  ([midcast and buffs](../systems/midcast-and-buffs.md)).
- `LifecycleManager.state_change` only; status and buffs keep their own copies
  ([core lifecycle](../systems/core-lifecycle.md)).
- `DRGJumpManager` through `//gs c jump`
  ([factories and helpers](../systems/factories-and-helpers.md#drg-jumps)).
- Factories, `JobChangeManager`, `CommonCommands`, `CycleHandler`, UI, dual-box
  ([commands and debug](../systems/commands-and-debug.md)).
- Set builder shape copied from [WAR](war.md) ("like WAR" comments,
  `set_builder.lua:72,148`); `DRK_COMMANDS` mirrors [SAM](sam.md).

## Invariants & gotchas

- The engaged builder never uses Mote's selection; any Mote-side engaged naming
  (`sets.engaged.Normal`, CombatForm, CustomMeleeGroups) is ignored on DRK.
- A weaponskill needs a set named exactly after it, or gear on the
  `sets.precast.WS` table itself; a child named `default` is invisible to Mote.
- `sets.idle.Town` is a one-slot table; Mote uses it as the whole idle base in
  every city, so the other slots keep whatever was worn before.
- `HybridMode` affects engaged gear only.
- Dark Seal / Nether Void midcast overlays read `buffactive`; the engaged
  variants read `buffactive` **or** the pending flags.
- `job_precast` equips before Mote's default precast; anything that must win
  belongs in `job_post_precast`.

## Extending

- New weapon: uncomment or add the `MainWeapon` option (`DRK_STATES.lua:55-66`)
  and a `sets[key]` in the sets file.
- New Dark Magic special case: add a branch in `job_post_midcast_dark_magic`
  (`DRK_MIDCAST.lua:43-60`) with a pseudo-skill and define
  `sets.midcast['<PseudoSkill>']` (the base set is mandatory).
- New skill: add a handler to `JOB_POST_MIDCAST_HANDLERS` and the base set.
- Engaged buff variants: define `sets.engaged[<weapon>][<PDT|Accu>]` with
  `DarkSeal` / `NetherVoid` / `DarkSealNetherVoid` children, and first make the
  pending flags reset (Known issues).
- New command: add it in the DRK section of `job_self_command`. A name that is
  also an alt config key (DRK_ALT has `lastresort`, `souleater`, ...) then runs
  here; the alt's version stays reachable as `//gs c alt <name>`.

## Known issues

- Dark Seal / Nether Void pending flags are never cleared; the header's "BUFFS
  clears the flag" step does not exist (`DRK_PRECAST.lua:74-80`,
  `DRK_AFTERCAST.lua:55-61`, `drk_buff_anticipation.lua:24`); inert until engaged
  variants are defined.
- Enfeebling Magic routed with the Enhancing database function
  (`DRK_MIDCAST.lua:103`).
- Elemental Magic routing is a no-op: no `sets.midcast['Elemental Magic']`
  (`DRK_MIDCAST.lua:110-116`).
- `sets.idle.PDT` unreachable (`set_builder.lua:123-142`).
- `sets.idle.Town = sets.MoveSpeed` is used as the whole town idle
  (`_master/sets/drk_sets.lua:560`).
- `sets.precast.WS.Acc` unreachable (`_master/sets/drk_sets.lua:388`).
- Nether Void legs applied to Absorb-TP against the set comment
  (`DRK_MIDCAST.lua:82`, `drk_sets.lua:587`).
- Redundant JA/FC equips in `job_precast` (`DRK_PRECAST.lua:88-103`); empty
  `cooldown_exclusions` (43-45).
- `DRK_STATUS` / `DRK_BUFFS` repeat `LifecycleManager` / `WAR_BUFFS` bodies,
  `DRK_COMMANDS` repeats `SAM_COMMANDS` (open duplication findings).
- Movement layer inline instead of `BaseSetBuilder.apply_movement`
  (`set_builder.lua:137-138`, already listed in
  [midcast and buffs](../systems/midcast-and-buffs.md#known-issues)).
- Dead code: `job_post_aftercast`, `DRKStates.validate`, `message_buffs` include,
  `DRK_MOVEMENT.lua` (comments only).
- Comments out of date: `DRK_MOVEMENT.lua:21-31`, `Tetsouo_DRK.lua:115-116`,
  `DRK_AFTERCAST.lua:63-65` (WAR text), `DRK_STATES.lua:43,54` (Alt+1/Alt+2),
  `DRK_IDLE.lua:5` / `DRK_ENGAGED.lua:5-6` (IdleMode/EngagedMode, NIN dual
  wield), `DRK_BUFFS.lua:4` (Chainspell).
- User docs out of date (`docs/user/jobs/drk/states.md`, `abilities.md`).

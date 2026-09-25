# RUN (Rune Fencer) job

The RUN job area is 12 hook files plus 4 logic modules under
`shared/jobs/run/functions/` (1 407 lines), one entry template, seven config
files and one sets file. No live character plays it: `character_db.lua` lists
RUN in `ARCHIVE_JOBS`, there is no `Tetsouo_RUN.lua`, and the only deployed copy
is the frozen `Hysoka/` clone (not analysed here). GearSwap would load it when
the main job becomes RUN; from then on Mote-Include calls its hooks on every
action, on status and buff changes, on `//gs c` commands and on state cycles.

RUN is structurally a copy of [PLD](pld.md) with less in it. What it adds on top
of the shared pipeline:

- **Weapon + grip set builder**: `MainWeapon` (Epeolatry, Lycurgos) and
  `SubWeapon` (Utu, Refined grip), grip skipped for Lycurgos, HybridMode
  PDT/MDT sets.
- **Name-before-skill midcast**: Flash and Enlight caught before the Divine
  skill, target-aware Cure III/IV, Phalanx by name, Enhancing by spell family,
  Blue Magic under one set.
- **Rune command** (`//gs c rune`) from `state.RuneMode`, and a BLU AOE rotation
  (`//gs c aoe`) with the BLU config loaded by the entry.
- **No gear swap for runes**: `sets.precast.JA` is empty on purpose.

It has no ward/rune tracking, no Gambit/Rayke logic and no Dark Magic routing
(the entry header no longer claims any since `b6c7dc6`).

Every file in scope was read in full except the gear content of the sets file.
Line numbers were re-checked against the working tree on 2026-09-25.

## Files

| Path | Lines | Role |
|------|------:|------|
| `_master/entry/Tetsouo_RUN.lua` | 271 | Entry point (template): same shape as PLD, BLU config preloaded (no TP config), keybinds deferred 0.5 s, initial macro book / lockstyle deferred 0.2 s |
| `shared/jobs/run/functions/run_functions.lua` | 113 | Facade: includes `message_buffs` and the 11 hook files, requires `dualbox_manager` |
| `shared/jobs/run/functions/RUN_PRECAST.lua` | 163 | `job_precast` (guard, cooldown, WS) / `job_post_precast` (TP gear, precast debug display) |
| `shared/jobs/run/functions/RUN_MIDCAST.lua` | 159 | `job_midcast` (Cure III/IV) / `job_post_midcast` (dispatch) |
| `shared/jobs/run/functions/RUN_AFTERCAST.lua` | 38 | `LifecycleManager.aftercast()`, empty `job_post_aftercast` |
| `shared/jobs/run/functions/RUN_IDLE.lua` | 43 | `customize_idle_set` -> `SetBuilder.build_idle_set` |
| `shared/jobs/run/functions/RUN_ENGAGED.lua` | 41 | `customize_melee_set` -> `SetBuilder.build_engaged_set` |
| `shared/jobs/run/functions/RUN_STATUS.lua` | 20 | `LifecycleManager.status_change()` |
| `shared/jobs/run/functions/RUN_BUFFS.lua` | 19 | `LifecycleManager.buff_change()` |
| `shared/jobs/run/functions/RUN_COMMANDS.lua` | 202 | `job_self_command` router, `job_state_change` (UI refresh only) |
| `shared/jobs/run/functions/RUN_MOVEMENT.lua` | 24 | Comments only |
| `shared/jobs/run/functions/RUN_LOCKSTYLE.lua` | 47 | Lazy `LockstyleManager.create('RUN', 'config/run/RUN_LOCKSTYLE', 1, 'SAM')` |
| `shared/jobs/run/functions/RUN_MACROBOOK.lua` | 42 | Lazy `MacrobookManager.create('RUN', ..., 'SAM', 1, 1)` |
| `shared/jobs/run/functions/logic/set_builder.lua` | 187 | Idle/engaged: HybridMode, weapon, grip, town, movement |
| `shared/jobs/run/functions/logic/aoe_manager.lua` | 182 | BLU rotation (same code as PLD's except strings; refuses without /BLU since 2026-09-25) |
| `shared/jobs/run/functions/logic/cure_set_builder.lua` | 51 | CureSelf / CureOther for Cure III/IV (identical to PLD's) |
| `shared/jobs/run/functions/logic/rune_manager.lua` | 76 | `//gs c rune` (identical to PLD's) |
| `_master/config/run/RUN_STATES.lua` | 152 | States, unused `validate` |
| `_master/config/run/RUN_KEYBINDS.lua` | 45 | Data only: 4 binds handed to `KeybindManager.create('RUN', ...)`, plus the character's `COMMON_KEYBINDS.lua` keys |
| `_master/config/run/RUN_LOCKSTYLE.lua` | 72 | Style 3 (`default`, `by_subjob`, `get_style`) |
| `_master/config/run/RUN_MACROBOOK.lua` | 76 |
| `_master/config/run/RUN_CUSTOM.lua` | 118 | Player modes and gear rules, commented examples only ([keybinds and custom states](../systems/keybinds-and-custom.md)) | Books 15-20 (same numbers as PLD) |
| `_master/config/run/RUN_TP_CONFIG.lua` | 74 | `_G.RUNTPConfig` - **never loaded** |
| `_master/config/run/RUN_BLU_MAGIC.lua` | 203 | Copy of `PLD_BLU_MAGIC`; loaded by the entry as `_G.BluMagicConfig` |
| `_master/sets/run_sets.lua` | 401 | Template sets (flat) |
| `shared/data/job_abilities/RUN_JA_DATABASE.lua` + `run/*.lua` | 13 + 276 | JA descriptions (runes, wards, SP) for `ability_message_handler` |
| `shared/utils/messages/data/jobs/run_messages.lua` | 29 | Valiance/Vallation expiry templates - no caller |

Live copies: none under `Tetsouo/` or `Kaories/`. `Hysoka/` has RUN and is a
frozen clone; it was not read.

## How it works

### Load sequence

```mermaid
sequenceDiagram
    participant GS as GearSwap
    participant E as Tetsouo_RUN.lua
    participant M as Mote-Include
    participant F as run_functions.lua
    GS->>E: run chunk (LOCKSTYLE_CONFIG, UIConfig, REGION_CONFIG)
    GS->>E: get_sets()
    E->>M: include Mote-Include (line 68)
    M->>E: user_setup(): states, schedule keybinds +0.5 s, UI, JCM, schedule macro/lockstyle gate +0.2 s, dualbox
    M->>E: init_gear_sets() -> include sets/run_sets.lua (254)
    E->>E: INIT_SYSTEMS, data_loader, message hooks (70-94)
    E->>E: _G.LockstyleConfig, _G.RECAST_CONFIG (96-97); _G.BluMagicConfig (102); TP / ward configs commented out (107-108)
    E->>E: JobChangeManager.cancel_all() (111-114)
    E->>F: include run_functions.lua (117)
    E->>E: register_lockstyle_cancel("RUN", ...) (121-123)
    Note over E: +0.2 s: select_default_macro_book(), lockstyle after 8 s (204-209)
    Note over E: +0.5 s: RUNKeybinds.bind_all() (165-181)
```

`user_setup()` (`Tetsouo_RUN.lua:157-231`):

1. `RUNStates.configure()` (159-160).
2. Keybinds in a `coroutine.schedule(..., 0.5)` (165-181): `require` into the
   global `RUNKeybinds`, `bind_all()`; a failed `require` prints
   `[RUN] Keybinds failed to load: <error>`. Why they are deferred is not
   recorded.
3. `KeybindUI.smart_init("RUN", UIConfig.init_delay)` (186-189).
4. `JobChangeManager.initialize()`, then the macrobook/lockstyle gate is
   scheduled 0.2 s later (204-209), the same pattern as BRD. The gate needs
   `select_default_macro_book` and `select_default_lockstyle`; at `user_setup`
   time nothing defines them on RUN (the keybinds, whose
   `KeybindManager` intro `require`s the wrapper files, are not loaded until
   0.5 s later). The facade defines them during the rest of
   `get_sets()` (`run_functions.lua:66-67`), so 0.2 s later the gate passes:
   macro book at once, lockstyle after `initial_load_delay` (8 s). Before
   2026-09-19 the gate ran synchronously and a fresh load or main job change
   applied neither.
5. `pcall(require, 'shared/utils/dualbox/dualbox_manager')` (218); a dual-box
   alt job update that brings a new job or subjob later calls
   `select_default_macro_book()` (`dualbox_manager.lua` `receive_alt_job`).
6. A commented-out WarpInit block (220-230).

`run_functions.lua` includes `message_buffs.lua` (29), `RUN_PRECAST`,
`RUN_MIDCAST`, `RUN_AFTERCAST` (36-40), `RUN_IDLE`, `RUN_ENGAGED` (47-49),
`RUN_STATUS`, `RUN_BUFFS` (56-58), `RUN_LOCKSTYLE`, `RUN_MACROBOOK`,
`RUN_COMMANDS`, `RUN_MOVEMENT` (66-70), then `dualbox_manager` (101).

### Precast

`job_precast` (`RUN_PRECAST.lua:82-106`) then Mote's `default_precast`, then
`job_post_precast` (`:113-150`):

```mermaid
flowchart TD
    A[job_precast] --> B{PrecastGuard.guard_precast}
    B -- blocked --> Z[return]
    B -- ok --> C{name in cooldown_exclusions}
    C -- no --> D[CooldownChecker ability or spell]
    D --> E{eventArgs.cancel}
    E -- yes --> Z
    E -- no --> G
    C -- yes --> G[WSPrecastHandler.handle with RUNTPConfig = empty]
    G --> H[Mote default_precast]
    H --> I[job_post_precast: apply_tp_gear, debug display if PrecastDebugState]
```

- `cooldown_exclusions` (50-75) is the same Scholar list as PLD's, redundant
  with `CooldownChecker` ([precast pipeline](../systems/precast-pipeline.md)).
- `RUNTPConfig = _G.RUNTPConfig or {}` (44): the entry never loads
  `RUN_TP_CONFIG.lua` (the line is commented out and spells the global
  `RUNTPCONFIG`, `Tetsouo_RUN.lua:107`), so no TP-bonus gear is computed.
- Mote's default precast: `sets.precast.FC` for magic (no name/skill variants
  defined), `sets.precast.JA[name]` for JAs, `sets.precast.WS[name]` for WS.
  `sets.precast.JA` is `{}` (`run_sets.lua:139`): runes and any JA without a
  named set swap nothing, by design ("No set defined = no equipment change",
  `run_sets.lua:158-160`).
- `sets.precast.WS['Resolution'|'Dimidiation'|'Herculean Slash'|'Spinning
  Slash'|'Ground Strike']` are `set_combine(sets.precast.WS, {})`
  (`run_sets.lua:260-264`): the generic gear until each gets its own. Mote's
  `get_named_set` returns the named table when it exists
  (`Mote-Include.lua:963-965`), so an empty `{}` there (as before 2026-09-19)
  equipped nothing and hid the generic set.
- `job_post_precast` debug block (124-149): when `_G.PrecastDebugState`
  (`//gs c debugprecast`), prints which FC set Mote picked.

### Midcast

Same Mote order as PLD: `job_midcast`, `default_midcast` unless handled,
`job_post_midcast` (`Mote-Include.lua:254-276`).

```mermaid
flowchart TD
    A[job_midcast] --> B{Cure III or IV}
    B -- yes --> C[CureSetBuilder.generate: nil on RUN, equip nothing, handled]
    B -- no --> D[Mote default_midcast]
    C --> E[job_post_midcast]
    D --> E
    E --> F[MidcastWatchdog.on_midcast_start]
    F --> G{handled}
    G -- yes --> Z[return]
    G -- no --> H{dispatch}
    H -- Flash --> H1[select_set skill Flash]
    H -- Enlight, Enlight II --> H2[select_set skill Enmity]
    H -- Healing Magic --> H3[select_set Healing Magic, Self/Other]
    H -- Enhancing: Phalanx --> H4[select_set Enhancing, P0 sets.midcast.Phalanx]
    H -- Enhancing: other --> H5[select_set Enhancing, Composure target, spell family]
    H -- Divine Magic --> H6[select_set Divine Magic]
    H -- Blue Magic --> H7[select_set Blue Magic]
```

- `CureSetBuilder` needs `sets.midcast.CureSelf` / `CureOther`
  (`cure_set_builder.lua:34`), which `run_sets.lua` does not define: it returns
  nil, and `handled` still suppresses Mote's default, so Cure III/IV wear the
  precast set through the cast.
- `sets.midcast['Healing Magic']` and `['Divine Magic']` are absent, so those
  routes are no-ops (`midcast_manager.lua` `select_set` returns when
  `sets.midcast[skill]` is missing). Enlight is a PLD spell;
  the branch only matters for a /PLD subjob that cannot learn it.
- Flash, Foil and Crusade alias `sets.midcast.SIRDEnmity`
  (`run_sets.lua:348-350`); Phalanx and Regen have named sets (`:331,354`,
  Regen IV reaches `Regen` through the P1 tier strip); every Blue spell wears
  `sets.midcast['Blue Magic']` (`:372`).

### Aftercast, idle, engaged, status, buffs

- `job_aftercast` = MidcastWatchdog tick; status and buff changes are the
  shared Doom handlers ([core lifecycle](../systems/core-lifecycle.md)).
- `build_engaged_set` (`shared/jobs/run/functions/logic/set_builder.lua:107-135`): Mote base
  (`sets.engaged.PDT`/`.MDT` through `HybridMode`) -> the HybridMode set again
  (`set_combine`, 114-126) -> `sets[MainWeapon]` -> `sets[SubWeapon]` unless
  MainWeapon is Lycurgos (`apply_grip`, 62-83).
- `build_idle_set` (144-181): town base (`sets.Adoulin` / `sets.idle.Town`) or
  Mote's idle -> HybridMode idle set (field only) -> weapon -> grip -> return in
  town, else `sets.MoveSpeed` when moving.
- For Lycurgos the grip is skipped, not removed: whatever grip was in the sub
  slot stays there. The header says so since `b6c7dc6`
  (`set_builder.lua:18`).

### Differences from PLD

The two jobs were cloned from the same files; this is what diverged.

| Area | PLD | RUN |
|------|-----|-----|
| Entry configs | `PLD_TP_CONFIG` and `PLD_BLU_MAGIC` loaded | `RUN_BLU_MAGIC` loaded (`Tetsouo_RUN.lua:102`), TP config commented out (107) |
| Keybinds | loaded synchronously; the `KeybindManager` intro requires the factory wrappers | deferred 0.5 s (same intro, too late for the gate); initial macro book / lockstyle gate deferred 0.2 s instead |
| Precast | Divine Emblem / Majesty auto-abilities, Cure/Flash precast equips, CureSelf FC, Sortie override | none of these; precast debug display instead |
| Midcast order | Healing checked before Flash | Flash and Enlight checked first |
| Phalanx | SIRD override (`Xp`, `PhalanxSIRD`) or pseudo-skill `Phalanx` | plain Enhancing, name set wins |
| Blue Magic | `Cocoon` pseudo-skill, else `Blue Magic` (no base set) | `Blue Magic` with a base set |
| Enmity override | `EnmityOverride` after dispatch | none |
| Set builder | weapon + shield, BurtgangKC, Shining grip, XP, Sortie map | weapon + grip, Lycurgos skip |
| HybridMode | PDT, MDT, Sortie; profile hook in `job_state_change` | PDT, MDT; UI refresh only |
| Subjob-filtered binds | Xp (/RDM), RuneMode (/RUN), SneakInviAOE (/SCH) | none |
| /SCH helpers | `aoe sneak` / `invi` / `erase`, `lightarts` | none |

## Mote states

Created by `RUNStates.configure()` (`_master/config/run/RUN_STATES.lua:34-113`).
Keybinds from `RUN_KEYBINDS.lua:18-43`; none of them has a `subjob` filter.

| State | Values | Default | Key | Read by |
|-------|--------|---------|-----|---------|
| `HybridMode` (Mote) | PDT, MDT | PDT | `^numpad9` | Mote `get_melee_set`; `set_builder.lua:115-120,153-159` |
| `MainWeapon` | Epeolatry, Lycurgos | Epeolatry | `^numpad1` | `set_builder.lua:47,64` |
| `SubWeapon` | Utu, Refined | Refined | `^numpad2` | `set_builder.lua:72-73` |
| `RuneMode` | Ignis .. Tenebrae (8) | Ignis | `^numpad3` | `rune_manager.lua:35-40` |
| `FastCast` | 0..80 step 10 | 30 | none | `midcast_watchdog.lua` |
| `AutoMedicine` | shared On/Off | persisted | `#numpad0` (from `config/COMMON_KEYBINDS.lua`) | `AutoMedicine.init` (`RUN_STATES.lua:109-112`) |

The UI readiness anchor for RUN is `state.RuneElement`
(`ui_lifecycle.lua:58-59`), a state RUN never creates: `smart_init` always
polls to its timeout. Since 2026-09-25 a pending HUD init from an older load
no longer creates a second HUD (`windower._ui_live_state` identity check, see
[UI overlay](../systems/ui-overlay.md)); the anchor itself is still wrong
(changing it to `RuneMode` was left for later: it changes RUN HUD timing).

## Commands

`job_self_command` (`RUN_COMMANDS.lua:71-184`): watchdog, dual-box internals,
CommonCommands, `ui`, `debugmidcast`, `cyclestate`, then RUN commands.

| Command | Effect | Handler |
|---------|--------|---------|
| `watchdog ...` | MidcastWatchdog | 84-87 |
| `altjobupdate` / `requestjob` | Dual-box job exchange (sender name forwarded since 2026-09-25) | 92-109 |
| common commands | as on every job | 114-125 |
| `ui ...` | UI toggles | 130-134 |
| `debugmidcast` | MidcastManager debug toggle | 139-149 |
| `cyclestate <State>` | `CycleHandler` | 158-161 |
| `aoe` | BLU rotation (`_G.BluMagicConfig` from `RUN_BLU_MAGIC`); without /BLU it prints "AOE needs the BLU subjob (RUN/BLU)" and casts nothing | 168-174 -> `aoe_manager.lua` `execute_aoe` |
| `rune` | `/ja "<RuneMode>" <me>` unless on recast | 177-183 -> `rune_manager.lua` `execute_rune` |

`job_state_change = LifecycleManager.state_change()` (194): HUD refresh only. It tests no state name except `Moving` (which has no description, so Mote and the UI-aware `cyclestate` both pass `Moving`), so it accepts the state key and the description alike.
No RUN command name is claimed by any alt-command config.

## Set names the code looks up

T = `_master/sets/run_sets.lua` (the only sets file in scope).

| Set | Looked up by | T |
|-----|--------------|---|
| `sets.Epeolatry`, `sets.Lycurgos` | `set_builder.lua:47` | 58, 61 |
| `sets.Utu`, `sets.Refined` | `set_builder.lua:73` | 64, 65 |
| `sets.idle`, `.PDT`, `.MDT` | Mote base, `set_builder.lua:155-158` | 72, 88, 91 |
| `sets.engaged`, `.PDT`, `.MDT` | Mote base, `set_builder.lua:117-120` | 98, 115, 118 |
| `sets.idle.Town`, `sets.Adoulin`, `sets.MoveSpeed` | BaseSetBuilder, movement | 384 (`= MoveSpeed`), 387, 379 |
| `sets.precast.JA` (empty) + 15 named JAs on `sets.FullEnmity` | Mote default precast | 139, 142, 163-200 |
| `sets.precast.FC` | Mote default precast | 221 |
| `sets.precast.WS`, `['Armor Break']` | Mote default precast | 242, 267 |
| `sets.precast.WS['Resolution']` and 4 other GS WS | Mote default precast | 260-264 (`set_combine(sets.precast.WS, {})`) |
| `sets.midcast.Enmity`, `.SIRDEnmity` | skill `Enmity`; aliases | 293, 296 |
| `sets.midcast['Flash']`, `['Foil']`, `['Crusade']` | skill `Flash`; P0 | 348-350 |
| `sets.midcast['Enhancing Magic']`, `['Regen']`, `['Phalanx']` | skill base, P0/P1 | 314, 331, 354 |
| `sets.midcast['Blue Magic']` | skill base | 372 |
| `sets.midcast.CureSelf`, `.CureOther` | `cure_set_builder.lua:34` | **absent** |
| `sets.midcast['Healing Magic']`, `['Divine Magic']` | `select_set` base | **absent** |
| `sets.buff.Doom` | DoomManager | 396 |

## Configuration

| File / key | Default | Where the default lives | Read by |
|------------|---------|-------------------------|---------|
| `<char>/config/run/RUN_STATES.lua` | see states | file | entry `user_setup` (hard-coded `Tetsouo/...`) |
| `<char>/config/run/RUN_KEYBINDS.lua` | 4 binds (+ `COMMON_KEYBINDS.lua`) | file | entry (deferred), `file_unload` |
| `<char>/config/run/RUN_CUSTOM.lua` | examples only | file | `KeybindManager` via `custom_states` |
| `<char>/config/run/RUN_LOCKSTYLE.lua` | 3 | file; factory fallback 1 | `LockstyleManager` (8 s after load, see above) |
| `<char>/config/run/RUN_MACROBOOK.lua` | book 15 page 1 | file; fallback book 1 page 1 | `MacrobookManager` (0.2 s after load, dual-box update) |
| `<char>/config/run/RUN_TP_CONFIG.lua` | Moonshade | file | nothing (entry line 107 commented) |
| `<char>/config/run/RUN_BLU_MAGIC.lua` | 5 AOE spells | file | entry `_G.BluMagicConfig` (102) -> `aoe_manager` |
| `RUN_WARD_CONFIG` | - | does not exist | commented reference, `Tetsouo_RUN.lua:108` |
| `RECAST_CONFIG`, `LOCKSTYLE_CONFIG`, `REGION_CONFIG`, UI config | - | shared | entry, `is_on_cooldown` |

## State & lifetime

- Module state: `aoe_manager` `SpellTracker`, lazy-load locals; all
  sandbox-local.
- `_G` written: the Mote hooks, `RUNKeybinds` (0.5 s after load),
  `LockstyleConfig`, `RECAST_CONFIG`, `RegionConfig`, the factory wrappers and
  exports. Nothing on `windower.*`, no events.
- Keybinds: bound 0.5 s after `user_setup`, unbound in `file_unload`
  (`Tetsouo_RUN.lua:268-270`). `bind_all` unbinds only keys that no longer
  apply, then binds.
- Coroutines: the 0.5 s keybind load; the scheduled keybind coroutine has no
  generation guard and is not cancelled by a reload, so a reload inside those
  0.5 s binds from the old sandbox (still open; no managed character plays RUN).
- Every subjob change ends in a `gs reload`; states reset to defaults. See
  [job change lifecycle](../architecture/job-change-lifecycle.md).

## Interactions

- Precast: `PrecastGuard`, `CooldownChecker`, `WSPrecastHandler`
  ([precast pipeline](../systems/precast-pipeline.md)); no `AbilityHelper`.
- Midcast: `MidcastManager`, `MidcastWatchdog`, `ENHANCING_MAGIC_DATABASE`
  ([midcast and buffs](../systems/midcast-and-buffs.md)).
- Commands: `CommonCommands`, `UICommands`, `WatchdogCommands`,
  `CycleHandler`, `LifecycleManager`
  ([commands and debug](../systems/commands-and-debug.md)).
- Factories, JobChangeManager, UI ([UI overlay](../systems/ui-overlay.md)),
  dual-box ([dualbox](../systems/dualbox.md)).
- [PLD](pld.md): the three shared-by-copy logic modules and the BLU config.

## Invariants & gotchas

- `RUNKeybinds` is nil during the first 0.5 s of every sandbox; anything that
  reads it (`file_unload`) must guard it, and does.
- The initial macrobook and lockstyle rely on the 0.2 s deferred gate in
  `user_setup` (see Load sequence), not on a `show_intro` side effect: moving
  that gate back to a synchronous call would make it fail again.
- An empty named set is not a fallback: `sets.precast.WS['X'] = {}` hides
  `sets.precast.WS`. Use `set_combine(sets.precast.WS, {})`.
- `sets.precast.JA = {}` is intentional: runes keep the tank set.
- `aoe_manager` captures `_G.BluMagicConfig` when first required.

## Extending

- Load the TP config in the entry next to the BLU one:
  `require('Tetsouo/config/run/RUN_TP_CONFIG')` (sets `_G.RUNTPConfig`).
- New weapon: add it to `state.MainWeapon` and `sets.<Name>`; if it takes no
  grip, extend the Lycurgos test in `apply_grip` (`set_builder.lua:64`).
- New midcast route: add a branch in `job_post_midcast` (`RUN_MIDCAST.lua:133-144`)
  and define `sets.midcast['<Skill>']`, or the route is a no-op.
- New state/bind: `RUN_STATES.lua` + `RUN_KEYBINDS.lua`, keeping `^numpad9` =
  HybridMode and `^numpad3` = RuneMode (see
  [keybinds and custom states](../systems/keybinds-and-custom.md)).

## Known issues

- No TP-bonus gear: `RUN_TP_CONFIG` is never loaded (`Tetsouo_RUN.lua:107`,
  `RUN_PRECAST.lua:44`).
- Cure III/IV get no midcast set (no CureSelf/CureOther) and Healing/Divine
  routes are no-ops (`RUN_MIDCAST.lua:61-68`, `cure_set_builder.lua:34`).
- UI readiness anchor `RuneElement` does not exist (`ui_lifecycle.lua:58-59`).
- `//gs c aoe` without /BLU: fixed 2026-09-25, `execute_aoe` now refuses with
  "AOE needs the BLU subjob (RUN/BLU)" instead of sending `/ma` the game
  refuses. The `unknown_spell` counter is left and only catches a misspelled
  name in the rotation config. To check in game.
- Fixed: the empty `auto_abilities` table and loop are gone from
  `RUN_PRECAST.lua`; the stale headers (entry, `run_functions.lua`,
  `RUN_IDLE`/`RUN_ENGAGED`, `RUN_KEYBINDS`, `RUN_STATES` Alt keys,
  `RUN_MIDCAST` XP mode, set builder "sub=empty") were rewritten by `b6c7dc6`.
- BLU dynamic rotation reads the main job's data
  (`_master/config/run/RUN_BLU_MAGIC.lua:104`), as on PLD.
- Fixed 2026-09-25: rune descriptions for Gelus, Tellus and Unda in
  `shared/data/job_abilities/run/run_subjob.lua` now match the state comments
  (`RUN_STATES.lua:82-87`) and BG-Wiki.
- Fixed by `22e1816` (KeybindManager): the old unbind-all loop of `bind_all` is
  gone.
- Duplicated with PLD: `aoe_manager`, `cure_set_builder`, `rune_manager`,
  `RUN_BLU_MAGIC`, `cooldown_exclusions`, the `job_midcast` skeleton
  (`RUN_MIDCAST.lua:52-70`).
- Dead: `RUNStates.validate`, `run_messages.lua` (no caller), commented
  WarpInit block (`Tetsouo_RUN.lua:220-230`).
- User docs: `docs/user/jobs/run/README.md` calls `cure_set_builder`
  "priority-based cure target selection", omits `SubWeapon`/`AutoMedicine`,
  and its setup steps do not mention the `Tetsouo/...` paths hard-coded in the
  entry; `docs/user/guides/commands.md:209-214` lists `aoe` as working.

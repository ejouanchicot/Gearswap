# SMN (Summoner) job

SMN is the 16th job area, added on 2026-07-29: the facade plus 12 hook
modules and one logic module under `shared/jobs/smn/functions/` (about 1 300
lines). Like every other job it has a generic template in `_master/`
(entry, `smn/`, flat `smn/sets/smn_sets.lua`), offered by the clone script
since 2026-09-28. Until then the entry, configs and sets existed only in the
author's gitignored live folder and overlay `_master/Tetsouo/`; the overlay
still keeps its own copy (modular set path), which wins for that character.
GearSwap loads SMN when that character's main job becomes
SMN. From then on Mote-Include calls its hooks on every action (including the
avatar's actions through the pet hooks), on status and buff changes, on
`//gs c` commands and on state cycles.

What SMN adds on top of the shared pipeline:

- **Blood Pact gear by category**: `blood_pact_classifier.lua` maps a pact
  name to `sets.pet_midcast.BPRage.{Physical,Magical,Hybrid,AstralFlow}` or
  `sets.pet_midcast.BPWard.{Buff,Debuff,Heal}`; the set is equipped in the
  master's `job_post_midcast` and again in `job_pet_midcast`.
- **Avatar idle**: with an avatar out the idle is `sets.idle.Avatar` (its
  `IdleMode` child when defined), without one the `IdleMode` set; a boolean
  state kept in sync with the Avatar's Favor buff lays
  `sets.buff["Avatar's Favor"]` on top; then the town set in town and
  `sets.MoveSpeed` while moving, through the shared `BaseSetBuilder` steps.
- **Commands**: `smn summon <avatar>`, `smn bp <pact>`, JA shortcuts
  (`smn apogee`, `smn astralflow`, ...), and a Summoning Magic skill-up loop
  (`skillup`: Siren, Release, repeat).
- **Carbuncle auto-summon** 10 s after `user_setup` when no pet is out.

Player pages: [start page](../../user/jobs/smn/README.md),
[modes](../../user/jobs/smn/states.md), [sets](../../user/jobs/smn/sets.md).

Re-verified against the code on 2026-09-28; idle, states and sets sections
updated on 2026-09-29. References name a file and a
function, not a line number. Commit hashes quoted in older versions of this
page predate the 2026-09-27 history rewrite and were removed.

## Deployment status

Verified on 2026-09-28:

| Piece | Where it exists | Versioned |
|-------|-----------------|-----------|
| Shared modules (`shared/jobs/smn/`, 14 files) | repo | yes |
| Blood Pact data (`shared/data/magic/SMN_SPELL_DATABASE.lua` + `summoning/*.lua`) | repo | yes |
| Reference notes (`docs/SMN_BLOOD_PACTS_REFERENCE.md`) | repo | yes |
| Alt command configs (`_master/config/alt/SMN_ALT_COMMANDS.lua`, `SMN_ALT_CUSTOM.lua`) | repo | yes |
| `character_db.lua`: SMN in the author's roster and in the all-jobs list | repo | yes |
| Generic entry `_master/entry/Tetsouo_SMN.lua` | repo | yes |
| Generic configs `SMN_STATES`, `SMN_KEYBINDS`, `SMN_CUSTOM`, `SMN_HUD`, `SMN_LOCKSTYLE`, `SMN_MACROBOOK`, `SMN_REFILL` (all comments: the common list) in `_master/config/smn/` | repo | yes |
| Generic flat sets `_master/sets/smn_sets.lua` | repo | yes |
| Author's copies: entry, `smn/`, modular `smn/sets/smn_sets.lua` | live folder and `_master/Tetsouo/` | **no** (gitignored) |
| `SMN_TP_CONFIG.lua`, `SMN_JA_DATABASE.lua`, SMN message formatter | nowhere | - |
| `clone_character.py` `ALL_VALID_JOBS` | 16 jobs, SMN included (no PUP) | yes |

Consequence: any clone can get SMN, from the generic template (manual job
selection offers it). A clone to the author's character, or any clone with
`--source Tetsouo`, takes the overlay's copies instead (the overlay's
`<job>/` tree wins over the generic flat file). The generic files are
the overlay's with `@author ejouanchicot` and the flat set include
`include('smn/sets/smn_sets.lua')`; the gear is the same. Until 2026-09-28 a
clone of any other character printed
`[WARN] No entry file for: SMN - these jobs will not load`.

## Files

| Path | Role |
|------|------|
| `_master/entry/Tetsouo_SMN.lua` (generic; the overlay `_master/Tetsouo/entry/` and the live folder hold the author's copy) | Entry: config preload, `get_sets`, `init_gear_sets`, `job_sub_job_change`, `user_setup` (Carbuncle auto-summon), `job_update` (HUD only), `file_unload` (stops the skill-up loop) |
| `shared/jobs/smn/functions/smn_functions.lua` | Facade: `message_buffs.lua`, the 12 hook files, `dualbox_manager`, a debug line |
| `shared/jobs/smn/functions/SMN_PRECAST.lua` | Guard, cooldown, WS; empty Blood Pact branch; `job_post_precast` (TP gear) |
| `shared/jobs/smn/functions/SMN_MIDCAST.lua` | `job_post_midcast`: Blood Pact set via the classifier, else `JOB_POST_MIDCAST_HANDLERS` by skill |
| `shared/jobs/smn/functions/SMN_PET_MIDCAST.lua` | `job_pet_midcast(spell, action, spellMap, eventArgs)`: re-equips the classified Blood Pact set and marks the event handled |
| `shared/jobs/smn/functions/SMN_AFTERCAST.lua` | Watchdog notify only |
| `shared/jobs/smn/functions/SMN_IDLE.lua` | `customize_idle_set`: `sets.idle.Avatar` with an avatar out, else `sets.idle[IdleMode]`; `sets.buff["Avatar's Favor"]` on top; town set, `sets.MoveSpeed` (`BaseSetBuilder`) |
| `shared/jobs/smn/functions/SMN_ENGAGED.lua` | `customize_melee_set` returns Mote's set |
| `shared/jobs/smn/functions/SMN_STATUS.lua` | `job_status_change = LifecycleManager.status_change()` |
| `shared/jobs/smn/functions/SMN_BUFFS.lua` | `DoomManager` + Avatar's Favor state sync |
| `shared/jobs/smn/functions/SMN_COMMANDS.lua` | `job_self_command`, skill-up loop, `job_state_change` (`LifecycleManager.state_change()`), `_G.cancel_smn_skillup_loop` |
| `shared/jobs/smn/functions/SMN_MOVEMENT.lua` | Empty `job_handle_equipping_gear` (movement gear is in `SMN_IDLE`) |
| `shared/jobs/smn/functions/SMN_LOCKSTYLE.lua` | Lazy `LockstyleManager.create('SMN', 'smn/display/SMN_LOCKSTYLE', 1, 'WHM')` |
| `shared/jobs/smn/functions/SMN_MACROBOOK.lua` | Lazy `MacrobookManager.create('SMN', ..., 'WHM', 1, 1)` |
| `shared/jobs/smn/functions/logic/blood_pact_classifier.lua` | Seven name sets, `classify`, `get_set`, `resolve` |
| `smn/keys/SMN_STATES.lua` | `IdleMode`, `CastingMode`, `AvatarFavor`, `Moving`, `FastCast`, AutoMedicine |
| `smn/keys/SMN_KEYBINDS.lua` | 3 binds handed to `KeybindManager.create('SMN', ...)` |
| `smn/keys/SMN_CUSTOM.lua` | Player modes and gear rules, commented examples only |
| `smn/display/SMN_HUD.lua` | Per-job HUD section / row order (empty = defaults) |
| `smn/display/SMN_LOCKSTYLE.lua` | `default = 1`, `by_subjob` (all 1), `get_style` |
| `smn/display/SMN_MACROBOOK.lua` | Book 1; page per subjob (WHM 1, SCH 2, RDM 3, BLM 4); empty `dualbox` |
| `smn/sets/smn_sets.lua` (generic, flat; `smn/sets/smn_sets.lua` in the author's overlay) | Skeleton sets (`empty_set()`), real gear only in `sets.precast.FC` |
| `shared/data/magic/SMN_SPELL_DATABASE.lua` + `summoning/*.lua` | Avatar / pact data for messages and `//gs c info` (SMN logic does not read it) |

The `config/` and `sets/` rows are relative to a character folder; their
templates are `_master/config/smn/` and `_master/sets/`. There is no SMN message formatter or message data file;
SMN prints through `MessageFormatter.show_info/show_success/show_error/show_debug`.

## How it works

### Load sequence

The entry chunk loads `LOCKSTYLE_CONFIG`, `REGION_CONFIG` and the UI config,
**and requires `JobChangeManager` and `UI_MANAGER` at file level**, before
`INIT_SYSTEMS` installs `ModuleCache`, so those two are pre-cache instances
([core lifecycle](../systems/core-lifecycle.md)). `get_sets()` includes
Mote-Include (which runs `user_setup()` and `init_gear_sets()` =
`include('smn/sets/smn_sets.lua')`), then `INIT_SYSTEMS`, `data_loader` and
the message hooks, sets `_G.LockstyleConfig`, `_G.UIConfig`,
`_G.RECAST_CONFIG`, calls `JobChangeManager.cancel_all()`, includes the facade
and registers the lockstyle cancel. It also marks each step for
`//gs c perf`. There is no TP config.

`user_setup()`:

1. `SMNStates.configure()`.
2. `require` of `SMN_KEYBINDS` -> global `SMNKeybinds`, `bind_all()` (3 binds
   plus the character's common keys), which calls `show_intro()`. The intro
   `require`s `SMN_MACROBOOK` and `SMN_LOCKSTYLE`, whose bodies define
   `select_default_macro_book` and `select_default_lockstyle`; the facade has
   not run yet, so without this the next step would find both nil. A failed
   require prints `[SMN] Keybinds failed to load: <error>`.
3. `KeybindUI.smart_init("SMN", UIConfig.init_delay)` (pre-cache instance).
4. `JobChangeManager.initialize()`, then `select_default_macro_book()` now and
   `select_default_lockstyle` after `initial_load_delay` (8 s).
5. A coroutine `initial_load_delay + 2` s later (10 s): if the main job is
   still SMN, the player is not `Dead` and `get_mob_by_target('pet')` finds
   nothing, `input /ma "Carbuncle" <me>`.
6. `pcall(require, 'shared/utils/dualbox/dualbox_manager')`.

### Precast

`job_precast`: `PrecastGuard`, then `CooldownChecker` by `action_type` (Blood
Pacts are `Ability` with their shared Rage / Ward recasts), cancel check,
`WSPrecastHandler.handle(spell, eventArgs, {})` for weaponskills only, and an
empty Blood Pact branch. `job_post_precast` applies TP gear (none).

- `PrecastGuard` routes Blood Pacts (`spell.type` `BloodPactRage` /
  `BloodPactWard`) to the generic ability check
  ([precast pipeline](../systems/precast-pipeline.md#precastguard-routing)).
- Mote uses `sets.precast[spell.type]` for a Blood Pact when it exists, else
  `sets.precast.JA` by name (`get_precast_set`). Since 2026-09-29 the set
  file defines `sets.precast.BloodPactRage` and `sets.precast.BloodPactWard`
  (empty skeletons, for "Blood Pact Ability Delay" / "Blood Pact Recast"
  gear), so a pact wears that set, refined by pact name when a child such as
  `sets.precast.BloodPactRage['Flaming Crush']` exists. The pact's damage /
  effect gear stays the pet midcast set below.
- Avatar summons are Summoning Magic and get
  `sets.precast.FC['Summoning Magic']`.
- A refused Blood Pact or ability goes through `CooldownChecker`, so
  `RecastAnnounce` can speak for it.

### Blood Pacts

```mermaid
sequenceDiagram
    participant U as Player
    participant GS as GearSwap
    participant M as Mote handle_actions
    participant J as SMN hooks
    U->>GS: /pet "Flaming Crush" <t>
    GS->>M: precast (ability path)
    M->>J: job_precast: guard, recast
    GS->>M: midcast (sent with the action)
    Note over M: default_midcast: sets.midcast['Flaming Crush'], else sets.midcast.BloodPactRage (spell.type), else nothing useful
    M->>J: job_post_midcast: classify -> sets.pet_midcast.BPRage.Hybrid, equip (wins)
    GS->>M: aftercast (master's action result)
    Note over M: default_aftercast re-equips idle unless pet_midaction()
    GS->>M: pet_midcast (the avatar readies the pact)
    M->>J: job_pet_midcast: resolve + equip the same set, eventArgs.handled = true
    Note over M: default_pet_midcast (sets.midcast.Pet) is skipped; it runs only for a pact the classifier does not know
    GS->>M: pet_aftercast -> default re-equips idle
```

- `BloodPactClassifier.classify` tests the lists in order: Astral Flow,
  Physical, Hybrid, Magical, Ward Buff, Ward Heal, Ward Debuff. `get_set`
  walks the dotted path under `sets.pet_midcast`; `resolve` returns
  `set, category`.
- `job_post_midcast` equips the set and prints the category under
  `debugmidcast`; an unknown pact is only reported in debug. Mote's own
  midcast choice (by pact name, then `sets.midcast.BloodPactRage` /
  `BloodPactWard` by `spell.type`) runs first and is overwritten by it.
- `job_pet_midcast(spell, action, spellMap, eventArgs)` sets
  `eventArgs.handled = true` once a Blood Pact set is on (since 2026-09-28),
  so Mote's `default_pet_midcast` (`get_pet_midcast_set`: `sets.midcast.Pet`,
  refined by pact name, spell map, type, then `OffenseMode` / `CastingMode`)
  no longer replaces it. For a pact the classifier does not know, nothing is
  equipped and `handled` stays false: `sets.midcast.Pet` still applies then.
- Whether the master's gear from midcast is still on when the pact fires
  depends on the order of the master's aftercast and the avatar's "readies"
  packet; the pet hook is the one that runs when the avatar acts.
- Compared with `res/job_abilities.lua`, every classified name exists. Not
  classified: `Raise II` (Cait Sith), wyvern breaths and `Cacodemonia`, which
  carry Blood Pact types in the resources. `Deconstruction` and
  `Chronoshift` are `BloodPactRage` in the resources but classified as
  `BPWard.Debuff`.

### Midcast (master magic)

Mote's default midcast runs first, then `job_post_midcast` dispatches on
`spell.skill` through `JOB_POST_MIDCAST_HANDLERS`: Summoning, Healing,
Divine, Dark with skill + spell; Enhancing with the Composure target (never
true on SMN); Elemental and Enfeebling with `mode_state = CastingMode` (P8
`base.Resistant`, which does not exist). Skills outside the table (Ninjutsu,
Blue Magic...) are routed by `MidcastFallback` from Mote's `cleanup_midcast`
([midcast and buffs](../systems/midcast-and-buffs.md#midcastfallback)).
Blood Pacts are abilities, so the fallback leaves them alone. `job_midcast`
only loads the modules.

### Aftercast, idle, engaged, status, buffs

- `job_aftercast` notifies the watchdog; Mote's `default_aftercast` returns to
  idle unless a pet action is in progress.
- `customize_idle_set` (since 2026-09-29):
  1. The idle (`select_mode_set`): with an avatar out (`pet.isvalid`) and
     `sets.idle.Avatar` a table, `sets.idle.Avatar[IdleMode]` when that child
     is a table (e.g. `sets.idle.Avatar.DT`), else `sets.idle.Avatar`.
     Without an avatar, `sets.idle[IdleMode]` (Normal / DT) when it is a
     table, else Mote's set. Mote re-runs `handle_equipping_gear` on
     `pet_change` (SMN has no `job_pet_change`), so the idle follows a summon
     or a release by itself.
  2. When `state.AvatarFavor` is true and `sets.buff["Avatar's Favor"]`
     exists, that set is laid over the idle with `set_combine` (before
     2026-09-29 Favor replaced the idle with `sets.idle.Avatar`).
  3. The result is passed to `BaseSetBuilder.select_idle_base_town`: in a
     city (Dynamis excluded) `sets.idle.Town` (in Adoulin `sets.Adoulin` if
     defined) goes on top of it.
  4. In town the set is returned as is; elsewhere
     `BaseSetBuilder.apply_movement` lays `sets.MoveSpeed` over it while
     `state.Moving` is `'true'`.
  Mote's defense / Kiting layers, applied to Mote's set before the hook, are
  dropped whenever the avatar set or an `IdleMode` set replaces it (the
  provided file defines all of them, so always). Mote's `sets.idle.Pet` is
  never reached while those sets exist.
- `customize_melee_set` returns Mote's set; `sets.engaged` is a flat
  skeleton.
- `job_status_change` is `LifecycleManager.status_change()` since 2026-09-28
  (Doom unlock, then an engage / disengage during an action is held until the
  aftercast). `job_buff_change` still calls `DoomManager` itself. On
  `Avatar's Favor` gain or loss, `job_buff_change`
  sets `state.AvatarFavor` to match and sends `gs c update`.

## Mote states

Created by `SMNStates.configure()`.

| State | Values | Default | Key | Read by |
|-------|--------|---------|-----|---------|
| `IdleMode` (replaced) | Normal, DT (the `Avatar` value was removed on 2026-09-29: the avatar idle is automatic) | Normal | `^numpad1` | `SMN_IDLE.lua` `select_mode_set` (also picks the `sets.idle.Avatar` child) |
| `CastingMode` (replaced) | Normal, Resistant | Normal | `^numpad2` | Mote default precast / midcast, the Elemental and Enfeebling handlers |
| `AvatarFavor` | boolean (`M(false, 'Avatar Favor')`) | false | `^numpad3` | `customize_idle_set` (lays `sets.buff["Avatar's Favor"]`), `job_buff_change` (sets it from the buff) |
| `Moving` | false, true | false | none | AutoMove writes it; `BaseSetBuilder.apply_movement` |
| `FastCast` | 0..80 | 0 | none | `midcast_watchdog.lua` fallback estimate |
| `AutoMedicine` | shared | persisted | `#numpad0` (from `COMMON_KEYBINDS.lua`) | `AutoMedicine.init` |

`cyclestate AvatarFavor` toggles the boolean (Mote's `cycle` acts as a toggle
on a boolean mode). The `AvatarFavor` HUD row has been reported missing; not
re-derived here.

## Commands

`job_self_command` lowercases the first word and tests, in order:
`altjobupdate` (forwards the sender name), `requestjob`, UI, `debugmidcast`,
`cyclestate`, watchdog, `skillup`, CommonCommands, `smn`. Anything else falls
through to Mote (and the alt fallback).

| Command | Effect |
|---------|--------|
| `smn summon <avatar>` | `input /ma "<Avatar>" <me>` for the 15 avatars and 8 spirits in `KNOWN_AVATARS` (case-insensitive, `caitsith` accepted) |
| `smn astralflow` / `astralconduit` / `apogee` / `siphon` / `manacede` / `favor` / `release` / `retreat` | `input /ja "<Name>" <me>` (`JA_SHORTCUTS`) |
| `smn assault` | `input /ja "Assault" <t>` |
| `smn bp <pact>` | `input /pet "<pact>" <target>`: `<me>` for a pact `classify` puts in `BPWard.Buff` / `BPWard.Heal`, `<t>` for every other pact and for an unknown name (`handle_bp`); the words are joined as typed, so the match is case-sensitive |
| `smn` alone / unknown word | usage line / `Unknown smn subcommand` |
| `skillup` / `skillup start|on|stop|off|status|<1-60>` | Toggle, start, stop or show the loop; a number sets `release_to_next_delay` and restarts |
| `debugmidcast`, `cyclestate`, `ui ...`, `watchdog ...`, common commands | as in the other jobs |

Skill-up loop: `start_skillup` reads `smn_skillup` from `_common/combat/TUNING.lua`
([Tuning](../systems/factories-and-helpers.md#tuning-sharedutilscoretuninglua); default `{avatar = 'Siren', release_after = 5.0}`) into
`SKILLUP_STATE.avatar` / `cast_to_release_delay` at each start.
`skillup_iteration` casts that avatar, schedules Release
`cast_to_release_delay` (5 s) later, then the next iteration
`release_to_next_delay` (1.5 s) after that. Every step checks
`skillup_valid` (active, same counter, main job SMN, not dead);
`stop_skillup` bumps the counter. `file_unload` calls
`_G.cancel_smn_skillup_loop` under `pcall`, so a reload or job change ends
the loop.

`job_state_change` is `LifecycleManager.state_change()`: skips `Moving`,
refreshes the HUD. It sends no `gs c update`: Mote's state commands and
`CycleHandler` both run `handle_update` right after the hook.

## Set names the code looks up

In the author's `smn/sets/smn_sets.lua`, every set except `sets.precast.FC`
is `empty_set()`, which returns `{}` (it returned all 16 slots set to `""`
until 2026-09-29).

| Set | Looked up by | In the file |
|-----|--------------|-------------|
| `sets.idle.Normal`, `.DT` | `customize_idle_set`, no avatar out | yes (skeleton) |
| `sets.idle.Avatar` (+ optional `[IdleMode]` child, e.g. `.DT`) | `customize_idle_set`, avatar out | yes (skeleton; no child) |
| `sets.buff["Avatar's Favor"]` | `customize_idle_set`, on top of the idle while `AvatarFavor` is true | yes (skeleton) |
| `sets.idle.Town` | `BaseSetBuilder.select_idle_base_town`, on top of the idle | yes (skeleton) |
| `sets.Adoulin` | same, in Adoulin | no (Adoulin gets `sets.idle.Town`) |
| `sets.MoveSpeed` | `BaseSetBuilder.apply_movement`, outside town while moving | yes (skeleton) |
| `sets.engaged` | Mote `get_melee_set` | yes (skeleton) |
| `sets.resting` | Mote resting | yes (skeleton) |
| `sets.precast.FC` (+ `['Summoning Magic']`, `['Healing Magic']`, `['Enhancing Magic']`) | Mote default precast | yes (real gear) |
| `sets.precast.WS` | Mote default precast | yes (skeleton) |
| `sets.precast.JA[...]` (7 SMN abilities) | Mote default precast | yes (skeleton) |
| `sets.precast.BloodPactRage`, `.BloodPactWard` | Mote precast for Blood Pacts (by `spell.type`) | yes (skeleton, since 2026-09-29) |
| `sets.midcast['Summoning Magic']`, `['Healing Magic']`, `['Enhancing Magic']`, `['Divine Magic']`, `['Dark Magic']`, `['Elemental Magic']`, `['Enfeebling Magic']` | `MidcastManager` base sets | yes (skeleton) |
| `sets.midcast.Cure`, `.Curaga`, `.Stoneskin`, `.Phalanx`, `.Refresh`, `.Haste` | `MidcastManager` P0 / P1 | yes (skeleton) |
| `sets.midcast['Elemental Siphon']` | Mote default midcast by name | yes (skeleton) |
| `sets.midcast.BloodPactRage`, `.BloodPactWard` | Mote default midcast by `spell.type` (then overwritten) | no |
| `sets.pet_midcast.BPRage.Physical/Magical/Hybrid/AstralFlow` | classifier | yes (skeleton) |
| `sets.pet_midcast.BPWard.Buff/Debuff/Heal` | classifier | yes (skeleton) |
| `sets.midcast.Pet` | Mote `default_pet_midcast`, only for a pact the classifier does not know (`job_pet_midcast` marks the others handled) | no |
| `sets.buff.Doom` | `DoomManager` | **no** |

GearSwap skips `""` items but `equip()` / `set_combine` merge slot by slot
(`set_merge`), so a `""` slot cancels the piece queued before it in the same
event (the old all-`""` `sets.MoveSpeed` cancelled the whole idle set while
running). With the empty sets, only the precast Fast Cast set is ever worn, and
it stays on after the first cast.

## Configuration

| File / key | Default | Read by |
|------------|---------|---------|
| `smn/keys/SMN_STATES.lua` | see states | entry `user_setup` |
| `smn/keys/SMN_KEYBINDS.lua` | 3 binds (+ `COMMON_KEYBINDS.lua`) | entry `user_setup`, `file_unload` |
| `smn/keys/SMN_CUSTOM.lua` | examples only | `KeybindManager` via `custom_states` |
| `smn/display/SMN_HUD.lua` | empty | HUD section / row order |
| `smn/display/SMN_LOCKSTYLE.lua` `default`, `by_subjob`, `get_style` | 1 everywhere | `LockstyleManager` (uses `get_style`) |
| `smn/display/SMN_MACROBOOK.lua` | book 1, pages 1-4 | `MacrobookManager` |
| `SKILLUP_STATE` knobs in `SMN_COMMANDS.lua` | Siren, 5.0 s cast-to-release, 1.5 s release-to-next | the loop; the first two from `_common/combat/TUNING.lua` `smn_skillup` at each start, `skillup <n>` changes the third |
| Carbuncle auto-summon delay | `initial_load_delay + 2.0` (10 s) | entry `user_setup` |
| Refill | `smn/inventory/SMN_REFILL.lua`, template all comments: the common list of `_common/inventory/REFILL_CONFIG.lua` (`shared/utils/inventory/refill/config_resolver.lua`) | `refill` |

## State & lifetime

- Module state: `SKILLUP_STATE` (module-local, dies on reload), lazy-load
  locals, the classifier's name sets.
- `_G` written: Mote hooks including `job_pet_midcast`, `SMNKeybinds`,
  `LockstyleConfig`, `UIConfig`, `RECAST_CONFIG`, `RegionConfig`,
  `cancel_smn_skillup_loop`, factory globals.
- `windower.*`: none from SMN code; no events registered.
- Coroutines: the Carbuncle summon (10 s) and the skill-up steps. The summon
  coroutine is not cancelled by a reload.
- Subjob change: Mote runs `user_setup()` in the current sandbox (states reset,
  keybinds rebound, a Carbuncle coroutine scheduled), then
  `job_sub_job_change` calls `on_job_change`, which reloads 2.0 s later; the
  new sandbox's `user_setup` schedules a second Carbuncle coroutine.
- `file_unload` stops the skill-up loop, cancels `JobChangeManager` timers; keys
  stay down for the next load.

## Interactions

- `PrecastGuard`, `CooldownChecker`, `RecastAnnounce`, `WSPrecastHandler`
  ([precast pipeline](../systems/precast-pipeline.md)); `MidcastManager`,
  `MidcastFallback`, `MidcastWatchdog`
  ([midcast and buffs](../systems/midcast-and-buffs.md)); `LifecycleManager`
  (status), `DoomManager` directly (buffs).
- Messages: `MessageFormatter` generic calls, `message_buffs` (included by the
  facade), `message_commands`; Blood Pact activation messages come from the
  shared ability handler through `SMN_SPELL_DATABASE`
  ([messages](../systems/messages.md)).
- Pet hooks are shared with [BST](bst.md) and PUP (`job_pet_midcast`).
- Factories, `JobChangeManager`, `CycleHandler`, `CommonCommands`, UI,
  dual-box.

## Invariants & gotchas

- SMN has two template copies: the generic one in `_master/` (versioned)
  and the author's overlay in `_master/Tetsouo/` (gitignored, modular sets).
  A template change goes into the generic files and, if the author's
  character should get it, into the overlay too.
- Blood Pact gear depends on the exact English pact name being in one of the
  classifier lists; keep them in sync with
  `docs/SMN_BLOOD_PACTS_REFERENCE.md`.
- `customize_idle_set` owns the whole idle choice; town and movement gear come
  from `BaseSetBuilder` there, after the avatar / `IdleMode` choice and the
  Avatar's Favor layer.
- A `""` slot is not neutral (it cancels the piece below it in a merge):
  `empty_set()` returns `{}`; never reintroduce `""` slots.
- The Carbuncle summon fires after every load in which no pet is out, not
  only the first one.

## Extending

- Templating SMN is done (2026-09-28): generic entry, `smn/`, flat
  sets and `ALL_VALID_JOBS`; a commented `SMN_REFILL.lua` since 2026-09-30.
- New Blood Pact: add the name to the right list in
  `blood_pact_classifier.lua` and to the reference doc.
- New Blood Pact category: a list and a branch in `classify`, and the set
  under `sets.pet_midcast`.
- Blood Pact delay gear: fill `sets.precast.BloodPactRage` /
  `BloodPactWard` (Mote picks them by `spell.type`).
- New JA shortcut: add it to `JA_SHORTCUTS`.

## For maintainers / AI

### Invariants to keep

- Blood Pact gear must be equipped in **both** `job_post_midcast` (the order)
  and `job_pet_midcast` (the avatar's action).
- `job_pet_midcast` sets `eventArgs.handled = true` after equipping a Blood
  Pact set; removing it lets Mote's `default_pet_midcast` equip
  `sets.midcast.Pet` over the pact set.
- `stop_skillup` must bump `SKILLUP_STATE.counter`: pending coroutines test it.
- Keep `_G.cancel_smn_skillup_loop` exported: the entry's `file_unload`
  calls it.

### Traps

- `Tetsouo/` in `.gitignore` also hides `_master/Tetsouo/`: `git status`
  never shows edits to the author's SMN copy (the generic files are tracked).
- Mote's `select_specific_set` checks `spell.skill` before `spell.type`; a
  Blood Pact has no skill, so `sets.midcast.BloodPactRage` is reachable by
  type.
- `state.AvatarFavor` is boolean: compare with `== true`, not `'On'`.
- The entry requires `JobChangeManager` and `UI_MANAGER` at file level,
  outside `ModuleCache`: a second instance exists after `INIT_SYSTEMS`.

### How to debug

- `//gs c debugmidcast`: prints `BP "<pact>" -> sets.pet_midcast.<category>`
  or `BP unclassified`, plus the `MidcastManager` walk for master magic.
- `//gs c trace on`: master-magic set choices.
- `//gs c skillup status`: loop state and delays.

### Offline testing (lua5.1)

- Syntax: from `data/`,
  `for f in shared/jobs/smn/functions/*.lua shared/jobs/smn/functions/logic/*.lua _master/entry/Tetsouo_SMN.lua _master/config/smn/*.lua _master/sets/smn_sets.lua; do luac5.1 -p "$f"; done`.
- Classifier: `lua5.1 -e "package.path='./?.lua;'..package.path; S=function(t) local s={} for _,v in ipairs(t) do s[v]=true end return setmetatable(s,{__index={contains=function(self,k) return rawget(self,k)==true end}}) end; local C=require('shared/jobs/smn/functions/logic/blood_pact_classifier'); print(C.classify('Flaming Crush'), C.classify('healing ruby'))"`
  prints `BPRage.Hybrid nil`, which shows the case sensitivity of `smn bp`.
- Pet midcast order: stub `equip` to record slots, call `job_pet_midcast`
  with an `eventArgs` table, then equip `sets.midcast.Pet` only if
  `eventArgs.handled` is false, as Mote's `handle_actions` does, and read the
  result.

## Known issues

- Fixed 2026-09-28: `sets.midcast.Pet` no longer overrides the Blood Pact set
  (`job_pet_midcast` marks the event handled); `SMN_STATUS` is the shared
  `LifecycleManager.status_change()`.
- Fixed 2026-09-29, checked offline, not yet in game: the idle follows the
  avatar (`sets.idle.Avatar` whenever one is out, its `IdleMode` child when
  defined), `IdleMode` lost its manual `Avatar` value, Avatar's Favor lays
  `sets.buff["Avatar's Favor"]` over the idle instead of replacing it, the set
  file gained `sets.precast.BloodPactRage` / `BloodPactWard`, and the unused
  `sets.weapons` / `sets.pet.Engaged` were removed. Offline, 16 combinations
  (field / town, avatar out or not, Normal / DT, Favor on / off) gave the
  expected layers and SMN loads.
- `smn bp` matches pact names case-sensitively: `smn bp healing ruby` is not
  recognised and targets `<t>`.
- The Carbuncle auto-summon is scheduled from both the old and the new
  sandbox on a subjob change and re-summons after every reload when no pet is
  out. PLAUSIBLE for the double cast.
- Skeleton sets blank every slot queued before them, so the Fast Cast set
  stays on. This includes `sets.MoveSpeed` and `sets.idle.Town`: once the
  idle sets hold gear, a still-skeleton `sets.MoveSpeed` blanks the whole idle
  set while moving.
- `file_unload` prints "[SMN] Skillup loop is not running" on unload when the
  loop was off, or raises under `pcall` when no `//gs c` command ran yet
  (`MessageFormatter` still nil in `SMN_COMMANDS.lua`).
- `Raise II` is not classified and gets no Blood Pact set.
- The author's live `smn/` has no `SMN_REFILL.lua` (the template's is all
  comments): `refill` uses the common list of `REFILL_CONFIG.lua` (the six
  medicines) and moves anything else back to the Case.
- No `SMN_JA_DATABASE.lua`; the ability message handler's job list has no SMN,
  so the first SMN job ability after a load walks every job database. Blood
  Pacts go straight to the SMN spell database by their type.
- Reported by an earlier audit, not re-derived here: 18 pact names collide
  with spell names in the shared spell namespace (`//gs c info` cannot show
  them, see [spell databases](../data/spell-databases.md#known-issues)), and
  the `AvatarFavor` row does not appear on the HUD.
- `CastingMode` has no effect (no `.Resistant` set); `sets.buff.Doom` is
  missing.
- Standards: `SMN_BUFFS` and `SMN_AFTERCAST` re-implement `LifecycleManager`
  (`SMN_STATUS` is the shared handler since 2026-09-28);
  `SMN_SPELL_DATABASE.can_use_pact` is broken and dead (known).
- The overlay's SMN configs and entry carry `@author Tetsouo`
  (convention: `ejouanchicot`); the generic copies are fixed.
- Not an issue: `Cacodemonia` (id 663, `mp_cost` 0) is not classified and
  should not be: it is not one of Diabolos' player pacts (BG-Wiki, Diabolos
  page, checked 2026-09-25).

# MNK (Monk) job

MNK was added on 2026-09-29. It is a thin job built on the shared systems,
like BLU and PUP: 11 hook modules plus 2 logic modules under
`shared/jobs/mnk/functions/`, a template entry point, seven config files and
one sets file. GearSwap loads it when the main job becomes MNK (the entry file
`<Character>_MNK.lua`, one `include` of `shared/entry/mnk.lua`, copied from
`_master/entry/Tetsouo_MNK.lua` by the clone script, which offers MNK in `ALL_VALID_JOBS`).

Player-facing pages: [hub](../../user/jobs/mnk/README.md),
[modes](../../user/jobs/mnk/states.md), [sets](../../user/jobs/mnk/sets.md).

What MNK adds on top of the shared pipeline:

- **Buff layers on the engaged set**: `sets.buff.Counterstance`,
  `sets.buff.Footwork`, `sets.buff.Impetus`, `sets.buff['Hundred Fists']`
  while the buff is up, in that order (later wins a shared slot). A layer may
  hold a child per HybridMode value, worn instead of it in that mode
  (`sets.buff.Impetus.DT`).
- **Buff layers on weaponskills**: with Impetus up, `sets.buff.Impetus` then
  `sets.precast.WS[name].Impetus` on every weaponskill; with Footwork up,
  `sets.buff.Footwork` then `sets.precast.WS[name].Footwork` on Dragon Kick
  and Tornado Kick only.
- **HybridMode Counter**: a third HybridMode value (`sets.engaged.Counter`),
  next to Normal and DT.
- Only `MainWeapon`: Monk has no off hand (Martial Arts, no Dual Wield trait).

MNK has no `//gs c` command of its own, no tier refinement, no automatic
ability and no job-specific message formatter. Job ability messages come from
the existing `shared/data/job_abilities/mnk/` database, weaponskill messages
from `H2H_WS_DATABASE.lua`.

## Files

| Path | Lines | Role |
|------|------:|------|
| `shared/entry/mnk.lua` | 190 | Entry (the same for every character; `<Char>_MNK.lua` and its template `_master/entry/Tetsouo_MNK.lua` are one `include` of it): config preload, `get_sets`, `job_sub_job_change`, `user_setup`, `job_update` (HUD), `init_gear_sets`, `file_unload` |
| `shared/jobs/mnk/functions/mnk_functions.lua` | 63 | Facade: includes `message_buffs` and the 11 hook files, requires `dualbox_manager`, debug line |
| `shared/jobs/mnk/functions/MNK_PRECAST.lua` | 119 | `job_precast` (guard, cooldown, WS handler) / `job_post_precast` (WS buff layers, then TP gear) |
| `shared/jobs/mnk/functions/MNK_MIDCAST.lua` | 75 | `job_midcast` (empty) / `job_post_midcast` (subjob magic via MidcastManager) |
| `shared/jobs/mnk/functions/MNK_AFTERCAST.lua` | 21 | `job_aftercast = LifecycleManager.aftercast()` |
| `shared/jobs/mnk/functions/MNK_IDLE.lua` | 30 | `customize_idle_set` -> `SetBuilder.build_idle_set` |
| `shared/jobs/mnk/functions/MNK_ENGAGED.lua` | 31 | `customize_melee_set` -> `SetBuilder.build_engaged_set` |
| `shared/jobs/mnk/functions/MNK_STATUS.lua` | 21 | `job_status_change = LifecycleManager.status_change()` |
| `shared/jobs/mnk/functions/MNK_BUFFS.lua` | 24 | `LifecycleManager.buff_change` + `refresh_after_buff` (the four layer buffs) |
| `shared/jobs/mnk/functions/MNK_COMMANDS.lua` | 115 | `job_self_command` router (shared commands only), `job_state_change = LifecycleManager.state_change()` |
| `shared/jobs/mnk/functions/MNK_MOVEMENT.lua` | 16 | Header only (`return {}`), kept for the 12-module layout |
| `shared/jobs/mnk/functions/MNK_LOCKSTYLE.lua` | 45 | Lazy `LockstyleManager.create('MNK', 'mnk/display/MNK_LOCKSTYLE', 1, 'WAR')` wrappers |
| `shared/jobs/mnk/functions/MNK_MACROBOOK.lua` | 37 | Lazy `MacrobookManager.create('MNK', 'mnk/display/MNK_MACROBOOK', 'WAR', 1, 1)` wrapper |
| `shared/jobs/mnk/functions/logic/buff_layers.lua` | 103 | `ENGAGED` / `WS` tables, `lay_engaged`, `ws_layers`, `equip_ws` |
| `shared/jobs/mnk/functions/logic/set_builder.lua` | 106 | Idle and engaged: base selection, buff layers, Mote layers, weapon, movement |
| `_master/config/mnk/MNK_STATES.lua` | 72 | Mote mode options, `MainWeapon`, `FastCast`, `AutoMedicine` |
| `_master/config/mnk/MNK_KEYBINDS.lua` | 33 | Data only: 4 entries (+ 1 commented per-weapon example) handed to `KeybindManager.create('MNK', ...)` |
| `_master/config/mnk/MNK_TP_CONFIG.lua` | 41 | `pieces` (Moonshade 250), `weapons` (commented Godhands 500 example), `get_weapon_bonus`, sets `_G.MNKTPConfig` |
| `_master/config/mnk/MNK_CUSTOM.lua` | 119 | Player modes and gear rules, commented examples only |
| `_master/config/mnk/MNK_HUD.lua` | 31 | HUD section / row order (empty = default) |
| `_master/config/mnk/MNK_LOCKSTYLE.lua` | 23 | `default = 1`, empty `by_subjob` |
| `_master/config/mnk/MNK_MACROBOOK.lua` | 26 | `default` book 1 page 1, empty `solo` and `dualbox` |
| `_master/config/mnk/MNK_REFILL.lua` | 42 | Refill list, every line commented (`extra`, `default`, `subjobs` examples): `//gs c rf` uses the common list of `REFILL_CONFIG.lua` until one is uncommented |
| `_master/sets/mnk_sets.lua` | 142 | Template sets: every set the code reads, all empty |

Shared files changed for MNK:

- `shared/utils/core/lifecycle_manager.lua`: `Impetus`, `Footwork`,
  `Hundred Fists` and `Counterstance` added to `GEAR_BUFFS`, so
  `refresh_after_buff` rebuilds the gear 0.1 s after one of them comes or
  goes. Another job that gets one of these buffs (Counterstance or Footwork
  as /MNK) also gets that `gs c update`; it is harmless there (the same set
  is rebuilt).
- Registries: `clone_character.py` (`ALL_VALID_JOBS`), `character_db.lua`
  (`ALL_JOBS`, and Tetsouo's job list: `validate()` wants every job assigned).

## How it works

### Load sequence

Same shape as BLU ([core lifecycle](../systems/core-lifecycle.md#how-a-job-file-boots)):
Mote-Include calls `user_setup()` and `init_gear_sets()` from inside
`include('Mote-Include.lua')`, before `INIT_SYSTEMS` and before the MNK hook
files exist.

`user_setup()`:

1. `MNKStates.configure()` creates the states (see [Mote states](#mote-states)).
2. `MNK_KEYBINDS` into the global `MNKKeybinds`, `bind_all()`; a failed require
   prints `[MNK] Keybinds failed to load: <error>`.
3. `KeybindUI.smart_init("MNK", init_delay)`.
4. `JobChangeManager.initialize()`; macro book at once, lockstyle after
   `LockstyleConfig.initial_load_delay`.
5. `pcall(require, 'shared/utils/dualbox/dualbox_manager')`.

`get_sets()` then sets `_G.LockstyleConfig`, `_G.RECAST_CONFIG`,
`_G.MNKTPConfig`, cancels pending job-change work, includes the facade and
registers `cancel_mnk_lockstyle_operations`.

`job_update`: `KeybindUI.update()`. `file_unload`:
`JobChangeManager.cancel_all()`, then `MNKKeybinds.unbind_all()`.

### Precast

`job_precast`: PrecastGuard, then `CooldownChecker` by action type (abilities
and spells), `eventArgs.cancel` return, then `WSPrecastHandler.handle(spell,
eventArgs, MNKTPConfig)`. Nothing MNK does can drop a tier, so there is no
exception before the cooldown check.

Mote's own precast picks the set: `sets.precast.JA[name]` for the job
abilities (Chakra, Boost, Counterstance...), `sets.precast.WS[name]` then
`[WeaponskillMode]` for weaponskills (Mote uses the OffenseMode value when
WeaponskillMode is Normal and has a value of that name), `sets.precast.FC` for
spells, `sets.precast.Waltz` for waltzes.

`job_post_precast` on a weaponskill: `BuffLayers.equip_ws(spell)` equips, in
this order, for each rule of `BuffLayers.WS` whose buff is up and whose list
names the weaponskill (no list = all): `sets.buff[buff]`, then
`sets.precast.WS[name][buff]`. Then `WSPrecastHandler.apply_tp_gear(spell)`,
last, so a layer cannot take the Moonshade slot. Trace line (`//gs c trace
on`): `WS <name> -> WS mode <m>, on top: ...`.

| Rule | Weaponskills | Why |
|------|--------------|-----|
| Impetus | all | The Bhikku Cyclas enhancement adds critical hit damage and accuracy per consecutive hit, and weaponskill hits count toward Impetus |
| Footwork | Dragon Kick, Tornado Kick | Footwork's boosts apply to those two (they use kick base damage under Footwork) |

The `.Impetus` / `.Footwork` children of a named WS set are layers laid on
Mote's pick (which may be the `.Acc` child); Mote itself never walks into them
(its WS walk only looks up the WeaponskillMode value). Under HybridMode the WS
layer is always the plain `sets.buff.Impetus`, never its HybridMode child.

### Midcast

Monk casts no magic of its own. Mote-Globals' `user_midcast` equips
`sets.midcast.FastRecast` first; Mote's default midcast picks by name / map /
skill / type (`sets.midcast.Utsusemi` for Utsusemi by its map).
`job_post_midcast`: `MidcastDeps.load()`, watchdog notify, return for anything
that is not magic with a skill, then `MidcastManager.select_set` on the skill,
with `target_func` / enhancing family for Enhancing Magic. `select_set` equips
nothing when `sets.midcast[skill]` does not exist, so the template's Utsusemi
keeps Mote's pick. Utsusemi: Ichi's shadow cancel is the shared one
(`shared/utils/midcast/utsusemi_shadows.lua`, from the universal spell hook).

### Idle and engaged

`logic/set_builder.lua` replaces Mote's base for both.

Idle (`build_idle_set`):

1. `BaseSetBuilder.select_idle_base`: `sets.idle.Town` / `sets.Adoulin` on
   top of the idle in a city; else `sets.idle[HybridMode]` when it is a table
   (`sets.idle.DT`; the template has no `sets.idle.Counter`, so Counter keeps
   Mote's base); else Mote's base.
2. Mote's defense / Kiting layers, `BaseSetBuilder.lay_weapon(result, 'main',
   MainWeapon)`.
3. `BaseSetBuilder.apply_movement` outside a city.

No buff layer on idle.

Engaged (`build_engaged_set`):

1. `select_engaged_base`: `sets.engaged`; `[OffenseMode]` when a table; then,
   for a HybridMode other than Normal, that level's `[HybridMode]`, else
   `sets.engaged[HybridMode]`, else the level itself. No `sets.engaged`:
   Mote's base.
2. `BuffLayers.lay_engaged`: `Counterstance`, `Footwork`, `Impetus`,
   `Hundred Fists`, each when `buffactive[buff]` and `sets.buff[buff]` is a
   table; the layer is `sets.buff[buff][HybridMode]` when that child is a
   table.
3. Mote's defense / Kiting layers, then MainWeapon.

Trace line: `ENGAGED <path>, on top: <layers>`.

The buff layers depend on `buffactive`, which is stale inside `buff_change`:
`job_buff_change` = `LifecycleManager.buff_change` + `refresh_after_buff(buff)`,
which sends `gs c update` 0.1 s after a gain or loss of one of the four
buffs (skipped under Doom and during an action, whose aftercast rebuilds).

## Mote states

Created by `MNKStates.configure()` on every `user_setup()`.

| State | Values (template) | Default | Key | Read by |
|-------|--------|---------|-----|---------|
| `MainWeapon` | Free | Free | `^numpad1` | `set_builder` (`lay_weapon`) |
| `WeaponskillMode` (Mote) | Normal, Acc | Normal | `^numpad2`, Mote's `@f9` | Mote WS set |
| `OffenseMode` (Mote) | Normal, Acc | Normal | `^numpad3`, Mote's `f9` | `select_engaged_base`; Mote's WS mode fallback |
| `HybridMode` (Mote) | Normal, DT, Counter | Normal | `^numpad9`, Mote's `^f9` | `select_idle_base`, `select_engaged_base`, `engaged_layer` |
| `FastCast` | 0..80 by 10 | 0 | none | midcast watchdog fallback estimate |
| `AutoMedicine` | ON, OFF | persisted | `#numpad0` (common key) | `AutoMedicine.init` |
| `IdleMode`, `CastingMode`, `RangedMode` (Mote) | Normal | Normal | Mote's F-keys | Mote only (`IdleMode` picks Mote's idle base, replaced outside a city under DT) |
| `CombatMode`, `TreasureMode` (optional states) | | Off | hidden | shared hooks |
| `JumpAuto` (created by `AutoJump.attach`) | Off, On | Off | `!numpad-`, shown on /DRG only | `auto_jump.lua`, through `WSPrecastHandler.handle` |

`^numpad2` holds WS Mode because Monk has no sub weapon (keybind rule: a job
without that weapon state reuses the slot). `^numpad3`, the signature slot,
is OffenseMode.

## Commands

`job_self_command` (`MNK_COMMANDS.lua`): `altjobupdate` / `requestjob`,
watchdog, `CommonCommands.handle_command(command, 'MNK',
table.unpack(args))`, UI, `debugmidcast`, `cyclestate`; anything else falls to
Mote and then to the alt commands.

## Set names the code looks up

T = `_master/sets/mnk_sets.lua`. Player version:
[sets.md](../../user/jobs/mnk/sets.md).

| Set | Looked up by | T |
|-----|--------------|---|
| `sets[MainWeapon]` | `WeaponResolver.set_for` | example only |
| `sets.MoveSpeed`, `sets.Kiting` | `BaseSetBuilder.apply_movement`, Mote Kiting | yes |
| `sets.Adoulin`, `sets.CombatMode` | `BaseSetBuilder`, Combat Mode | commented |
| `sets.buff.Counterstance`, `.Footwork`, `.Impetus`, `['Hundred Fists']` | `BuffLayers.lay_engaged` (Footwork, Impetus also `equip_ws`) | yes |
| `sets.buff.<buff>[HybridMode]` | `BuffLayers.engaged_layer` | `.Impetus.DT` commented |
| `sets.buff.Doom` | DoomManager | yes |
| `sets.precast.JA[<name>]` (Hundred Fists, Boost, Dodge, Focus, Chakra, Chi Blast, Counterstance, Footwork, Mantra, Formless Strikes, Perfect Counter, Impetus, Inner Strength) | Mote default precast | yes |
| `sets.precast.Waltz`, `['Healing Waltz']` | Mote | yes |
| `sets.precast.FC`, `.FC.Utsusemi` | Mote | yes |
| `sets.precast.WS`, `.WS.Acc`, `WS['Victory Smite' / 'Shijin Spiral' / 'Asuran Fists' / 'Raging Fists' / 'Howling Fist' / 'Tornado Kick' / 'Dragon Kick' / "Ascetic's Fury" / 'Final Heaven']` | Mote | yes |
| `sets.precast.WS[name].Impetus`, `.Footwork` | `BuffLayers.ws_layers` | Victory Smite / Ascetic's Fury `.Impetus`, Tornado Kick / Dragon Kick `.Footwork` |
| `sets.midcast.FastRecast`, `.Utsusemi` | Mote-Globals / Mote | yes |
| `sets.resting` | Mote | yes |
| `sets.idle`, `.DT`, `.Town` | `BaseSetBuilder.select_idle_base` | yes |
| `sets.engaged`, `.Acc`, `.DT`, `.Counter` | `select_engaged_base` | yes |
| `sets.engaged.Acc.DT`, `.Acc.Counter` | `select_engaged_base` | first commented |
| `sets.defense.PDT` / `.MDT` | Mote defense layer | no |
| `sets.TreasureHunter` | shared Treasure Hunter | commented |

## Configuration

| File / key | Default | Read by |
|------------|---------|---------|
| `<char>/mnk/MNK_STATES.lua` | see states | entry `user_setup` |
| `<char>/mnk/MNK_KEYBINDS.lua` | 4 entries | entry `user_setup`, `file_unload` |
| `<char>/mnk/MNK_TP_CONFIG.lua` `pieces`, `weapons` | Moonshade 250 | `WSPrecastHandler` |
| `<char>/mnk/MNK_CUSTOM.lua` | examples only | shared custom states |
| `<char>/mnk/MNK_HUD.lua` | empty | HUD |
| `<char>/mnk/MNK_LOCKSTYLE.lua`, `MNK_MACROBOOK.lua` | 1 / book 1 page 1 | factories |

## Game mechanics relied on (BG-Wiki)

| Mechanic | Page |
|----------|------|
| Impetus: +2 Attack / +1% crit rate per consecutive hit (cap 50), reset on a miss, weaponskill and counter hits counted; Bhikku Cyclas: crit damage +1% and Accuracy +2 per hit | [Impetus](https://www.bg-wiki.com/ffxi/Impetus) |
| Footwork: kick rate and kick damage up; its boosts apply to Dragon Kick and Tornado Kick | [Footwork](https://www.bg-wiki.com/ffxi/Footwork) |
| Counterstance: counter rate +45%, defense -50%; its gear counts when it is used | [Counterstance](https://www.bg-wiki.com/ffxi/Counterstance) |
| Hundred Fists: 45 s, attack delay -75%; Hesychast's Hose extend it (a `sets.precast.JA` piece) | [Hundred Fists](https://www.bg-wiki.com/ffxi/Hundred_Fists) |
| Chakra: HP from VIT and max HP, gear potency multiplier | [Chakra](https://www.bg-wiki.com/ffxi/Chakra) |
| No Dual Wield trait on Monk | [Monk](https://www.bg-wiki.com/ffxi/Monk) |
| Godhands TP Bonus +500 (commented example) | [Godhands](https://www.bg-wiki.com/ffxi/Godhands) |

## Left out on purpose (later options)

- No `sets.buff.Boost` layer: BG-Wiki does not say whether Boost gear (Ask
  Sash) must be worn when Boost is used or while the buff is up; a
  `sets.precast.JA.Boost` is provided, and `MNK_CUSTOM.lua` shows a
  `buff = 'Boost'` rule for players who want the waist while the buff is up.
- No automatic Impetus / Footwork / Boost before a weaponskill (AbilityHelper).
- No Perfect Counter, Inner Strength, Mantra or Formless Strikes layer while
  up: they are JA sets only.
- No per-WS opt-out of the generic Impetus layer.

## Needs an in-game check

- That `buffactive` names the four buffs as in `res/buffs.lua` (ids 61
  Counterstance, 46 Hundred Fists, 406 Footwork, 461 Impetus) and that the
  0.1 s rebuild puts the layer on / off.
- That the Impetus / Footwork WS layers land before the weaponskill (they are
  equipped from `job_post_precast`, like the TP bonus piece).
- The HUD rows of the four keys.

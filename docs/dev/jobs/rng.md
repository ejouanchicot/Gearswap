# RNG (Ranger) job

RNG was added on 2026-09-29. It is a thin job built on the shared systems,
like BLU and PUP: 12 hook modules plus 2 logic modules under
`shared/jobs/rng/functions/`, a template entry point, seven config files and
one sets file. GearSwap loads it when the main job becomes RNG (the entry file
`<Character>_RNG.lua`, made from `_master/entry/Tetsouo_RNG.lua` by the clone
script, which lists RNG in `ALL_VALID_JOBS`).

Player-facing pages: [hub](../../user/jobs/rng/README.md),
[modes](../../user/jobs/rng/states.md), [sets](../../user/jobs/rng/sets.md).

What RNG adds on top of the shared pipeline:

- **Three weapon states**: `RangeWeapon` (the bow / gun / crossbow, whose set
  also carries the ammo), `MainWeapon`, `SubWeapon`, all laid through
  `WeaponResolver` (`BaseSetBuilder.lay_weapon(result, 'range', ...)` for the
  range slot).
- **Ranged precast by Flurry**: `sets.precast.RA[RangedMode].Flurry1 / .Flurry2`
  picked by Mote from `classes.CustomRangedGroups`, which the shared
  `FlurryTracker` fills (the same helper COR uses).
- **Ranged midcast through MidcastManager** (skill `'RA'`, `state.RangedMode`),
  then **buff layers** on the shot: `sets.buff['Velocity Shot']`, `['Hover
  Shot']`, `['Decoy Shot']`, `['Unlimited Shot']`, `['Double Shot']`,
  `.Barrage`, each while its buff is up. Velocity Shot is also laid on the aim.
- **Ammo refill**: after a ranged attack, the worn ammo's quiver / pouch is
  opened when 15 or fewer are left (`QuiverManager`, like COR and THF).
- No job command.

## Files

| Path | Lines | Role |
|------|------:|------|
| `_master/entry/Tetsouo_RNG.lua` | 185 | Entry (template): config preload, `get_sets`, `job_sub_job_change`, `user_setup`, `job_update` (HUD), `init_gear_sets`, `file_unload` |
| `shared/jobs/rng/functions/rng_functions.lua` | 64 | Facade: includes `message_buffs` and the hook files, requires `dualbox_manager`, debug line |
| `shared/jobs/rng/functions/RNG_PRECAST.lua` | 123 | `job_precast` (guard, cooldown, Flurry groups, WS handler) / `job_post_precast` (TP gear, Velocity Shot layer on the aim); starts `FlurryTracker` at load |
| `shared/jobs/rng/functions/RNG_MIDCAST.lua` | 90 | `job_midcast` (empty) / `job_post_midcast` (ranged attack and subjob magic via MidcastManager, ranged buff layers) |
| `shared/jobs/rng/functions/RNG_AFTERCAST.lua` | 37 | `LifecycleManager.aftercast` + `QuiverManager.after_ranged_attack(spell, nil, nil, 15)` |
| `shared/jobs/rng/functions/RNG_IDLE.lua` | 31 | `customize_idle_set` -> `SetBuilder.build_idle_set` |
| `shared/jobs/rng/functions/RNG_ENGAGED.lua` | 31 | `customize_melee_set` -> `SetBuilder.build_engaged_set` |
| `shared/jobs/rng/functions/RNG_STATUS.lua` | 20 | `job_status_change = LifecycleManager.status_change()` |
| `shared/jobs/rng/functions/RNG_BUFFS.lua` | 22 | `job_buff_change = LifecycleManager.buff_change()` (no `refresh_after_buff`: no RNG buff swaps idle / engaged gear) |
| `shared/jobs/rng/functions/RNG_COMMANDS.lua` | 115 | `job_self_command` router, `job_state_change = LifecycleManager.state_change()` |
| `shared/jobs/rng/functions/RNG_MOVEMENT.lua` | 16 | Header only (`return {}`), kept for the 12-module layout |
| `shared/jobs/rng/functions/RNG_LOCKSTYLE.lua` | 45 | Lazy `LockstyleManager.create('RNG', 'config/rng/RNG_LOCKSTYLE', 1, 'WAR')` wrappers |
| `shared/jobs/rng/functions/RNG_MACROBOOK.lua` | 37 | Lazy `MacrobookManager.create('RNG', 'config/rng/RNG_MACROBOOK', 'WAR', 1, 1)` wrapper |
| `shared/jobs/rng/functions/logic/ranged.lua` | 85 | `PRECAST_LAYERS`, `MIDCAST_LAYERS`, `layers`, `equip_layers`, `prepare_precast` (Flurry groups), `start` (Flurry listener) |
| `shared/jobs/rng/functions/logic/set_builder.lua` | 117 | Idle and engaged: HybridMode, town, Mote layers, weapons (main, sub, range), movement |
| `_master/config/rng/RNG_STATES.lua` | 80 | Mote mode options, `RangeWeapon`, `MainWeapon`, `SubWeapon`, `FastCast`, `AutoMedicine` |
| `_master/config/rng/RNG_KEYBINDS.lua` | 42 | Data only: 7 entries (+ 3 commented weaponskill examples) handed to `KeybindManager.create('RNG', ...)` |
| `_master/config/rng/RNG_TP_CONFIG.lua` | 45 | `pieces` (Moonshade 250), empty `weapons`, `get_weapon_bonus`, sets `_G.RNGTPConfig` |
| `_master/config/rng/RNG_CUSTOM.lua` | 118 | Player modes and gear rules, commented examples only |
| `_master/config/rng/RNG_HUD.lua` | 31 | HUD section / row order (empty = default) |
| `_master/config/rng/RNG_LOCKSTYLE.lua` | 27 | `default = 1`, empty `by_subjob` |
| `_master/config/rng/RNG_MACROBOOK.lua` | 30 | `default` book 1 page 1, empty `solo` and `dualbox` |
| `_master/sets/rng_sets.lua` | 170 | Template sets: every set the code reads, all empty |
| `_master/config/alt/RNG_ALT_COMMANDS.lua` | - | Dual-box commands for an RNG partner (read by the main's alt system, not by the RNG job file) |

## How it works

### Load sequence

Same shape as BLU and PUP ([core lifecycle](../systems/core-lifecycle.md#how-a-job-file-boots)):
Mote-Include calls `user_setup()` and `init_gear_sets()` from inside
`include('Mote-Include.lua')`, before `INIT_SYSTEMS` and before the RNG hook
files exist. The entry sets `_G.RegionConfig` first, then loads the UI config
(`config_loader`).

`user_setup()`:

1. `RNGStates.configure()` creates the states (see [Mote states](#mote-states)).
2. `RNG_KEYBINDS` into the global `RNGKeybinds`, `bind_all()`; a failed
   require prints `[RNG] Keybinds failed to load: <error>`.
3. `KeybindUI.smart_init("RNG", init_delay)`. `ui_lifecycle.lua` waits for
   `state.RangeWeapon` before drawing the HUD of an RNG.
4. `JobChangeManager.initialize()`; macro book at once, lockstyle after
   `LockstyleConfig.initial_load_delay`.
5. `pcall(require, 'shared/utils/dualbox/dualbox_manager')`.

`get_sets()` then sets `_G.LockstyleConfig`, `_G.RECAST_CONFIG`,
`_G.RNGTPConfig`, cancels pending job-change work, includes the facade and
registers `cancel_rng_lockstyle_operations`.

`job_update`: `KeybindUI.update()`. `file_unload`:
`JobChangeManager.cancel_all()`, then `RNGKeybinds.unbind_all()`.

### Precast

`job_precast`: `PrecastGuard.guard_precast` -> cooldown check (abilities
`check_ability_cooldown`, spells `check_spell_cooldown`; a ranged attack has
no recast entry and is not checked) -> on a ranged attack
`Ranged.prepare_precast()` (`FlurryTracker.apply_ranged_groups`) ->
`WSPrecastHandler.handle(spell, eventArgs, RNGTPConfig)`. RNG has no tiered
spell and no redirect, so nothing runs before the cooldown check.

Mote then builds the precast set: `sets.precast.RA` -> `[RangedMode]` ->
`.Flurry1` / `.Flurry2` (`get_ranged_set`); `sets.precast.JA[name]`;
`sets.precast.WS[name][WeaponskillMode]` (for Archery / Marksmanship
weaponskills Mote uses `RangedMode` as the WS mode when WeaponskillMode is
Normal and contains that value; for the others, `OffenseMode`).

`job_post_precast`: `WSPrecastHandler.apply_tp_gear(spell)`; on a ranged
attack `Ranged.equip_layers(Ranged.PRECAST_LAYERS, 'PRECAST')`, i.e.
`sets.buff['Velocity Shot']` while Velocity Shot is up.

The Flurry listener (`FlurryTracker.start()`, an action-packet listener that
records whether Flurry I or II landed on this character) is started once per
load when `RNG_PRECAST.lua` is included.

Hachirin-no-Obi / Orpheus's Sash on Trueflight and Wildfire come from the
shared ElementalBelt hook (`elemental_belt.lua` lists both), with no line in
the RNG files.

### Midcast

`job_post_midcast` (after `MidcastDeps.load()` and the watchdog start):

- `spell.action_type == 'Ranged Attack'` (GearSwap gives `/ra` the type
  `'Misc'` and no skill): `MidcastManager.select_set({skill = 'RA', spell,
  mode_state = state.RangedMode})`, i.e. `sets.midcast.RA[RangedMode]` or
  `sets.midcast.RA`; then `Ranged.equip_layers(Ranged.MIDCAST_LAYERS,
  'MIDCAST')`.
- `spell.action_type == 'Magic'`: `select_set({skill = spell.skill, spell})`;
  Enhancing Magic also gets `target_func = MidcastManager.get_enhancing_target`
  and `database_func = EnhancingSPELLS.get_spell_family`. A skill with no
  `sets.midcast[skill]` keeps Mote's pick (`sets.midcast.Utsusemi` for
  Utsusemi).

### Ranged buff layers

`logic/ranged.lua`. `Ranged.layers(names)` walks the list in order and
`set_combine`s `sets.buff[name]` for every buff up in `buffactive` whose set
is a table; a later layer wins a slot. `equip_layers` equips the result and
writes one trace line (`PRECAST` / `MIDCAST Ranged buff layers: ...`).
`buffactive` is current inside precast / midcast events, so nothing is
scheduled.

| List | Order (lowest priority first) |
|------|------|
| `PRECAST_LAYERS` | Velocity Shot |
| `MIDCAST_LAYERS` | Velocity Shot, Hover Shot, Decoy Shot, Unlimited Shot, Double Shot, Barrage |

Why these (BG-Wiki): Velocity Shot gear "must remain equipped" and reduces
aiming delay and raises ranged attack, hence the aim and the shot; Double Shot
gear only counts while the ability is active; Barrage gear adds shots and
accuracy and the buff lasts until the next ranged attack; Unlimited Shot
feet remove its distance correction; Hover Shot and Decoy Shot have no
enhancing gear listed, their layers are for the player's own choice.

### Aftercast

`LifecycleManager.aftercast` ticks the watchdog, then
`QuiverManager.after_ranged_attack(spell, nil, nil, 15)`: after an
uninterrupted ranged attack, the worn ammo's own container
(`item_index.ammo_container`) is used when 15 or fewer of that ammo are left
across inventory and wardrobes. The container must be in the inventory.

### Idle and engaged

`logic/set_builder.lua` replaces Mote's base for both.

Idle (`build_idle_set`): `BaseSetBuilder.select_idle_base` (town set on top
of the idle in a city; outside, `sets.idle[HybridMode]` when it exists, so
`sets.idle.DT` under DT) -> `finish` (Mote's defense / Kiting layers,
`apply_weapons`) -> `BaseSetBuilder.apply_movement` outside a city.

Engaged (`build_engaged_set` / `select_engaged_base`): `sets.engaged`, then
`sets.engaged[OffenseMode]` when a table, then under HybridMode DT that
level's `.DT`, else `sets.engaged.DT`. Then `finish`. No `sets.engaged`: Mote's
base is kept.

`apply_weapons`: `BaseSetBuilder.lay_weapons` (MainWeapon, SubWeapon), then
`BaseSetBuilder.lay_weapon(result, 'range', RangeWeapon)`. `WeaponResolver`
drops an off-hand weapon when the player cannot dual wield: RNG is not in
`DW_MAIN`, so only /NIN (10+) and /DNC (20+) keep it; otherwise
`sets.SingleWield.sub` (or nothing) takes its place.

Dual Wield tiers (`sets.DW.*`), Treasure Hunter and Combat Mode (which locks
`main`, `sub` and `range`) are shared hooks on `handle_equipping_gear` and
need nothing from RNG.

Trace lines (`//gs c trace on`): `IDLE town|field, range weapon <v>` and
`ENGAGED <path>, range weapon <v>`.

## Mote states

Created by `RNGStates.configure()` on every `user_setup()`.

| State | Values (template) | Default | Key | Read by |
|-------|--------|---------|-----|---------|
| `MainWeapon` | Free | Free | `^numpad1` | `BaseSetBuilder.lay_weapons` |
| `RangeWeapon` | Free | Free | `^numpad2` | `SetBuilder.apply_weapons` |
| `RangedMode` (Mote) | Normal, Acc | Normal | `^numpad3`, Mote's `!f9` | Mote `get_ranged_set` (precast / midcast), `select_set` RA, Mote WS mode for Archery / Marksmanship |
| `HybridMode` (Mote) | Normal, DT | Normal | `^numpad9`, Mote's `^f9` | `select_idle_base`, `select_engaged_base` |
| `SubWeapon` | Free | Free | `^numpad4` | `BaseSetBuilder.lay_weapons` |
| `OffenseMode` (Mote) | Normal, Acc | Normal | `^numpad5`, Mote's `f9` | `select_engaged_base`; Mote WS mode for melee weaponskills |
| `WeaponskillMode` (Mote) | Normal, Acc | Normal | `^numpad6`, Mote's `@f9` | Mote `get_weaponskill_set` |
| `FastCast` | 0..80 by 10 | 0 | none | midcast watchdog fallback estimate |
| `AutoMedicine` | ON, OFF | persisted | `#numpad0` (common key) | `AutoMedicine.init` |
| `IdleMode`, `CastingMode` (Mote) | Normal | Normal | Mote's F-keys | Mote only |
| `CombatMode`, `TreasureMode` (optional states) | | Off | hidden | shared hooks |

## Commands

`job_self_command` (`RNG_COMMANDS.lua`): `altjobupdate` / `requestjob`,
watchdog, `CommonCommands.handle_command(command, 'RNG',
table.unpack(args))`, UI, `debugmidcast`, `cyclestate`; anything else falls
to Mote and then to the alt commands. No RNG command.

## Set names the code looks up

T = `_master/sets/rng_sets.lua`. Player version:
[sets.md](../../user/jobs/rng/sets.md).

| Set | Looked up by | T |
|-----|--------------|---|
| `sets[RangeWeapon]`, `sets[MainWeapon]`, `sets[SubWeapon]` | `WeaponResolver.set_for` | examples only |
| `sets.SingleWield` | `WeaponResolver` | commented |
| `sets.MoveSpeed`, `sets.Kiting` | `BaseSetBuilder.apply_movement`, Mote Kiting | yes |
| `sets.Adoulin` | `BaseSetBuilder` | commented |
| `sets.buff['Velocity Shot']`, `['Hover Shot']`, `['Decoy Shot']`, `['Unlimited Shot']`, `['Double Shot']`, `.Barrage` | `Ranged.layers` | yes |
| `sets.buff.Doom` | DoomManager | yes |
| `sets.precast.RA`, `.Flurry1`, `.Flurry2` (and `[RangedMode]`) | Mote `get_ranged_set` | first three; `.Acc` commented |
| `sets.precast.JA[<name>]` (Eagle Eye Shot, Bounty Shot, Scavenge, Camouflage, Shadowbind, Sharpshot) | Mote | yes |
| `sets.precast.Waltz`, `['Healing Waltz']` | Mote | yes |
| `sets.precast.FC`, `.FC.Utsusemi` | Mote | yes |
| `sets.precast.WS`, `.WS.Acc`, `WS['Last Stand' / 'Wildfire' / 'Trueflight' / 'Coronach' / "Jishnu's Radiance" / 'Empyreal Arrow' / 'Apex Arrow' / 'Savage Blade' / 'Evisceration']` | Mote | yes |
| `sets.midcast.RA`, `.RA.Acc` | `MidcastManager.select_set` (skill `'RA'`) | yes |
| `sets.midcast.FastRecast`, `.Utsusemi` | Mote-Globals / Mote | yes |
| `sets.resting` | Mote | yes |
| `sets.idle`, `.DT`, `.Town` | `select_idle_base` | yes |
| `sets.engaged`, `.Acc`, `.DT` (and `.Acc.DT`) | `select_engaged_base` | first three |
| `sets.DW.NoHaste` .. `.MaxHaste` | shared Dual Wield tiers | commented |
| `sets.defense.PDT` / `.MDT` | Mote defense layer | no |
| `sets.TreasureHunter` | shared Treasure Hunter | commented |

## Configuration

| File / key | Default | Read by |
|------------|---------|---------|
| `<char>/config/rng/RNG_STATES.lua` | see states | entry `user_setup` |
| `<char>/config/rng/RNG_KEYBINDS.lua` | 7 entries | entry `user_setup`, `file_unload` |
| `<char>/config/rng/RNG_TP_CONFIG.lua` `pieces`, `weapons` | Moonshade 250 | `WSPrecastHandler` |
| `<char>/config/rng/RNG_CUSTOM.lua` | examples only | shared custom states |
| `<char>/config/rng/RNG_HUD.lua` | empty | HUD |
| `<char>/config/rng/RNG_LOCKSTYLE.lua`, `RNG_MACROBOOK.lua` | 1 / book 1 page 1 | factories |

Registries that list RNG: `clone_character.py` `ALL_VALID_JOBS`,
`character_db.lua` `ALL_JOBS`, `UI_FORMATTER.lua` `job_titles`,
`ui_lifecycle.lua` `are_states_ready`. No character of `character_db.lua`
plays RNG yet.

## Left out on purpose (later options)

- Ammo protection (refusing a shot or weaponskill that would spend a rare
  ammo outside Unlimited Shot).
- Aftermath of the ranged relic / mythic / empyrean weapons.
- Overkill, Flashy Shot, Stealth Shot, Sharpshot and Camouflage as gear
  layers (they are only JA precast sets, or nothing).
- Unlimited Shot on ranged weaponskills: BG-Wiki does not say whether a
  weaponskill consumes it, so the layer is on `/ra` only.

## Needs an in-game check

- `sets.precast.RA.Flurry1` / `.Flurry2`: FlurryTracker reads Flurry I / II
  from the action packet (COR has used it since 2026-09-25).
- The Velocity Shot layer on the aim: a Snapshot-type effect, so it must be on
  at precast; check with `//gs c trace on` that the body stays through the
  shot.
- The refill threshold (15) against a Barrage volley.
- TP bonus of a ranged weapon: `TPBonusCalculator` reads main / sub only, so a
  range weapon listed in `RNG_TP_CONFIG.weapons` is not counted.
- Custom rules (`RNG_CUSTOM.lua`) never touch a ranged attack
  (`custom_guards.lua` skips `'Ranged Attack'`).

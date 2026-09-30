# NIN (Ninja) job

NIN was added on 2026-09-29. It is a thin job built on the shared systems,
like BLU and PUP: 11 hook modules plus 2 logic modules under
`shared/jobs/nin/functions/`, a template entry point, seven config files and
one sets file. GearSwap loads it when the main job becomes NIN (the entry file
`<Character>_NIN.lua`, made from `_master/entry/Tetsouo_NIN.lua` by the clone
script).

Player-facing pages: [hub](../../user/jobs/nin/README.md),
[modes](../../user/jobs/nin/states.md), [sets](../../user/jobs/nin/sets.md).

What NIN adds on top of the shared pipeline:

- **Ninjutsu by family**: every Ninjutsu spell is routed to `MidcastManager`
  with its family (`Utsusemi`, `Migawari`, `Elemental`, `Enfeebling`,
  `Enhancing`) as the spell type (`logic/ninjutsu.lua`).
- **Magic Burst mode** for elemental ninjutsu: `state.MagicBurstMode` On hands
  `mode_value = 'MagicBurst'` to `MidcastManager`, which finds
  `sets.midcast.Ninjutsu.Elemental.MagicBurst`.
- **Futae layer**: `sets.buff.Futae` on top of an elemental ninjutsu while the
  buff is up.
- **Engaged buff layers**: `sets.buff.Yonin`, `.Innin`, `.Sange`,
  `.Issekigan` while the buff is up.
- **Night movement speed**: `sets.MoveSpeed.Night` instead of `sets.MoveSpeed`
  from 17:00 to 7:00 Vana'diel time.

NIN has no `//gs c` command of its own, no tier refinement and no job-specific
message formatter. Everything else is shared: Utsusemi: Ichi's shadow cancel
(`utsusemi_shadows.lua`, from the universal spell hook), Monomi / Tonko through
`//gs c stealth`, Obi / Orpheus on elemental ninjutsu and on Blade: Chi / Teki
/ To / Ei (ElementalBelt), Dual Wield tiers, Treasure Hunter, Combat Mode, JA
and spell messages (`NIN_JA_DATABASE`, `NINJUTSU_DATABASE`).

## Files

| Path | Lines | Role |
|------|------:|------|
| `_master/entry/Tetsouo_NIN.lua` | 186 | Entry (template): config preload, `get_sets`, `job_sub_job_change`, `user_setup`, `job_update` (HUD), `init_gear_sets`, `file_unload` |
| `shared/jobs/nin/functions/nin_functions.lua` | 64 | Facade: includes `message_buffs` and the 11 hook files, requires `dualbox_manager`, debug line |
| `shared/jobs/nin/functions/NIN_PRECAST.lua` | 108 | `job_precast` (guard, cooldown, WS handler) / `job_post_precast` (TP gear) |
| `shared/jobs/nin/functions/NIN_MIDCAST.lua` | 96 | `job_midcast` (empty) / `job_post_midcast` (Ninjutsu by family + Futae, other skills on their own chain) |
| `shared/jobs/nin/functions/NIN_AFTERCAST.lua` | 21 | `job_aftercast = LifecycleManager.aftercast()` |
| `shared/jobs/nin/functions/NIN_IDLE.lua` | 30 | `customize_idle_set` -> `SetBuilder.build_idle_set` |
| `shared/jobs/nin/functions/NIN_ENGAGED.lua` | 31 | `customize_melee_set` -> `SetBuilder.build_engaged_set` |
| `shared/jobs/nin/functions/NIN_STATUS.lua` | 21 | `job_status_change = LifecycleManager.status_change()` |
| `shared/jobs/nin/functions/NIN_BUFFS.lua` | 25 | `LifecycleManager.buff_change` + `refresh_after_buff` (Yonin, Innin, Sange, Issekigan) |
| `shared/jobs/nin/functions/NIN_COMMANDS.lua` | 116 | `job_self_command` router, `job_state_change = LifecycleManager.state_change()` |
| `shared/jobs/nin/functions/NIN_MOVEMENT.lua` | 16 | Header only (`return {}`), kept for the 12-module layout |
| `shared/jobs/nin/functions/NIN_LOCKSTYLE.lua` | 45 | Lazy `LockstyleManager.create('NIN', 'nin/NIN_LOCKSTYLE', 1, 'WAR')` wrappers |
| `shared/jobs/nin/functions/NIN_MACROBOOK.lua` | 37 | Lazy `MacrobookManager.create('NIN', 'nin/NIN_MACROBOOK', 'WAR', 1, 1)` wrapper |
| `shared/jobs/nin/functions/logic/ninjutsu.lua` | 74 | `family(name)`, `midcast_config(spell)`, `futae_layer(family)` |
| `shared/jobs/nin/functions/logic/set_builder.lua` | 151 | Idle and engaged: base, buff layers, Mote layers, weapons, movement (night set) |
| `_master/config/nin/NIN_STATES.lua` | 77 | Mote mode options, `MainWeapon`, `SubWeapon`, `MagicBurstMode`, `FastCast`, `AutoMedicine` |
| `_master/config/nin/NIN_KEYBINDS.lua` | 39 | Data only: 6 entries (+ 2 commented per-weapon examples) handed to `KeybindManager.create('NIN', ...)` |
| `_master/config/nin/NIN_TP_CONFIG.lua` | 42 | `pieces` (Moonshade 250), empty `weapons`, `get_weapon_bonus`, sets `_G.NINTPConfig` |
| `_master/config/nin/NIN_CUSTOM.lua` | 117 | Player modes and gear rules, commented examples only |
| `_master/config/nin/NIN_HUD.lua` | 31 | HUD section / row order (empty = default) |
| `_master/config/nin/NIN_LOCKSTYLE.lua` | 27 | `default = 1`, empty `by_subjob` |
| `_master/config/nin/NIN_MACROBOOK.lua` | 30 | `default` book 1 page 1, empty `solo` and `dualbox` |
| `_master/sets/nin_sets.lua` | 173 | Template sets: every set the code reads, all empty |

Shared files changed for NIN (registries only):

- `shared/utils/core/lifecycle_manager.lua`: `Yonin`, `Innin`, `Sange`,
  `Issekigan` added to `GEAR_BUFFS`, so `refresh_after_buff` rebuilds the gear
  0.1 s after one of them comes or goes. No other job gets those buffs.
- `shared/utils/ui/ui_lifecycle.lua`: `are_states_ready` waits for
  `state.MagicBurstMode` on NIN.
- `shared/utils/ui/UI_FORMATTER.lua`: `NIN = "Ninja Settings"` title.
- `clone_character.py` (`ALL_VALID_JOBS`) and `character_db.lua` (`ALL_JOBS`).

## How it works

### Load sequence

Same shape as BLU ([core lifecycle](../systems/core-lifecycle.md#how-a-job-file-boots)).
`user_setup()`: `NINStates.configure()`, `NIN_KEYBINDS` into the global
`NINKeybinds` and `bind_all()` (a failed require prints `[NIN] Keybinds failed
to load: <error>`), `KeybindUI.smart_init("NIN", init_delay)`,
`JobChangeManager.initialize()` with the macro book at once and the lockstyle
after `LockstyleConfig.initial_load_delay`, then the dual-box manager.

`get_sets()` sets `_G.LockstyleConfig`, `_G.RECAST_CONFIG`, `_G.NINTPConfig`,
cancels pending job-change work, includes the facade and registers
`cancel_nin_lockstyle_operations`. `job_update` refreshes the HUD.
`file_unload`: `JobChangeManager.cancel_all()`, then `NINKeybinds.unbind_all()`.

### Precast

`job_precast`: PrecastGuard, then `CooldownChecker` by action type (abilities
and spells, Utsusemi included), `eventArgs.cancel` return, then
`WSPrecastHandler.handle(spell, eventArgs, NINTPConfig)`. `job_post_precast`
lays the TP bonus piece. The sets are Mote's picks: `sets.precast.FC` (and
`.FC.Utsusemi` by Mote's `Utsusemi` spell map), `sets.precast.JA[name]`,
`sets.precast.RA`, `sets.precast.WS[name]` with its `WeaponskillMode` child.

No tier exception before the cooldown check: a San / Ni on recast is
cancelled, it does not drop to the tier below. The shared `TierRefiner` cannot
do it as it stands (see [Known issues](#known-issues)).

### Midcast

Mote-Globals equips `sets.midcast.FastRecast` first; Mote's default midcast
then picks by name / map / skill (`sets.midcast.Utsusemi` by the map,
`sets.midcast.Ninjutsu` by the skill). `job_post_midcast`: `MidcastDeps.load()`,
watchdog notify, return for anything that is not magic with a skill, then:

- **Ninjutsu**: `Ninjutsu.midcast_config(spell)` gives
  `{skill = 'Ninjutsu', spell, database_func = Ninjutsu.family}` plus
  `mode_value = 'MagicBurst'` for an `Elemental` spell under MagicBurstMode On.
  `MidcastManager.select_set` walks P0-P9 with that type:
  P0 `sets.midcast['Katon: San']` (and its `.MagicBurst` child),
  P3 `sets.midcast.Ninjutsu.Elemental.MagicBurst`,
  P6 the type at the root (`sets.midcast.Utsusemi`, `sets.midcast.Migawari`),
  P7 the type under the skill (`sets.midcast.Ninjutsu.Elemental`,
  `.Enfeebling`, `.Enhancing`), P9 `sets.midcast.Ninjutsu`. Then
  `Ninjutsu.futae_layer(family)`: `equip(sets.buff.Futae)` for an elemental
  spell while `buffactive.Futae`.
- **Any other skill** (none of the four subs casts, but a /RDM or /WHM
  would): `select_set` on the skill, with `target_func` and the enhancing
  family for Enhancing Magic.

After it, in `cleanup_midcast`, the shared ElementalBelt lays Obi / Orpheus on
elemental ninjutsu, then the Treasure Hunter action overlay, then the player's
custom gear.

Families (`Ninjutsu.family`, the name before the colon):

| Family | Spells |
|--------|--------|
| `Utsusemi` | Utsusemi: Ichi / Ni / San |
| `Migawari` | Migawari: Ichi |
| `Elemental` | Katon, Suiton, Raiton, Doton, Huton, Hyoton (Ichi / Ni / San) |
| `Enfeebling` | Kurayami, Hojo, Dokumori, Jubaku (Ichi / Ni / San), Aisha, Yurin |
| `Enhancing` | anything else: Tonko, Monomi, Myoshu, Kakka, Gekka, Yain |

The type names were chosen so the root lookup (P6) only hits the two sets
meant to live at the root: nothing names `sets.midcast.Elemental`,
`.Enfeebling` or `.Enhancing`, so the walk goes on to the skill's child (P7).

### Idle and engaged

`logic/set_builder.lua` replaces Mote's base for both.

Idle (`build_idle_set`):

1. `BaseSetBuilder.select_idle_base`: town set on top of the idle in a city,
   else `sets.idle[HybridMode]` (`sets.idle.DT`), else Mote's base.
2. Mote's defense / Kiting layers, `BaseSetBuilder.lay_weapons` (MainWeapon,
   SubWeapon).
3. Outside a city, `SetBuilder.apply_movement`: while moving,
   `sets.MoveSpeed.Night` when it is a table and `world.time` (minutes since
   Vana'diel midnight) is >= 1020 or < 420; otherwise
   `BaseSetBuilder.apply_movement` (`sets.MoveSpeed`).

Engaged (`build_engaged_set`): `select_engaged_base` takes `sets.engaged`,
then `sets.engaged[OffenseMode]` when a table, then under HybridMode DT that
level's `.DT`, else `sets.engaged.DT`. Then `lay_buff_layers` over
`ENGAGED_BUFFS = {'Yonin', 'Innin', 'Sange', 'Issekigan'}` (each
`sets.buff[name]` whose buff is in `buffactive`, in that order), Mote's
layers, the weapons. The shared Dual Wield tier pieces go on after, from
`dual_wield.lua`'s wrapper of `handle_equipping_gear`.

Trace line (`//gs c trace on`): `ENGAGED <path>, on top: <layers>`.

Buffs: `job_buff_change` = `LifecycleManager.buff_change` +
`refresh_after_buff(buff)`, which sends `gs c update` 0.1 s after a gain or
loss of a `GEAR_BUFFS` buff (inside `buff_change`, `buffactive` still holds the
old list).

## Mote states

Created by `NINStates.configure()` on every `user_setup()`.

| State | Values (template) | Default | Key | Read by |
|-------|--------|---------|-----|---------|
| `MainWeapon` | Free | Free | `^numpad1` | `BaseSetBuilder.lay_weapons` |
| `SubWeapon` | Free | Free | `^numpad2` | `BaseSetBuilder.lay_weapons` |
| `MagicBurstMode` | Off, On | Off | `^numpad3` | `Ninjutsu.midcast_config` |
| `OffenseMode` (Mote) | Normal, Acc | Normal | `^numpad4`, Mote's `f9` | `select_engaged_base`; Mote's WS mode fallback |
| `WeaponskillMode` (Mote) | Normal, Acc | Normal | `^numpad5`, Mote's `@f9` | Mote's WS set |
| `HybridMode` (Mote) | Normal, DT | Normal | `^numpad9`, Mote's `^f9` | `select_idle_base`, `select_engaged_base` |
| `FastCast` | 0..80 by 10 | 0 | none | midcast watchdog fallback estimate |
| `AutoMedicine` | ON, OFF | persisted | `#numpad0` (common key) | `AutoMedicine.init` |
| `IdleMode`, `CastingMode`, `RangedMode` (Mote) | Normal | Normal | Mote's F-keys | Mote only |
| `CombatMode`, `TreasureMode` (optional states) | | Off | hidden | shared hooks |

## Commands

`job_self_command` (`NIN_COMMANDS.lua`): `altjobupdate` / `requestjob`,
watchdog, `CommonCommands.handle_command(command, 'NIN', table.unpack(args))`,
UI, `debugmidcast`, `cyclestate`; anything else falls to Mote and then to the
alt commands.

## Set names the code looks up

T = `_master/sets/nin_sets.lua`. Player version:
[sets.md](../../user/jobs/nin/sets.md).

| Set | Looked up by | T |
|-----|--------------|---|
| `sets[MainWeapon]`, `sets[SubWeapon]` | `WeaponResolver.set_for` | example only |
| `sets.MoveSpeed`, `sets.MoveSpeed.Night`, `sets.Kiting` | `SetBuilder.apply_movement`, Mote Kiting | yes |
| `sets.Adoulin` | `BaseSetBuilder` | commented |
| `sets.buff.Yonin`, `.Innin`, `.Sange`, `.Issekigan` | `lay_buff_layers` | yes |
| `sets.buff.Futae` | `Ninjutsu.futae_layer` | yes |
| `sets.buff.Doom` | DoomManager | yes |
| `sets.precast.JA[<name>]` (Mijin Gakure, Yonin, Innin, Futae, Sange, Issekigan, Mikage, Provoke) | Mote | yes |
| `sets.precast.Waltz`, `['Healing Waltz']`, `sets.precast.Step` | Mote | yes |
| `sets.precast.FC`, `.FC.Utsusemi` | Mote | yes |
| `sets.precast.RA`, `sets.midcast.RA` | Mote | yes |
| `sets.precast.WS`, `.WS.Acc`, `WS[<name>]` (Blade: Hi, Shun, Metsu, Ku, Ten, Chi, Teki, To, Ei, Savage Blade, Aeolian Edge), `WS[<name>].Acc` | Mote | all but the per-WS `.Acc` |
| `sets.midcast.FastRecast` | Mote-Globals | yes |
| `sets.midcast.Utsusemi`, `.Migawari` | `MidcastManager` P6 (and Mote's map for Utsusemi) | yes |
| `sets.midcast.Ninjutsu`, `.Ninjutsu.Elemental`, `.Elemental.MagicBurst`, `.Enfeebling`, `.Enhancing` | `MidcastManager` | yes |
| `sets.midcast['<spell name>']` | `MidcastManager` P0 | no |
| `sets.resting` | Mote | yes |
| `sets.idle`, `.DT`, `.Town` | `BaseSetBuilder.select_idle_base` | yes |
| `sets.engaged`, `.Acc`, `.DT`, `.Acc.DT` | `select_engaged_base` | `.Acc.DT` commented |
| `sets.DW.*`, `sets.CombatMode`, `sets.TreasureHunter` | shared | commented |
| `sets.defense.PDT` / `.MDT` | Mote defense layer | no |

## Configuration

| File / key | Default | Read by |
|------------|---------|---------|
| `<char>/nin/NIN_STATES.lua` | see states | entry `user_setup` |
| `<char>/nin/NIN_KEYBINDS.lua` | 6 entries | entry `user_setup`, `file_unload` |
| `<char>/nin/NIN_TP_CONFIG.lua` `pieces`, `weapons` | Moonshade 250 | `WSPrecastHandler` |
| `<char>/nin/NIN_CUSTOM.lua` | examples only | shared custom states |
| `<char>/nin/NIN_HUD.lua` | empty | HUD |
| `<char>/nin/NIN_LOCKSTYLE.lua`, `NIN_MACROBOOK.lua` | 1 / book 1 page 1 | factories |

## Mechanics relied on (BG-Wiki)

- Dual Wield is a NIN trait (I at 10 up to V at 83):
  <https://www.bg-wiki.com/ffxi/Ninja>. `WeaponResolver` already lists NIN in
  `DW_MAIN`.
- Futae: the next elemental ninjutsu, within one minute, uses two tools and
  deals 50 % more damage; the buff ends with that spell:
  <https://www.bg-wiki.com/ffxi/Futae>. Hence the layer read at midcast.
- Yonin / Innin: 5-minute stances (Yonin: enmity, evasion in front; Innin:
  critical rate and ninjutsu damage from behind); enhancing pieces work while
  the stance is up: <https://www.bg-wiki.com/ffxi/Yonin>,
  <https://www.bg-wiki.com/ffxi/Innin>.
- Sange: one minute of Daken on every attack round, shuriken consumed; its
  enhancing body counts when the ability is used:
  <https://www.bg-wiki.com/ffxi/Sange> (hence `sets.precast.JA.Sange`; the
  `sets.buff.Sange` layer is for the throws during the minute).
- Issekigan: one minute of higher parry rate with enmity on parry:
  <https://www.bg-wiki.com/ffxi/Issekigan>.
- Utsusemi: Ichi does not overwrite Ni's shadows:
  <https://www.bg-wiki.com/ffxi/Utsusemi:_Ichi> (handled by the shared
  `utsusemi_shadows.lua`).
- Dusk to dawn movement: Ninja Kyahan works 18:00-6:00, the +1 and the
  Hachiya line 17:00-7:00: <https://www.bg-wiki.com/ffxi/Ninja_Kyahan>,
  <https://www.bg-wiki.com/ffxi/Hachiya_Kyahan_%2B3>. The code uses 17:00-7:00.

## Invariants & gotchas

- `world.time` is Vana'diel minutes since midnight (GearSwap copies
  `windower.ffxi.get_info()`). The night set is chosen when the idle set is
  built (moving starts or stops, any update): crossing 17:00 or 7:00 while
  running keeps the previous feet until the next update.
- A NIN/<sub> engaged set never switches to a single-wield variant: the job
  always dual wields.
- The Futae layer is equipped after `select_set`; a `sets.buff.Futae` piece
  in the waist slot is replaced by the ElementalBelt afterwards whenever a
  belt applies.

## Known issues

- No Utsusemi tier drop (San -> Ni -> Ichi when the higher one is on recast).
  `TierRefiner.refine` parses `spell.name` as `(%a+)%s*(%a*)` and builds
  `category .. ' ' .. tier`: with "Utsusemi: San" the category is `Utsusemi`,
  the tier is empty and the names it tests (`Utsusemi `) do not exist. Doing
  it would need `TierRefiner` to accept "Family: Tier" names (a separator
  option in the correspondence), then a `NINJUTSU_TIERS` table.
- No ninja tool check (Shihei, Inoshishinofuda...): a spell without its tool
  fails in the game, with the game's message.

## Needs an in-game check

- That `world.time` reads Vana'diel minutes in the job environment (as the
  GearSwap beta example `Byrth_DNC.lua` uses it).
- The buff layers going on 0.1 s after Yonin / Innin / Sange / Issekigan.
- The Futae layer on the elemental ninjutsu cast right after Futae.

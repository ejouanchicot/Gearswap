# DRG (Dragoon) job

Added on 2026-09-29. A thin job built on the shared systems, shaped like PUP
and BLU: 12 hook modules, a pet midcast module and 3 logic modules under
`shared/jobs/drg/functions/`, a template entry point, seven config files and
one sets file. GearSwap loads it when the main job becomes DRG (the entry
file `<Character>_DRG.lua`, made from `_master/entry/Tetsouo_DRG.lua` by the
clone script, which offers DRG).

Player-facing pages: [hub](../../user/jobs/drg/README.md),
[modes](../../user/jobs/drg/states.md), [sets](../../user/jobs/drg/sets.md).

What DRG adds on top of the shared pipeline:

- **Wyvern idle layer**: `sets.idle.Pet` (`.DT` under HybridMode DT) on top
  of the idle set while the wyvern is out, outside a city.
- **Spirit Surge layer**: `sets.buff['Spirit Surge']` on top of the engaged
  set while the buff is up (rebuilt 0.1 s after the buff changes).
- **Healing Breath trigger**: `sets.midcast.HealingBreathTrigger` on top of a
  spell's midcast set when the wyvern is out and the HP is under the
  subjob's line.
- **Breath gear**: `sets.midcast.HealingBreath` / `ElementalBreath` when
  GearSwap reports a wyvern breath through `pet_midcast`.
- **Jumps**: one set per jump (`sets.precast.JA[name]`), and the job
  command `//gs c jump`.

## Files

| Path | Lines | Role |
|------|------:|------|
| `_master/entry/Tetsouo_DRG.lua` | 186 | Entry (template): config preload, `get_sets`, `job_sub_job_change`, `user_setup`, `job_update` (HUD), `init_gear_sets`, `file_unload` |
| `shared/jobs/drg/functions/drg_functions.lua` | 66 | Facade: includes `message_buffs` and the hook files, requires `dualbox_manager`, debug line |
| `shared/jobs/drg/functions/DRG_PRECAST.lua` | 109 | `job_precast` (guard, cooldown, WS handler) / `job_post_precast` (TP gear) |
| `shared/jobs/drg/functions/DRG_MIDCAST.lua` | 100 | `job_midcast` (empty) / `job_post_midcast` (subjob magic via MidcastManager, then the Healing Breath trigger) |
| `shared/jobs/drg/functions/DRG_PET_MIDCAST.lua` | 43 | `job_pet_midcast`: wyvern breaths |
| `shared/jobs/drg/functions/DRG_AFTERCAST.lua` | 21 | `job_aftercast = LifecycleManager.aftercast()` |
| `shared/jobs/drg/functions/DRG_IDLE.lua` | 30 | `customize_idle_set` -> `SetBuilder.build_idle_set` |
| `shared/jobs/drg/functions/DRG_ENGAGED.lua` | 30 | `customize_melee_set` -> `SetBuilder.build_engaged_set` |
| `shared/jobs/drg/functions/DRG_STATUS.lua` | 23 | `job_status_change = LifecycleManager.status_change()` |
| `shared/jobs/drg/functions/DRG_BUFFS.lua` | 23 | `LifecycleManager.buff_change` + `refresh_after_buff` (Spirit Surge) |
| `shared/jobs/drg/functions/DRG_COMMANDS.lua` | 125 | `job_self_command` router (+ `jump`), `job_state_change = LifecycleManager.state_change()` |
| `shared/jobs/drg/functions/DRG_MOVEMENT.lua` | 16 | Header only (`return {}`), kept for the 12-module layout |
| `shared/jobs/drg/functions/DRG_LOCKSTYLE.lua` | 45 | Lazy `LockstyleManager.create('DRG', 'drg/DRG_LOCKSTYLE', 1, 'SAM')` wrappers |
| `shared/jobs/drg/functions/DRG_MACROBOOK.lua` | 37 | Lazy `MacrobookManager.create('DRG', 'drg/DRG_MACROBOOK', 'SAM', 1, 1)` wrapper |
| `shared/jobs/drg/functions/logic/set_builder.lua` | 156 | Idle and engaged: base, town / HybridMode, wyvern layer, Spirit Surge, Mote layers, weapons, movement |
| `shared/jobs/drg/functions/logic/wyvern.lua` | 71 | `TRIGGER_HPP` by subjob, `trigger_line`, `spell_triggers_breath`, `breath_set` |
| `shared/jobs/drg/functions/logic/jumps.lua` | 81 | `order`, `pick`, `execute` (`//gs c jump`) |
| `_master/config/drg/DRG_STATES.lua` | 71 | Mote mode options, `MainWeapon`, `SubWeapon`, `FastCast`, `AutoMedicine` |
| `_master/config/drg/DRG_KEYBINDS.lua` | 35 | Data only: 5 entries (+ 1 commented per-weapon example) handed to `KeybindManager.create('DRG', ...)` |
| `_master/config/drg/DRG_TP_CONFIG.lua` | 51 | `pieces` (Moonshade 250), empty `weapons`, `jumps` order, `get_weapon_bonus`, sets `_G.DRGTPConfig` |
| `_master/config/drg/DRG_CUSTOM.lua` | 119 | Player modes and gear rules, commented examples only |
| `_master/config/drg/DRG_HUD.lua` | 31 | HUD section / row order (empty = default) |
| `_master/config/drg/DRG_LOCKSTYLE.lua` | 27 | `default = 1`, empty `by_subjob` |
| `_master/config/drg/DRG_MACROBOOK.lua` | 30 | `default` book 1 page 1, empty `solo` and `dualbox` |
| `_master/sets/drg_sets.lua` | 160 | Template sets: every set the code reads, all empty |

Already there before the job: `shared/data/job_abilities/DRG_JA_DATABASE.lua`
(+ `drg/`, JA messages), `POLEARM_WS_DATABASE.lua` (WS messages), the /DRG
helpers `shared/utils/drg/DRG_JUMP_MANAGER.lua` and `auto_jump.lua` (see
[Jumps](#jumps)).

Shared files changed for DRG:

- `shared/utils/core/lifecycle_manager.lua`: `Spirit Surge` added to
  `GEAR_BUFFS`, so `refresh_after_buff('Spirit Surge')` rebuilds the gear
  0.1 s after the buff comes or goes. No other job gets that buff.
- `clone_character.py` `ALL_VALID_JOBS` and `character_db.lua` `ALL_JOBS`:
  `DRG` added.

## How it works

### Load sequence

Same shape as PUP / BLU ([core lifecycle](../systems/core-lifecycle.md#how-a-job-file-boots)).
`user_setup()`: `DRGStates.configure()`, `DRG_KEYBINDS` into the global
`DRGKeybinds` and `bind_all()` (a failed require prints `[DRG] Keybinds
failed to load: <error>`), `KeybindUI.smart_init("DRG", init_delay)`,
`JobChangeManager.initialize()`, macro book at once and lockstyle after
`LockstyleConfig.initial_load_delay`, `dualbox_manager`. `get_sets()` then
sets `_G.LockstyleConfig`, `_G.RECAST_CONFIG`, `_G.DRGTPConfig`, cancels
pending job-change work, includes the facade and registers
`cancel_drg_lockstyle_operations`. `job_update` repaints the HUD.
`file_unload`: `JobChangeManager.cancel_all()`, `DRGKeybinds.unbind_all()`.

### Precast

`job_precast`: PrecastGuard, then `CooldownChecker` by action type (abilities
and spells), `eventArgs.cancel` return, then `WSPrecastHandler.handle(spell,
eventArgs, DRGTPConfig)`. `job_post_precast` lays the TP bonus piece. No DRG
action drops a tier, so there is no exception before the cooldown check.

Mote's own precast picks the set: `sets.precast.JA[name]` for the job
abilities, jumps included. Restoring Breath, Smiting Breath, Steady Wing and
Dismiss are `PetCommand` in the game's data: Mote looks for
`sets.precast.PetCommand` first, then `sets.precast.JA[name]`. The template
declares every jump; High Jump, Spirit Jump and Soul Jump start as a
`set_combine` of `sets.precast.JA.Jump`, since Mote takes a named set over
anything else (an empty named set would hide a shared one).

There is no `sets.precast.JA['Steady Wing']`: its barrier is 30% of the
wyvern's max HP plus the damage it has taken, and the wyvern HP gear must be
worn a tick before the order (BG-Wiki "Steady Wing"), so a swap at the order
does nothing.

### Jumps

`shared/utils/drg/` serves `/DRG` only and was not changed:
`DRG_JUMP_MANAGER.execute_jump` (the common `//gs c jump`) and
`AutoJump.auto_trigger_jump` (WAR / DNC precast) both return at once when
`player.sub_job ~= 'DRG'`, and use Jump / High Jump only (recast ids 158 /
159). On a Dragoon main job `DRG_COMMANDS` takes `jump` before the common
commands and runs `logic/jumps.lua`:

1. `Jumps.order()`: `DRGTPConfig.jumps`, or `{'Soul Jump', 'Spirit Jump',
   'Jump', 'High Jump'}` when missing or empty.
2. `Jumps.pick()`: the first name with `AbilityHelper.can_use_ability` (the
   game's ability list: job, level, job points) and
   `AbilityHelper.is_ability_ready` (recast, RECAST_CONFIG tolerance).
3. `Jumps.execute()`: `input /ja "<name>" <t>`; none known ->
   `show_error('No jump available on this job and level')`; all on recast ->
   one `show_multi_status` cooldown block with each known jump's time left
   (`res.job_abilities` recast id, `get_ability_recasts`).

No automatic jump before a weaponskill on the main job: see
[Known issues](#known-issues).

### Midcast (the Dragoon)

Mote-Globals' `user_midcast` equips `sets.midcast.FastRecast` first. Mote's
default midcast picks by name / map / skill / type. `job_post_midcast`:
`MidcastDeps.load()`, watchdog notify, return for anything that is not magic
with a skill, `MidcastManager.select_set` on the skill (target and enhancing
family for Enhancing Magic, enfeebling database for Enfeebling Magic), then
the Healing Breath trigger.

**Healing Breath trigger** (`logic/wyvern.lua`, BG-Wiki "Healing Breath",
"Wyvern (Dragoon Pet)"): the wyvern cures when the Dragoon casts a spell
while the HP at the end of the cast is under a line set by the subjob:

| Subjob | Wyvern | Line | With the artifact head | `TRIGGER_HPP` |
|---|---|---|---|---|
| WHM BLM RDM SMN BLU SCH GEO | defensive | 33.3% | 50% | 50 |
| PLD DRK BRD NIN RUN | hybrid | 25% | 33.3% | 33.3 |
| any other, none | offensive | never | never | - |

`Wyvern.spell_triggers_breath(spell)`: magic, not Summoning Magic, `pet.isvalid`,
a subjob in `TRIGGER_HPP` at a level above 0 (Sheol Gaol sets it to 0), and
`player.hpp < TRIGGER_HPP[sub]`. When true, `equip(sets.midcast
.HealingBreathTrigger)` after `select_set`. The table holds the "head on"
lines because the set is meant to carry the head: with it the trigger fires
up to that line; a set without it simply changes nothing between the two
lines.

### The wyvern's breaths

`job_pet_midcast` (`DRG_PET_MIDCAST.lua`): `Wyvern.breath_set(spell.english)`
-> `sets.midcast.HealingBreath` for any name starting `Healing Breath`
(res ids 639-642), `sets.midcast.ElementalBreath` for Flame / Frost / Gust /
Sand / Lightning / Hydro Breath (646-651); when that set exists it is
equipped and `eventArgs.handled` is set. Anything else is left to Mote's
`default_pet_midcast` (`sets.midcast.Pet...`, none in the template).

GearSwap calls `pet_midcast` only on a "readies" action packet of the pet
(categories 7, 8, 9, 12, `triggers.lua`). Whether the wyvern's breaths send
one is not established here: see [Needs an in-game check](#needs-an-in-game-check).

### Idle and engaged

`logic/set_builder.lua` replaces Mote's base for both.

Idle (`build_idle_set`):

1. `master_idle`: Mote walks into `sets.idle.Pet` (`get_idle_set`, `pet.isvalid`)
   when the wyvern is out; that pick is replaced by `sets.idle`.
2. `BaseSetBuilder.select_idle_base`: in a city `sets.idle.Town` /
   `sets.Adoulin` on top of the idle (then only the Mote layers and weapons
   follow, trace `IDLE town`); else `sets.idle[HybridMode]` when a table
   (`sets.idle.DT`).
3. `wyvern_idle_layer`: wyvern out -> `sets.idle.Pet.DT` under HybridMode DT
   when defined, else `sets.idle.Pet`; `set_combine` on top.
4. Mote's defense / Kiting layers, `BaseSetBuilder.lay_weapons` (MainWeapon,
   SubWeapon).
5. `BaseSetBuilder.apply_movement`.

Engaged (`build_engaged_set` / `select_engaged_base`): `sets.engaged`, then
`sets.engaged[OffenseMode]` when a table; under HybridMode DT that level's
`.DT`, else `sets.engaged.DT`. Then `lay_spirit_surge` (`buffactive['Spirit
Surge']` and the set exists), Mote's layers, weapons.

Trace lines (`//gs c trace on`): `IDLE town`, `IDLE sets.idle.Pet[.DT]`,
`IDLE no wyvern`; `ENGAGED sets.engaged[.Acc][.DT][ + Spirit Surge]`.

The wyvern needs no status hook: Mote's `pet_change` equips after Call
Wyvern, Spirit Surge (the wyvern is absorbed) or the wyvern's death, and no
DRG set depends on the wyvern's own status.

Spirit Surge: `job_buff_change` = `LifecycleManager.buff_change` +
`refresh_after_buff(buff)` (`gs c update` 0.1 s later; inside `buff_change`
`buffactive` still holds the old list).

## Mote states

Created by `DRGStates.configure()` on every `user_setup()`.

| State | Values (template) | Default | Key | Read by |
|-------|--------|---------|-----|---------|
| `MainWeapon` | Free | Free | `^numpad1` | `BaseSetBuilder.lay_weapons` |
| `SubWeapon` | Free | Free | `^numpad2` | `BaseSetBuilder.lay_weapons` (the grip) |
| `OffenseMode` (Mote) | Normal, Acc | Normal | `^numpad3`, Mote's `f9` | `select_engaged_base`; Mote's WS mode fallback |
| `WeaponskillMode` (Mote) | Normal, Acc | Normal | `^numpad4` | Mote `get_weaponskill_set` |
| `HybridMode` (Mote) | Normal, DT | Normal | `^numpad9`, Mote's `^f9` | `select_idle_base`, `wyvern_idle_layer`, `select_engaged_base` |
| `FastCast` | 0..80 by 10 | 0 | none | midcast watchdog fallback estimate |
| `AutoMedicine` | ON, OFF | persisted | `#numpad0` (common key) | `AutoMedicine.init` |
| `IdleMode`, `CastingMode`, `RangedMode` (Mote) | Normal | Normal | Mote's F-keys | Mote only |
| `CombatMode`, `TreasureMode` (optional states) | | Off | hidden | shared hooks |

DRG has no signature state yet (like DRK and SAM): `^numpad3` holds Offense
Mode.

## Commands

`job_self_command` (`DRG_COMMANDS.lua`): `altjobupdate` / `requestjob`,
`jump`, watchdog, `CommonCommands.handle_command(command, 'DRG',
table.unpack(args))`, UI, `debugmidcast`, `cyclestate`; anything else falls to
Mote and then to the alt commands.

## Set names the code looks up

T = `_master/sets/drg_sets.lua`. Player version:
[sets.md](../../user/jobs/drg/sets.md).

| Set | Looked up by | T |
|-----|--------------|---|
| `sets[MainWeapon]`, `sets[SubWeapon]` | `WeaponResolver.set_for` | example only |
| `sets.MoveSpeed`, `sets.Kiting` | `BaseSetBuilder.apply_movement`, Mote Kiting | yes |
| `sets.Adoulin` | `BaseSetBuilder` | commented |
| `sets.buff['Spirit Surge']` | `lay_spirit_surge` | yes |
| `sets.buff.Doom` | DoomManager | yes |
| `sets.precast.JA[<name>]`: Jump, High Jump, Spirit Jump, Soul Jump, Super Jump, Call Wyvern, Spirit Link, Spirit Surge, Angon, Ancient Circle, Deep Breathing, Dragon Breaker, Fly High, Spirit Bond, Restoring Breath, Smiting Breath | Mote default precast | yes |
| `sets.precast.Waltz`, `['Healing Waltz']` | Mote | yes |
| `sets.precast.FC` | Mote | yes |
| `sets.precast.WS`, `.WS.Acc`, `WS['Stardiver' / "Camlann's Torment" / 'Drakesbane' / 'Impulse Drive' / 'Geirskogul' / 'Sonic Thrust' / 'Savage Blade']` | Mote | yes |
| `sets.midcast.FastRecast` | Mote-Globals | yes |
| `sets.midcast['Blue Magic']`, `.Utsusemi`, other skills | MidcastManager / Mote | commented |
| `sets.midcast.HealingBreathTrigger` | `job_post_midcast` | yes |
| `sets.midcast.HealingBreath`, `.ElementalBreath` | `job_pet_midcast` | yes |
| `sets.resting` | Mote | yes |
| `sets.idle`, `.DT`, `.Town` | `master_idle`, `BaseSetBuilder` | yes |
| `sets.idle.Pet`, `.Pet.DT` | `wyvern_idle_layer` | yes |
| `sets.engaged`, `.Acc`, `.DT` (and `.Acc.DT`) | `select_engaged_base` | first three |
| `sets.defense.PDT` / `.MDT` | Mote defense layer | no |
| `sets.TreasureHunter` | shared Treasure Hunter | commented |

## Configuration

| File / key | Default | Read by |
|------------|---------|---------|
| `<char>/drg/DRG_STATES.lua` | see states | entry `user_setup` |
| `<char>/drg/DRG_KEYBINDS.lua` | 5 entries | entry `user_setup`, `file_unload` |
| `<char>/drg/DRG_TP_CONFIG.lua` `pieces`, `weapons` | Moonshade 250 | `WSPrecastHandler` |
| `<char>/drg/DRG_TP_CONFIG.lua` `jumps` | Soul Jump, Spirit Jump, Jump, High Jump | `Jumps.order` |
| `<char>/drg/DRG_CUSTOM.lua` | examples only | shared custom states |
| `<char>/drg/DRG_HUD.lua` | empty | HUD |
| `<char>/drg/DRG_LOCKSTYLE.lua`, `DRG_MACROBOOK.lua` | 1 / book 1 page 1 | factories |

## Known issues

- `//gs c jump` on another job with /DRG is unchanged; the common
  `CommonCommands.handle_jump` comment says "DRG main or sub" but
  `DRG_JUMP_MANAGER` refuses anything but /DRG: on DRG main the job's own
  `jump` answers first.
- No automatic jump before a weaponskill on DRG main (`state.JumpAuto`):
  `auto_jump.lua` is /DRG-only and not extended here.

## Left out on purpose (later options)

Automatic Jump before a weaponskill, automatic Call Wyvern / Spirit Link /
Restoring Breath, a wyvern HP watch, Angon / Dragon Breaker tracking, a
breath trigger toggle (an empty `HealingBreathTrigger` set is the "off").

## Needs an in-game check

- Whether GearSwap's `pet_midcast` fires for the wyvern's breaths (a
  "readies" packet). If not, `sets.midcast.HealingBreath` / `ElementalBreath`
  are never worn and the breath gear has to live in the idle / engaged sets.
- The Healing Breath trigger with the artifact head at the 50% / 33.3%
  lines, and whether the HP read at midcast (`player.hpp`) matches the
  server's reading at the end of the cast.
- The jump order and names against `get_abilities()` at each level.

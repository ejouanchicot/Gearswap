# SCH (Scholar) job

SCH was added on 2026-09-29. It is a thin mage job built on the shared
systems: 12 hook modules plus 4 logic modules under `shared/jobs/sch/functions/`,
a template entry point, seven config files and one sets file. GearSwap loads it
when the main job becomes SCH (the entry file `<Character>_SCH.lua`, made from
`_master/entry/Tetsouo_SCH.lua` by the clone script, which offers SCH).

Player-facing pages: [hub](../../user/jobs/sch/README.md),
[modes](../../user/jobs/sch/states.md), [sets](../../user/jobs/sch/sets.md).

What SCH adds on top of the shared pipeline:

- **Grimoire layers**: `sets.precast.FC.Grimoire` on a spell of the Arts in
  force; `sets.buff.Celerity` / `.Alacrity` at precast and midcast;
  `sets.buff.Perpetuance`, `.Rapture`, `.Ebullience`, `.Immanence`,
  `.Klimaform` at midcast (`logic/grimoire.lua`).
- **Tier refinement** for nukes, -ra, Aspir (shared `NUKE_TIERS`) and for
  helices and storms (II -> base, `logic/spell_tiers.lua`), through the shared
  `TierRefiner`, in place of the recast check.
- **Stratagem charge gate**: a stratagem with no charge left is cancelled with
  the time to the next one (shared `stratagem_charges.lua`).
- **Helix and Kaustra midcast**: `sets.midcast.Helix` as the helices' base,
  typed Dark / Light; Magic Burst mode on nukes, helices and Kaustra.
- **Sublimation idle layer** while it charges; the buff is in
  `LifecycleManager`'s `GEAR_BUFFS`.
- Job commands: `nuke`, `helix`, `storm` (from the Element mode), `strat`,
  `schhelp`. `lightarts`, `darkarts` and `aoe` are common commands, the same on
  every job with /SCH (`ScholarActions.handle_command`).

## Files

| Path | Lines | Role |
|------|------:|------|
| `_master/entry/Tetsouo_SCH.lua` | 187 | Entry (template): config preload, `get_sets`, `job_sub_job_change`, `user_setup`, `job_update` (HUD), `init_gear_sets`, `file_unload` |
| `shared/jobs/sch/functions/sch_functions.lua` | 62 | Facade: includes `message_buffs` and the hook files, requires `dualbox_manager` |
| `shared/jobs/sch/functions/SCH_PRECAST.lua` | 152 | `job_precast` (guard, tier refiner or cooldown, stratagem charges, WS handler) / `job_post_precast` (TP gear, grimoire layers) |
| `shared/jobs/sch/functions/SCH_MIDCAST.lua` | 134 | `job_midcast` (empty) / `job_post_midcast` (MidcastManager per skill, grimoire layers) |
| `shared/jobs/sch/functions/SCH_AFTERCAST.lua` | 21 | `LifecycleManager.aftercast()` |
| `shared/jobs/sch/functions/SCH_IDLE.lua` | 30 | `customize_idle_set` -> `SetBuilder.build_idle_set` |
| `shared/jobs/sch/functions/SCH_ENGAGED.lua` | 30 | `customize_melee_set` -> `SetBuilder.build_engaged_set` |
| `shared/jobs/sch/functions/SCH_STATUS.lua` | 19 | `LifecycleManager.status_change()` |
| `shared/jobs/sch/functions/SCH_BUFFS.lua` | 24 | `LifecycleManager.buff_change` + `refresh_after_buff` (Sublimation) |
| `shared/jobs/sch/functions/SCH_COMMANDS.lua` | 182 | `job_self_command` router + job commands, `job_state_change` |
| `shared/jobs/sch/functions/SCH_MOVEMENT.lua` | 16 | Header only, kept for the 12-module layout |
| `shared/jobs/sch/functions/SCH_LOCKSTYLE.lua` | 45 | Lazy `LockstyleManager.create('SCH', 'sch/SCH_LOCKSTYLE', 1, 'RDM')` |
| `shared/jobs/sch/functions/SCH_MACROBOOK.lua` | 37 | Lazy `MacrobookManager.create('SCH', 'sch/SCH_MACROBOOK', 'RDM', 1, 1)` |
| `shared/jobs/sch/functions/logic/grimoire.lua` | 136 | Arts in force (addendum first), precast / midcast layer lists |
| `shared/jobs/sch/functions/logic/spell_tiers.lua` | 47 | Tier families for `TierRefiner` |
| `shared/jobs/sch/functions/logic/spell_commands.lua` | 106 | Element -> nuke / helix / storm names, `cast`, the `strat` block |
| `shared/jobs/sch/functions/logic/set_builder.lua` | 111 | Idle (base, Sublimation, Mote layers, weapons, movement) and engaged |
| `_master/config/sch/SCH_STATES.lua` | 88 | Modes (see below) |
| `_master/config/sch/SCH_KEYBINDS.lua` | 46 | 9 mode keys + 5 action keys, `KeybindManager.create('SCH', ...)` |
| `_master/config/sch/SCH_TP_CONFIG.lua` | 44 | Moonshade 250, empty `weapons`, sets `_G.SCHTPConfig` |
| `_master/config/sch/SCH_CUSTOM.lua` | 120 | Player modes and gear rules, commented examples only |
| `_master/config/sch/SCH_HUD.lua` | 32 | HUD section / row order (empty = default) |
| `_master/config/sch/SCH_LOCKSTYLE.lua` | 27 | `default = 1` |
| `_master/config/sch/SCH_MACROBOOK.lua` | 30 | Book 1 page 1 |
| `_master/sets/sch_sets.lua` | 160 | Template sets: every set the code reads, all empty |

Shared files changed for SCH (registries only):

- `shared/utils/core/lifecycle_manager.lua`: `'Sublimation: Activated'` in
  `GEAR_BUFFS`.
- `shared/utils/ui/UI_FORMATTER.lua` (`SCH = "Scholar Settings"`),
  `shared/utils/ui/ui_lifecycle.lua` (states ready when `state.Element` exists).
- `character_db.lua` (`ALL_JOBS`), `clone_character.py` (`ALL_VALID_JOBS`),
  `docs/tools/build_wiki.py` (`JOBS`, `JOB_NAMES`).

Already there before: the JA message database (`SCH_JA_DATABASE.lua` and
`shared/data/job_abilities/sch/`), `SCH_SPELL_DATABASE.lua` (spell messages),
the helix and storm spell data, `stratagem_charges.lua` and
`scholar_actions.lua` (used by BLM / GEO / PLD on /SCH), the stratagem
exemptions in `cooldown_checker.lua`.

## How it works

### Load sequence

Same shape as PUP / BLU ([core lifecycle](../systems/core-lifecycle.md#how-a-job-file-boots)).
`user_setup()`: `SCHStates.configure()`, `SCH_KEYBINDS` into the global
`SCHKeybinds` and `bind_all()` (a failed require prints
`[SCH] Keybinds failed to load: <error>`), `KeybindUI.smart_init("SCH")`,
`JobChangeManager.initialize()`, macro book at once and lockstyle after
`initial_load_delay`, `dualbox_manager`. `get_sets()` sets `_G.LockstyleConfig`,
`_G.RECAST_CONFIG`, `_G.SCHTPConfig`, cancels pending job-change work, includes
the facade and registers `cancel_sch_lockstyle_operations`. `job_update`
repaints the HUD. `file_unload`: `JobChangeManager.cancel_all()`, then
`SCHKeybinds.unbind_all()`.

### Arts

`Grimoire.arts()` returns `'Light'` for `Addendum: White` or `Light Arts`,
`'Dark'` for `Addendum: Black` or `Dark Arts`, nil otherwise. The addendum is
tested first: it replaces the Arts buff while it is up
(`.claude/CODE_QUALITY.md` §7.5). A spell "matches" when it
is `WhiteMagic` under Light or `BlackMagic` under Dark.

### Precast

1. `PrecastGuard.guard_precast`.
2. `SpellTiers.get(spell)`: a Magic spell whose family (first word) is a
   helix, a storm or a `NUKE_TIERS` family goes to `TierRefiner.refine`,
   which casts the highest tier that is learned, off recast and paid for, or
   cancels and lists every tier's recast. Anything else takes
   `CooldownChecker` (abilities / spells). This is the documented
   "tiers before cooldown" exception (CLAUDE.md), as on BLM / RDM / GEO.
3. A `JobAbility` with `recast_id` 231 (the 16 stratagems) is cancelled when
   `StratagemCharges.get_max() > 0` and `available() == 0`, with
   `ScholarActions.warn_no_charge`. `available()` assumes the 240 s full
   recharge; the 550 JP gift shortens it (48 s -> 33 s a charge), so the
   estimate can only read **higher** than the real count: a cast cancelled
   here would have been refused by the game. The cooldown checker itself
   skips stratagems (`MULTI_CHARGE_ABILITIES`).
4. `WSPrecastHandler.handle(spell, eventArgs, SCHTPConfig)`.

`job_post_precast`: `WSPrecastHandler.apply_tp_gear`, then
`Grimoire.precast_layers`: `sets.precast.FC.Grimoire` on a matching spell,
`sets.buff.Celerity` (white magic, Celerity up) / `sets.buff.Alacrity` (black
magic, Alacrity up).

### Midcast

`job_post_midcast`: `MidcastDeps.load()`, watchdog, return for anything not
magic, then one `MidcastManager.select_set` from `config_for(spell)`:

| Skill | Config |
|------|--------|
| Elemental Magic, helix (`^%a+helix`) with `sets.midcast.Helix` | `skill = 'Helix'`, `mode_value = 'MagicBurst'` under Magic Burst On, `database_func` = Dark (Noctohelix) / Light (Luminohelix) / nil |
| Elemental Magic, other | `skill = 'Elemental Magic'`, same `mode_value` |
| Dark Magic | `mode_value` only for Kaustra |
| Enhancing Magic | `target_func = get_enhancing_target`, `database_func` = enhancing family (Regen, Storm...) |
| Enfeebling Magic | `skill = 'MndEnfeebles'` (white) / `'IntEnfeebles'` (black) when that set exists, else the skill; `database_func` = enfeebling type |
| other | the skill |

MidcastManager's P0-P9 chain then gives, for example: `sets.midcast.Helix.Dark
.MagicBurst` (P3 type + mode), `sets.midcast.Helix.Dark` (P7),
`sets.midcast.Helix.MagicBurst` (P8), `sets.midcast.Pyrohelix` (P1, tier-less
name), `sets.midcast.Kaustra.MagicBurst` (P0 with mode), `sets.midcast.Regen`
(P1), `sets.midcast.Storm` (P6 family), `sets.midcast.Cure` /
`.StatusRemoval` (P8b Mote map), `sets.midcast.Cursna` (P0).

Then `Grimoire.midcast_layers`, in this order: Perpetuance (Enhancing Magic),
Rapture (white magic), Ebullience (black magic), Immanence and Klimaform
(Elemental Magic; Klimaform only when `spell.element == world.weather_element`),
Celerity / Alacrity. The shared ElementalBelt then picks Obi / Orpheus in
`cleanup_midcast`, and the player's `SCH_CUSTOM.lua` gear goes last.

### Idle and engaged

`build_idle_set`: `BaseSetBuilder.select_idle_base` (town set on top of the
idle in a city, else `sets.idle[HybridMode]`, else Mote's pick), then
`sets.buff.Sublimation` while `buffactive['Sublimation: Activated']`, Mote's
defense / Kiting layers, `lay_weapons`, and `apply_movement` outside a city.
`SCH_BUFFS` calls `refresh_after_buff`, which rebuilds 0.1 s after
`Sublimation: Activated` comes or goes (buffactive is stale inside
`buff_change`).

`build_engaged_set`: `sets.engaged`, `[OffenseMode]` when defined, `.DT` under
HybridMode DT (that level's, else `sets.engaged.DT`), Mote layers, weapons.

### Commands

`job_self_command` order: `altjobupdate`, `requestjob`, the job commands,
watchdog, common (`table.unpack` forwarding), UI, `debugmidcast`,
`cyclestate`. `nuke` / `helix` / `storm` send `input /ma "<name>" <t|me>` from
`state.Element` (`nuke` also `state.NukeTier`; tier I is the base spell);
helix and storm always ask for tier II and precast drops them to I when II is
not learned. Light / Dark have no nuke: a warning, nothing sent. `aoe` (common
command) reads `state.SneakInviAOE`. `strat` is an
`InfoBlock`.

## Mechanics relied on (BG-Wiki)

- Stratagems: charges 1 / 2 / 3 / 4 / 5 at SCH 10 / 30 / 50 / 70 / 90; 48 s a
  charge at 99, 33 s with the 550 JP gift ([Stratagems](https://www.bg-wiki.com/ffxi/Stratagems)).
  The 16 abilities on recast 231 come from `res/job_abilities.lua`.
- Light Arts: white magic casting time and recast -10%
  ([Light Arts](https://www.bg-wiki.com/ffxi/Light_Arts)); "Grimoire:
  spellcasting time" gear applies to spells of the active grimoire.
- Sublimation: charges while "Sublimation: Activated", HP gear must stay on
  while it charges ([Sublimation](https://www.bg-wiki.com/ffxi/Sublimation)).
- Perpetuance (white enhancing duration, hands), Rapture (next white magic,
  head), Ebullience (next black magic, head), Immanence (skillchain bonus,
  hands) ([Perpetuance](https://www.bg-wiki.com/ffxi/Perpetuance),
  [Rapture](https://www.bg-wiki.com/ffxi/Rapture),
  [Ebullience](https://www.bg-wiki.com/ffxi/Ebullience),
  [Immanence](https://www.bg-wiki.com/ffxi/Immanence)).
- Klimaform: magic accuracy for spells of the weather's element; Arbatel
  Loafers add magic damage with matching weather
  ([Klimaform](https://www.bg-wiki.com/ffxi/Klimaform)).
- Pedagogy Loafers: casting time and recast reduction under Celerity /
  Alacrity with matching weather
  ([Pedagogy Loafers +3](https://www.bg-wiki.com/ffxi/Pedagogy_Loafers_+3)).
- Helix: initial hit plus damage over time; Helix II overwrites
  ([Helix](https://www.bg-wiki.com/ffxi/Helix)).

## Not done

- No Klimaform + storm chain (BLM's `klima` / `CastStorm` live in BLM's own
  files), no automatic Arts before a spell, no Tabula Rasa / Enlightenment
  helpers.
- Celerity / Alacrity are laid on any spell of their magic type; the weather
  condition of Pedagogy Loafers is not tested.
- Not tested in game.

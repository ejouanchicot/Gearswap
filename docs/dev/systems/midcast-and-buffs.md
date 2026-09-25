# Midcast selection, set building and buff helpers

`MidcastManager` picks the midcast set for a spell from nested `sets.midcast` tables. Every job's `job_post_midcast` calls it (directly or through a router) after Mote-Include's default midcast has already equipped its own guess. Alongside it sit a lazy loader for its dependencies (`MidcastDeps`), the helpers every job `set_builder.lua` uses for idle movement and town gear (`BaseSetBuilder`), and three action helpers that send `/ja`/`/ma` from `//gs c` commands: the `//gs c buff` self-buff queue (`SelfBuffManager`), the /WAR subjob buff list shared by DNC and THF (`SubjobWarBuffs`), and the /SCH Arts, Accession and Addendum chains (`ScholarActions`, `StratagemCharges`).

None of these modules registers a Windower event. `MidcastManager` keeps its debug flag on `windower._midcast_debug`, and `ScholarActions` polls buffs with `coroutine.schedule` under a `windower._sch_cast_seq` generation counter; everything else is module-local or on the sandbox `_G`, so it is rebuilt whenever GearSwap rebuilds the user environment (see [State & lifetime](#state--lifetime)).

## Files

| Path | Lines | Role |
|---|---|---|
| `shared/utils/midcast/midcast_manager.lua` | 777 | `select_set()` with the 10-level standard chain (P0-P9) and the Singing chain, persistent debug toggle, Composure target helper, song helpers, unused preset configs |
| `shared/utils/midcast/midcast_deps.lua` | 44 | Loads `MidcastManager` and `ENHANCING_MAGIC_DATABASE` once per instance, for the 7 subjob-magic jobs |
| `shared/utils/messages/formatters/magic/message_midcast.lua` | 156 | Debug output used by `MidcastManager` (templates in `shared/utils/messages/data/systems/midcast_messages.lua`) |
| `shared/utils/set_building/base_set_builder.lua` | 104 | `apply_movement`, `select_idle_base_town`, `is_in_town` |
| `shared/utils/buffs/self_buff_manager.lua` | 259 | Factory: resolves a list of spells/abilities and queues the missing ones (only BLM uses it) |
| `shared/utils/smartbuff/subjob_war_buffs.lua` | 74 | Berserk / Aggressor / Warcry collection and casting for DNC and THF subbing /WAR |
| `shared/utils/scholar/scholar_actions.lua` | 346 | Light/Dark Arts toggles, the `aoe sneak/invi/erase` Accession casts, buff-gated stratagem chains, Addendum: Black casts (BLM, PLD, GEO) |
| `shared/utils/scholar/stratagem_charges.lua` | 104 | Stratagem charge count derived from recast id 231 |

`shared/utils/midcast/midcast_manager.lua.preref.bak` also sits on disk. It is ignored by `.gitignore` (`*.bak`) and nothing loads it.

## Where MidcastManager runs

Mote-Include drives every action through `handle_actions` (`libs/Mote-Include.lua:227`). For midcast:

```mermaid
sequenceDiagram
    participant GS as GearSwap midcast()
    participant Mote as Mote handle_actions
    participant Job as job_midcast (JOB_MIDCAST.lua)
    participant Def as default_midcast
    participant Post as job_post_midcast
    participant MM as MidcastManager.select_set
    GS->>Mote: midcast(spell)
    Mote->>Job: only if not eventArgs.handled (Mote-Include.lua:254)
    Mote->>Def: only if not eventArgs.handled (Mote-Include.lua:263)
    Note over Def: equip(get_midcast_set) - name, spellMap, skill, type, CastingMode
    Mote->>Post: always unless cancelled (Mote-Include.lua:274)
    Post->>MM: select_set(config)
    MM-->>Post: equip(chosen set), returns true/false
    Note over Post: job overrides equip() on top (Saboteur, instrument lock, EnmityOverride...)
```

Consequences:

- `MidcastManager` equips on top of whatever `default_midcast` chose (`Mote-Include.lua:332-334`, `705-760`). A partial set (only a few slots) leaves the other slots as Mote left them, which is often the precast Fast Cast set.
- When `select_set` returns `false` nothing more is equipped, so Mote's default choice stands.
- `job_post_midcast` runs even when `job_midcast` set `eventArgs.handled` (`Mote-Include.lua:274`). PLD relies on that and returns early itself (`shared/jobs/pld/functions/PLD_MIDCAST.lua:167`); that early return also skips `EnmityOverride.apply_midcast` for Cure III/IV.
- `user_post_midcast` (the spell-message hook, `shared/hooks/init_spell_messages.lua`) runs between `default_midcast` and `job_post_midcast` (`Mote-Include.lua:269-270`). A cancelled precast never reaches midcast, so no message is printed for it.

## MidcastManager.select_set

`MidcastManager.select_set(config)` (`midcast_manager.lua:621-654`):

1. Returns `false` if `config` or `config.skill` is missing (`:622-624`) or `sets.midcast` is missing (`:626-628`).
2. Resolves the base set: `sets.midcast.BardSong` when `config.skill == 'Singing'`, otherwise `sets.midcast[config.skill]` (`:631-636`).
3. **Returns `false` if the base set is missing** (`:638-640`). This happens before any lookup, so a job that has `sets.midcast['Cure II']` but no `sets.midcast['Healing Magic']` gets nothing from `MidcastManager`, and only Mote's default choice applies.
4. With debug on, prints the header: spell, skill, target name (`:642-647`).
5. Routes to `select_singing_set` or `select_standard_set` (`:649-653`).

### Config keys

| Key | Type | Used at | Meaning |
|---|---|---|---|
| `skill` | string, required | `:622`, `:635`, every path string | Name of the base set under `sets.midcast`. It does not have to be a real FFXI skill: jobs pass "pseudo-skills" that are just root set names (`'Flash'`, `'Enmity'`, `'Phalanx'`, `'Cocoon'` in PLD; `'Death'` in BLM; `'Absorb'`, `'Dread Spikes'` in DRK; `'StatusRemoval'` in WHM; `'RA'` in COR) |
| `spell` | GearSwap spell table | P0, P1, header, pickers | Only `spell.english` and `spell.target.name` are read by the manager; `target_func` receives the whole table |
| `mode_value` | string | `resolve_metadata` `:322-326` | Explicit mode. Wins over `mode_state`. Only BLM passes it (`shared/jobs/blm/functions/logic/midcast_router.lua:150-162`, value `'MagicBurst'`) |
| `mode_state` | Mote state | `:327-331` | Its `.value` is the mode when `mode_value` is absent |
| `database_func` | `function(spell_name) -> string` | `:339` | Called with `spell.english` under `pcall`. Its result is the **type** (for example `'Refresh'`, `'Enspell'`, `'mnd_potency'`). An error or `nil` means no type |
| `target_func` | `function(spell) -> string` | `:357` | Called with the whole spell under `pcall`. Its result is the **target** key (`'Composure'` from `get_enhancing_target`, `'Self'`/`'Other'` in PLD/RUN) |

Any other key is ignored. The Singing branch reads only `spell`.

`mode_state` values passed today: `state.EnfeebleMode` and `state.NukeMode` (RDM, `RDM_MIDCAST.lua:122,262`; defined in `_master/config/rdm/RDM_STATES.lua:117,126`), `state.EnhancingMode` (RDM only, `RDM_MIDCAST.lua:217`), and `state.CastingMode` (SMN, `SMN_MIDCAST.lua:135,148`; Mote creates it, the Tetsouo overlay `_master/Tetsouo/config/smn/SMN_STATES.lua:24` gives Normal/Resistant). No states file in `_master/`, `Tetsouo/`, `Kaories/` or `shared/` defines `state.EnhancingMode`, so that value is always `nil`. `state.CureMode` (`_master/config/whm/WHM_STATES.lua:75`) is read by `WHM_MIDCAST.lua` itself and never passed to `select_set`; only the unused `MidcastManager.cure` preset names it.

### Standard chain (every skill except Singing)

`select_standard_set` (`:574-610`) resolves `mode`, `type` and `target` once, then walks `RESOLVERS` (`:562-572`) in order and stops at the first set found. Table order is priority order. "base" below is `sets.midcast[skill]`.

| Level | Resolver (lines) | Runs when | Paths tried, in order |
|---|---|---|---|
| P0 | `resolve_exact_spell` (`:388-403`) | `spell.english` set | `sets.midcast[spell.english]` |
| P1 | `resolve_base_name` (`:406-442`) | `spell.english` set | `name` = `spell.english` with a trailing space-separated word made only of the letters I, V, X removed (`:411`, pattern `%s+[IVX]+$`). If a target exists: `sets.midcast[name][target]`, `sets.midcast[target][name]`, `base[name][target]`, `base[target][name]`. Then, unless target is `'others'`: `sets.midcast[name]`, `base[name]` |
| P2 | `resolve_type_target_mode` (`:445-462`) | type, target and mode all set | `base[type][target][mode]` |
| P3 | `resolve_type_mode` (`:465-478`) | type and mode | `base[type][mode]` |
| P4 | `resolve_target_mode` (`:481-494`) | target and mode | `base[target][mode]` |
| P5 | `resolve_target` (`:497-518`) | target | `base[target]`, then `sets.midcast[target]` |
| P6 | `resolve_type_root` (`:521-535`) | type | `sets.midcast[type]` |
| P7 | `resolve_type_under_skill` (`:538-547`) | type | `base[type]` |
| P8 | `resolve_mode` (`:550-559`) | mode | `base[mode]` |
| P9 | fallback (`:597-601`) | nothing above matched | `base` |

P0 and P1 go through `try_path` (`:88-116`): missing intermediate tables are fine and only the last node has to be a table. P2-P8 index tables directly and accept any non-nil value. After choosing a set, `equip_with_debug` (`:123-146`) calls `equip()` and, with debug on, prints every slot in `SLOT_ORDER` (`:77`). `is_fallback` is `selected_set == base` (`:607`). A named set that is literally the same table as the base (for example `sets.midcast['Comet'] = sets.midcast['Elemental Magic']` in the BLM sets) is therefore reported as a fallback.

The header of `midcast_manager.lua` (lines 4-13) describes this P0-P9 chain and is accurate; `.claude/CODE_QUALITY.md` §4.2 and `.claude/rules/midcast-pattern.md` were rewritten to the same chain on 2026-09-25.

```mermaid
flowchart TD
    A["select_set(config)"] --> B{"config.skill and sets.midcast?"}
    B -- no --> F0["return false"]
    B -- yes --> C{"base set exists?"}
    C -- no --> F0
    C -- yes --> D{"skill == 'Singing'?"}
    D -- yes --> S["select_singing_set"]
    D -- no --> M["resolve mode / type / target"]
    M --> P0["P0 sets.midcast[spell]"]
    P0 -- miss --> P1["P1 tier-less name x target x skill"]
    P1 -- miss --> P2["P2 base[type][target][mode]"]
    P2 -- miss --> P3["P3 base[type][mode]"]
    P3 -- miss --> P4["P4 base[target][mode]"]
    P4 -- miss --> P5["P5 base[target], sets.midcast[target]"]
    P5 -- miss --> P6["P6 sets.midcast[type]"]
    P6 -- miss --> P7["P7 base[type]"]
    P7 -- miss --> P8["P8 base[mode]"]
    P8 -- miss --> P9["P9 base"]
    P0 -- hit --> E["equip_with_debug, return true"]
    P1 -- hit --> E
    P2 -- hit --> E
    P3 -- hit --> E
    P4 -- hit --> E
    P5 -- hit --> E
    P6 -- hit --> E
    P7 -- hit --> E
    P8 -- hit --> E
    P9 --> E
```

Properties that follow from the order:

- A spell-name set (P0) or a tier-less name set (P1) beats every type, target and mode set. No level looks up `sets.midcast[spell][mode]`, so a mode sub-table hung under a spell-name set is never selected.
- When a spell's tier-less name equals its database family (Refresh, Regen, Phalanx, Stoneskin, Aquaveil in `ENHANCING_MAGIC_DATABASE`), P1 finds `sets.midcast[family]` or `base[family]` before P2-P4, so mode-specific family sets are unreachable for those spells.
- Target beats type (P5 before P6/P7) and type beats mode (P6/P7 before P8).
- The chain picks one set and never combines. Inheritance from the base set has to be written into the set file with `set_combine`.

#### Worked examples

These were checked by loading the real `midcast_manager.lua` under `lua5.1` with stubbed `sets`, `equip` and `set_combine` (2026-09-19; the resolvers have not changed since):

| Job / cast | Metadata | Result |
|---|---|---|
| RDM Refresh III on self (`_master/sets/rdm_sets.lua:391`) | type `Refresh`, target nil | P1 `sets.midcast.Refresh`, a 2-slot set (see Known issues) |
| RDM Refresh III on a party member with Composure | type `Refresh`, target `Composure` | P1 `sets.midcast.Refresh.Composure` |
| BLM Thunder VI, MagicBurstMode On | mode `MagicBurst` | P8 `sets.midcast['Elemental Magic'].MagicBurst` |
| BLM Comet, MagicBurstMode On | mode `MagicBurst` | P0 `sets.midcast.Comet`, which is the non-MB base table (see Known issues) |
| PLD Cure II (no `sets.midcast['Healing Magic']` in any PLD set file) | target `Self` | returns `false`, nothing equipped |
| RDM Slow II, EnfeebleMode Potency (traced by reading, not simulated) | type `mnd_potency` (`shared/data/magic/enfeebling/enfeebling_debuffs.lua:78`), mode `Potency` | P3 misses (`.mnd_potency.Potency` absent), P7 `base.mnd_potency`; the `.Potency` mode set is never reached while a type set exists |

### Singing chain (BRD)

`select_singing_set` (`:247-299`) has two phases: **pickers** choose one set, most specific first, and stop at the first hit (`SONG_PICKERS`, `:221`). **Layers** then `set_combine` onto whatever was chosen.

| Step | Function (lines) | Lookup |
|---|---|---|
| 1 | `song_by_name` (`:166-181`) | `sets.midcast[spell.english]` |
| 1.5 | same | `sets.midcast[name with all whitespace removed]` ("Honor March" -> `HonorMarch`, "Aria of Passion" -> `AriaofPassion`) |
| 2 | `song_by_base_name` (`:184-192`) | `sets.midcast[name without tier]` ("Valor Minuet V" -> "Valor Minuet") |
| 3 | `song_by_type` (`:195-203`) | `sets.midcast[last word of the tier-less name]` via `get_song_type` (`:695-702`): Minne, Madrigal, March, Paeon... |
| 3.5 | `song_by_first_word` (`:206-218`) | `sets.midcast[first word]` ("Honor March" -> `Honor`), skipped for one-word names |
| 4 (layer) | `layer_instrument` (`:224-233`) | `get_song_instrument(name)` (`:708-724`); if `sets.midcast.Songs[instrument]` exists it is combined on top of the pick (or used alone when nothing was picked) |
| 5 (layer) | `layer_troubadour` (`:236-245`) | with `buffactive['Troubadour']`, `sets.midcast.Songs.Duration` combined on top |
| 6 | `:278-285` | nothing picked and no layer applied: `sets.midcast.BardSong` |

`get_song_instrument` delegates to `_G.SongRotationManager.get_required_instrument`, which now delegates to `instrument_lock_config.get_instrument` (`shared/jobs/brd/functions/logic/song_rotation_manager.lua:141-143`; the duplicate table was removed 2026-09-25): Honor March -> Marsyas, Aria of Passion -> Loughnashade, all others `nil`. `BRD_MIDCAST.lua:46-50` publishes that global on first midcast. The hard-coded fallback at `midcast_manager.lua:717-721` repeats the same two pairs.

After `select_set`, the BRD router (`shared/jobs/brd/functions/logic/midcast_router.lua` `equip_normal_song`, 180-199) forces `range = _G.locked_instrument` for a song that holds the instrument lock (Honor March, Aria of Passion) and otherwise puts the instrument chosen by `state.MainInstrument` in the range slot (`apply_main_instrument`, 160-176): only the `range` of `sets.midcast.Songs[instrument]` is taken, so the family pieces stay (added in `f413682`).

Data facts that shape the result today (`_master/sets/brd_sets.lua`, same in `Tetsouo/sets/brd/brd_sets.lua`):

- `sets.midcast.Songs` holds `Gjallarhorn`, `Marsyas`, `Daurdabla`, each `set_combine(sets.midcast.BardSong, {range = ...})` (`:354-357`). There is no `Songs.Loughnashade` and no `Songs.Duration`, so the Troubadour layer never fires and Aria of Passion gets no instrument layer.
- Because `Songs.Marsyas` is a full BardSong set, layering it onto `HonorMarch` overwrites every slot BardSong defines.
- Songs that are not "normal" never reach this chain: dummy songs are equipped from `sets.midcast.DummySong` and debuff songs (Lullaby, Threnody, Elegy, Requiem, Virelai, Nocturne, Finale) are left to Mote's default midcast (`midcast_router.lua` `Router.handle_singing`, 208-234).
- `default_midcast` has already equipped `sets.midcast.BardSong` via the `spell.type` (`'BardSong'`) fallback in `select_specific_set` (`Mote-Include.lua:929-948`), so layer-only results still sit on top of the BardSong base.

### Debug mode

- `//gs c debugmidcast` is handled in each job's COMMANDS file (16 files: BLM `:313`, BRD `:248`, BST `:190`, COR `:128`, DNC `:121`, DRK `:119`, GEO `:143`, PLD `:150`, PUP `:181`, RDM `:232`, RUN `:139`, SAM `:114`, SMN `:327`, THF `:133`, WAR `:138`, WHM `:122`). Each requires the manager, calls `MidcastManager.toggle_debug()` (`midcast_manager.lua:53-59`), then prints `MessageCommands.show_debugmidcast_toggled(job, _G.MidcastManagerDebugState)`.
- **The flag lives on `windower._midcast_debug`** and is copied into `_G.MidcastManagerDebugState` every time the module loads (`:30-31`); `enable_debug` / `disable_debug` (`:39-50`) write both. It therefore survives `gs reload`, main job changes and subjob changes, and is reset only by `//lua reload gearswap` (since `11ff91e`). Job routers read the `_G` mirror to gate their own traces (`RDM_MIDCAST.lua:334`, `BRD_MIDCAST.lua:97`, `BLM_MIDCAST.lua:147`, `SMN_MIDCAST.lua:186,190`).
- Output: header (`:642-647`), mode/type/target steps (`resolve_metadata`), one line per priority checked (P1 prints only its first failing path), then the chosen path and every equipped slot (`equip_with_debug`).

### Helpers and presets

| Function | Lines | Callers |
|---|---|---|
| `get_enhancing_target(spell)` | `:663-675` | `target_func` in BRD router, BST, COR, DNC, GEO, PLD, PUP, RDM, RUN, SAM, SMN, THF, WAR, WHM midcast files. Returns `'Composure'` when `buffactive['Composure']` and the target is not the player, else `nil` |
| `get_song_type(name)` | `:695-702` | only `song_by_type` |
| `get_song_instrument(name)` | `:708-724` | `layer_instrument`, BRD router `apply_main_instrument` |
| `get_element(spell)` | `:680-685` | none |
| `rdm_enfeebling`, `enhancing`, `elemental`, `cure` | `:734-775` | none (preset config builders) |
| `MidcastManager.debug.enabled` | `:64-70` | none |
| `enable_debug`, `disable_debug`, `toggle_debug` | `:39-59` | `toggle_debug` from the 16 COMMANDS files |

## MidcastDeps

`MidcastDeps.load()` (`midcast_deps.lua:29-42`) `pcall`-requires `midcast_manager` and `ENHANCING_MAGIC_DATABASE` on first call and returns the same pair afterwards, even if a load failed (`loaded = true` is set unconditionally, `:40`). Callers: `COR_MIDCAST.lua:55`, `DNC_MIDCAST.lua:46`, `DRK_MIDCAST.lua:135`, `SAM_MIDCAST.lua:36`, `THF_MIDCAST.lua:46`, `WAR_MIDCAST.lua:39`, `WHM_MIDCAST.lua:171`, each at the top of `job_post_midcast`. These callers index `MidcastManager.select_set` without a nil check, so they depend on the manager loading.

The cache lives in module locals. GearSwap's `require` is `include_user`, which reads `package.loaded` but never writes it (`GearSwap/user_functions.lua:300-333`); caching comes from `ModuleCache`, installed by `INIT_SYSTEMS.lua:53-58` on the sandbox `_G`. Each user environment therefore gets its own `MidcastDeps` instance.

## Job usage patterns

Every `[JOB]_MIDCAST.lua` exports `job_midcast` and `job_post_midcast` on `_G` and returns them. The three samples show the variants:

**PLD** (`shared/jobs/pld/functions/PLD_MIDCAST.lua`): `ensure_modules_loaded()` (`:33`) loads the manager, `CureSetBuilder`, `EnmityOverride` and the enhancing DB. `job_midcast` (`:58-77`) handles Cure III/IV itself with `CureSetBuilder.generate` and sets `eventArgs.handled`. `job_post_midcast` (`:161-191`) returns when handled, then dispatches name-before-skill: Healing with a `'Self'`/`'Other'` `target_func` (`midcast_healing`, `:79`), Flash as pseudo-skill `'Flash'` (`midcast_flash`, `:90`), Enlight/Enlight II as `'Enmity'` (`midcast_enlight`, `:98`), Enhancing (Phalanx goes to `sets.midcast.SIRDPhalanx` when `PhalanxSIRD` or `Xp` is On, otherwise pseudo-skill `'Phalanx'`, `midcast_phalanx`, `:109`; the rest with Composure target and `get_spell_family`, `midcast_enhancing`, `:125`), Divine (`midcast_divine`, `:140`), Blue (`'Cocoon'` or `'Blue Magic'`, `midcast_blue`, `:149`). `EnmityOverride.apply_midcast(spell)` runs last (`:189`).

**RDM** (`shared/jobs/rdm/functions/RDM_MIDCAST.lua`): `job_midcast` is empty (`:75`). `job_post_midcast` (`:329-360`) looks up `SKILL_HANDLERS` (`:316`): Enfeebling with `EnfeebleMode` and `get_enfeebling_type`, then `sets.midcast['Enfeebling Magic'].Saboteur` on top when Saboteur is up (`:130-135`); Enhancing with the Accession + Phalanx exception to the plain base set (`:193-200`) and otherwise mode/target/family; Healing, Elemental (`NukeMode`), Dark with only skill and spell. The fallback to `midcast_subjob` with `skill = spell.skill` (`:296`) is gated on `spell.type == 'Magic'` (`:347`), which no spell has (`spell.type` is `WhiteMagic`, `Ninjutsu`, ...), so subjob spells (Utsusemi, Divine, Blue...) keep Mote's default set.

**BRD** (`shared/jobs/brd/functions/BRD_MIDCAST.lua`): a dispatcher (`job_post_midcast`, `:87`) that builds a `ctx` and hands off to `logic/midcast_router.lua` (Singing, Healing, Enhancing, Enfeebling, Elemental). It also defines a passthrough `job_customize_midcast_set` (`:78`).

**BLM**: `BLM_MIDCAST.lua` builds a `ctx` and hands off to `logic/midcast_router.lua`. The Enfeebling branch no longer passes the Enhancing database as `database_func` (2026-09-25; that function always returned nil for enfeebles, so the behaviour is unchanged).

## BaseSetBuilder and job set builders

Each `[JOB]_IDLE.lua` / `[JOB]_ENGAGED.lua` implements Mote's `customize_idle_set(idleSet)` / `customize_melee_set(meleeSet)` and returns `SetBuilder.build_idle_set(...)` / `build_engaged_set(...)` from `shared/jobs/<job>/functions/logic/set_builder.lua` (for example `PLD_IDLE.lua:40`). Builders layer overlays with `set_combine`, which returns a new table. When no overlay applies they can return a table from `sets` itself (the set Mote passed in, `sets.idle.Town`, `sets.Adoulin`, `sets.idle[mode]`), so a builder that writes into its result in place (DNC `apply_weapon` assigns `result.sub`, `shared/jobs/dnc/functions/logic/set_builder.lua:114`) edits that shared set when its weapon set was missing.

`BaseSetBuilder` (`shared/utils/set_building/base_set_builder.lua`):

- `apply_movement(result)` (`:37-47`): when `state.Moving.value == 'true'` (the string state created by `shared/utils/movement/automove.lua:130`) and `sets.MoveSpeed` exists, returns `set_combine(result, sets.MoveSpeed)` under `pcall`; on error shows `MessageFormatter.show_error` and returns `result`.
- `select_idle_base_town(base_set)` (`:63-81`): returns `sets.Adoulin, true` in Western/Eastern Adoulin when that set exists; otherwise `sets.idle.Town, true` when `areas.Cities` (`libs/Mote-Mappings.lua:219-247`) contains `world.area` and the area name does not contain "Dynamis"; otherwise `base_set, false`. No Dynamis zone is in `areas.Cities`, so the Dynamis test never changes the result.
- `is_in_town()` (`:87-98`): the same test without a set.

The "Used by" lists in the header (`:34`, `:57-58`) name BLM, BRD, COR, DNC, GEO, PLD, RDM, RUN, SMN, THF, WAR and WHM, which matches the code.

Who uses what:

| Job builder | Town | Movement |
|---|---|---|
| BLM, GEO | `BaseSetBuilder.select_idle_base_town` called directly | `apply_movement` outside town (`shared/jobs/blm/functions/logic/set_builder.lua:180-181`) |
| WHM | `BaseSetBuilder.select_idle_base_town` called directly (`shared/jobs/whm/functions/logic/set_builder.lua:49`) | `BaseSetBuilder.apply_movement` always, in town too (`:64`) |
| COR, DNC, PLD, RUN, THF | `SetBuilder.select_idle_base = BaseSetBuilder.select_idle_base_town` | `apply_movement` (DNC and PLD return before it in town: `shared/jobs/dnc/functions/logic/set_builder.lua:147`, `shared/jobs/pld/functions/logic/set_builder.lua:349`) |
| WAR, BRD | own `select_idle_base` wrapping `select_idle_base_town` | `apply_movement` outside town (`shared/jobs/war/functions/logic/set_builder.lua:248-253`); BRD also applies it to the engaged set (`shared/jobs/brd/functions/logic/set_builder.lua:175`) |
| RDM | `SetBuilder.check_town = select_idle_base_town`, applied after IdleMode (`shared/jobs/rdm/functions/logic/set_builder.lua:197`) | `apply_movement` outside town |
| SMN | `SMN_IDLE.lua` calls `select_idle_base_town` / `is_in_town` directly | `BaseSetBuilder.apply_movement` (`SMN_IDLE.lua:57`) |
| BST | `BaseSetBuilder.is_in_town()` for Town feet only (`shared/jobs/bst/functions/logic/set_builder.lua:121`) | inline `set_combine(..., sets.MoveSpeed)` (`:114-115`) |
| DRK | none | inline `set_combine(result, sets.MoveSpeed)` (`shared/jobs/drk/functions/logic/set_builder.lua:138-139`) |
| SAM | none | none from this module |
| PUP | `PUP_IDLE.lua:29` and `PUP_ENGAGED.lua:29` require `shared/jobs/pup/functions/logic/set_builder`, which does not exist on disk (their headers say so) | n/a |

Typical order (PLD `build_idle_set`, `shared/jobs/pld/functions/logic/set_builder.lua:329`): town base -> main weapon -> shield -> (return early in town) -> HybridMode set -> Xp set -> movement -> Sortie shield. Engaged (`build_engaged_set`, `:291`): BurtgangKC / Kraken Club / HybridMode base -> weapon -> Alber Strap -> Xp -> Sortie shield.

## SelfBuffManager

`SelfBuffManager.create({buffs = list, action_type = 'Magic'})` (`self_buff_manager.lua:135-257`) returns `{ buff_self = fn }`. A list entry is `{spell = name}` or `{ability = name}` with optional `buff` (buff name to test) and `delay` (seconds to wait after this action, default `DEFAULT_DELAY = 6`, `:30`).

`buff_self()` (`:225-254`):

1. Reads spell and ability recasts; shows an error and returns `false` if either is not a table.
2. Resources: `_G.res or windower.res or require('resources')` (`:239`).
3. `usable_entries` (`:203`) resolves each entry (`resolve_entry`, `:59`): the buff name comes from `res.buffs[data.status].en` unless given; entries with no buff name are dropped. `is_usable` (`:108`): an ability must be in `windower.ffxi.get_abilities().job_abilities`; a spell must be known and either listed for the main job at any level or listed for the subjob at a level `<=` `player.sub_job_level`.
4. `queue_ready` (`:146`) keeps entries whose buff is not active, whose recast is 0 and that were not queued in the last `CAST_COOLDOWN = 2.0` seconds (`:26`, `os.clock`). The wait for each entry is the sum of the `delay` of the entries queued before it.
5. `send_queue` (`:170`) sends every action at once as `wait N; input /ma "X" <me>` (or `/ja`) and stamps the anti-spam time.
6. With nothing to send, `show_active` (`:182`) lists the buffs already up with `MessageBuffs.show_buff_status`. If none is up (everything missing is on recast) nothing is printed and `false` is returned.

Only caller: `shared/jobs/blm/functions/logic/buff_manager.lua:25` (Stoneskin with `delay = 8`, Blink, Aquaveil, Ice Spikes), reached by `//gs c buff|buffs|buffself|selfbuff` (`BLM_COMMANDS.lua:357-366` -> global `BuffSelf()` in `blm_functions.lua:162`). The anti-spam table is per manager instance, created when `buff_manager.lua` loads.

## SubjobWarBuffs

`SubjobWarBuffs.collect()` (`subjob_war_buffs.lua:37-58`) walks Berserk (recast 1), Aggressor (4), Warcry (2): an active buff goes to `status_data` as `active`; a ready recast (`is_recast_ready`, the global defined by `RECAST_CONFIG.lua` and loaded by each entry file's `get_sets`, for example `_master/entry/Tetsouo_THF.lua:110`) goes to `abilities_to_cast`; otherwise `status_data` gets `cooldown` with `math.ceil(recast)`. `SubjobWarBuffs.cast(list)` (`:62-72`) sends the first `/ja` at once and each next one `2 * (i - 1)` seconds later. Defender is left out on purpose (Attack -25%); the header now says so instead of claiming /WAR has no Defender (2026-09-25).

It does not check the subjob. Callers: THF `SmartbuffManager.apply_war_buffs()` (`shared/jobs/thf/functions/logic/smartbuff_manager.lua:85-95`, uses both `collect` and `cast`) and DNC `collect_subjob_buffs('WAR')` (`shared/jobs/dnc/functions/logic/smartbuff_manager.lua:225`, uses `collect` only and casts through its own queue). Entry commands: `//gs c smartbuff` (THF `THF_COMMANDS.lua:158`), `//gs c smartbuff|buffself` (DNC `DNC_COMMANDS.lua:146`).

## ScholarActions and StratagemCharges

`StratagemCharges` (`stratagem_charges.lua`):

- Scholar level from main or sub job (`get_scholar_level`, `:42-50`); capacity by tier 10/30/50/70/90 -> 1..5 charges (`CHARGE_TIERS`, `:32`, `get_max` `:54-64`).
- `available()` (`:68-78`): `floor(max - max * recast / 240)` using ability recast id 231, the shared stratagem slot (`:26`, `:29`). The 240 s full-recharge constant is the base value: the Scholar 550 Job Point gift shortens it, so the estimate is slightly optimistic for a SCH main with that gift and exact for a job subbing /SCH (header `:12-16`, corrected 2026-09-25; it used to speak of merits).
- `next_charge_minutes()` (`:88-102`): time until the next whole-charge boundary, in minutes; `0` when Scholar is neither main nor sub.
- Example with 2 charges: recast 0 -> 2 available; 120 -> 1 available, next in 2.00 min; 121 -> 0 available, next in 1 s.

`ScholarActions` (`scholar_actions.lua`):

- `run_chain(steps, on_done, finish_anyway)` (`:204`): sends each step only once the previous one's buff is actually up (poll every `POLL_INTERVAL` 0.5 s, give up after `POLL_GRACE` 6 s per step, `:83`, `:89`), then runs `on_done`. `finish_anyway` decides what a step that never lands means: Klimaform is worth casting without Manifestation, a lone Sneak instead of a party one is not. BLM `klima` uses it (`BLM_COMMANDS.lua:416`).
- `chain(steps)` (`:38-40`): joins steps with `; wait 2; ` (`STEP_SPACING`, `:21`). A blind Windower chain; kept only as the spacing hint passed to `AbilityHelper.follow_up`, no chain is built with it any more.
- `light_arts()` / `dark_arts()` (`:59-67`, `:72-80`): Addendum already up -> message; Arts up -> Addendum; otherwise Arts. Addendum is tested first because it replaces the Arts buff in `buffactive`.
- `cast_with_stratagems(spell, aoe_state, needs_addendum)` (`:222-279`, replaces the old `build_accession_chain`): target `<me>` when the state is missing or On, else `<stal>`. With `needs_addendum` and Addendum: White not up, Addendum takes the first charge (without it the cast is refused); Accession takes the next when the target is `<me>` and Accession is not up. A stratagem that cannot be paid shows `warn_no_charge` (`:44-46`) and is dropped. With nothing to wait for the spell goes out at once; otherwise Light Arts (only if neither Light Arts nor Addendum: White is up) and the stratagems run through `run_steps`, then `cast_when_ready` waits until every required buff is up and casts, or warns "`<spell>` cancelled: `<buff>` never came up" at the deadline.
- `cast_under_black_addendum(spell, target)` (`:294-315`): Dark Arts, then Addendum: Black, then the spell, skipping what is already up, each step through `AbilityHelper.follow_up` (Addendum shares recast 231, so the helper watches the buff). Used for Dispel by BLM (`BLM_COMMANDS.lua:436`) and GEO (`GEO_COMMANDS.lua:385`).
- `try_aoe_subcommand(word, aoe_state)` (`:337-344`) maps `sneak`, `invi`, `invisible` (use the state) and `erase` (ignores the state, needs Addendum) through `AOE_SPELLS` (`:326-331`).
- Every new cast bumps `windower._sch_cast_seq` (`:94`, `:205`, `:257`); a pending chain from an older cast (or an older sandbox) sees the mismatch and stops.
- Messages go through `MessageFormatter.show_stratagem_no_charges` / `show_arts_already_active` / `show_warning`; the first two forward to the BLM message templates, so PLD and GEO print them with the BLM templates and a dynamic job tag.

## Commands

| Command | Handler | Effect |
|---|---|---|
| `//gs c debugmidcast` | 16 job COMMANDS files (see Debug mode) | Toggle `windower._midcast_debug` / `_G.MidcastManagerDebugState` |
| `//gs c buff` / `buffs` / `buffself` / `selfbuff` (BLM) | `BLM_COMMANDS.lua:357-366` | `SelfBuffManager` queue |
| `//gs c lightarts` | BLM `:370`, PLD `PLD_COMMANDS.lua:205` -> `ScholarActions.light_arts()`; GEO `GEO_COMMANDS.lua:337-349` (own copy) | Light Arts, then Addendum: White |
| `//gs c darkarts` | BLM `:376` -> `ScholarActions.dark_arts()`; GEO `:351-363` (own copy) | Dark Arts, then Addendum: Black |
| `//gs c aoe sneak\|invi\|invisible\|erase` | BLM `:384-387` (`state.SneakInviAOE`), PLD `:180-190` (same state; bare `aoe` runs the PLD Blue Magic rotation, which since 2026-09-25 refuses without /BLU), GEO `:366-370` (no state, always AoE) | `cast_with_stratagems` |
| `//gs c klima` / `klimaform` | BLM `:393` | Dark Arts if not up and ready, Manifestation if `KlimaformAOE` is on and a charge exists, then Klimaform (`run_chain` with `finish_anyway`) |
| `//gs c dispel` | BLM `:431`, GEO `:379` | `cast_under_black_addendum('Dispel', ...)` |
| `//gs c smartbuff` | THF `:158`, DNC `:146` (also `buffself`) | Job smartbuff, using `SubjobWarBuffs` for /WAR |

`SCH_ALT_COMMANDS.lua` defines `darkarts`, `lightarts` (level 10) and `klimaform` (level 46) (`_master/config/alt/SCH_ALT_COMMANDS.lua:38,45,187`, same in `Tetsouo/config/alt/`). The local handlers in the table above still answer those words: `CommonCommands.is_common_command` knows only built-in names and warp aliases, and the dual-box alt's commands are Mote's last lookup, reached only when `job_self_command` leaves a name unhandled (`shared/utils/dualbox/alt_commands.lua` `AltCommands.install_fallback`, see [dualbox](dualbox.md#alt-command-routing)). `//gs c alt lightarts` sends the alt's version. Commit 6970e82 moved Sneak/Invisible/Erase under `aoe` when the alt keys still took precedence over job commands.

## Configuration

No config file is read by these modules. Inputs are:

- Set tables: `sets.midcast[...]`, `sets.midcast.BardSong`, `sets.midcast.Songs[instrument]`, `sets.midcast.Songs.Duration`, `sets.MoveSpeed`, `sets.Adoulin`, `sets.idle.Town`.
- Mote states: whatever a caller passes as `mode_state`; `state.Moving`; `state.MainInstrument` (BRD router).
- Globals: `buffactive`, `player`, `world`, `areas.Cities`, `_G.SongRotationManager`, `is_recast_ready` (from `RECAST_CONFIG.lua`, tolerance 2.0 s in `_master/config_global/RECAST_CONFIG.lua:34`).
- Hard-coded constants: `CAST_COOLDOWN = 2.0`, `DEFAULT_DELAY = 6` (self buffs); `CAST_SPACING = 2` (/WAR buffs, `subjob_war_buffs.lua:30`); `STEP_SPACING = 2`, `POLL_INTERVAL = 0.5`, `POLL_GRACE = 6.0` (scholar chains); `STRATAGEM_RECAST_ID = 231`, `FULL_RECHARGE = 240` (stratagems); WAR recast ids 1/4/2.

## State & lifetime

- `windower._midcast_debug` (`midcast_manager.lua:30`, written by `enable_debug` / `disable_debug`): survives every job load, reset by `//lua reload gearswap`. `_G.MidcastManagerDebugState` is its per-load mirror (`:31`).
- `windower._sch_cast_seq` (`scholar_actions.lua:94`): generation of the latest scholar cast; pending polls of an older one stop.
- `_G.SongRotationManager`: written `BRD_MIDCAST.lua:50` on the first BRD midcast; read `midcast_manager.lua:713`.
- Module locals: `MidcastDeps` cache (`midcast_deps.lua:20-22`), `SelfBuffManager` per-instance `last_use_times`, `ScholarActions` lazy `MessageFormatter` (`scholar_actions.lua:25-33`). All die with the user environment.
- `CureSetBuilder.generate` (PLD `cure_set_builder.lua:40`, RUN `:42`) assigns `sets.midcast.Cure`, so after the first Cure III/IV that key holds the last CureSelf/CureOther choice until the next reload.
- Coroutines: the `ScholarActions` buff polls (`coroutine.schedule`, invalidated by `windower._sch_cast_seq`) and the `AbilityHelper.follow_up` polls it starts. `send_command('wait N; ...')` chains (self buffs, /WAR buffs) are handed to Windower and cannot be cancelled by a reload or job change. No events, keybinds or text objects.

## Interactions

- Mote-Include midcast pipeline (described above) and the job midcast files: see the job pages under [../jobs/](../jobs/) (for example [../jobs/pld.md](../jobs/pld.md), [../jobs/rdm.md](../jobs/rdm.md), [../jobs/brd.md](../jobs/brd.md), [../jobs/blm.md](../jobs/blm.md)).
- Messages: `MessageMidcast`, `MessageBuffs`, `MessageFormatter`, BLM templates. See [messages.md](messages.md).
- `MidcastWatchdog.on_midcast_start(spell)` is called by most `job_post_midcast` functions before routing (for example `PLD_MIDCAST.lua` `job_post_midcast`), independent of `MidcastManager`.
- Enhancing/Enfeebling databases under `shared/data/magic/` supply `database_func`.
- `AbilityHelper.follow_up` (see [precast-pipeline.md](precast-pipeline.md#abilityhelper)) runs the Addendum: Black chain.
- `JobChangeManager` (reload on job/subjob change) determines the lifetime of everything here except the `windower.*` fields.

## Invariants & gotchas

- `select_set` equips nothing unless `sets.midcast[skill]` exists, even for a spell that has its own named set (`:638-640`). No PLD set file defines `sets.midcast['Healing Magic']`, `['Divine Magic']` or `['Blue Magic']`, so for PLD those calls return `false` and Mote's default choice stands.
- Sets are chosen, never merged. A set that only lists the slots that differ (for example RDM `sets.midcast.Refresh`, `sets.midcast.Regen`) is worn over whatever was on before, which is the precast set for the slots Mote's default did not touch.
- A spell-name or tier-less-name set shadows every mode and family set for that spell (P0/P1 come first).
- `target_func` values must match the keys in the set file exactly. PLD/RUN return `'Self'`/`'Other'`; no PLD or RUN set defines those keys. RDM's `sets.midcast.CureSelf` (`_master/sets/rdm_sets.lua:286`) has no selector.
- Singing Step 1.5 removes every space: "Aria of Passion" looks up `AriaofPassion`, not the `AriaPassion` defined in the BRD sets.
- `get_enhancing_target` only returns something on a RDM main with Composure; for every other job it is `nil`.
- `SubjobWarBuffs.collect` needs the global `is_recast_ready`, which exists only after the entry file has required `RECAST_CONFIG`.
- `StratagemCharges` returns 0 when Scholar is neither main nor sub; `ScholarActions` then warns "No charges available (next charge: 0.0m)" for each stratagem it wanted.
- The debug flag outlives job changes on purpose (it is there to trace them); remember to turn it off.

## Extending

- **New skill in a job**: add a branch in `job_post_midcast` calling `MidcastManager.select_set({skill = ..., spell = spell, ...})` and define `sets.midcast[skill]` (the base set is mandatory). Pass `database_func` only if the database returns strings that match set keys.
- **Mode-specific gear**: put it under the base (`base[mode]`, P8) or under a family (`base[type][mode]`, P3). Do not hang it under a spell-name set, and do not define a root set named after a spell whose family you want mode-routed (P0/P1 would win).
- **New target key**: write a `target_func` returning the key, then define `base[key]` (P5) or `base[type][key]` / `base[type][key][mode]` (P2).
- **New song set**: name it exactly like the spell, the tier-less spell, the family word, or the first word; for a multi-word name without spaces use the name with every space removed.
- **New self-buff list for another job**: `SelfBuffManager.create({buffs = {...}})` in the job's logic folder and a `buff` command that calls `buff_self()`.
- **New /SCH cast**: add an entry to `AOE_SPELLS` (`scholar_actions.lua:326-331`) with `toggle` and `addendum` flags, or call `cast_with_stratagems` / `cast_under_black_addendum` / `run_chain` from the job command.

## Known issues

Open:

- BLM Comet never uses the MagicBurst set: P0 returns `sets.midcast['Comet']`, which is the base Elemental table (`midcast_manager.lua:388-403`, `_master/sets/blm_sets.lua:547-548`).
- RDM self-cast Refresh/Regen wear only 2 midcast slots over the precast set (`_master/sets/rdm_sets.lua:391,403`, live `Kaories/sets/rdm_sets.lua`).
- `sets.midcast.AriaPassion` is unreachable by name (`midcast_manager.lua:173`, `_master/sets/brd_sets.lua:365`).
- The Marsyas instrument layer overwrites a customised `HonorMarch` set (`midcast_manager.lua:224-233`, `_master/sets/brd_sets.lua:356`).
- PLD/RUN Healing `select_set` calls always return `false`; Cure I/II gear depends on the last Cure III/IV target (`PLD_MIDCAST.lua:79`, `cure_set_builder.lua:40`).
- Unused public API: `get_element`, the four preset builders, `MidcastManager.debug` (`midcast_manager.lua:64-70,680-685,734-775`).
- Dead `ctx.target ~= 'others'` guard (`midcast_manager.lua:423`).
- Scholar chains warn "No charges (0.0m)" when /SCH is absent (`scholar_actions.lua:44-46`).
- GEO keeps its own Light/Dark Arts toggles (`GEO_COMMANDS.lua:337-363`).
- BST and DRK repeat `apply_movement` inline (`shared/jobs/bst/functions/logic/set_builder.lua:114-115`, `shared/jobs/drk/functions/logic/set_builder.lua:138-139`).
- RDM's subjob-magic fallback is gated on `spell.type == 'Magic'` and never runs (`shared/jobs/rdm/functions/RDM_MIDCAST.lua:347`).
- DRK passes the Enhancing database's `get_spell_family` as `database_func` for Enfeebling Magic (`shared/jobs/drk/functions/DRK_MIDCAST.lua:107`).
- The `AOE_SPELLS` comment says `CommonCommands` answers `sneak`/`invi`/`erase` before the job block and sends them to the partner; since `b55f8e9` alt keys are Mote's last lookup, so that reason no longer holds (`scholar_actions.lua:317-319`).

Fixed:

- "Debug state survives reloads" was false: the flag now lives on `windower._midcast_debug` (`11ff91e`); the `.claude` standards were updated 2026-09-25.
- The fallback chain described in `.claude/CODE_QUALITY.md` §4.2, `.claude/rules/midcast-pattern.md` and the `midcast_manager.lua` header did not match the code: all three now describe P0-P9 (2026-09-25).
- `midcast_manager.lua` carried a false "copy" rationale comment: replaced (2026-09-25).
- `base_set_builder.lua` listed the wrong users: the header lists match the code.
- The comment in `self_buff_manager.lua` described a sub-second window: it now explains why `os.clock` is used for the 2.0 s window (`b6c7dc6`).
- BLM passed the Enhancing database to Enfeebling midcast (`database_func` always nil): removed (2026-09-25).
- `build_accession_chain` (a blind `wait 2` chain) was replaced by the buff-gated `cast_with_stratagems`.
- BRD kept two copies of the song -> instrument table: `SongRotationManager.get_required_instrument` delegates to `instrument_lock_config` (2026-09-25).

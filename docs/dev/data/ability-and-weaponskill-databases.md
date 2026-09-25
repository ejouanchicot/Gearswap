# Job ability and weapon skill databases

The project keeps two curated data sets under `shared/data/`: job abilities (`job_abilities/`,
one folder of small modules per job plus one factory-built aggregator per job) and weapon skills
(`weaponskills/`, one file per weapon skill type plus a lazy-loading facade). Neither data set has
behaviour of its own. They are read at runtime by three consumers: the JA announcement hook
(`shared/hooks/init_ability_messages.lua` -> `ability_message_handler.lua`, on every action whose
`action_type` is `'Ability'`), the WS announcement hook (`shared/hooks/init_ws_messages.lua`, on every
weapon skill), and the `//gs c info <name>` viewer (through `shared/utils/data/data_loader.lua`). RDM's
command fallback reads neither: it resolves names from the game resources. Offline, the job-ability
module files are the input of the generator that produced `config/alt/<JOB>_ALT_COMMANDS.lua`
(dual-box alt commands); that generator is not in the repository.

Nothing in this area registers events, keybinds, coroutines or `windower.*` fields. All state is
module-local or on the GearSwap sandbox `_G`, and is discarded every time GearSwap loads a job file.

Scope of reading: every file in `shared/data/job_abilities/` (84 module files, 21 wrappers, factory)
and `shared/data/weaponskills/` (14 files) was read in full; in addition every entry was loaded with `lua5.1` for the integrity checks in [Integrity checks](#integrity-checks).
Counts and lines were re-measured on 2026-09-25, after `45e28d9` (PUP/DRG pet commands loaded),
`72e135d` (weaponskill query API removed), `18fc471` / `c9eb8f8` (data checked against `res` and
BG-Wiki) and that day's fixes (15 JA recasts, rune texts, `_G.WS_DATABASE` root copies removed).

## Files

### Job abilities (`shared/data/job_abilities/`)

| Path | Lines | Role |
|------|-------|------|
| `JA_DATABASE_FACTORY.lua` | 67 | `Factory.create(job, opts)`: loads `<job>/<job>_<suffix>` modules and merges their `.abilities` into one flat table. |
| `<JOB>_JA_DATABASE.lua` (21 files: BLM BLU BRD BST COR DNC DRG DRK GEO MNK NIN PLD PUP RDM RNG RUN SAM SCH THF WAR WHM) | 13 each; BST 17, DRG 20, PUP 20, COR 21, SCH 25, DNC 26 | One `Factory.create` call per job. 15 use the default module list; BST, COR, DNC, DRG, PUP, SCH pass an explicit list. |
| `<job>/<job>_subjob.lua`, `<job>_mainjob.lua`, `<job>_sp.lua` (17 standard jobs) | 33-145 | `M.abilities = { [name] = entry }`. Subjob file = usable as sub (`main_job_only = false`); mainjob and sp = main only. |
| `bst/` 5 files | 42-78 | Standard three + `bst_pet_commands_mainjob.lua` (Ready, Snarl, Spur, Run Wild), `bst_pet_commands_subjob.lua` (Fight, Heel, Stay, Sic, Leave). |
| `cor/` 5 files | 44-174 | Standard three + `cor_rolls_subjob.lua` (18 rolls, Lv5-58) and `cor_rolls_mainjob.lua` (13 rolls, Lv61-97). Rolls also carry `lucky`/`unlucky`. |
| `dnc/` 15 files | 30-62 | Standard three + waltzes, sambas, steps, jigs (sub/main each), `flourishes1_subjob`, `flourishes2_subjob/_mainjob`, `flourishes3_mainjob`. Flourishes carry `fm_cost`. |
| `sch/` 7 files | 44-70 | Standard three + white and black grimoire stratagems (sub/main each). |
| `drg/` 4 files | 44-82 | Standard three + `drg_pet_commands.lua` (Dismiss, Smiting Breath, Restoring Breath, Steady Wing), loaded by `DRG_JA_DATABASE` since `45e28d9`. |
| `pup/` 4 files | 42-123 | Standard three + `pup_pet_commands_subjob.lua` (Deploy, Deactivate, Retrieve, 8 Maneuvers), loaded by `PUP_JA_DATABASE` since `45e28d9`. |
| `nin/` 2 files | 44-69 | `nin_mainjob.lua`, `nin_sp.lua`. There is no `nin_subjob` module; the factory skips it silently. |

There is no `smn/` folder and no `SMN_JA_DATABASE` (see `_master/config/alt/SMN_ALT_CUSTOM.lua:23-26`).

### Weapon skills (`shared/data/weaponskills/`)

| Path | Lines | Entries | Role |
|------|-------|---------|------|
| `UNIVERSAL_WS_DATABASE.lua` | 140 | - | Facade: `resolve()` merges the file of the WS's own skill into `_G.WS_DATABASE`; `ensure_weapon_type()`. Nothing else since `72e135d`. |
| `SWORD_WS_DATABASE.lua` | 302 | 18 | Standard schema. |
| `DAGGER_WS_DATABASE.lua` | 297 | 18 | Alternate schema (see below). |
| `H2H_WS_DATABASE.lua` | 293 | 17 | Standard schema. |
| `GREATSWORD_WS_DATABASE.lua` | 254 | 15 | Standard schema. |
| `GREATAXE_WS_DATABASE.lua` | 244 | 14 | Standard schema. |
| `AXE_WS_DATABASE.lua` | 243 | 15 | Standard schema. |
| `SCYTHE_WS_DATABASE.lua` | 255 | 15 | Standard schema. |
| `POLEARM_WS_DATABASE.lua` | 254 | 15 | Standard schema. |
| `KATANA_WS_DATABASE.lua` | 242 | 15 | Standard schema. |
| `GREATKATANA_WS_DATABASE.lua` | 247 | 15 | Standard schema. |
| `STAFF_WS_DATABASE.lua` | 340 | 18 | Standard schema. |
| `CLUB_WS_DATABASE.lua` | 345 | 17 | Standard schema. |
| `ARCHERY_WS_DATABASE.lua` | 240 | 12 | Standard schema. |

There is no Marksmanship file. The weapon files are pure data: the per-weapon helper functions
were removed in `72e135d`, and each WS is now filed once, in the file of its own skill (`18fc471`
moved the cross-filed copies out).

### Developer notes (`_dev/`, gitignored by `.gitignore:91`, local only)

| Path | Lines | Status |
|------|-------|--------|
| `_dev/JOB_ABILITIES_DATABASE.md` | 215 | Describes a pre-factory design (string-valued entries, a 12-job merge loop, PRECAST modules reading `JA_DB[spell.english]`). None of this matches the code. |
| `_dev/WS_DATABASE_SYSTEM.md` | 399 | Describes a `GREAT_AXE_WS_DATABASE` file, the DAGGER-style schema as the standard, PRECAST integration through `WS_DB[spell.english]`, and "only Great Axe complete". None of this matches the code. |
| `_dev/ATTACK_PDL_SYSTEM.md` | 258 | French design note on pDIF caps and a "count buff sources, switch to a `.PDL` WS set" rule. No `.lua` file in `shared/`, `_master/`, `Tetsouo/` or `Kaories/` implements it (the only `PDL` token in Lua is a comment at `Tetsouo/config/thf/THF_STATES.lua:71`). It does not touch the WS databases. |

### Consumers (documented elsewhere, listed for navigation)

| Path | Uses |
|------|------|
| `shared/hooks/init_ability_messages.lua` | Wraps `user_post_precast`, calls `AbilityMessageHandler.show_message` for `action_type == 'Ability'` (`:86-93`). |
| `shared/utils/messages/handlers/ability_message_handler.lua` | Requires `<JOB>_JA_DATABASE` per job, reads `.description` (`load_ja_db` `:78-85`, `find_ability_in_databases` `:150-186`, `:253`). |
| `shared/hooks/init_ws_messages.lua` | The only module that requires `UNIVERSAL_WS_DATABASE` (`:64`); calls `resolve(spell.english, spell.skill)` in `full` mode only and reads `.description` (`:122-129`). |
| `shared/utils/data/data_loader.lua` + `shared/utils/commands/info_command.lua` | `//gs c info`: loads every module file directly into `_G.FFXI_DATA`. |

`CooldownChecker`, `AbilityHelper`, `WSPrecastHandler` and `tp_bonus_handler`/`tp_bonus_calculator` do
not read these databases: cooldowns come from `spell.recast_id`, `AbilityHelper` reads Windower
`resources` and `windower.ffxi.get_abilities()` (`ability_helper.lua`). RDM's `//gs c <name>` fallback resolves names from the game
resources too (`RDM_COMMANDS.lua:43-66`, see [Commands](#commands)).

## Data schemas

### Job ability entry

Every module file has the shape `local M = {} ; M.abilities = { ['Name'] = entry } ; return M`
(COR rolls included: `cor_rolls_subjob.lua:18`, `cor_rolls_mainjob.lua:16`).

| Field | Type | Present on | Runtime reader |
|-------|------|------------|----------------|
| `description` | string | all 334 entries | `ability_message_handler.lua:253` (only in `ja_mode == 'full'`), `info_command.lua:239` |
| `level` | number | all | `info_command.lua:245`; offline alt-commands generator |
| `recast` | number, seconds (comments give the unit; SCH stratagems and rolls use `0`). 15 values were corrected against BG-Wiki on 2026-09-25 (MNK, WHM, DRK, SAM, DRG) | all | `info_command.lua:240` |
| `main_job_only` | boolean | all | offline alt-commands generator only (`main_only` in `config/alt/*_ALT_COMMANDS.lua`) |
| `cumulative_enmity`, `volatile_enmity` | number | all except the 31 rolls and `Assassin's Charge` (`thf_mainjob.lua:42-47`) | none |
| `fm_cost` | number | DNC flourishes | none |
| `lucky`, `unlucky` | number | COR rolls | none (COR roll logic uses its own `shared/jobs/cor/functions/logic/roll_data.lua`; the two copies agree for all 31 rolls) |

`display_job_ability` (`info_command.lua:236-250`) also asks for `type`, `duration`, `effect`,
`radius`, `cost`, `category`; no JA entry has them, so they are simply not printed.

### Main job vs subjob

The split is by file, and every file is consistent with its suffix (checked): all entries in
`*_subjob.lua` have `main_job_only = false`, all entries in `*_mainjob.lua`, `*_sp.lua` and
`drg_pet_commands.lua` have `main_job_only = true`. Master Level abilities are filed as subjob with a
level above 49 and a comment: Building Flourish 50, Contradance 50, Life Cycle 50, Random Deal 50,
Super Jump 50, Valiance 50, Unlimited Shot 51, Puppet Roll 52, Consume Mana 55, Ebullience 55,
Gallant's Roll 55, Rapture 55, Wizard's Roll 58.

At runtime nothing filters on `main_job_only` or `level`: an aggregator merges all files of a job,
main-only ones included, and `ability_message_handler` looks names up in the whole main and sub job
aggregators (`ability_message_handler.lua:163-171`).

### Weapon skill entry, standard schema (12 files)

| Field | Type | Notes |
|-------|------|-------|
| `description` | string | The only field read by the WS announcement (`init_ws_messages.lua:128`). |
| `type` | `'Physical'` / `'Magical'` / `'Hybrid'` | |
| `mods` | `{STAT = percent}` | |
| `hits` | number | `0` for self-target utilities (Starlight, Moonlight, Dagan, Myrkr). |
| `element` | string or nil | |
| `skillchain` | array of property names | |
| `ftp` | `{[1000]=n, [2000]=n, [3000]=n}` | |
| `skill_required` | number | |
| `jobs` | `{JOB = level}` | |
| `special_notes` | string, optional | |
| `weapon_type`, `weapon_file` | string | Not in the files: written into the entry by `merge_weapon_db` (`UNIVERSAL_WS_DATABASE.lua:102-103`). |

### Weapon skill entry, DAGGER schema

`DAGGER_WS_DATABASE.lua` uses different keys (`:31-47`): `description`, `skill_level`, `job_levels`,
`stat_modifiers` (string such as `"100% DEX"`), `sc_properties`, `requires_quest`, `quest_name`,
`requires_merit`, `merit_ranks`, `special_weapons` (array of `{weapon, level, type, bonus|aftermath}`),
`element`, `notes`. It has no `type`, `mods`, `hits`, `ftp`, `skill_required`, `jobs` or `skillchain`.
The announcement only needs `description`, so it works; `//gs c info` shows only the fields it knows
(see [Known issues](#known-issues)).

## How it works

### Building a job database

```mermaid
flowchart TD
  A["require WAR_JA_DATABASE (one wrapper per job)"] --> B["Factory.create(job_code, opts)"]
  B --> C{"next suffix in opts.modules (default: subjob, mainjob, sp)"}
  C --> D["pcall(require, 'shared/data/job_abilities/job/job_suffix')"]
  D -->|"ok and module has .abilities"| E["copy every entry into DB, later module overwrites"]
  D -->|"missing file, runtime error, or no field"| C
  E --> C
  C -->|"list exhausted"| F["return flat table name -> entry"]
```

1. The wrapper calls `Factory.create('WAR')` (`WAR_JA_DATABASE.lua:13`) or passes `opts.modules`
   (`BST_JA_DATABASE.lua:15-17`, `COR_JA_DATABASE.lua:19-21`, `DNC_JA_DATABASE.lua:15-26`,
   `DRG_JA_DATABASE.lua:18-20`, `PUP_JA_DATABASE.lua:18-20`, `SCH_JA_DATABASE.lua:19-25`).
2. `create` lowercases the job (`JA_DATABASE_FACTORY.lua:37`), picks `opts.modules` or
   `{'subjob','mainjob','sp'}` (`:38`) and `opts.source_field` or `'abilities'` (`:39`).
3. For each suffix it builds `shared/data/job_abilities/<job>/<job>_<suffix>` and `pcall(require, ...)`
   (`:45-46`). In the sandbox `require` is `include_user` (GearSwap `refresh.lua:132`), which raises
   `Cannot find the include file` for a missing file (`user_functions.lua:315-317`); the `pcall`
   swallows it, so a wrong suffix or a missing file (`nin_subjob`) is skipped without any message.
4. Entries are copied with `DB[name] = data` (`:48-50`); on a name collision inside one job the later
   module wins. There are no collisions today.
5. `opts.extra` (`:57-62`) would run a second pass with another field name. No wrapper passes it.

### Module caching and lifetime

`include_user` never writes `package.loaded`, so without help every `require` re-executes the file.
`INIT_SYSTEMS.lua:54-56` installs `ModuleCache` (`shared/utils/core/module_cache.lua:44-88`), which
replaces the sandbox `require` with a caching one keyed by the lower-cased path. From then on each
aggregator, each module file and the WS facade are executed once per sandbox. GearSwap builds a new
sandbox (`user_env`) on every job-file load (`refresh.lua:83`, `:114`, `:149`), and `JobChangeManager`
sends `gs reload` on main and sub job changes (`job_change_manager.lua:189`), so the cache, the
aggregators, `_G.WS_DATABASE` and `_G.FFXI_DATA` are all rebuilt after a job or subjob change.
Because the cache hands the same table to every caller, the entry tables mutated by
`merge_weapon_db` (`weapon_type`, `weapon_file`) are the same objects `data_loader` stores.

### Runtime lookup on an action

```mermaid
sequenceDiagram
  participant Mote as Mote precast
  participant WSHook as init_ws_messages wrapper
  participant JAHook as init_ability_messages wrapper
  participant AMH as AbilityMessageHandler
  participant UWS as UniversalWS
  Mote->>WSHook: user_post_precast(spell)
  WSHook->>JAHook: original user_post_precast
  JAHook->>AMH: show_message(spell) when action_type is Ability
  AMH->>AMH: WeaponSkill: return; Blood Pact: SMN spell DB only
  AMH->>AMH: lookup in main job DB, then sub job DB
  AMH->>AMH: miss, type held by the JA DBs: lookup in each of 21 job DBs
  AMH-->>JAHook: show_ja_activated or silent
  WSHook->>UWS: resolve(spell.english, spell.skill) when type is WeaponSkill, TP >= 1000 and ws_mode is full
  UWS-->>WSHook: entry or nil
  WSHook-->>Mote: show_ws_activated or show_ws_tp
```

Every entry file includes the ability hook before the WS hook (for example
`_master/entry/Tetsouo_WAR.lua:103` then `:109`), so the WS wrapper runs the ability wrapper first.

JA path (`ability_message_handler.lua`):

1. `show_message` returns unless `spell.action_type == 'Ability'` (`:217`), returns for
   `type == 'WeaponSkill'` (`:223`), skips `type == 'CorsairRoll'` (`:228`) and `name == 'Pianissimo'`
   (`:233`), returns when `ja_mode` is off (`:238`).
2. `find_ability_in_databases(spell.name, spell.type)` (`:150-186`): `BloodPactRage` and
   `BloodPactWard` go straight to `shared/data/magic/SMN_SPELL_DATABASE`, accepting only
   `Blood Pact: Rage/Ward` categories (`find_blood_pact`, `:130-143`).
3. Otherwise it reads `windower.ffxi.get_player()` (`:163`) and tries the main then the sub job
   database via `load_ja_db` (`:165-170`). `load_ja_db` memoises each job in `JOB_DATABASES`, storing
   `false` for a job without a database (`:79-86`).
4. On a miss, and only when `spell.type` is one of the types the JA databases hold (`DATABASE_TYPES`,
   `:94-98`: JobAbility, Scholar, Rune, Ward, Effusion, Waltz, Samba, Step, Jig, Flourish1-3), it walks
   all 21 codes in `JOBS` (`:66-70`, `:177-184`), loading every aggregator it has not loaded yet.
   `Monster` (Ready moves), `CorsairShot` (Quick Draw) and `PetCommand` stop after main/sub: the BST,
   PUP and DRG databases hold their own job's pet commands, and only that job (main or sub) can use
   them, so the main/sub pass finds them; SMN's are in no database.
5. A hit prints `show_ja_activated(name, description)` (`:271`), `description` only in `full` mode.

GearSwap gives `action_type = 'Ability'` to `/ws`, `/pet`, `/bstpet` and `/ms`
(GearSwap `statics.lua:33-35`), and `type = 'WeaponSkill'` to every weapon skill (`statics.lua:80`).
Weapon skills, pet commands, Quick Draw shots and Blood Pacts therefore reach this handler; the
type checks above keep them out of the 21-database walk.

### Weapon skill resolution

```mermaid
flowchart TD
  R["resolve(ws_name, weapon_type)"] --> C1{"in _G.WS_DATABASE.weaponskills?"}
  C1 -->|yes| RET["return entry"]
  C1 -->|no| H{"weapon_type is a configured type?"}
  H -->|yes| M1["merge_weapon_db(config for weapon_type)"]
  M1 --> C2{"found now?"}
  C2 -->|yes| RET
  C2 -->|no| NIL["return nil"]
  H -->|no| NIL
```

1. On first require the facade creates `_G.WS_DATABASE = {weaponskills={}, weapon_types={}}`
   (`UNIVERSAL_WS_DATABASE.lua:45-50`). The `loaded`, `load_stats`, `count` and `expected` fields went
   with the query API (`72e135d`, and the last ones on 2026-09-25).
2. `init_ws_messages.lua:122-129` passes `spell.skill`, the weaponskill's own skill as GearSwap reports
   it (`res.skills[id].english`), not the main hand's: a ranged WS belongs to the range slot.
3. `resolve` (`UNIVERSAL_WS_DATABASE.lua:127-134`) returns an already merged entry, else merges that
   skill's file and returns whatever it holds. Every WS is filed once, in the file of its own skill, so
   a miss means no file holds the name; nothing else is merged. `weapon_type_configs` (`:63-77`) lists
   Sword, Dagger, Hand-to-Hand, Great Sword, Great Axe, Axe, Scythe, Polearm, Katana, Great Katana,
   Staff, Club, Archery.
4. `merge_weapon_db` (`:91-109`) is idempotent per type: `weapon_types[type]` (set to the file name at
   the end, `:108`) is the "already merged" flag checked at `:92`. It stores each entry once, in
   `_G.WS_DATABASE.weaponskills[name]`, tagging it with `weapon_type`/`weapon_file` (the root copy
   `_G.WS_DATABASE[name]` was removed on 2026-09-25: nothing read it). A file that fails to load is
   not marked, so it is retried on the next miss.
5. `init_ws_messages.lua:122-133`: in `ws_mode == 'full'` it calls `resolve` and prints
   `show_ws_activated(name, description, tp)` only when an entry was found; in `on` mode it prints
   `show_ws_tp(name, tp)` without calling `resolve`.

### `//gs c info` path

`data_loader.lua` keeps its own copy in `_G.FFXI_DATA` (`:40-51`). `load_abilities` (`:156-220`)
tries 21 jobs x (3 standard suffixes + 21 special suffixes) = 504 `pcall(require)` calls, keeping the
first entry for each name. Its suffix list includes `pet_commands_subjob` and, since 2026-09-25, the
bare `pet_commands` (`:181`), so both PUP and DRG pet commands are visible to `info`.
`load_weaponskills` (`:228-251`) loads the 13 files in its own order (Sword first) and also keeps the
first entry for each name. `search_all_databases` (`info_command.lua:325-379`) looks up exact name,
then case-insensitive.

## Public API

### `JA_DATABASE_FACTORY`

`Factory.create(job_code, opts) -> table` (`JA_DATABASE_FACTORY.lua:35-65`)
- `job_code`: 3-letter job code, any case (lowercased for paths). A nil `job_code` errors at `:37`.
- `opts.modules`: array of suffixes; default `{'subjob','mainjob','sp'}`.
- `opts.source_field`: field read on each module; default `'abilities'`. No caller sets it.
- `opts.extra`: array of `{modules=..., source_field=...}` merged after the main pass. No caller sets it.
- Returns a new flat table `name -> entry`. No side effects besides the `require` calls.
- Callers: the 21 `<JOB>_JA_DATABASE.lua` wrappers only.

### `<JOB>_JA_DATABASE` (21 modules)

Return the flat table built by the factory. Only caller: `ability_message_handler.lua:81` (one per
job, lazily). Entry counts (2026-09-25): BLM 7, BLU 8, BRD 7, BST 19,
COR 40, DNC 37, DRG 18, DRK 12, GEO 14, MNK 13, NIN 7, PLD 13, PUP 21, RDM 6, RNG 15, RUN 23, SAM 14,
SCH 24, THF 15, WAR 12, WHM 9: **334**, every entry on disk.

### `UNIVERSAL_WS_DATABASE` (module `UniversalWS`)

| Function | Line | Behaviour | Callers |
|----------|------|-----------|---------|
| `resolve(ws_name, weapon_type)` | 127 | Returns the entry or nil, merging at most the one file of `weapon_type`. | `init_ws_messages.lua:126` |
| `ensure_weapon_type(weapon_type)` | 113 | Merges one file by its `res.skills` English name; ignores unknown names. | `resolve` only |

`load()`, the 13 query helpers (`get_ws_data`, `can_use`, ..., `print_load_summary`) and the seven
helpers each standard weapon file exported were removed in `72e135d`: none had a caller. The facade
and `data_loader` only read `.weaponskills`.

## Commands

The data files register no command. Commands that reach them:

| Command | Handler | Effect on this area |
|---------|---------|---------------------|
| `//gs c info <name>` | `COMMON_COMMANDS.lua:644-645` -> `DebugCommands.handle_info` (`DEBUG_COMMANDS.lua:248`) -> `InfoCommand.handle` (`info_command.lua:388`) | Loads all JA module files and/or all 13 WS files into `_G.FFXI_DATA` on first use, prints the entry. |
| `//gs c jamsg <full\|on\|off>` | `DebugCommands.handle_jamsg` (`DEBUG_COMMANDS.lua:222`) | Chooses whether JA announcements print `description`. |
| `//gs c wsmsg <full\|on\|off\|tp>` | `DebugCommands.handle_wsmsg` (`DEBUG_COMMANDS.lua:237`) | `full` prints WS `description`, and prints nothing for a WS missing from the database. |

RDM's `//gs c <ability, WS or spell name> [<target>]` fallback (the end of `job_self_command` in
`RDM_COMMANDS.lua`) does not reach these databases: `resolve_action_prefix` (`:52-66`) sends `/ja` when
`res.job_abilities` has the name with prefix `/jobability` (pet moves, prefix `/pet`, are skipped
because 51 of them share a spell's name), else `/ws` when `res.weapon_skills` has it, else `/ma` when
`res.spells` has it (`ACTION_RESOURCES`, `:43-47`).

## Configuration

The data modules read no configuration file. The consumers read the message modes from
`shared/config/message_settings.lua`, persisted per character in `<char>/config/message_modes.lua`;
defaults are `ja_mode = 'on'`, `ws_mode = 'on'` (`message_settings.lua:105-106`). Tetsouo's live file
sets `ja_mode = 'full'`, `ws_mode = 'on'`.

## State & lifetime

- `_G.WS_DATABASE` (sandbox global): created at `UNIVERSAL_WS_DATABASE.lua:45-50`, filled by
  `merge_weapon_db` (`:101-108`). It holds only `weaponskills` and `weapon_types`.
- `_G.FFXI_DATA` (sandbox global): `data_loader.lua:40-51`, flags at `:145`, `:217`, `:248`.
- Module-local: `JOB_DATABASES`, `JA_MESSAGES_CONFIG`, `recent_messages` in
  `ability_message_handler.lua:55`, `:64`, `:105`; `UniversalWS`/`modules_loaded` in
  `init_ws_messages.lua:40-43`.
- Entry tables of the weapon modules are mutated in place (`weapon_type`, `weapon_file`).
- Reads: `windower.ffxi.get_player()` (`ability_message_handler.lua:163`, `init_ws_messages.lua:113`).
- All of the above die with the sandbox: gs reload, main job change, subjob change (through
  `JobChangeManager`'s debounced `gs reload`). Between a subjob change and that reload,
  `ability_message_handler` already looks in the new sub job's database, because it reads the jobs live
  on every lookup. Zone changes and death do not touch this area.
- No events, keybinds, coroutines, text objects or `windower.*` fields. (The two hook files increment
  `windower._hook_wraps` - see [messages](../systems/messages.md).)

## Interactions

- Announcements and their modes: [messages](../systems/messages.md).
- WS precast chain (`WSPrecastHandler` does not load the facade): [precast pipeline](../systems/precast-pipeline.md).
- `//gs c info` and the debug command table: [commands and debug](../systems/commands-and-debug.md).
- Sandbox, `ModuleCache`, load order in `get_sets`: [core lifecycle](../systems/core-lifecycle.md),
  [job change lifecycle](../architecture/job-change-lifecycle.md).
- Dual-box alt commands generated from the JA module files: [dual-box](../systems/dualbox.md).
- Job pages that depend on specific entries: [PUP](../jobs/pup.md) (pet commands), [COR](../jobs/cor.md) (rolls, Quick Draw),
  [PLD](../jobs/pld.md) and [RUN](../jobs/run.md) (rune announcements come from the ability handler
  reading `RUN_JA_DATABASE`, since `Rune` is one of the `DATABASE_TYPES`; `rune_manager.lua` itself
  reads `res` for the recast. The Gelus, Tellus and Unda texts were corrected on 2026-09-25).

## Integrity checks

Run with `C:/ProgramData/chocolatey/bin/lua5.1.exe` by `dofile`-ing every module and comparing with
Windower `res/job_abilities.lua`, `res/weapon_skills.lua` and `res/skills.lua`.

| Check | Result |
|-------|--------|
| JA module files | 84, all reachable from an aggregator (since `45e28d9`). |
| JA entries | 334 on disk, 334 through the aggregators (2026-09-25). |
| Duplicate JA names (across all 84 files) | none, so the main-then-sub lookup order never changes the result. |
| JA names present in `res/job_abilities.lua` | all 334. |
| Suffix vs `main_job_only` | consistent in every file. |
| Missing fields | `cumulative_enmity`/`volatile_enmity` absent on 31 rolls and `Assassin's Charge`; no reader, no effect. |
| WS entries | 204 across 13 files, 204 distinct names (2026-09-25). |
| Cross-file WS duplicates | none since `18fc471` (the SWORD and GREATAXE copies of Aeolian Edge, Black Halo, Judgment, True Strike, Shining Strike, Dimidiation and Decimation were removed; `res` files them under Dagger, Club, Great Sword and Axe). |
| WS names present in `res/weapon_skills.lua` | all. |
| Player WS in `res` with no entry | Marksmanship (14, including Leaden Salute, Last Stand, Wildfire, Trueflight, Coronach), Sword (Atonement, Spirits Within, Glory Slash, Imperator, Knights of Rotund), Great Axe (Disaster), Hand-to-Hand (Final Paradise). |
| Schema | 12 files standard, DAGGER alternate. |
| Configured counts vs actual | no configured counts any more; the facade header lists the real per-file counts (SWORD 18, GREATAXE 14, 204 total). |

## Invariants & gotchas

- Every weapon skill reaches `AbilityMessageHandler.show_message` (GearSwap maps `/ws` to
  `action_type = 'Ability'`); it returns on `type == 'WeaponSkill'` (`ability_message_handler.lua:223`)
  before any lookup.
- A player can only use abilities of the main or sub job, and there are no cross-job duplicates, so the
  21-job fallback in `find_ability_in_databases` can only miss. Blood Pacts never reach it: their type
  sends them to the SMN database first (`:151-153`). DRG and PUP pet commands are found by the
  main/sub pass since their files are loaded.
- A missing or misspelt module file is silent (step 3 of the build). Check new files by loading them
  with `lua5.1` as in [Integrity checks](#integrity-checks), or with `//gs c info <name>`.
- Collision precedence differs by consumer (no collision exists today): factory = later module wins;
  `ability_message_handler` = main job before sub job; `data_loader` = first file in its own order wins.
- `resolve` is given the weapon skill's own skill (`spell.skill`), so it merges at most that one file. A
  WS missing from its skill's file (Atonement, every Marksmanship WS) returns nil and merges nothing
  else (`UNIVERSAL_WS_DATABASE.lua:127-134`).
- The JA handler looks up `spell.name`; the WS hook uses `spell.english`.
- Files are found through GearSwap `pathsearch`, which checks `data/<player>/` before `data/`
  (GearSwap `refresh.lua:693-703`); a file at `data/<player>/shared/data/...` would shadow the shared
  one. None exists today.
- `info` shows `Weapon Type` for a WS only after `resolve` has merged that WS's file in the same
  sandbox (shared tables through `ModuleCache`); `data_loader` does not set it.
- Descriptions are printed in FFXI chat; `_dev/JOB_ABILITIES_DATABASE.md:113` records a 50-character
  guideline.

## Extending

**Add an ability to an existing job**: add the entry to the right module file (`_subjob` if usable as
sub, else `_mainjob` or `_sp`) with all six standard fields. Nothing else is needed for announcements
or `info`. The generated `config/alt/<JOB>_ALT_COMMANDS.lua` does not pick it up (the generator is not
in the repository); add it to `<JOB>_ALT_CUSTOM.lua` if the alt should use it.

**Add a module file to a job**: create `<job>/<job>_<suffix>.lua` with `.abilities`, then add the suffix
to the wrapper's `modules` list (the default list only covers `subjob`, `mainjob`, `sp`). If the
suffix is not one of the 24 in `data_loader.lua:90-94` and `:181-201`, add it there too, or `info`
will not see it.

**Add a job**: create the folder and `<JOB>_JA_DATABASE.lua`; add the code to `JOBS` in
`ability_message_handler.lua:66-70` and `ABILITY_JOBS` in `data_loader.lua:84-88`. A job whose abilities
use a `res` type not yet in `DATABASE_TYPES` (`:94-98`) needs that type added there too.

**Add a weapon skill**: use the standard schema, in the file matching the WS's skill in
`res/weapon_skills.lua` (not the weapon that happens to unlock it).

**Add a weapon type**: create `<TYPE>_WS_DATABASE.lua` with `.weaponskills`, add
`{file=..., type=<res.skills English name>}` to `weapon_type_configs`
(`UNIVERSAL_WS_DATABASE.lua:63-77`; `type` must equal `res.skills[id].en`, the `spell.skill` that `resolve` receives, or the file is never merged),
and add the path to `WEAPONSKILL_DATABASES` in `data_loader.lua:100-114`.

## Known issues

Re-checked on 2026-09-25. Open:

- Every SMN job ability (Apogee, Astral Conduit, Mana Cede, Elemental Siphon, Astral Flow) runs the ability handler's 21-database walk: SMN has no JA database and the type is `JobAbility`, so the first one after a job-file load loads every JA database (`ability_message_handler.lua:173-184`).
- No Marksmanship file and several missing Sword/Great Axe/H2H WS; in `ws_mode == 'full'` those WS print nothing (e.g. Atonement, Leaden Salute) (`UNIVERSAL_WS_DATABASE.lua:63-77`, `init_ws_messages.lua:122-129`).
- DAGGER uses a different schema; `info` shows only the description (and element when set) for its 18 WS (`DAGGER_WS_DATABASE.lua:31-43`).
- `_dev/JOB_ABILITIES_DATABASE.md` and `_dev/WS_DATABASE_SYSTEM.md` describe a design that no longer exists.
- The recast and rune-text corrections of 2026-09-25 are checked against BG-Wiki only; `//gs c info` on a corrected JA and a rune message with `ja_mode full` are not yet seen in game.

Fixed:

- PUP and DRG pet command files not loaded by their aggregators (no JA message for maneuvers, Deploy, Retrieve, Deactivate): loaded since `45e28d9`.
- Seven WS filed in two weapon files, wrong configured counts: each WS filed once since `18fc471`; counts removed from the config and the facade header corrected (fixed 2026-09-25).
- `UniversalWS.load`, its 13 query helpers and the 77 per-weapon helpers without reader: removed in `72e135d`. The `_G.WS_DATABASE[name]` root copies: removed (fixed 2026-09-25).
- Stale factory and COR headers (`.rolls`, `extra` used by COR, a `cor_rolls` file): corrected (`b6c7dc6`).
- `//gs c info` could not see the DRG pet commands (no bare `pet_commands` suffix): added (fixed 2026-09-25).

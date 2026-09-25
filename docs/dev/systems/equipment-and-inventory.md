# Equipment checker, wardrobe auditor, refill, quiver and HP priority

Four player-triggered inventory tools and one load-time pass share this area. `//gs c checksets` walks the live `sets` table of the loaded job and reports every set slot whose item is not in an equippable bag (`shared/utils/equipment/equipment_checker.lua`). `//gs c wa` reads as text the set files of every job of the logged-in character (plus `common/`), compares the item names it finds against the eight wardrobes, and writes the unused ones to `data/wardrobe_audit.txt` (`shared/utils/equipment/wardrobe_auditor.lua`); the same file also feeds the wardrobe organizer with item-usage and bag-pin maps. `//gs c rf` restocks consumables in the inventory from the Mog Case and Mog Sack according to a per-character, per-job Lua config, pushes surplus and "foreign" consumables back, and prints a report (`shared/utils/inventory/refill_manager.lua` plus four helpers under `refill/`). `QuiverManager` opens an ammo quiver or pouch from THF and COR aftercast when the ammo stack runs low (`shared/utils/inventory/quiver_manager.lua`). None of these four is loaded at job load: each is `pcall(require, ...)`-ed on first use by its caller. The fifth, `HPPriority` (`shared/utils/equipment/hp_priority.lua`), runs once per job load from `INIT_SYSTEMS` and gives every HP piece of the loaded sets an equip `priority` (see [HP priority](#hp-priority)).

Line numbers below were re-read on 2026-09-25; where a line adds nothing the function is named instead.

## Files

| Path | Lines | Role |
|---|---|---|
| `shared/utils/equipment/equipment_checker.lua` | 489 | `//gs c checksets`: builds a name -> location cache of owned items, walks `sets`, reports unavailable slots |
| `shared/utils/equipment/wardrobe_auditor.lua` | 695 | `//gs c wa` report; text parser of set files; `build_pinned_bags` / `build_frequency_map` / `collect_all_used_names` for the wardrobe organizer |
| `shared/utils/equipment/hp_priority.lua` | 196 | Load-time pass: `priority = HP` (HP*1000+MP on BLM/RDM/GEO) on every HP piece of `_G.sets` |
| `shared/data/equipment/ITEM_HP_MP.lua` | 6 534 | Generated HP/MP table read by `hp_priority.lua` (do not edit by hand) |
| `scripts/item_db/build_item_db.py` | 379 | Builds the item database from Windower `res/` and regenerates `ITEM_HP_MP.lua` |
| `shared/utils/inventory/refill_manager.lua` | 315 | `//gs c rf` facade: plans pulls/pushes, queues the moves, schedules them 0.6 s apart |
| `shared/utils/inventory/refill/config_resolver.lua` | 245 | Picks the refill list (craft / job+subjob / fallback) and builds the cross-character foreign item set |
| `shared/utils/inventory/refill/item_resolver.lua` | 75 | Lazy name -> item id index over `res.items` |
| `shared/utils/inventory/refill/bag_scanner.lua` | 45 | Counts one item id in one bag and returns its slots |
| `shared/utils/inventory/refill/refill_panels.lua` | 227 | Chat output of the refill (banner, progress, report) |
| `shared/utils/inventory/quiver_manager.lua` | 170 | After a ranged attack with the tracked ammo, uses a quiver/pouch with `/item` when the ammo count drops to a threshold |
| `_master/Tetsouo/config/<job>/<JOB>_REFILL.lua` | 20-54 | Refill templates for Tetsouo (BLM BRD BST COR DNC PLD THF WAR) |
| `_master/Tetsouo/config/craft/CRAFT_REFILL.lua` | 34 | Refill list used while a craft set is active |
| `_master/Kaories/config/<job>/<JOB>_REFILL.lua` | 22-42 | Refill templates for Kaories (COR GEO PLD RDM) |

Live copies (gitignored): `Tetsouo/config/{blm,brd,bst,cor,craft,dnc,pld,thf,war}/*_REFILL.lua`, `Kaories/config/{cor,geo,pld,rdm}/*_REFILL.lua`. On 2026-09-25 every live file is identical to its template (`diff --strip-trailing-cr`), including both `PLD_REFILL.lua`: the Tetsouo template now has the live Echo Drops lines, and Kaories has its own overlay `_master/Kaories/config/pld/PLD_REFILL.lua`.

Related code outside this area: the command router `shared/utils/core/COMMON_COMMANDS.lua`, the message formatter `shared/utils/messages/formatters/system/message_equipment.lua` and its templates `shared/utils/messages/data/systems/equipment_messages.lua`, the dual-box IPC `shared/utils/dualbox/dualbox_sync_ipc.lua`, the craft modules `shared/utils/craft/craft_manager.lua` and `craft_commands.lua`, and the wardrobe organizer under `shared/utils/wardrobe/`.

## How it works

### `//gs c checksets`

```mermaid
flowchart TD
    A["COMMON_COMMANDS.lua:545 checksets"] --> B["handle_checksets(job_name) :139"]
    B --> C["check_job_equipment(job_name) :449"]
    C --> D{"sets is a table?"}
    D -- no --> X1["show_no_sets_found"]
    D -- yes --> E["build_cache_or_report :366 (pcall build_item_cache)"]
    E --> F["scan_all_sets :390 (pcall scan_sets_recursive from 'sets')"]
    F --> G{"any set with items?"}
    G -- no --> X2["show_no_sets_found"]
    G -- yes --> H["report_set_issues :419"]
    H --> I["show_check_summary"]
```

1. `CommonCommands.handle_command` passes the job code the job file supplied (`'WAR'`, `'BRD'`, ...; `shared/jobs/*/functions/*_COMMANDS.lua`) to `handle_checksets` (`COMMON_COMMANDS.lua:139`), which requires the checker and calls `check_job_equipment(job_name)` (`equipment_checker.lua:449`). The job name is only used for the header and warning text; the data walked is always the sandbox global `sets` of the loaded job file.
2. Item cache (`build_item_cache`, `equipment_checker.lua:184`), built once per command from one `windower.ffxi.get_items()` call:
   - `add_equipped_items` (`:138-147`) iterates `items.equipment` and treats each non-`_bag` value as an item id. In the Windower API those values are inventory indices inside the `<slot>_bag` bag, not item ids (see Known issues). Equipped items are still found by the next step because an equipped item stays in its bag.
   - `add_bag_items` (`:149`) adds inventory and wardrobe 1-8 (`EQUIPPABLE_BAGS`) as `available = true`, then `safe safe2 storage locker satchel sack case temporary` (`STORAGE_BAGS`, `:100-102`) as `in_storage = true`.
   - `add_slip_items` (`:164`) adds Porter Moogle slip contents as storage (`bag_name = 'Slip NN'`) when `pcall(require, 'slips')` succeeded at module load (`:20-23`). Inside the sandbox this resolves to Windower's `addons/libs/slips.lua` through GearSwap's path search.
   - Every name field of the resource entry in `NAME_FIELDS` (`:92-97`) becomes a lowercase key (`make_cache_adder`). With the Windower resources library only `en`, `enl` and their aliases `english`, `english_log` return strings; the Japanese fields exist too, the French and German ones do not. When two bags hold the same name, an available location replaces an unavailable one; otherwise the first one written wins (`make_cache_adder`).
3. Walk (`scan_sets_recursive`, `:341`), starting at `sets` with path `'sets'`:
   - `skip_node` (`:247`) stops at depth > 15 (`MAX_RECURSION_DEPTH`, `:28`, with an error message), at non-tables, at a table already visited in this scan (aliases such as `sets.a = sets.b` are therefore reported once, under whichever path `pairs` reaches first), and at `sets.naked` / any `*.naked` path. `visited_tables` is a module-level table (`:31`) reset by `scan_all_sets` (`:398`).
   - A table is an equipment set if any key is in `VALID_SLOTS` (`:51-72`: `main sub range ammo head neck ear1 ear2 left_ear right_ear body hands ring1 ring2 left_ring right_ring back waist legs feet`). GearSwap also accepts `ranged`, `lear`, `rear`, `learring`, `rearring`, `lring`, `rring` (`GearSwap/statics.lua:148-176`); those keys are not slots for the checker.
   - `collect_set_issues` (`:287`) takes the item name of each slot value (a string, or `.name` of a table, `get_item_name`, `:81`), looks it up lowercased, treats `'empty'` as available, and records every slot whose status is not `available`. Augments, `bag` and `priority` fields are ignored. A set that names no item (only `empty` tables, for example) is not counted.
   - The walk always continues into child tables whose key is not a slot and not `naked` (end of `scan_sets_recursive`). Paths are built with `.` separators, so `sets.precast.WS['Savage Blade']` prints as `sets.precast.WS.Savage Blade`.
4. `record_set` (`:312`) counts a set as valid or increments `storage_count` / `missing_count` once per unavailable slot per set: the same missing ring in 20 sets counts 20.
5. Output: only problems are printed (`report_set_issues`, `:419`). Each problem is two lines from `equipment_messages.lua`: `[MISSING] [SLOT] Item` or `[STORAGE] [SLOT] Item - Found in <bag>`, followed by `  Set: <path>`. The header (`[EQUIPMENT CHECK] <JOB>` between `=` rules of `MessageCore.SEPARATOR_WIDTH`, 69 characters) and the summary (`Valid Sets: v/t`, then `Items in Storage: n` and `Missing Items: n` only when non-zero) are printed by `message_equipment.lua` `show_check_header` / `show_check_summary`.
6. Errors: a throw in the cache build or in the walk is caught and reported (`show_cache_build_failed`, `show_scan_failed`); the command returns `false`. The debug lines (`show_scanning`, `show_alias_detected`, cache size) exist but only print when the file-level `local DEBUG = false` (`:26`) is edited to `true`; no command toggles it.

### `//gs c wa` and the organizer helpers

```mermaid
flowchart TD
    A["audit() :557"] --> B["parse_all_job_sets :494"]
    B --> C["discover_jobs :119 -> discover_job_files :84"]
    C --> D["walk_lua_files(data/CHAR/sets/) :54"]
    B --> E["parse_job_sets(job) :232 -> extract_items_from_text :200"]
    A --> F["scan_wardrobes :290"]
    A --> G["find_unused_items :517"]
    A --> H["export_report :418 -> data/wardrobe_audit.txt"]
    A --> I["show_ingame_summary :448"]
```

1. Sets folder: `windower.addon_path .. 'data/' .. <player name> .. '/sets/'`, falling back to `Tetsouo` when `get_player()` returns nothing (`sets_dir`, `wardrobe_auditor.lua:39-43`). Nothing is loaded with `loadfile`; files are read with `io.open` because the sandbox has no `loadfile`/`setfenv`.
2. `walk_lua_files` (`:54`) walks the tree iteratively; an entry ending in `.lua` is a file, anything else is pushed as a directory (a file without that extension is then probed with `get_dir` and returns nothing).
3. `discover_job_files` (`:84`) maps each file to a job: `<job>_sets.lua` at the root (flat layout, Kaories and the templates) or anything under `<job>/` (modular layout, Tetsouo live). Only the 22 codes in `VALID_JOBS` (`:29`) count, so root files such as `bonecraft_sets.lua` and `fishing_sets.lua` are skipped. Every file under `common/` is appended to every discovered job. `parse_job_sets` calls `discover_job_files()` again for each job, so the tree is walked once per job plus once for the job list.
4. `extract_items_from_text` (`:200-223`) removes `--` line comments, then collects every single- or double-quoted string that follows `=` (patterns 3 and 4, `name = '...'`, are already covered by patterns 1 and 2). `looks_like_item_name` (`:160`) drops `empty`, `Path: A-D`, augment-like strings (`^%u%u%u?%u?[%+%-]%d`), numbers, strings shorter than 3 characters, and strings starting with `System:` or `wardrobe`. Every string that survives is a "used" name for that job, whether or not a set references the variable that holds it. Strings in list form without `=` (`{'Aegis', 'Ochain'}`) are not collected; continuation lines of `--[[ ... ]]` block comments are.
5. `scan_wardrobes` (`:290`) lists wardrobe 1-8 with, for each item, the `en`/`english`/`enl`/`english_log` variants in lowercase (`get_all_names`, `:270`). An item is used if any variant is a used name (`find_unused_items`, `:517`). `IGNORED_WARDROBES = { wardrobe7 = true }` (`:137-139`) is counted in totals but never judged.
6. `export_report` (`:418`) writes `data/wardrobe_audit.txt`: header with scanned and failed jobs, one block per wardrobe, and a summary where `used = total - unused - ignored` (`write_report_summary`, `:398`). The file name carries no character name; each run overwrites the previous one. The chat summary (`show_ingame_summary`, `:448`) prints the unused count per wardrobe and `Used: total - unused / total`, which includes the ignored wardrobe in "used".
7. The command fails with a chat message when no job file could be read or when all wardrobes are empty (both in `audit()`).

Organizer helpers (same text parser, no report):

- `build_pinned_bags()` (`:619`) scans every `.lua` under the sets folder and records `name` + `bag` pairs. It repeatedly removes the innermost `{...}` block (at most 200 passes per file), which handles `{name=..., augments={...}, bag=...}` and nested maps such as `common/rings.lua`. The name pattern `name%s*=%s*['"]([^'"]+)['"]` stops at the first quote character of either kind. Bag strings are mapped by `BAG_NAME_TO_ID` (`:599-608`, `wardrobe`/`wardrobe 1`/`wardrobe1` -> 8, `wardrobe N` -> 10..16); any other bag string is ignored. Caller: `wardrobe/lib/state.lua`.
- `build_frequency_map()` (`:590`) and `collect_all_used_names()` (`:686`) have identical bodies and return `{[name_lower] = {[JOB] = true}}`. Callers: `wardrobe/lib/reports.lua` (declared-vs-held report of `//gs c wo scan`) and `wardrobe/lib/orchestrator_alt.lua` (`//gs c wo alt`). The docstring of `build_frequency_map` now names the report as its user.

### `//gs c rf`

```mermaid
sequenceDiagram
    participant U as Player or auto sender
    participant CC as CommonCommands.handle_refill
    participant RM as RefillManager.refill
    participant CR as ConfigResolver
    participant W as windower.ffxi
    participant IPC as DualBoxSyncIPC
    U->>CC: gs c rf
    CC->>RM: refill()
    RM->>W: get_items() one snapshot
    RM->>CR: resolve_list_for_player()
    RM->>RM: plan_item() per entry
    RM->>CR: build_foreign_items_set()
    RM->>W: first move now, then one move every 0.6 s
    RM-->>U: report after the last move
    CC->>IPC: broadcast rf
    IPC-->>RM: partner instance hook calls refill()
```

1. Entry points. `//gs c refill` / `//gs c rf` -> `COMMON_COMMANDS.lua:551-552` -> `handle_refill` (`:234`), which calls `RefillManager.refill()` and then, whatever it returned, `DualBoxSyncIPC.broadcast('rf')`. The partner instance runs the hook registered at `INIT_SYSTEMS.lua:193-198`, which calls `RefillManager.refill()` directly and does not broadcast again. `gs c rf` is also sent automatically: 2.5 s after any craft set is equipped (`lock_after_delay` in `craft_commands.lua`), 0.5 s after `//gs c uncraft` (`craft_manager.lua:188-191`), and 3.5 s after a successful wardrobe organize (`schedule_lockstyle` in `wardrobe_organizer.lua`). Each of these goes through `handle_refill` and therefore also refills the partner.
2. Guards (`refill_manager.lua:249-259`): the sandbox `player` must exist and `get_items()` must return a table; otherwise one red `[Refill]` line. There is no in-progress guard.
3. List resolution (`ConfigResolver.resolve_list_for_player`, `config_resolver.lua:192-243`):
   - No player or main job `NON`: `FALLBACK_LIST` (`:39-46`, six medicines at 12).
   - Craft mode (`_G.CraftManager.is_active()`; `craft_manager.lua` owns the session state): `require('<Char>/config/craft/CRAFT_REFILL')`; its `.default` is used (label `CRAFT (<name>)`) and its `store_bag` applies. Without the file or without `.default`, resolution falls through to the job.
   - Job: `require('<Char>/config/<job>/<JOB>_REFILL')`. If the require throws (missing file or error in the file) the fallback list is used with label `fallback (no <path>)`. `subjobs[<SUB>]` replaces `.default` entirely when present; otherwise `.default`; otherwise the fallback.
   - `store_bag` (`case` default, `sack`, `satchel`; `BAG_INFO` and `DEFAULT_STORE_BAG`, `:49-57`) only sets where surplus and foreign items go. Pulls always come from Case, then Sack (`refill_manager.lua:38-41`).
4. Planning (`plan_item`, `refill_manager.lua:153-202`), for each list entry:
   - `ItemResolver.resolve_variants(name)` keeps the variants whose name resolves in `res.items` through `en`/`enl`/`name`/`name_log` (`item_resolver.lua:30-73`). If none resolves, the row is reported with `current = 0` and `short = target` (printed as "Out of stock").
   - Held count = sum of all variants in the inventory (`count_held`, `:60`). Target: the number, or for `target = 'all'` the held count plus everything of every variant in Case and Sack (`effective_target`, `:78`).
   - Deficit > 0: pull moves, variants in list order, Case before Sack, stack by stack (`queue_deficit`, `:119`).
   - Deficit < 0: push moves of the surplus to the store bag, variants in list order (`queue_surplus`, `:94`); the preferred variant is pushed first.
5. Foreign sweep (`sweep_foreign_items`, `:209-240`): `ConfigResolver.build_foreign_items_set` (`config_resolver.lua:152-180`) loads every `*_REFILL.lua` found under `data/<Dir>/config/<sub>/` for every directory of `data/` whose name starts with an uppercase letter (`load_all_refill_configs`, `:107-124`), i.e. all characters including frozen clones; the `char_name` argument is not used. Every item id named in any of those lists (defaults and all subjob lists) that is not a variant of the current list is foreign, and every inventory stack of a foreign id is queued for a full push to the store bag.
6. Execution (`:285-313`): the queue holds pulls and pushes in plan order, foreign pushes last. `execute_move(1)` runs immediately; each move schedules the next with `coroutine.schedule(..., 0.6)`. Pushes use `windower.ffxi.put_item(dst_bag, inventory_slot, count)`, pulls `windower.ffxi.get_item(src_bag, slot, count)`. Slots and counts come from the single snapshot taken at step 2; free space in the inventory or the store bag is not checked and failed moves are not detected. The report (`RefillPanels.show_report`, `refill_panels.lua:158-225`) is printed after the last move and shows the planned numbers.
7. Output example (produced by running the module against a mock inventory holding 12 Sublime Sushi +1 and 12 Sublime Sushi on WAR):

```
==========================================================================
========================= Inventory Refill - Started =========================
==========================================================================
  Config: WAR/default
  Surplus bag: Case
  Items tracked: 1
[Refill] Transferring 1 operation ...
==========================================================================
======================== Inventory Refill - Complete =========================
==========================================================================
  Sublime Sushi +1: 24/12 -> 12/12  (-12 -> Case)
  Pushed out: 12 item(s) (surplus)
==========================================================================
```

Report row kinds (`refill_panels.lua:165-209`): foreign (`foreign (n) -> Case`), surplus, already at target (`n/t (OK)`), fully refilled, partially refilled (`Short n`), nothing available (`Out of stock! Short n`). Item names are coloured by keyword: food, ammo/quiver, everything else as medicine (`:46-54`, `:116-126`).

### Quiver auto-open

`THF_AFTERCAST.lua:50-53` and `COR_AFTERCAST.lua:31-34` require `QuiverManager` on every aftercast and call `QuiverManager.after_ranged_attack(spell, 'Acid Bolt', 'Ac. Bolt Quiver', 5)` and `after_ranged_attack(spell, 'Bronze Bullet', 'Brz. Bull. Pouch', 15)`. The names are hardcoded in the shared job modules, so they apply to every character playing THF or COR.

`after_ranged_attack` (`quiver_manager.lua:154-168`) returns `false` unless `spell.action_type == 'Ranged Attack'` (GearSwap gives `/ra` the `type` `'Misc'`) and the shot was not interrupted, and unless `player.equipment.ammo` is the tracked ammo, so a shot with other ammo does not warn about a stack that is not in use. Otherwise it schedules `check_and_refill(ammo, quiver, threshold)` 1.0 s later, so FFXI has decremented the ammo count first, and returns `true`.

`check_and_refill` (`quiver_manager.lua:90`):
1. Returns if the same quiver was used less than `OPEN_COOLDOWN = 8.0` s ago (`os.clock`, per-name table `last_open`, `:36-39`).
2. Resolves both names through its own lazy `res.items` index (`build_name_index` / `resolve_id`, `:60-86`, same fields and logic as `ItemResolver`).
3. Counts the ammo in the inventory and wardrobes 1-8 (`:27-31`); returns if the total is above the threshold.
4. If no quiver is in the inventory it prints a warning (`<ammo>: n left, no <quiver> in inventory!`) and returns without setting the cooldown, so the warning repeats on every ranged attack while the ammo stays low.
5. Otherwise it records the time, sends `input /item "<quiver>" <me>` and prints a success line.

The quiver has to be in the inventory for `/item`; the refill lists keep it there (`THF_REFILL.lua` `Ac. Bolt Quiver` 12, Kaories `COR_REFILL.lua` `Brz. Bull. Pouch` 2). Because of the foreign sweep, a character whose own list for the current job does not name the quiver has it pushed back to the store bag on every refill.

### Weapon states: `weapon_resolver.lua`

Every `set_builder` that applies `state.MainWeapon` / `state.SubWeapon` (BLM, BRD, COR, DNC, GEO, RDM, RUN,
SAM, THF, WAR; PLD and DRK use their own weapon logic) asks `WeaponResolver.set_for(slot, value)` instead of
reading `sets[value]` itself (2026-09-25).

- Default: returns `sets[value]`, exactly the old lookup. Tetsouo and Kaories have no `WEAPON_CONFIG.lua`, so
  nothing changed for them (38 weapon values audited; Tetsouo's BLM relies on `Hvergelmir` having no set, so
  its idle and engaged sets keep their own staves).
- `<Char>/config/WEAPON_CONFIG.lua` with `equip_without_set = true` (template in `_master/config_global/`):
  `sets[value]` only when it names that slot, an off-hand pick never moves the main hand, otherwise
  `{main|sub = value}` when `value` is a weapon in `res.items` (category `Weapon`, grips included), else nothing.
  Asked by Gab: plain weapons without sets, the same weapon in main or sub.

### HP priority

`INIT_SYSTEMS.lua:64-70` calls `HPPriority.apply()` once per job load, under `pcall`, right after the `ModuleCache` install: by then `get_sets()` has returned from `include('Mote-Include.lua')`, so Mote has run `init_gear_sets()` and `_G.sets` holds the job's sets.

GearSwap sends the pieces of a set from the highest `priority` to the lowest, pieces without one counting as 0 (the reason is in the header of `hp_priority.lua`). `apply()` (`hp_priority.lua:175-188`):

1. Returns 0 unless `player.name` is in `CHARACTERS` (`Tetsouo` with the top of the Unity range, `Kaories` with the bottom, `:43-46`), `player.main_job` is known, `_G.sets` is a table and the job is not in `SKIP_JOBS` (`PLD`, which keeps its hand-tuned HP deltas, `:53`).
2. Loads `ITEM_HP_MP.lua` with `pcall(dofile, windower.addon_path .. 'data/shared/data/equipment/ITEM_HP_MP.lua')`; the header comment says `dofile` is used instead of `require` so the module cache does not keep the table for the whole session.
3. Walks `_G.sets` (`walk`, `:146-166`) with a `visited` table, since sets reference each other. For every key in `SLOTS` (GearSwap's slot names and aliases, `:55-61`) whose value is a plain name or a table with a string `name` and no `priority`, it computes HP and MP (`piece_hp_mp`, `:107-116`): the table entry, plus the Unity bonus for the character's rank, plus the `HP+N` / `MP+N` augments written in the set (pet augments such as `Pet:` or `Avatar:` are ignored, `:64`, `augment_hp_mp`).
4. `priority = HP`, or `HP * 1000 + MP` on `MP_JOBS` (BLM, RDM, GEO, `:49-50`). A priority of 0 is not written. A plain name becomes `{name = ..., priority = n}`; a table gets its `priority` field. A piece that already has a `priority` is never touched.

It walks `_G.sets` as it stands at that call; returns the number of pieces changed. No message is printed.

`ITEM_HP_MP.lua` (6 534 lines, marked "GENERATED ... do not edit by hand") maps a lowercase item name to `{hp, mp}` or `{hp, mp, unity_hp_min, unity_hp_max, unity_mp_min, unity_mp_max}`. Only armor and weapons that give HP or MP are listed; when several items share a name, the highest item level wins (`write_hp_mp_lua` in the script).

To regenerate it (after a game update that changes `res/`):

```
cd "D:/Windower Tetsouo/addons/GearSwap/data/scripts/item_db"
python build_item_db.py                 # or: --res "<Windower>/res"
```

The script reads `res/items.lua`, `res/item_descriptions.lua`, `res/jobs.lua`, `res/slots.lua` and `res/skills.lua` from the Windower root (default `parents[5] / "res"` of the script), parses the stats out of the item descriptions, writes `items.sqlite`, `items.json` and `equipment.csv` to `scripts/item_db/out/` (gitignored, `.gitignore:103`), then overwrites `shared/data/equipment/ITEM_HP_MP.lua` (LF). `scripts/item_db/find_items.py` queries the SQLite file (`python find_items.py --stat hp --slot Head --job WAR --top 10`). A reload (`//gs reload`) is enough to use the new table: it is read with `dofile` at every job load.

## Public API

### EquipmentChecker (`equipment_checker.lua`)

| Function | Returns | Notes |
|---|---|---|
| `check_job_equipment(job_name)` `:449` | `boolean` | Reads the global `sets`, prints report. `false` on missing job name, no `sets`, cache or scan error, or no set with items. Caller: `CommonCommands.handle_checksets` only. |

Everything else is local. The module has no `_G` export.

### WardrobeAuditor (`wardrobe_auditor.lua`)

| Function | Returns | Side effects | Callers |
|---|---|---|---|
| `audit()` `:557` | `boolean` | Reads set files, `get_items()`, writes `data/wardrobe_audit.txt`, prints chat summary | `CommonCommands.handle_wardrobeaudit` |
| `build_frequency_map()` `:590` | `{[name_lower] = {[JOB] = true}}` | Reads set files | `wardrobe/lib/reports.lua:110` |
| `build_pinned_bags()` `:619` | `{[name_lower] = {bag_id, ...}}` | Reads set files | `wardrobe/lib/state.lua` |
| `collect_all_used_names()` `:686` | same as `build_frequency_map` | Reads set files | `wardrobe/lib/orchestrator_alt.lua:52` |

### RefillManager and helpers

| Function | Returns | Callers |
|---|---|---|
| `RefillManager.refill()` `refill_manager.lua:249` | `boolean` (true once the queue is started) | `CommonCommands.handle_refill`, IPC hook `INIT_SYSTEMS.lua:193-198` |
| `ConfigResolver.resolve_list_for_player()` `config_resolver.lua:192` | `list, source_label, store_info {id, display}` | `RefillManager.refill` |
| `ConfigResolver.build_foreign_items_set(char_name, current_list)` `:152` | `{[item_id] = config_name}` (`char_name` unused) | `sweep_foreign_items` |
| `ItemResolver.resolve_item_id(name)` `item_resolver.lua:52` | `number or nil`; builds the index on first call | `config_resolver.lua`, `resolve_variants` |
| `ItemResolver.resolve_variants(name)` `:63` | `{ {name, id}, ... }` resolved only | `plan_item` |
| `BagScanner.count_item_in_bag(items, bag_key, id)` `bag_scanner.lua:25` | `total, { {slot, count}, ... }` | `refill_manager.lua` (`count_held`, `effective_target`, `queue_surplus`, `queue_deficit`) |
| `RefillPanels.show_error(msg)` / `show_start(label, store, n)` / `show_progress(n)` / `show_report(results)` `refill_panels.lua:134-225` | - | `refill_manager.lua` only |

### QuiverManager

| Function | Returns | Callers |
|---|---|---|
| `after_ranged_attack(spell, ammo_name, quiver_name, threshold)` `quiver_manager.lua:154` | `true` when a check was scheduled | `THF_AFTERCAST.lua:52`, `COR_AFTERCAST.lua:33` |
| `check_and_refill(ammo_name, quiver_name, threshold)` `quiver_manager.lua:90` | `true` when a use-item command was sent | `after_ranged_attack` |

## Commands

| Command | Args | Effect | Handler |
|---|---|---|---|
| `//gs c checksets` | none | Walks `sets`, prints missing and storage slots and a summary | `COMMON_COMMANDS.lua:545-546` -> `handle_checksets` (`:139`) -> `equipment_checker.lua:449` |
| `//gs c wardrobeaudit`, `//gs c wa` | none | Writes `data/wardrobe_audit.txt`, prints per-wardrobe unused counts | `:547-548` -> `handle_wardrobeaudit` (`:155`) -> `wardrobe_auditor.lua:557` |
| `//gs c refill`, `//gs c rf` | none | Restock from Case/Sack, push surplus and foreign items, then broadcast `rf` to the partner | `:551-552` -> `handle_refill` (`:234`) -> `refill_manager.lua:249` |

All three names are listed in `CommonCommands.is_common_command` (`COMMON_COMMANDS.lua:687-689`). There is no command for the quiver manager, nor for HP priority.

## Configuration

Refill file schema (reference comment in `_master/Tetsouo/config/war/WAR_REFILL.lua:1-15`):

```lua
local M = {}
M.store_bag = 'case'            -- 'case' (default) | 'sack' | 'satchel'; unknown values are ignored
M.default = {                   -- used when no subjobs[<SUB>] entry exists
    {name = 'Panacea', target = 12},
    {name = {'Sublime Sushi +1', 'Sublime Sushi'}, target = 12},  -- variants share one target
    {name = 'Pet Food Theta', target = 'all'},                    -- take everything Case/Sack hold
}
M.subjobs = {                   -- optional; a subjob list REPLACES default
    DNC = { ... },
}
return M
```

- Lookup path: `<Char>/config/<job lower>/<JOB>_REFILL` through the sandbox `require`, which is GearSwap's `include_user` path search (`GearSwap/refresh.lua:677-720`: `addons/GearSwap/libs-dev/`, `libs/`, `data/<player>/`, `data/common/`, `data/`, then `%APPDATA%/Windower/GearSwap/...`, then `addons/libs/`) wrapped by the project's `ModuleCache` (`shared/utils/core/module_cache.lua`, installed near the top of `INIT_SYSTEMS.lua`). The directory scan for foreign detection uses `windower.addon_path .. 'data/'` only (`config_resolver.lua:72`, `:109`); `windower.windower_path` is not used anywhere in this area.
- Craft list: `<Char>/config/craft/CRAFT_REFILL.lua` (`config_resolver.lua:203`), only `.default` and `.store_bag` are read.
- Defaults in code: `FALLBACK_LIST` (`config_resolver.lua:39-46`), `DEFAULT_STORE_BAG = 'case'` (`:57`), `MOVE_DELAY = 0.6` (`refill_manager.lua:46`), `OPEN_COOLDOWN = 8.0` (`quiver_manager.lua:36`), quiver thresholds in the aftercast callers, `IGNORED_WARDROBES` (`wardrobe_auditor.lua:137-139`), `MAX_RECURSION_DEPTH = 15` (`equipment_checker.lua:28`), and in `hp_priority.lua` `CHARACTERS`, `MP_JOBS`, `SKIP_JOBS` (`:43-53`). None of them is read from a config file.
- Templates and deployment: `clone_character.py` (`clone()`, step 4) copies `config/<job>/` per file, taking the overlay `_master/<Source>/config/<job>/<file>` when an overlay is selected and has the file, and `_master/config/<job>/<file>` otherwise (`_resolve_src`). The overlay is selected only when the target is the source character (default `Tetsouo`) or `--source` names it (`_select_overlay`). The shared config folders (`craft`, plus `alt` for a MAIN) are copied the same way, so `config/craft/CRAFT_REFILL.lua` is now deployed. See [characters-and-templates.md](../architecture/characters-and-templates.md).

## State & lifetime

- Module state: `visited_tables` (checker, reset per scan), `_name_to_id` (ItemResolver and QuiverManager, built on first lookup), `last_open` (QuiverManager). Because `ModuleCache` stores modules on the sandbox `_G`, these live for one user environment and are rebuilt after every `gs reload` and job change (GearSwap drops `user_env` in `load_user_files`, `GearSwap/refresh.lua:81-83`).
- Globals read: `sets` (checker, `scan_all_sets` and `check_job_equipment`), `player` (refill, `RefillManager.refill`), `_G.CraftManager` (config resolver). `HPPriority` writes `priority` fields into `_G.sets` and exports `_G.HPPriority`. No `windower.*` field is used for persistence.
- Config caching: refill configs are cached by `ModuleCache` like modules, so an edited `*_REFILL.lua` is only read again after a `gs reload` or job change. A config that failed to load is not cached and is retried on the next refill.
- Files written: `data/wardrobe_audit.txt` only.
- Events, keybinds, text objects: none.
- Coroutines: the refill move chain (one `coroutine.schedule` per move, `execute_move` in `RefillManager.refill`) and the aftercast quiver check (1.0 s). Neither is tracked or cancelled; a refill started before a job change keeps moving items and prints its report from the old environment's closures.
- Zone: nothing is re-checked; a refill that spans a zone line keeps sending moves from its snapshot.

## Interactions

- Command routing and the diagnostic command table: [commands-and-debug.md](commands-and-debug.md).
- Dual-box mirror of `rf`: [dualbox.md](dualbox.md).
- `require` caching and user-environment lifetime: [core-lifecycle.md](core-lifecycle.md).
- Checker messages and templates: [messages-formatters.md](messages-formatters.md), [messages-catalog.md](messages-catalog.md). The auditor and `refill_panels.lua` print with `add_to_chat` directly; both are listed diagnostic/panel exceptions in `.claude/CODE_QUALITY.md` section 6. `QuiverManager` uses `MessageFormatter.show_warning` / `show_success`.
- Auto-medicine (`shared/utils/debuff/precast_guard.lua`) uses Echo Drops, Remedy and Panacea from the inventory, which the refill lists stock: [precast-pipeline.md](precast-pipeline.md).
- Craft: `craft_manager.lua` owns the session state (`_G.__CraftManagerState`, read through `CraftManager.is_active()`); `craft_commands.lua` and `craft_manager.lua` send `gs c rf`.
- Wardrobe organizer: `shared/utils/wardrobe/lib/state.lua`, `reports.lua`, `orchestrator_alt.lua` consume the auditor's maps; `wardrobe_organizer.lua` sends `gs c rf` after a successful run.

## Invariants & gotchas

- `checksets` matches by name only, case-insensitively, over `en`/`enl`. An augmented piece is "valid" as soon as any item with that name is in an equippable bag; `bag = 'wardrobe N'` pins are not checked either. GearSwap itself matches augments for non-Rare items and honours `bag` (`GearSwap/equip_processing.lua:79-101`, `:154-172`).
- `checksets` never sees items under the `ranged` key, which BRD sets use for Linos (`grep -rn "ranged" Tetsouo/sets/brd _master/sets/brd_sets.lua`).
- STORAGE means "owned but not in inventory or wardrobe 1-8": safe, safe2, storage, locker, satchel, sack, case, temporary, or a storage slip.
- `wa` treats any quoted string after `=` in any set file of the job, plus all of `common/`, as a used item; a ring declared in `common/rings.lua` is used by every job even if no set references it.
- Wardrobe 7 is never judged by `wa` for any character.
- A refill `subjobs` list replaces the default list. Items of the default that are missing from the subjob list are foreign on that subjob and are pushed out.
- Foreign detection is global across characters: an item named in any list of any character under `data/` is pushed out unless the current list names it. Adding a consumable to one character's list makes it foreign for every list of every character that does not name it.
- A refill entry whose `target` is neither a number (a numeric string is coerced) nor `'all'` makes `plan_item` do arithmetic on it and throws after the start banner was printed; `handle_refill` does not catch it.
- Refill moves address inventory slots by index from one snapshot; running two refills at once (two quick `rf`, or `rf` from the partner while one is running) replays moves against slots the first run already changed.
- The quiver must stay in the inventory, and the character's refill list for the job must name it, or the next refill pushes it away as foreign.

## Extending

- New refill list: add `<Char>/config/<job>/<JOB>_REFILL.lua` (and the template under `_master/<Char>/config/<job>/`), then `gs reload`. Check the effect on other characters: every item it names becomes foreign for every list that does not name it.
- New quiver pair: call `QuiverManager.after_ranged_attack(spell, ammo, quiver, threshold)` from the job's `job_aftercast`, as THF and COR do (it filters ranged attacks by `action_type`, checks the equipped ammo and adds the 1 s delay), and add the quiver to that job's refill list of every character that plays it.
- New slot alias for `checksets`: add the key to `VALID_SLOTS` (`equipment_checker.lua:51-72`).
- New ignored wardrobe for `wa`: add it to `IGNORED_WARDROBES` (`wardrobe_auditor.lua:137-139`); the in-game total will still count it as used.
- HP priority for another character or job: edit `CHARACTERS`, `MP_JOBS` or `SKIP_JOBS` in `hp_priority.lua`; a piece that should keep a hand-set order gets an explicit `priority` in its set (never overwritten).

## Known issues

Fixed since the page was first written (night cleanup `b6c7dc6` unless noted):

- Stale comments in `refill_panels.lua`, `refill_manager.lua` ("~150 lines"), `CRAFT_REFILL.lua` (now names `config_resolver` and `CraftManager.is_active()`), misplaced docstrings in the checker and auditor, the `build_frequency_map` docstring.
- `SLOT_NAMES` in `wardrobe_auditor.lua` removed.
- PLD template SCH/RDM lists now carry Echo Drops (template = live); Kaories has its own PLD overlay.
- `config/craft/` is deployed by the clone (`f6f1683`).

Still open:

- `checksets` skips the `ranged` slot key, so BRD's Linos is never checked - `VALID_SLOTS`, `shared/utils/equipment/equipment_checker.lua:51-72`
- `checksets` ignores `augments` and `bag`, so a set naming an augment variant or a pinned copy you do not have is reported valid - `collect_set_issues`, `equipment_checker.lua:287`
- `add_equipped_items` reads inventory indices from `get_items().equipment` as item ids (the code comment says so) - `equipment_checker.lua:138-147`
- Refill surplus pushes the preferred variant back first and keeps the lesser one - `queue_surplus`, `refill_manager.lua:94`
- Tetsouo's COR list lacks `Brz. Bull. Pouch`, so the global foreign sweep pushes the pouches COR_AFTERCAST needs - `_master/Tetsouo/config/cor/COR_REFILL.lua` (Kaories' list has it)
- Unresolvable refill item names are reported as "Out of stock" - `plan_item`, `refill_manager.lua:153`
- A refill config that fails to load (syntax error) silently falls back to `FALLBACK_LIST` with the label "no <path>", and its food then counts as foreign - `resolve_list_for_player`, `config_resolver.lua:192`
- Refill has no in-progress guard; overlapping runs replay stale slot moves - `RefillManager.refill`, `refill_manager.lua:249`
- `store_bag = 'satchel'` is accepted, but pulls only read Case and Sack (`SOURCE_BAGS`, `refill_manager.lua:38-41`), so surplus pushed to the Satchel is never pulled back and later reads as "Out of stock" (no current config uses it)
- Tetsouo plays SMN live (`Tetsouo/Tetsouo_SMN.lua`, `Tetsouo/sets/smn/`) but `Tetsouo/config/smn/` holds no refill file: `rf` on SMN uses `FALLBACK_LIST` and pushes every food, Echo Drops and quiver named in any list to the Case as foreign
- With no player the auditor falls back to Tetsouo's sets folder, on any character; `wo` reaches it through `build_pinned_bags` and `collect_all_used_names` - `sets_dir`, `wardrobe_auditor.lua:39-43`
- `wa` counts strings inside `--[[ ]]` block comments as used items (only `--` to end of line is stripped) - `extract_items_from_text`, `wardrobe_auditor.lua:200`
- `build_pinned_bags` truncates names containing an apostrophe - `wardrobe_auditor.lua:619`
- `wa` chat summary counts wardrobe 7 items as used while the text report does not - `show_ingame_summary`, `wardrobe_auditor.lua:448`
- Duplicated code: `build_frequency_map` and `collect_all_used_names` identical (`:590`, `:686`); QuiverManager duplicates ItemResolver's index (`quiver_manager.lua:60-86`)
- HP priority processes only the characters listed in `CHARACTERS` (Tetsouo, Kaories); a new clone gets no automatic priorities until it is added - `hp_priority.lua:43-46`
- User docs contradict the code: `docs/user/features/equipment-validation.md:30-47`, `docs/user/guides/configuration.md:196-208`, `README.md:141-145`

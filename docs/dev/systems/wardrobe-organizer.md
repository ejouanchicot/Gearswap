# Wardrobe organizer (`//gs c wo`)

The wardrobe organizer moves gear between the character's bags so that what the game reads first (W1, then W2) holds the gear the character needs, and everything else sits in "overflow" bags. It runs only on demand, from `//gs c wo` (alias `worganize`), dispatched by `CommonCommands.handle_wardrobeorganize` (`shared/utils/core/COMMON_COMMANDS.lua:150-193`, routed from `:491-492`). A run strips the character naked, locks every slot with `gs disable all`, walks through up to six phases that issue raw item-move packets (`windower.ffxi.get_item` / `put_item`), snapshots the result, retries the whole chain up to 12 times while it keeps making progress, and finally unlocks the slots and fires `gs c ls` (lockstyle) and `gs c rf` (refill). Two flows exist: the **active-job flow** (default: only the gear named by the currently loaded job's `sets` is "used") and the **all-jobs / alt flow** (every set file under `data/<char>/sets/` counts, primary/overflow come from the `ALT_*` lists). Which one `//gs c wo` runs is decided by the character's `WARDROBE_CONFIG.lua` (`SCOPE`), `//gs c wo alt` forces the second. Two read-only reports (`wo scan`, `wo keep`) and two recovery commands (`wo reset`, `wo recover`) complete the area.

Nothing in the organizer is loaded at job load: `COMMON_COMMANDS.lua:151` requires it lazily the first time a `wo` command is typed.

## Files

| Path | Lines | Role |
|---|---|---|
| `shared/utils/wardrobe/wardrobe_organizer.lua` | 697 | Public API, active-job phase chain, outer retry loop, module run state (`IS_RUNNING`, iteration counters, `start_job_tag`). Uncommitted: the reports were moved out to `lib/reports.lua` |
| `shared/utils/wardrobe/lib/config.lua` | 238 | Defaults (bag lists, timing, limits, log path) and `Config.refresh()` which overlays `data/<char>/config/WARDROBE_CONFIG.lua` |
| `shared/utils/wardrobe/lib/phases.lua` | 787 | Phase 0 (unequip + lock), shared burst loop, Phase 2/3/3.5/4, alt phases A2/A3, `enable_slots`, `force_enable_all`, `count_unpacked` |
| `shared/utils/wardrobe/lib/state.lua` | 262 | Snapshot of the bags into a state table, pin resolution (`pin_target_for`) |
| `shared/utils/wardrobe/lib/moves.lua` | 172 | Packet primitives `pull_slot` / `push_slot`, `space_in`, pin-bag ordering (`unclaimed_pins_first`) |
| `shared/utils/wardrobe/lib/items.lua` | 152 | `res.items` helpers, walk of `_G.sets` to collect used names, always-kept items (KEEP_ITEMS, warp rings) |
| `shared/utils/wardrobe/lib/orchestrator_alt.lua` | 161 | Alt / all-jobs phase chain, built by a factory that receives the organizer's state setters |
| `shared/utils/wardrobe/lib/reports.lua` | 265 | Untracked (new). `wo scan` and `wo keep` |
| `shared/utils/wardrobe/lib/warp_owned.lua` | 114 | Scan / load / save of the warp items the character owns (`WARP_ITEMS_OWNED.lua`) |
| `shared/utils/wardrobe/lib/chat.lua` | 151 | Chat panel helpers (direct `windower.add_to_chat`; listed as an allowed exception in `.claude/CODE_QUALITY.md` section 6) |
| `shared/utils/wardrobe/lib/log.lua` | 42 | `wardrobe_debug.log` writer, `bag_name()` |
| `_master/Tetsouo/config_global/WARDROBE_CONFIG.lua` | 53 | Tetsouo template, deployed as `Tetsouo/config/WARDROBE_CONFIG.lua` (identical on disk) |
| `_master/Kaories/config_global/WARDROBE_CONFIG.lua` | 58 | Kaories template, deployed as `Kaories/config/WARDROBE_CONFIG.lua` (identical on disk) |

External dependency: `shared/utils/equipment/wardrobe_auditor.lua` provides `build_pinned_bags()` (`:623-678`), `collect_all_used_names()` (`:691-698`) and `build_frequency_map()` (`:594-600`). All three parse set-file text found by the recursive walk of `data/<char>/sets/` (`:51-72`), not the loaded `sets` table: `build_pinned_bags()` reads every `.lua` of the tree (root files such as `bonecraft_sets.lua` included), the other two only the files `discover_job_files()` maps to a job code, plus `common/` (`:81-111`).

There is no generic `WARDROBE_CONFIG.lua` in `_master/config_global/`; `clone_character.py:641-655` copies `config_global` files from `_master/config_global` and the character overlay, so a clone without an overlay file runs on the defaults of `lib/config.lua`.

## Vocabulary

| Term | Meaning in the code |
|---|---|
| Bag ids | `0` inventory, `5` Satchel, `6` Sack, `7` Case, `8` W1, `10` W2, `11..14` W3..W6, `15` W7, `16` W8 (`lib/config.lua:6-8`, `Config.BAG_LABELS` `:223-236`) |
| Primary bags | `Config.PRIMARY_BAGS`, default `{8, 10}`. Where the used gear must live, in load order |
| Overflow bags | `Config.OVERFLOW_BAGS`, default `{16, 14, 13, 12, 11}` (W8 first). Push order for unused gear |
| Used | An item whose name (any of `en`/`enl`/`english`/`english_log`, lower-cased, `lib/items.lua:23-36`) is in `used_names` |
| Movable | `status == 0` and `res.items[id].slots ~= 0` (`lib/items.lua:46-49`). Equipped (5), bazaar, linkshell copies are never moved |
| Pin | `{name = 'X', bag = 'wardrobe N'}` found anywhere in the character's set files. `pinned_bags[name_lower] = {bag_id, ...}`, deduplicated, in the order the parser meets them (file-walk order, innermost tables first), which is not necessarily declaration order |
| `w1w2_unused` | State list: entries in a primary bag that must leave (unused, or pinned elsewhere) |
| `w3w6_used` | State list: entries in a scanned non-primary bag that must be promoted (used, or pinned elsewhere) |
| Misplaced | `#w1w2_unused + #w3w6_used + inventory gear that is not used` (`wardrobe_organizer.lua:263-264`) |

## How it works

### Command entry

`handle_wardrobeorganize(arg, arg2)` (`COMMON_COMMANDS.lua:150-193`) compares `arg` case-sensitively (the router lower-cases only the command name). Anything unrecognised falls through to `organize()`.

`WardrobeOrganizer.organize()` (`wardrobe_organizer.lua:499-526`):

1. Refuses if `IS_RUNNING` (`:500-503`) or if `_G.sets` is not a table (`:504-507`).
2. `Config.refresh()` (`:508`, see Configuration).
3. If `Config.SCOPE == 'all_jobs'`, delegates to `organize_alt()` (`:513-515`).
4. `reset_module_state()` and `pcall(start_organize)`; on error re-enables slots and prints (`:517-525`).

### Active-job phase chain

```mermaid
flowchart TD
    A["organize()"] --> B["start_organize: outer_iteration++ (:462)"]
    B -->|"iteration > 1 and job changed"| X["abort_run"]
    B --> P0["Phase 0: Phases.unequip (phases.lua:92)"]
    P0 --> P1["Phase 1: build_state_and_dispatch (:407)"]
    P1 -->|"job changed"| X
    P1 -->|"nothing to do"| OK["clean_exit + schedule_lockstyle"]
    P1 -->|"only inventory leftovers or packing"| P35
    P1 --> P2["Phase 2: empty_w1w2 (phases.lua:333)"]
    P2 -->|"PHASE_DELAY 1.5 s"| R["rebuild_then_phase3 (:382)"]
    R -->|"job changed"| X
    R -->|"snapshot failed"| P4b["Phase 4 with Phase-1 state"]
    R --> P3["Phase 3: fill_w1w2 (phases.lua:397)"]
    P3 -->|"PHASE_DELAY 1.5 s"| P35["Phase 3.5: compact_primary if count_unpacked > 0 (:359)"]
    P35 --> P4["start_phase4 (:349)"]
    P4 -->|"job changed"| X
    P4 --> C4["Phase 4: cleanup_inv (phases.lua:460)"]
    P4b --> F
    C4 --> F["finish_run: SETTLE_DELAY 2 s, snapshot (:249)"]
    F -->|"misplaced > 0, progress, under cap"| B
    F -->|"misplaced == 0"| OK
    F -->|"no retry"| V["last-chance verify after 2 s (:286)"]
    V -->|"0 misplaced"| OK
    V -->|"progress and under cap"| B
    V -->|"otherwise"| S["print_summary + dump_stuck_items, clean_exit, schedule_lockstyle"]
```

**Phase 0 - unequip and lock** (`phases.lua:92-154`). Sends `gs enable all` first (`:101`; the comment at `:95-100` records why: a previous run cut short left the slots disabled and `equip()` is a no-op on a disabled slot). After 0.3 s it tries up to four strategies, each followed by a 1.2 s settle and a check of `windower.ffxi.get_items().equipment` (`still_equipped`, `:70-79`):

1. `gs c naked` (handled by `CommonCommands.handle_naked`, `COMMON_COMMANDS.lua:303-317`),
2. `gs c naked` again,
3. `gs equip naked` (GearSwap's built-in `sets.naked`, `GearSwap/refresh.lua:143-146`),
4. `input /equip <slot> empty` for every slot still occupied, using the Windower equipment key names (`left_ear`, `right_ring`, ...; `:55-58`, `:109-114`).

As soon as a check finds no equipped slot, or after the fourth attempt regardless of the result (`:127-135`), it sends `gs disable all` and calls the continuation 0.3 s later (`:117-123`). Because each iteration re-enters Phase 0, the slots are briefly re-enabled at the start of every retry.

**Phase 1 - recensement** (`build_state_and_dispatch`, `wardrobe_organizer.lua:407-456`). Checks `job_changed()`, builds the state (`State.build_state`, below), counts inventory gear split into used/unused (`count_inv_gear`, `:165-180`) and the number of used items that could move from a later primary bag into an earlier one (`Phases.count_unpacked`, `phases.lua:595-619`). Then:

- nothing to evict, promote, clean or pack: success message, `clean_exit`, `schedule_lockstyle` (`:432-444`);
- nothing to evict or promote: skip to Phase 3.5 then Phase 4 (`:448-453`);
- otherwise Phase 2 (`:455`).

**Phase 2 - empty the primary bags** (`phases.lua:333-388`). Pending = movable items in `PRIMARY_BAGS` that are unused and unpinned, or whose pin resolves to another bag. Drainable = movable inventory gear that is pinned (destinations = its pins, empty pins first) or unused (destinations = `OVERFLOW_BAGS`). Used unpinned inventory gear is left for Phase 3.

**Phase 2.5 - re-snapshot** (`rebuild_then_phase3`, `wardrobe_organizer.lua:382-396`) rebuilds the state; if that fails it jumps to Phase 4 with the Phase 1 state (`:388-393`).

**Phase 3 - fill the primary bags** (`phases.lua:397-452`). Pending = movable items in `OVERFLOW_BAGS` that are used and unpinned, or whose pin resolves to another bag. Drainable = inventory gear that is pinned (to its pins) or used (to `PRIMARY_BAGS` only, never back to overflow - `:393-395`).

**Phase 3.5 - pack** (`start_phase_pack` `wardrobe_organizer.lua:359-368`, `Phases.compact_primary` `phases.lua:630-686`). Runs only when `count_unpacked(state) > 0`. For every primary bag after the first, pulls at most as many used, unpinned items as the earlier primary bags have free slots (`:638-659`), and pushes every used inventory item, pinned or not, back to the first primary bag with room (`:664-678`). `discover_pending` recomputes the room from `get_bag_info` on every step without counting what already waits in the inventory, so on the next step it pulls up to the same number again; the surplus finds the first bag full and is pushed back to the later bag it came from, contrary to the comment at `:622-623`. `count_unpacked` applies the same filters so the Phase 1 decision matches what the phase will do (comment `phases.lua:590-592`).

**Phase 4 - inventory cleanup** (`phases.lua:460-571`). Guarded by `job_changed()` in `start_phase4` (`wardrobe_organizer.lua:349-356`). Builds a plan for every movable inventory item (`:464-503`):

| Item | Destination order |
|---|---|
| Pinned and used | its pins (empty pins first), `PRIMARY_BAGS`, `FILL_FALLBACK` |
| Pinned, not used | its pins, `FILL_FALLBACK` |
| Used, unpinned | `PRIMARY_BAGS`, `FILL_FALLBACK` |
| Unused, unpinned | `OVERFLOW_BAGS` only |

It pushes one item every `MOVE_DELAY` (0.35 s), re-checking that the slot still holds the same id (`:548-550`), and runs up to `CLEANUP_MAX_PASSES` (3) passes 0.7 s apart; a fourth plan that is still non-empty is logged as `LEFTOVER` and the phase ends (`:520-528`).

**finish_run** (`wardrobe_organizer.lua:249-342`). After `SETTLE_DELAY` (2 s) it snapshots again and computes the misplaced count. `should_retry` (`:184-193`) retries when misplaced > 0, `outer_iteration < MAX_OUTER_ITERATIONS` (12) and the count has not been identical `TRULY_STUCK_THRESHOLD` (4) times in a row. The retry keeps the slots locked in the meantime but the next Phase 0 re-enables them (`phases.lua:101`). When no retry is granted and misplaced > 0, a "last-chance verify" re-snapshots 2 s later (`:286-333`): clean -> success; fewer misplaced and under the cap -> one more iteration with the stuck counter reset; otherwise the summary panel (`print_summary`, `:196-223`) and a per-item dump to the log (`dump_stuck_items`, `:226-243`).

`schedule_lockstyle` (`:123-132`) runs on every successful or "with leftovers" exit, never on abort, crash, preview, verify or the "snapshot failed" exit of `finish_run` (`:253-257`): `gs c ls` after 1.5 s, `gs c rf` after 3.5 s. `gs c rf` also broadcasts `rf` to the dual-box partner through `DualBoxSyncIPC` (`COMMON_COMMANDS.lua:209-213`, hook registered at `INIT_SYSTEMS.lua:167`), so the partner refills its consumables too. No re-equip is requested: the character stays naked until the next GearSwap event, except for equip requests GearSwap queued while the slots were disabled, which `gs enable` flushes (`GearSwap/user_functions.lua:145-183`).

### The burst loop (Phases 2, 3, 3.5, A2, A3)

`run_burst_loop(opts)` (`phases.lua:205-327`) is shared by every phase except 0 and 4. Each phase supplies `discover_pending()` (items to pull out of a source bag) and `discover_drainable()` (inventory items with a destination list). Every step re-discovers both from live bag contents, so slot indices are never reused across steps.

```mermaid
stateDiagram-v2
    [*] --> Step
    Step --> Done: steps above MAX_STEPS (200)
    Step --> Done: pending + drainable is 0
    Step --> Done: remaining unchanged for 4 samples (cycle)
    Step --> Burst
    Burst --> Done: 4 bursts in a row moved nothing (STUCK_LIMIT)
    Burst --> Step: wait max(1.0, min(3.0, packets x 0.1)) s
    Done --> [*]
```

Per step (`:224-324`):

1. `push_budget = min(BURST_SIZE (30), #drainable)`; `pull_budget = min(30 - push_budget, inv_free + push_budget, #pending)` (`:260-265`). Pushes are sent first so the captured inventory indices stay valid; pulls go after (`:167-175` comment).
2. Pushes walk each drainable's `dst_list` and use the first bag whose `space_in()` is positive. For pinned items a per-burst `(id, bag)` claim table keeps two copies of the same ring from both targeting the same pin (`:268-289`), because `space_in()` does not change until the server answers.
3. Pulls call `pull_slot(bag, slot)` for the first `pull_budget` pending entries (`:297-301`).
4. Delay before the next step: `max(1.0, min(POST_BURST_DELAY (3.0), packets * 0.1))` (`:319-323`).

`space_in` reads `windower.ffxi.get_bag_info` (`moves.lua:31-34`) and is not decremented locally, so within one burst several pushes can target a bag that has fewer free slots than pushes; whatever did not land is still in the inventory at the next step, where it is re-discovered and routed again (by then the full bag reports no space). A pull-only step leaves `pending + drainable` unchanged (the items move from one list to the other), so the cycle counter only trips when pushes also fail for several consecutive steps.

### Move primitives

| Function | Packet | Guards (`moves.lua`) |
|---|---|---|
| `pull_slot(src_bag, src_slot)` | `windower.ffxi.get_item(src_bag, src_slot, count)` bag -> inventory | inventory has space, slot non-empty, `status == 0` (`:38-63`) |
| `push_slot(inv_slot, dst_bag)` | `windower.ffxi.put_item(dst_bag, inv_slot, count)` inventory -> bag | destination has space, slot non-empty, `status == 0` (`:67-84`) |

All moves go through the inventory; there is no direct bag-to-bag move. Neither function waits for the server; both return `true` as soon as the packet is sent. The whole stack (`it.count`) is moved.

### State snapshot and pins

`State.build_state()` (`state.lua:168-246`):

1. `used_names = Items.collect_used_names()` (`items.lua:143-150`): recursive walk of the loaded `_G.sets` (depth cap 50, cycle-safe, `:67-85`) collecting every string stored under a slot key or `name` (`Config.SLOT_KEYS`, `config.lua:68-90`), then `Items.add_always_kept` (`items.lua:113-139`): every `KEEP_ITEMS` name, plus the warp items when any `OVERFLOW_BAGS` entry is not equippable (`overflow_stays_reachable`, `:91-101`). The warp list comes from `WARP_ITEMS_OWNED.lua` when present, otherwise from `WarpDatabase.get_all_item_names()` (`warp_database_core.lua:236-253`).
2. `pinned_bags = WardrobeAuditor.build_pinned_bags()` (pcall'd, `state.lua:174-180`). The auditor strips comments, then repeatedly replaces every innermost `{...}` block that has no nested brace with `''`, extracting `name=` and `bag=` from each (leaf-first, max 200 passes, `wardrobe_auditor.lua:637-677`). This is what finds the second ring of a pair inside a nested table and a pin written after an `augments={...}` table. Only `wardrobe`, `wardrobe N` and `wardrobeN` names map to a bag (`:603-613`).
3. Snapshots every bag of `Config.ALL_WARDROBES` (movable equipment only, `snapshot_bag` `:136-154`).
4. Resolves each entry's target with one shared `claim_pool` in `ALL_WARDROBES` order (`:200-213`) and fills `w1w2_unused` / `w3w6_used` (`:219-243`). Inventory is not part of the state lists; it is counted separately by the orchestrator.

`State.pin_target_for(entry, pinned_bags, claim_pool)` (`state.lua:96-132`), per item name:

1. On first sight of the name, the pool is the pin list minus any pin bag that holds a non-movable copy (`init_claim_pool_for`, `:40-64`).
2. If the entry's own bag is still in the pool, claim it (stay put).
3. Else claim the first pool bag that holds no copy at all (status ignored, `bag_holds`, `:74-81`).
4. Else, if the entry already sits in one of its pins, return that bag (no move).
5. Else `nil` (pinned, but not in any pin and no free pin) - it then follows the used/unused rules.

`Moves.unclaimed_pins_first` (`moves.lua:145-170`) orders the same pins for the drainers: pins holding no copy first, pins holding a copy last. Steps 3 and 4 of `pin_target_for` were aligned with that ordering by commits `44e7f66` and `3d8cb28` so the snapshot never asks for a move the drainer then undoes.

Phase 2 and Phase 3 re-run `pin_target_for` with a fresh `claim_pool` over only their own source bags (`phases.lua:339-346`, `:403-410`), so their claims can differ from the snapshot's when copies are spread over primary and overflow; the drainer's ordering is what finally decides the destination.

### Alt / all-jobs chain

`organize_alt()` (`wardrobe_organizer.lua:680-695`) shares `IS_RUNNING` with the active-job flow and starts `AltOrchestrator.start` (`orchestrator_alt.lua:129-156`), built at module load by `OrchestratorAlt.create(ctx)` (`wardrobe_organizer.lua:657-667`) with the organizer's setters and helpers injected.

```mermaid
sequenceDiagram
    participant O as organize_alt
    participant A as AltOrchestrator
    participant P as Phases
    O->>A: start()
    A->>A: build_alt_state() - used = all set files plus always-kept
    A->>P: unequip(cb)
    P-->>A: alt_phase2 (job_changed guard)
    A->>P: empty_alt - ALT_PRIMARY unused to ALT_OVERFLOW
    P-->>A: after 1.5 s, alt_phase3 (job_changed guard, re-snapshot)
    A->>P: fill_alt - ALT_OVERFLOW used to ALT_PRIMARY
    P-->>A: after 1.5 s, alt_phase4
    A->>P: cleanup_inv(used, empty pins, alt_finish)
    P-->>A: alt_finish after 2 s - enable slots, panel, schedule_lockstyle
```

Differences from the active-job flow:

- `used_names` = `WardrobeAuditor.collect_all_used_names()` (text regex over the job-mapped set files plus `common/`, `wardrobe_auditor.lua:205-230`) plus `Items.add_always_kept` (`orchestrator_alt.lua:38-60`).
- Pins are ignored (`pinned_bags = {}`, `:56`; comment `phases.lua:579-580`).
- No Phase 3.5, no outer retry, no misplaced count, no last-chance verify; the final panel only shows free slots (`:72-93`).
- Phase 4 is the same `Phases.cleanup_inv`, which reads the regular `PRIMARY_BAGS` / `FILL_FALLBACK` / `OVERFLOW_BAGS`, not the `ALT_*` lists (see Known issues).
- No `with_panic_unlock` wrapper on any alt callback.

### Read-only commands

- `preview()` (`wardrobe_organizer.lua:529-601`): refresh config, build the state, print counts (evict, promote, pinned moves), and log every planned move to `wardrobe_debug.log` (the log is truncated first).
- `verify_global()` (`:604-626`): refresh config, build the state, report `w1w2_unused` and `w3w6_used`. Neither counts Phase 3.5 packing or inventory leftovers.
- `Reports.show_kept()` (`reports.lua:210-263`): lists `KEEP_ITEMS` and, when overflow is not all equippable, the warp items and where the list came from.
- `Reports.scan_warp_items()` (`reports.lua:168-203`): `WarpOwned.scan()` walks every bag of `windower.ffxi.get_items()` (storage included, `warp_owned.lua:51-88`), saves the names found to `data/<char>/config/WARP_ITEMS_OWNED.lua` (`:94-112`), then writes `data/wardrobe_scan_<char>.txt` (`write_scan_report`, `reports.lua:60-162`): bag occupancy, warp items with their bag, and per-job "declared in the sets vs held" counts from `WardrobeAuditor.build_frequency_map()`.

## Public API

`shared/utils/wardrobe/wardrobe_organizer.lua` returns a table; nothing is exported to `_G`. The only caller of every function below is `CommonCommands.handle_wardrobeorganize` (`COMMON_COMMANDS.lua:150-193`); no keybind, macro config or `send_command` in the repository or the live folders invokes a `wo` subcommand.

| Function | Effect |
|---|---|
| `organize()` (`:499`) | Active-job run, or `organize_alt()` when `SCOPE == 'all_jobs'`. Sets `IS_RUNNING`. Sends item-move packets, `gs enable/disable all`, `gs c naked`, `gs c ls`, `gs c rf` |
| `organize_global` (`:647`) | Alias of `organize` (legacy name) |
| `organize_alt()` (`:680`) | Alt / all-jobs run |
| `preview()` / `preview_global` (`:529`, `:648`) | Dry run; truncates and rewrites `wardrobe_debug.log` |
| `verify_global()` (`:604`) | Read-only layout check |
| `reset()` (`:629`) | `IS_RUNNING = false`, counters reset, `gs enable all`. Does not stop scheduled phase coroutines |
| `recover()` (`:639`) | `IS_RUNNING = false`, counters reset, `gs enable all` at 0, 0.5 and 1.5 s (`Phases.force_enable_all`, `phases.lua:62-67`). Does not stop scheduled phase coroutines either |
| `scan_warp_items` (`:675`) | `Reports.scan_warp_items` |
| `show_kept` (`:676`) | `Reports.show_kept` |

Library modules (internal to the area; callers are the organizer files only):

| Module | Functions |
|---|---|
| `lib/phases.lua` | `unequip(on_done)`, `enable_slots()`, `force_enable_all()`, `empty_w1w2(state, on_done)`, `fill_w1w2(state, on_done)`, `count_unpacked(state) -> number`, `compact_primary(state, on_done)`, `cleanup_inv(used_names, pinned_bags, on_done)`, `empty_alt(state, on_done)`, `fill_alt(state, on_done)` |
| `lib/state.lua` | `build_state() -> state or nil, err`, `pin_target_for(entry, pinned_bags, claim_pool) -> bag_id or nil`, `snapshot_bag(bag_id, used_names)`, `dlog_state(state, label)` |
| `lib/moves.lua` | `space_in(bag)`, `pull_slot(bag, slot) -> ok, reason`, `push_slot(inv_slot, bag) -> ok, reason`, `all_pinned_bags(id, pins)`, `unclaimed_pins_first(id, pins)`; `find_inv_slot` and `first_pinned_bag` have no caller |
| `lib/items.lua` | `item_names(id)`, `display_name(id)`, `is_equipment(id)`, `is_used_name(id, used)`, `add_always_kept(used)`, `collect_used_names()` |
| `lib/config.lua` | constants, `refresh() -> path or nil` |
| `lib/warp_owned.lua` | `path()`, `load() -> names or nil`, `scan() -> found, total, where`, `save(names) -> path or nil, err` |
| `lib/reports.lua` | `scan_warp_items()`, `show_kept()` |
| `lib/orchestrator_alt.lua` | `create(ctx) -> { start = fn }` |
| `lib/chat.lua` | `separator`, `banner`, `section`, `info`, `success`, `error`, `warn`, `alert`, `phase`, `detail`; `divider` and `kv` have no caller |
| `lib/log.lua` | `dlog(line)`, `dlog_clear()`, `bag_name(id)` |

## Commands

All are `//gs c wo <arg> [arg2]` or `//gs c worganize ...`; arguments are case-sensitive (`COMMON_COMMANDS.lua:157-191`).

| Syntax | Effect | Handler |
|---|---|---|
| `wo` | Organize according to `SCOPE` | `organize()` `wardrobe_organizer.lua:499` |
| `wo alt` / `wo kaories` | Alt / all-jobs organize | `organize_alt()` `:680` |
| `wo global` | Same as `wo` (alias) | `:647` |
| `wo preview` / `wo dry` / `wo global preview` / `wo global dry` | Dry run of the active-job plan | `preview()` `:529` |
| `wo verify` / `wo check` | Layout check | `verify_global()` `:604` |
| `wo reset` | Clear run state, enable slots | `reset()` `:629` |
| `wo recover` / `wo unlock` | Clear run state, enable slots three times | `recover()` `:639` |
| `wo scan` / `wo scanwarp` | Record owned warp items, write scan report | `reports.lua:168` |
| `wo keep` / `wo kept` / `wo items` | Show what is kept out of overflow | `reports.lua:210` |
| anything else | `organize()` | |

Commands the organizer itself sends (through the sandbox `windower.send_command`, which GearSwap prefixes with `@`, `GearSwap/user_functions.lua:247-252`): `gs enable all` (`phases.lua:64-66`, `:101`, `:159`), `gs c naked` (`:106-107`), `gs equip naked` (`:108`), `input /equip <slot> empty` (`:112`), `gs disable all` (`:121`), `gs c ls` (`wardrobe_organizer.lua:127`), `gs c rf` (`:130`).

## Configuration

### Defaults (`lib/config.lua`)

| Key | Default | Used by |
|---|---|---|
| `SCOPE` | `'active_job'` (`:27`) | `organize()` routing |
| `KEEP_ITEMS` | `{}` (`:37`) | `Items.add_always_kept`, `wo keep` |
| `PRIMARY_BAGS` | `{8, 10}` (`:39`) | Phases 2/3/3.5/4, state |
| `OVERFLOW_BAGS` | `{16, 14, 13, 12, 11}` (`:46`) | Phases 2/3/4, warp reachability, `wo keep` |
| `FILL_FALLBACK` | `{16, 14, 13, 12, 11}` (`:47`) | Phase 4 |
| `PROTECTED` | `{[15] = true}` (`:48`) | nothing reads it (see Known issues) |
| `ALL_WARDROBES` | `{8, 10, 11, 12, 13, 14, 16}` (`:51`) | `build_state` scan list |
| `ALT_PRIMARY_BAGS` / `ALT_OVERFLOW_BAGS` / `ALT_ALL_BAGS` | `{8,10,11,12}` / `{6,7,5}` / union (`:63-65`) | alt flow |
| `MOVE_DELAY` | 0.35 s | Phase 4 pacing |
| `PHASE_DELAY` | 1.5 s | gap after Phases 2, 3, A2, A3 |
| `POST_BURST_DELAY` | 3.0 s | burst delay ceiling |
| `SETTLE_DELAY` | 2.0 s | before the final and verify snapshots, before `alt_finish` |
| `RETRY_DELAY` | 2.5 s | between outer iterations |
| `BURST_SIZE` | 30 | packets per burst |
| `STUCK_LIMIT` | 4 | zero-move bursts before a phase gives up |
| `MAX_STEPS` | 200 | bursts per phase |
| `MAX_OUTER_ITERATIONS` | 12 | outer retries |
| `CLEANUP_MAX_PASSES` | 3 | Phase 4 passes |
| `TRULY_STUCK_THRESHOLD` | 4 | same misplaced count before giving up; also the burst-loop cycle threshold (`phases.lua:43`) |
| `MAX_WALK_DEPTH` | 50 | `_G.sets` walk |
| `DEBUG_LOG` / `LOG_PATH` | `true` / `<addon>/data/wardrobe_debug.log` (`:134-135`) | `lib/log.lua` |
| `UNEQUIP_DELAY`, `EQUIP_SLOTS`, `BAG_NAME_TO_ID` | (`:93-112`, `:117`, `:143`) | nothing reads them |

### Per-character override

`Config.refresh()` (`config.lua:165-220`) runs at the start of `organize`, `organize_alt`, `preview`, `verify_global` and `show_kept`. It `pcall(dofile, ...)` `data/<player.name>/config/WARDROBE_CONFIG.lua` and copies over the module table only the keys it knows and the file defines: `SCOPE`, `KEEP_ITEMS`, `PRIMARY_BAGS`, `OVERFLOW_BAGS`, `FILL_FALLBACK`, `ALL_WARDROBES`, the three `ALT_*` lists (`:180-188`) and `PROTECTED`, converted from an array to a set (`:191-195`). Any other key (timings, limits) is ignored. Then:

- `FILL_FALLBACK` mirrors `OVERFLOW_BAGS` unless the file sets it (`:199-201`);
- with `SCOPE == 'all_jobs'`, `ALT_PRIMARY_BAGS` / `ALT_OVERFLOW_BAGS` mirror the regular lists unless the file sets them (`:205-208`);
- `ALT_ALL_BAGS` is rebuilt from the two `ALT_*` lists unless the file sets it (`:211-216`).

Keys are only ever overwritten, never reset: removing a key from the file keeps its previous value until the sandbox is rebuilt (`gs reload` or job change). A missing file only clears `LOADED_CHAR_CONFIG`.

The shared `Config` table is seen by all libs only because `require` is cached per sandbox by `ModuleCache` (`shared/utils/core/module_cache.lua:60-85`, installed at `INIT_SYSTEMS.lua:47-52`). Without the cache, each lib would get its own default `Config` table and `refresh()` would only affect `wardrobe_organizer.lua`'s copy.

### Current character configs

| Key | Tetsouo (`_master/Tetsouo/config_global/WARDROBE_CONFIG.lua`) | Kaories (`_master/Kaories/config_global/WARDROBE_CONFIG.lua`) |
|---|---|---|
| `SCOPE` | `'active_job'` (`:20`) | `'active_job'` (`:26`) |
| `PRIMARY_BAGS` | `{8, 10}` | `{8, 10}` |
| `OVERFLOW_BAGS` | `{16, 14, 13, 12, 11}` | `{12, 11, 6, 7, 5}` (`:38`): W4, W3, then Sack, Case, Satchel |
| `PROTECTED` | `{15}` | `{}` |
| `ALL_WARDROBES` | `{8, 10, 11, 12, 13, 14, 16}` | `{8, 10, 11, 12}` (`:44`) |
| `KEEP_ITEMS` | `{}` | `{}` |
| Warp items kept | no (overflow all equippable) | yes (overflow contains Sack/Case/Satchel) |

The live copies `Tetsouo/config/WARDROBE_CONFIG.lua` and `Kaories/config/WARDROBE_CONFIG.lua` are byte-identical to the templates. Both characters also have a `config/WARP_ITEMS_OWNED.lua` generated by `wo scan`.

## State & lifetime

Module state (locals of `wardrobe_organizer.lua:49-55`): `IS_RUNNING`, `outer_iteration`, `last_misplaced`, `same_misplaced_count`, `start_job_tag`. Each phase keeps its own counters in closures (`run_burst_loop` `phases.lua:211-216`, `cleanup_inv` `:505-506`, `unequip` `:104`). `Config` is mutated by `refresh()`.

- `_G`: reads `_G.sets` (`items.lua:144`, `wardrobe_organizer.lua:504`) and the `player` global (`job_changed`, `active_job_tag`, `:72-94`). Writes nothing.
- `windower.*` persistent fields: none. Events: none registered. Keybinds, text or prim objects: none.
- Scheduled coroutines: every phase step, phase transition, retry, snapshot and the post-run `gs c ls` / `gs c rf`. None is cancellable and none checks a run identifier; they stop only by reaching their own exit condition or a `job_changed()` guard.
- Files written: `data/wardrobe_debug.log` (one fixed path for every character of this Windower install, `config.lua:135`; truncated at the start of each run and each preview, `log.lua:29-34`, appended one line per event), `data/wardrobe_scan_<char>.txt`, `data/<char>/config/WARP_ITEMS_OWNED.lua`.
- Files read: `data/<char>/config/WARDROBE_CONFIG.lua`, `data/<char>/config/WARP_ITEMS_OWNED.lua`, every `.lua` under `data/<char>/sets/` (through the auditor).
- Slot lock: `gs disable all` sets GearSwap's `disable_table` (`GearSwap/statics.lua:194`, `user_functions.lua:131-143`), which is GearSwap global state and survives `gs reload` and job changes. Only a `gs enable` clears it.

Behaviour on lifecycle events during a run:

| Event | Effect |
|---|---|
| Main or sub job change | GearSwap rebuilds the sandbox (new organizer instance, `IS_RUNNING = false` there). The old chain keeps running with the old job's `used_names` until its next `job_changed()` check (start of an iteration > 1, Phase 1, Phase 2 -> 3, before Phase 4), which aborts and sends `gs enable all`. Until then the new job's slots stay disabled. The Phase 3 -> 3.5 transition, `finish_run` (its snapshot and verify evaluate the old job's `sets`, so a change during Phase 4 can still end on the "Layout OK" panel), the alt flow's Phase 4 and `alt_finish`, and the inside of every phase have no check |
| `gs reload` on the same job (typed, or `//gs c reload` -> `JobChangeManager.force_reload`, `job_change_manager.lua:187-207`) | Same sandbox rebuild, but `job_changed()` stays false, so the old chain runs to completion, including retries, while the new sandbox accepts another `wo` |
| `//lua reload gearswap` | The addon's Lua state is destroyed with every coroutine; slots are left as they were (possibly disabled). Recovery: `wo recover` or the Phase 0 unlock of the next run |
| Zone | Not handled; the chat tells the player not to zone (`wardrobe_organizer.lua:476`) |
| Lua error in a phase coroutine | Only `build_state_and_dispatch`, `finish_run.snapshot` and `finish_run.verify` are wrapped by `with_panic_unlock` (`:137-146`, `:251`, `:288`, `:491`). An error elsewhere kills that coroutine and leaves `IS_RUNNING = true` and the slots disabled; `wo reset` / `wo recover` clear both |

## Interactions

- Calls: `WardrobeAuditor` (pins, all-jobs used names, frequency map), `WarpDatabase.get_all_item_names` (`shared/utils/warp/database/warp_database_core.lua:236`), `res.items` / `res.bags`, `CommonCommands.handle_naked` via `gs c naked`, the lockstyle command via `gs c ls`, `RefillManager` and `DualBoxSyncIPC` via `gs c rf`.
- Called by: `CommonCommands.handle_wardrobeorganize` only. Routing details: [commands-and-debug.md](commands-and-debug.md).
- Sandbox model (why old coroutines outlive a reload): [core-lifecycle.md](core-lifecycle.md).
- Dual-box side effect of `gs c rf`: [dualbox.md](dualbox.md).
- `shared/utils/craft/craft_commands.lua:189-200` re-enables all slots before equipping craft gear because a `wo` run may have left them disabled; conversely a `wo` run started during a craft session sends `gs enable all` and removes the craft lock.

## Invariants & gotchas

- Only items with `status == 0` and a non-zero `slots` field move (`moves.lua:49`, `:78`; every discover filter). Equipped, bazaar and linkshell-locked copies are never touched, but they still count as "occupying" a pin (`bag_holds`, `unclaimed_pins_first`).
- Every move is a bag -> inventory -> bag round trip; the inventory is the staging area, so a full inventory makes every pull fail (the phase exits through `STUCK_LIMIT`).
- Pins are the union of all set files of the character, not the active job's (`wardrobe_auditor.lua:623-678`). A ring pinned by any job is kept in, or promoted to, its pin bags whatever job is loaded, even if the active job does not use it (`state.lua:203-206`, `phases.lua:412-414`).
- In the active-job flow "used" means "named somewhere in the loaded `_G.sets`". Gear equipped by code outside `sets` (inline `equip({...})` in job logic, weapon names kept in config tables) counts as unused and is evicted unless listed in `KEEP_ITEMS`.
- The alt flow's "used" comes from a regex over the set files' text (`wardrobe_auditor.lua:205-230`): any quoted string after `=` counts, which is broader than the loaded sets.
- Warp items are kept out of overflow only when `OVERFLOW_BAGS` contains a bag that cannot be equipped from (`items.lua:91-101`, `res.bags[..].equippable`).
- Every run starts and ends with `gs enable all`: slots the player disabled on purpose are re-enabled.
- Phase 0 removes the weapons, so TP is lost.
- The chat panels print W1..W8 free slots by fixed bag id (`wardrobe_organizer.lua:196-205`, `:553-566`), whatever the configured lists; bags a character does not scan show 0.
- Phase 3.5 is printed as "Phase 3": `Chat.phase` formats the number with `%d` (`chat.lua:124`), which truncates 3.5 in Lua 5.1.
- `wo reset` is what the "already in progress" message suggests (`wardrobe_organizer.lua:501`), but it does not stop the running chain.

## Extending

Adding a phase to the active-job chain:

1. Write `Phases.<name>(state, on_done)` that calls `run_burst_loop{label, discover_pending, discover_drainable, on_done}`. `discover_pending` returns `{bag, slot, id, name}` entries in non-inventory bags; `discover_drainable` returns `{slot, dst_list, name, id, is_pinned}` for inventory slots. Both must re-read live bag contents on every call.
2. If the phase can be the only work left, add a counter to the Phase 1 test (`wardrobe_organizer.lua:432-433`) that uses exactly the same filters as `discover_pending`; `count_unpacked` shows why (`phases.lua:590-592`: a counter that reports work the phase refuses to do makes the outer loop retry to the cap).
3. Chain it in `wardrobe_organizer.lua` with a `job_changed()` check before it starts, and wrap the callback in `with_panic_unlock` if an error there should unlock the slots.
4. Make sure the phase does not undo another one: every phase's drain destination must agree with `pin_target_for` and with the other phases' pending filters, or items ping-pong until `TRULY_STUCK_THRESHOLD`.

Adding a configuration key: default in `lib/config.lua`, an override line in `Config.refresh()` (`:180-188`), and a commented entry in both `_master/*/config_global/WARDROBE_CONFIG.lua` templates (then redeploy or copy to the live folders).

## Known issues

- `wo reset` / `wo recover` and a same-job `gs reload` do not stop an in-flight chain; a second `wo` then runs concurrently with it - `shared/utils/wardrobe/wardrobe_organizer.lua:629-644`
- Gear in overflow bags that are not in `ALL_WARDROBES` (Kaories: Sack, Case, Satchel) is invisible to the snapshot, so "already optimized" / "Layout OK" are reported while used gear sits there - `shared/utils/wardrobe/lib/state.lua:192-195`
- The alt flow's Phase 4 routes leftovers with the regular bag lists, so unused gear can be pushed back into the alt primary bags (W3/W4) - `shared/utils/wardrobe/lib/orchestrator_alt.lua:98`, `lib/phases.lua:480-492`
- The alt flow decides whether to keep warp items from `OVERFLOW_BAGS`, not `ALT_OVERFLOW_BAGS`; with the default config `wo alt` evicts warp rings to Sack/Case - `shared/utils/wardrobe/lib/items.lua:92`
- `verify` / `preview` ignore Phase 3.5 packing and inventory leftovers - `shared/utils/wardrobe/wardrobe_organizer.lua:604-626`
- The scan report matches set names against `en` only; the many set files that use the long log name are reported as "declared but not held" - `shared/utils/wardrobe/lib/reports.lua:45`
- Warp-keep reachability and source selection are implemented twice - `shared/utils/wardrobe/lib/reports.lua:213-237`, `lib/items.lua:91-132`
- `Config.PROTECTED` is never read; W7 stays untouched only because it is in no bag list, and a `bag='wardrobe 7'` pin would send gear there - `shared/utils/wardrobe/lib/config.lua:48`
- Dead helpers and constants: `Moves.find_inv_slot`, `Moves.first_pinned_bag`, `Chat.divider`, `Chat.kv`, `Config.UNEQUIP_DELAY`, `Config.EQUIP_SLOTS`, `Config.BAG_NAME_TO_ID`, unused locals in `phases.lua:28,32-33` and `wardrobe_organizer.lua:37`
- No `job_changed()` check between Phase 3 and Phase 3.5 - `shared/utils/wardrobe/wardrobe_organizer.lua:373-376`
- No `job_changed()` check before the alt flow's Phase 4 or `alt_finish`, nor in `finish_run` - `shared/utils/wardrobe/lib/orchestrator_alt.lua:96-99`, `wardrobe_organizer.lua:249-342`
- `FILL_FALLBACK` mirrors `OVERFLOW_BAGS` by default, so for a character whose overflow ends in Sack/Case/Satchel (Kaories) Phase 4 files used or pinned gear there when the primary bags and pins are full; the snapshot does not scan those bags, so the run then reports the layout as OK - `shared/utils/wardrobe/lib/config.lua:199-201`, `lib/phases.lua:480-488`
- The debug log path carries no character name; two characters organising at the same time truncate and interleave one log - `shared/utils/wardrobe/lib/config.lua:135`, `lib/log.lua:29-34`
- Phase 3.5 over-pulls: pending ignores items already waiting in the inventory, so the surplus goes back to the bag it came from - `shared/utils/wardrobe/lib/phases.lua:635-661`
- Phase 3.5 prints as "Phase 3" - `shared/utils/wardrobe/wardrobe_organizer.lua:365`, `lib/chat.lua:124`
- Comments that contradict the code: `wardrobe_organizer.lua:277` ("keep slots locked through the retry") vs `phases.lua:101`; `COMMON_COMMANDS.lua:146-149` (`wo global` described as a frequency-based layout, W8 described as protected)

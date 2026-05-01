---  ═══════════════════════════════════════════════════════════════════════════
---   Refill Manager - Restock consumables from Mog Case/Sack
---  ═══════════════════════════════════════════════════════════════════════════
---   Scans inventory for consumable items and pulls from Mog Case / Mog Sack
---   to maintain target quantities (default 12 each).
---
---   Usage: //gs c refill  (or //gs c rf)
---
---   @file    shared/utils/inventory/refill_manager.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    2026-02-14
---  ═══════════════════════════════════════════════════════════════════════════

local RefillManager = {}

local res = require('resources')

---  ═══════════════════════════════════════════════════════════════════════════
---   CONFIGURATION
---  ═══════════════════════════════════════════════════════════════════════════
---
--- Per-character config files at:
---     <charname>/config/<job>/<JOB>_REFILL.lua
---
--- Each file returns a table with:
---     .default = { {name='X', target=N}, ... }
---     .subjobs = { DNC = { {name=..., target=...}, ... }, ... }  -- optional
---
--- Item `name` can be a string (single item) or a list of strings:
---     { name = {'Squid Sushi +1', 'Squid Sushi'}, target = 12 }
--- The list is tried in order: prefer +1, fall back to base. The displayed
--- name is the FIRST variant present in inventory at scan time, or the FIRST
--- variant overall if none is in inventory yet.

--- Hardcoded fallback list, used if no config file is found for the active job.
local FALLBACK_LIST = {
    { name = 'Panacea',      target = 12 },
    { name = 'Antacid',      target = 12 },
    { name = 'Holy Water',   target = 12 },
    { name = 'Remedy',       target = 12 },
    { name = 'Prism Powder', target = 12 },
    { name = 'Silent Oil',   target = 12 },
}

--- Source bags in priority order (Case first, then Sack)
local SOURCE_BAGS = {
    { key = 'case', id = 7, display = 'Case' },
    { key = 'sack', id = 6, display = 'Sack' },
}

--- Bag-key -> {id, display} resolver for store_bag overrides.
local BAG_INFO = {
    case    = { id = 7, display = 'Case'    },
    sack    = { id = 6, display = 'Sack'    },
    satchel = { id = 5, display = 'Satchel' },
}

--- Default destination bag for SURPLUS items (count > target -> move back).
--- Configs may override via `<config>.store_bag = 'sack' | 'case' | 'satchel'`.
local DEFAULT_STORE_BAG = 'case'

local INVENTORY_BAG_ID = 0

--- Delay between move operations (seconds) to respect FFXI packet rate
local MOVE_DELAY = 0.6

---  ═══════════════════════════════════════════════════════════════════════════
---   CONFIG LOADING
---  ═══════════════════════════════════════════════════════════════════════════

--- Lazy-built name->id lookup table.
--- Populated once on first call to resolve_item_id; subsequent calls are O(1).
--- Without this cache, scanning all res.items (~30k entries) for every refill
--- entry causes a multi-second freeze.
local _name_to_id = nil

local function build_name_index()
    local idx = {}
    for id, item_data in pairs(res.items) do
        if item_data then
            for _, field in ipairs({'en', 'enl', 'name', 'name_log'}) do
                local v = item_data[field]
                if type(v) == 'string' then
                    local key = v:lower()
                    -- First match wins; later collisions ignored (rare anyway)
                    if not idx[key] then idx[key] = id end
                end
            end
        end
    end
    return idx
end

--- Resolve item name to resource ID via res.items.
--- Matches against ALL common name fields (en, enl, name, name_log) so the
--- caller can use either the full form ("Red Curry Bun +1") or FFXI's
--- abbreviated log form ("R. Curry Bun +1") and still find the item.
--- @param item_name string The English item name
--- @return number|nil Item ID or nil if not found
local function resolve_item_id(item_name)
    if not _name_to_id then _name_to_id = build_name_index() end
    return _name_to_id[item_name:lower()]
end

--- Normalise an entry's name field into a list of {display_name, item_id} tuples,
--- preserving order (preferred variant first).
--- @param name string|table  e.g. 'Panacea' OR {'Squid Sushi +1', 'Squid Sushi'}
--- @return table list of {name=string, id=number} (only successfully resolved IDs)
local function resolve_variants(name)
    local names = (type(name) == 'table') and name or { name }
    local out = {}
    for _, n in ipairs(names) do
        local id = resolve_item_id(n)
        if id then table.insert(out, { name = n, id = id }) end
    end
    return out
end

--- Internal: scan <charname>/config/ for any *_REFILL.lua and load them.
--- Returns a list of loaded config tables, regardless of which job they target.
--- @param char_name string
--- @return table list of {job=string, cfg=table}
local function load_all_refill_configs(char_name)
    if not char_name then return {} end
    local configs = {}
    local base_dir = windower.addon_path
    -- GearSwap addon path is the parent; data is at base_dir/data/<char>/config/
    -- windower.get_dir wants forward slashes from windower root.
    local config_dir = windower.windower_path .. 'addons/GearSwap/data/' ..
                       char_name .. '/config/'
    local subdirs = windower.get_dir(config_dir)
    if not subdirs then return {} end

    for _, entry in ipairs(subdirs) do
        -- entry can be a subdir name (job folder) or a .lua file at root
        local job_path = config_dir .. entry .. '/'
        local files = windower.get_dir(job_path)
        if files then
            for _, fname in ipairs(files) do
                local job = fname:match('^(%w+)_REFILL%.lua$')
                if job then
                    -- require uses '/'-relative paths from data root
                    local mod = char_name .. '/config/' .. entry .. '/' .. job .. '_REFILL'
                    local ok, cfg = pcall(require, mod)
                    if ok and type(cfg) == 'table' then
                        table.insert(configs, { job = job:upper(), cfg = cfg })
                    end
                end
            end
        end
    end
    return configs
end

--- Iterate all entries in a config (default + every subjob list) and call fn(entry).
local function iterate_config_entries(cfg, fn)
    if cfg.default then
        for _, e in ipairs(cfg.default) do fn(e) end
    end
    if cfg.subjobs then
        for _, list in pairs(cfg.subjobs) do
            for _, e in ipairs(list) do fn(e) end
        end
    end
end

--- Build a set of item IDs that belong to OTHER jobs (not the active list).
--- Used to identify foreign refill items sitting in inventory that should be
--- pushed back to the store_bag.
--- @param char_name string
--- @param current_list table  the list resolved for the active job/subjob
--- @return table {[item_id] = display_name}, table {[item_id] = true} (current)
local function build_foreign_items_set(char_name, current_list)
    local current_ids = {}
    for _, entry in ipairs(current_list) do
        local variants = (type(entry.name) == 'table') and entry.name or { entry.name }
        for _, n in ipairs(variants) do
            local id = resolve_item_id(n)
            if id then current_ids[id] = true end
        end
    end

    local foreign = {}
    for _, c in ipairs(load_all_refill_configs(char_name)) do
        iterate_config_entries(c.cfg, function(entry)
            local variants = (type(entry.name) == 'table') and entry.name or { entry.name }
            for _, n in ipairs(variants) do
                local id = resolve_item_id(n)
                if id and not current_ids[id] and not foreign[id] then
                    foreign[id] = n
                end
            end
        end)
    end
    return foreign, current_ids
end

--- Resolve the refill list for the current player (job + subjob).
--- Looks for <charname>/config/<job>/<JOB>_REFILL.lua. Picks subjobs[<sub>]
--- entry if defined, else .default. Falls back to FALLBACK_LIST.
--- Also resolves the store_bag override (top-level cfg.store_bag).
---
--- CRAFT MODE: if a craft set is currently active (//gs c craft / //gs c fish
--- locked the slots), uses <charname>/config/craft/CRAFT_REFILL.lua instead
--- so the inventory gets craft-relevant food (Coconut Rusk, Kitron Macaron)
--- and everything else is detected as foreign and pushed back.
---
--- @return table list, string source_label, table store_info {id, display}
local function resolve_list_for_player()
    local p = windower.ffxi.get_player()
    local store_info = BAG_INFO[DEFAULT_STORE_BAG]
    if not p or not p.main_job or p.main_job == 'NON' then
        return FALLBACK_LIST, 'fallback (no player)', store_info
    end
    local char = p.name

    -- Craft mode override: check the global flag set by craft_manager.
    if _G.__CraftManagerState and _G.__CraftManagerState.active then
        local craft_path = char .. '/config/craft/CRAFT_REFILL'
        local ok_c, cfg_c = pcall(require, craft_path)
        if ok_c and type(cfg_c) == 'table' then
            if cfg_c.store_bag and BAG_INFO[cfg_c.store_bag] then
                store_info = BAG_INFO[cfg_c.store_bag]
            end
            if cfg_c.default then
                local label = 'CRAFT'
                if _G.__CraftManagerState.active_name then
                    label = label .. ' (' .. _G.__CraftManagerState.active_name .. ')'
                end
                return cfg_c.default, label, store_info
            end
        end
        -- If craft refill file missing, fall through to job-based logic
    end

    local job = p.main_job:upper()
    local sub = (p.sub_job and p.sub_job ~= 'NON') and p.sub_job:upper() or nil

    -- Build require path: <charname>/config/<lowerjob>/<JOB>_REFILL
    local mod_path = char .. '/config/' .. job:lower() .. '/' .. job .. '_REFILL'
    local ok, cfg = pcall(require, mod_path)
    if not ok or type(cfg) ~= 'table' then
        return FALLBACK_LIST, ('fallback (no %s)'):format(mod_path), store_info
    end

    -- Top-level store_bag override (default = Case)
    if cfg.store_bag and BAG_INFO[cfg.store_bag] then
        store_info = BAG_INFO[cfg.store_bag]
    end

    if sub and cfg.subjobs and cfg.subjobs[sub] then
        return cfg.subjobs[sub], ('%s/%s'):format(job, sub), store_info
    end
    if cfg.default then
        return cfg.default, ('%s/default'):format(job), store_info
    end
    return FALLBACK_LIST, ('fallback (%s has no .default)'):format(mod_path), store_info
end

---  ═══════════════════════════════════════════════════════════════════════════
---   ITEM ID RESOLUTION
---  ═══════════════════════════════════════════════════════════════════════════

-- (resolve_item_id and resolve_variants are now declared earlier in the file
-- so they're visible to load_all_refill_configs / build_foreign_items_set.)

---  ═══════════════════════════════════════════════════════════════════════════
---   BAG SCANNING
---  ═══════════════════════════════════════════════════════════════════════════

--- Count total quantity of an item in a specific bag
--- @param items_data table Data from windower.ffxi.get_items()
--- @param bag_key string Bag string key (e.g., 'inventory', 'sack', 'case')
--- @param target_id number Item resource ID to search for
--- @return number Total count
--- @return table List of {slot=number, count=number} for each matching stack
local function count_item_in_bag(items_data, bag_key, target_id)
    local bag = items_data[bag_key]
    if not bag or type(bag) ~= 'table' then
        return 0, {}
    end

    local total = 0
    local slots = {}

    for slot, item in pairs(bag) do
        if type(slot) == 'number' and type(item) == 'table'
            and item.id and item.id == target_id
            and item.count and item.count > 0 then
            total = total + item.count
            table.insert(slots, { slot = slot, count = item.count })
        end
    end

    return total, slots
end

---  ═══════════════════════════════════════════════════════════════════════════
---   IN-GAME DISPLAY  (74-char ASCII panels, project-standard style)
---  ═══════════════════════════════════════════════════════════════════════════

local CHANNEL = 121
local WIDTH   = 74
local SEP     = string.rep('=', WIDTH)
local SUBSEP  = string.rep('-', WIDTH)

-- Inline FFXI color codes
local C = {
    gray   = string.char(0x1F, 160),
    yellow = string.char(0x1F, 50),
    green  = string.char(0x1F, 158),
    red    = string.char(0x1F, 167),
    cyan   = string.char(0x1F, 123),
    white  = string.char(0x1F, 1),
    orange = string.char(0x1F, 205),
}

local function send(line) windower.add_to_chat(CHANNEL, line) end
local function separator() send(C.gray .. SEP) end
local function divider()   send(C.gray .. SUBSEP) end

--- 3-line banner block (project standard, 74-char wide).
--- Middle line has +1 '=' on each side (total +2) so the variable-width FFXI
--- font makes the title row visually match the outer rules.
local function banner(title)
    local padded = ' ' .. title .. ' '
    local total  = math.max(2, WIDTH - #padded) + 4  -- +4 visual compensation
    local left   = math.floor(total / 2)
    local right  = total - left
    send(C.gray .. SEP)
    send(C.gray .. string.rep('=', left) ..
         C.yellow .. padded ..
         C.gray   .. string.rep('=', right))
    send(C.gray .. SEP)
end

--- Sub-section header: --- name ---
local function section(name)
    send(C.gray .. '--- ' .. C.cyan .. name .. C.gray ..
         ' ' .. string.rep('-', math.max(3, WIDTH - 5 - #name)))
end

--- Simple key/value row: "  label: value"  (no dot leader: variable-width
--- font makes column alignment unreliable anyway).
local function kv(label, value)
    send('  ' .. C.cyan .. label .. C.gray .. ': ' ..
         C.green .. tostring(value))
end

--- Tag-prefixed status line: [Refill] message
local TAG = '[Refill]'
local function tagged(color, msg)
    send(C.gray .. '[' .. C.cyan .. 'Refill' .. C.gray .. ']' ..
         C.white .. ' ' .. color .. msg)
end

--- Public start banner: shown when refill begins, with config + scope info.
--- The 3-line banner already provides closing rule; no extra separator.
local function show_start(source_label, store_display, item_count)
    banner('Inventory Refill - Started')
    kv('Config',         source_label)
    kv('Surplus bag',    store_display)
    kv('Items tracked',  tostring(item_count))
end

--- Public progress notice: shown when transfers are about to begin.
local function show_progress(op_count)
    tagged(C.orange,
        ('Transferring %d operation%s ...'):format(op_count, op_count == 1 and '' or 's'))
end

--- Detect food items by name keyword. Refill lists currently use these:
---   sushi, curry bun, bun, gyudon, crepe, sandwich, soup, stew, taco, pizza,
---   paella, pie, cake, salad, omelette, riceball, dumpling
local FOOD_KEYWORDS = {
    'sushi','curry','gyudon','crepe','sandwich','soup','stew','taco','pizza',
    'paella','pie','cake','salad','omelette','riceball','dumpling','bun',
    'pumpkin','cookie','daifuku','rolanberry','ration',
    'rusk','macaron','tart','rice','bread','noodle','pasta',
}
local function is_food(name)
    local n = name:lower()
    for _, kw in ipairs(FOOD_KEYWORDS) do
        if n:find(kw, 1, true) then return true end
    end
    return false
end

--- Per-item status row: "  Name: status".
--- Name color depends on category: green for medicine, yellow for food.
--- @param value_str pre-colored value string
local function item_row(name, value_str)
    local name_color = is_food(name) and C.yellow or C.green
    send('  ' .. name_color .. name .. C.gray .. ': ' .. value_str)
end

--- Public final report: per-item lines + totals.
--- @param results table List of {name, target, current, deficit, moved, short,
---                source, surplus, surplus_dest, is_foreign}
local function show_report(results)
    banner('Inventory Refill - Complete')

    local total_moved   = 0
    local total_short   = 0
    local total_surplus = 0

    for _, r in ipairs(results) do
        if r.is_foreign then
            -- FOREIGN: belongs to another job's list, fully pushed back
            item_row(r.name,
                C.cyan .. 'foreign (' .. r.surplus .. ') -> ' .. (r.surplus_dest or 'Case'))
            total_surplus = total_surplus + r.surplus

        elseif r.surplus and r.surplus > 0 then
            -- SURPLUS: had more than target, excess pushed back
            item_row(r.name,
                C.yellow .. r.current .. '/' .. r.target ..
                C.gray   .. ' -> ' ..
                C.green  .. r.target .. '/' .. r.target ..
                C.gray   .. '  (-' .. r.surplus .. ' -> ' .. (r.surplus_dest or 'Case') .. ')')
            total_surplus = total_surplus + r.surplus

        elseif r.deficit <= 0 then
            -- Already at target: 12/12 + (OK) both green
            item_row(r.name,
                C.green .. r.current .. '/' .. r.target ..
                ' (OK)')

        elseif r.moved > 0 and r.short <= 0 then
            -- Fully refilled: source -> target, both shown
            item_row(r.name,
                C.gray  .. r.current .. '/' .. r.target ..
                C.gray  .. ' -> ' ..
                C.green .. (r.current + r.moved) .. '/' .. r.target ..
                C.gray  .. '  (+' .. r.moved .. ' ' .. r.source .. ')')
            total_moved = total_moved + r.moved

        elseif r.moved > 0 and r.short > 0 then
            -- Partially refilled
            item_row(r.name,
                C.gray   .. r.current .. '/' .. r.target ..
                ' -> ' ..
                C.orange .. (r.current + r.moved) .. '/' .. r.target ..
                C.gray   .. '  (+' .. r.moved .. ' ' .. r.source .. ')' ..
                C.red    .. '  Short ' .. r.short)
            total_moved = total_moved + r.moved
            total_short = total_short + r.short

        else
            -- Nothing available at all
            item_row(r.name,
                C.red .. r.current .. '/' .. r.target ..
                '  Out of stock! Short ' .. r.short)
            total_short = total_short + r.short
        end
    end

    if total_moved   > 0 then kv('Pulled in',  total_moved   .. ' item(s)') end
    if total_surplus > 0 then kv('Pushed out', total_surplus .. ' item(s) (surplus)') end
    if total_short   > 0 then kv('Missing',    total_short   .. ' item(s) - restock Case/Sack!') end
    if total_moved == 0 and total_short == 0 and total_surplus == 0 then
        kv('Status', 'Inventory already complete')
    end
    separator()
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MAIN REFILL LOGIC
---  ═══════════════════════════════════════════════════════════════════════════

--- Execute the full refill operation
--- @return boolean Success
function RefillManager.refill()
    if not player then
        tagged(C.red, 'Player not connected')
        return false
    end

    -- Read all bag contents
    local items_data = windower.ffxi.get_items()
    if not items_data then
        tagged(C.red, 'Could not read inventory')
        return false
    end

    -- Resolve which list to use for the active job/subjob + store_bag for surplus
    local list, source_label, store_info = resolve_list_for_player()
    show_start(source_label, store_info.display, #list)

    -- Build refill plan: each entry can have multiple item variants (e.g.
    -- {'Squid Sushi +1', 'Squid Sushi'}). The total count across variants
    -- counts toward `target`; pulls prefer the FIRST variant.
    local results = {}
    local move_queue = {}

    for _, refill_item in ipairs(list) do
        local variants = resolve_variants(refill_item.name)

        if #variants == 0 then
            -- Could not resolve any variant in res.items
            local display = (type(refill_item.name) == 'table')
                and refill_item.name[1] or tostring(refill_item.name)
            table.insert(results, {
                name = display, target = refill_item.target,
                current = 0, deficit = refill_item.target,
                moved = 0, short = refill_item.target, source = '',
            })
        else
            -- Count current inventory across ALL variants
            local inv_count = 0
            local present_variant = nil  -- first variant that is present in inventory
            for _, v in ipairs(variants) do
                local n = count_item_in_bag(items_data, 'inventory', v.id)
                inv_count = inv_count + n
                if n > 0 and not present_variant then present_variant = v end
            end
            -- Display name: variant present in inv, else preferred variant
            local display_name = (present_variant and present_variant.name) or variants[1].name
            local deficit = refill_item.target - inv_count

            local result = {
                name = display_name, target = refill_item.target,
                current = inv_count, deficit = deficit,
                moved = 0, short = 0, source = '',
                surplus = 0, surplus_dest = nil,
            }

            -- ---- SURPLUS: inv has more than target -> push back to store_bag ---
            if deficit < 0 then
                local surplus = -deficit  -- positive count to remove from inv
                local remaining_surplus = surplus
                -- Iterate variants (preferred first) to push their inv stacks out
                for _, v in ipairs(variants) do
                    if remaining_surplus <= 0 then break end
                    local _, inv_slots = count_item_in_bag(items_data, 'inventory', v.id)
                    for _, slot_info in ipairs(inv_slots) do
                        if remaining_surplus <= 0 then break end
                        local to_move = math.min(remaining_surplus, slot_info.count)
                        table.insert(move_queue, {
                            bag_id    = INVENTORY_BAG_ID,
                            dst_id    = store_info.id,
                            slot      = slot_info.slot,
                            count     = to_move,
                            item_name = v.name,
                            is_surplus = true,
                        })
                        remaining_surplus = remaining_surplus - to_move
                    end
                end
                result.surplus      = surplus - remaining_surplus
                result.surplus_dest = store_info.display
            end

            if deficit > 0 then
                local remaining = deficit
                local sources = {}
                local pulled_variants = {}  -- track which variant was pulled

                -- Iterate variants in priority order (preferred first)
                for _, v in ipairs(variants) do
                    if remaining <= 0 then break end

                    -- Try each source bag for this variant
                    for _, source in ipairs(SOURCE_BAGS) do
                        if remaining <= 0 then break end
                        local available, slots = count_item_in_bag(items_data, source.key, v.id)
                        if available > 0 then
                            for _, slot_info in ipairs(slots) do
                                if remaining <= 0 then break end
                                local to_move = math.min(remaining, slot_info.count)
                                table.insert(move_queue, {
                                    bag_id    = source.id,
                                    slot      = slot_info.slot,
                                    count     = to_move,
                                    item_name = v.name,
                                })
                                remaining     = remaining - to_move
                                result.moved  = result.moved + to_move
                                if not sources[source.display] then
                                    sources[source.display] = true
                                    table.insert(sources, source.display)
                                end
                                if not pulled_variants[v.name] then
                                    pulled_variants[v.name] = true
                                end
                            end
                        end
                    end
                end

                result.short  = math.max(0, remaining)
                result.source = table.concat(sources, '+')
                -- If the preferred variant was missing in inv but we pulled it, update display
                if not present_variant then
                    for _, v in ipairs(variants) do
                        if pulled_variants[v.name] then
                            result.name = v.name
                            break
                        end
                    end
                end
            end

            table.insert(results, result)
        end
    end

    -- ====================================================================
    -- FOREIGN ITEMS: items in inventory that belong to OTHER jobs' refill
    -- lists (e.g. Omelette Sandwich on WAR - PLD's food). Push them all to
    -- the store_bag so the inventory only keeps the active job's items.
    -- ====================================================================
    local foreign_set = build_foreign_items_set(player.name, list)
    local foreign_results = {}  -- {[item_name] = {moved=N, dest=str}}
    local inv_items = items_data.inventory
    if type(inv_items) == 'table' then
        for slot, it in pairs(inv_items) do
            if type(slot) == 'number' and type(it) == 'table'
               and it.id and it.count and it.count > 0
               and foreign_set[it.id] then
                local display = foreign_set[it.id]
                table.insert(move_queue, {
                    bag_id     = INVENTORY_BAG_ID,
                    dst_id     = store_info.id,
                    slot       = slot,
                    count      = it.count,
                    item_name  = display,
                    is_surplus = true,  -- routed via put_item
                })
                local key = display
                foreign_results[key] = foreign_results[key]
                    or { moved = 0, dest = store_info.display }
                foreign_results[key].moved = foreign_results[key].moved + it.count
            end
        end
    end
    -- Append a "foreign" result row for each pushed item type so it shows up
    -- in the panel.
    for name, info in pairs(foreign_results) do
        table.insert(results, {
            name        = name,
            target      = 0,
            current     = info.moved,
            deficit     = -info.moved,
            moved       = 0,
            short       = 0,
            source      = '',
            surplus     = info.moved,
            surplus_dest= info.dest,
            is_foreign  = true,
        })
    end

    -- Execute move queue with delays
    if #move_queue > 0 then
        local function execute_move(index)
            if index > #move_queue then
                -- All moves complete — show report
                show_report(results)
                return
            end

            local move = move_queue[index]
            if move.is_surplus then
                -- INV -> store_bag: use put_item (canonical for inv->bag).
                -- put_item(dest_bag, inv_slot, count)
                windower.ffxi.put_item(move.dst_id, move.slot, move.count)
            else
                -- bag -> INV: use get_item (canonical for bag->inv).
                -- get_item(src_bag, src_slot, count)
                windower.ffxi.get_item(move.bag_id, move.slot, move.count)
            end

            -- Schedule next move after delay
            coroutine.schedule(function()
                execute_move(index + 1)
            end, MOVE_DELAY)
        end

        show_progress(#move_queue)
        execute_move(1)
    else
        -- Nothing to move, show report immediately
        show_report(results)
    end

    return true
end

return RefillManager

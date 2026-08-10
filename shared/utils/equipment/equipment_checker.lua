---  ═══════════════════════════════════════════════════════════════════════════
---   Equipment Checker - Universal equipment validation system
---  ═══════════════════════════════════════════════════════════════════════════
---   Scans job equipment sets and verifies item availability across all bags.
---   Uses optimized caching system for instant lookups (O(1) complexity).
---   Distinguishes between equippable bags (inventory, wardrobes) and storage.
---
---   @file    shared/utils/equipment/equipment_checker.lua
---   @author  Tetsouo
---   @version 2.2 - Critical bug fixes: slip_number nil check + item_name type checks
---   @date    Created: 2025-01-02 | Updated: 2025-11-13
---  ═══════════════════════════════════════════════════════════════════════════

local EquipmentChecker = {}

-- Load dependencies
local MessageEquipment = require('shared/utils/messages/formatters/system/message_equipment')
local res = require('resources')

-- Try to load slips library (optional, for Storage Slip support)
local slips_success, slips = pcall(require, 'slips')
if not slips_success then
    slips = nil
end

-- DEBUG MODE (set to true to see cache performance logs)
local DEBUG = false  -- Disabled - Alias tables detected as circular (normal behavior)

-- MAX RECURSION DEPTH (prevent infinite loops and stack overflow)
local MAX_RECURSION_DEPTH = 15

-- SAFETY: Track visited tables to detect circular references
local visited_tables = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   BAG CONFIGURATION
---  ═══════════════════════════════════════════════════════════════════════════

-- Equippable bags (inventory + wardrobes 1-8)
local EQUIPPABLE_BAGS = {
    'inventory',    -- Bag 0
    'wardrobe',     -- Bag 8
    'wardrobe2',    -- Bag 10
    'wardrobe3',    -- Bag 11
    'wardrobe4',    -- Bag 12
    'wardrobe5',    -- Bag 13
    'wardrobe6',    -- Bag 14
    'wardrobe7',    -- Bag 15
    'wardrobe8'     -- Bag 16
}

-- Valid equipment slots
local VALID_SLOTS = {
    main = true,
    sub = true,
    range = true,
    ammo = true,
    head = true,
    neck = true,
    ear1 = true,
    ear2 = true,
    left_ear = true,
    right_ear = true,
    body = true,
    hands = true,
    ring1 = true,
    ring2 = true,
    left_ring = true,
    right_ring = true,
    back = true,
    waist = true,
    legs = true,
    feet = true
}

---  ═══════════════════════════════════════════════════════════════════════════
---   ITEM SEARCH FUNCTIONS
---  ═══════════════════════════════════════════════════════════════════════════

--- Extract item name from equipment entry
--- @param item_entry any Equipment entry (string or table)
--- @return string|nil Item name or nil
local function get_item_name(item_entry)
    if type(item_entry) == 'string' then
        return item_entry
    elseif type(item_entry) == 'table' and item_entry.name then
        return item_entry.name
    end
    return nil
end

--- Build complete item cache (scan all bags once for fast lookups)
--- @return table Item cache {item_name_lower = {available, in_storage, bag_name}}
-- A set may name an item in any client language, so every variant an item
-- resource carries becomes a key.
local NAME_FIELDS = {
    'en', 'english', 'enl', 'english_log',
    'ja', 'japanese', 'jal', 'japanese_log',
    'fr', 'french', 'frl', 'french_log',
    'de', 'german', 'del', 'german_log'
}

-- Bags whose contents cannot be equipped from where they are.
local STORAGE_BAGS = {
    'safe', 'safe2', 'storage', 'locker', 'satchel', 'sack', 'case', 'temporary'
}

--- Build the function that writes into a cache: it knows the language variants
--- and the priority rule, so no caller has to.
--- @param cache table Cache being filled
--- @return function add(item_id, available, in_storage, bag_name)
local function make_cache_adder(cache)
    return function(item_id, available, in_storage, bag_name)
        local item_data = res.items[item_id]
        if not item_data then
            return
        end

        local status = {
            available = available,
            in_storage = in_storage,
            bag_name = bag_name
        }

        for _, field in ipairs(NAME_FIELDS) do
            local item_name = item_data[field]
            if item_name and type(item_name) == 'string' then
                local key = item_name:lower()
                -- Priority: equipped > inventory > storage (first found wins)
                if not cache[key] or (available and not cache[key].available) then
                    cache[key] = status
                end
            end
        end
    end
end

--- Equipped items, which outrank every other location.
--- The `*_bag` keys say which bag a slot's item came from, not an item id.
local function add_equipped_items(add, items)
    if not items.equipment then return end

    for slot_name, item_id in pairs(items.equipment) do
        if type(item_id) == 'number' and item_id > 0 and not slot_name:match('_bag$') then
            add(item_id, true, false, 'equipped')
        end
    end
end

--- Contents of a list of bags, all sharing the same availability.
local function add_bag_items(add, items, bag_names, available, in_storage)
    for _, bag_name in ipairs(bag_names) do
        local bag_items = items[bag_name]
        if bag_items and type(bag_items) == 'table' then
            for _, item in pairs(bag_items) do
                if type(item) == 'table' and item.id and item.id > 0 then
                    add(item.id, available, in_storage, bag_name)
                end
            end
        end
    end
end

--- Porter Moogle slips, when the slips library is loaded. Slip contents are
--- bare item ids, not item tables like a bag's.
local function add_slip_items(add)
    if not slips then return end

    local slip_storages = slips.get_player_items()
    if not slip_storages then return end

    for _, slip_id in ipairs(slips.storages) do
        local slip_number = slips.get_slip_number_by_id(slip_id)
        local items_in_slip = slip_number and slip_storages[slip_id]
        if items_in_slip then
            local slip_name = string.format('Slip %02d', slip_number)
            for _, item_id in ipairs(items_in_slip) do
                add(item_id, false, true, slip_name)
            end
        end
    end
end

local function build_item_cache()
    local cache = {}
    local items = windower.ffxi.get_items()

    if not items then
        return cache
    end

    local add = make_cache_adder(cache)

    add_equipped_items(add, items)
    add_bag_items(add, items, EQUIPPABLE_BAGS, true, false)
    add_bag_items(add, items, STORAGE_BAGS, false, true)
    add_slip_items(add)

    return cache
end

--- Check item availability using pre-built cache (fast O(1) lookup)
--- @param item_name string Item name
--- @param item_cache table Pre-built item cache
--- @return table Status {available=bool, in_storage=bool, bag_name=string|nil}
local function check_item_status(item_name, item_cache)
    if not item_name or type(item_name) ~= 'string' or item_name == '' then
        return {
            available = false,
            in_storage = false,
            bag_name = nil
        }
    end

    -- Skip "empty" - this is a placeholder for intentionally empty slots
    if item_name:lower() == 'empty' then
        return {
            available = true,
            in_storage = false,
            bag_name = 'empty'
        }
    end

    local search_name = item_name:lower()
    local status = item_cache[search_name]

    if status then
        return status
    end

    -- Item not found anywhere
    return {
        available = false,
        in_storage = false,
        bag_name = nil
    }
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SET SCANNING FUNCTIONS
---  ═══════════════════════════════════════════════════════════════════════════

--- Recursively scan sets and validate equipment
--- @param sets_table table Sets table to scan
--- @param path string Current path in sets hierarchy
--- @param results table Results accumulator
--- @param item_cache table Pre-built item cache for fast lookups
--- @param depth number Current recursion depth (for safety)
--- Whether this node must not be walked, marking it visited on the way.
--- Marking happens before the naked check on purpose: a naked set is still a
--- node that has been seen, and must not be re-entered through an alias.
--- @return boolean True when the caller should return immediately
local function skip_node(sets_table, path, depth)
    if depth > MAX_RECURSION_DEPTH then
        MessageEquipment.show_max_recursion_error(MAX_RECURSION_DEPTH, path)
        return true
    end

    if not sets_table or type(sets_table) ~= 'table' then
        return true
    end

    -- Aliases (sets.X = sets.Y) land here too, which is normal and harmless
    if visited_tables[sets_table] then
        if DEBUG then
            MessageEquipment.show_alias_detected(path)
        end
        return true
    end
    visited_tables[sets_table] = true

    if DEBUG then
        MessageEquipment.show_scanning(path, depth)
    end

    -- Known empty by design: nothing to report about it
    return path ~= nil and (path:match('%.naked$') ~= nil or path == 'sets.naked')
end

--- @return boolean True when the table names at least one equipment slot
local function is_equipment_set(sets_table)
    for slot_name in pairs(sets_table) do
        if VALID_SLOTS[slot_name] then
            return true
        end
    end
    return false
end

--- Slots of one set whose item is not equippable from where it sits.
--- @return table Issues, one per unavailable slot
--- @return boolean Whether the set named any item at all
local function collect_set_issues(sets_table, item_cache)
    local issues, has_items = {}, false

    for slot, item_entry in pairs(sets_table) do
        if VALID_SLOTS[slot] then
            local item_name = get_item_name(item_entry)
            if item_name then
                has_items = true
                local status = check_item_status(item_name, item_cache)
                if not status.available then
                    table.insert(issues, {
                        slot = slot,
                        item = item_name,
                        in_storage = status.in_storage,
                        bag_name = status.bag_name
                    })
                end
            end
        end
    end

    return issues, has_items
end

--- File one set into the results, counting each issue as storage or missing.
local function record_set(results, path, issues)
    local valid = #issues == 0

    table.insert(results.sets, {
        path = path,
        valid = valid,
        issues = issues
    })

    if valid then
        results.valid_count = results.valid_count + 1
        return
    end

    for _, issue in ipairs(issues) do
        if issue.in_storage then
            results.storage_count = results.storage_count + 1
        else
            results.missing_count = results.missing_count + 1
        end
    end
end

local function scan_sets_recursive(sets_table, path, results, item_cache, depth)
    depth = depth or 0

    if skip_node(sets_table, path, depth) then
        return
    end

    if is_equipment_set(sets_table) then
        local issues, has_items = collect_set_issues(sets_table, item_cache)
        if has_items then
            record_set(results, path, issues)
        end
    end

    -- ALWAYS continue recursion: a set table can hold nested sets as well as slots
    for key, value in pairs(sets_table) do
        if key ~= 'naked' and not VALID_SLOTS[key] and type(value) == 'table' then
            local new_path = path and (path .. '.' .. key) or key
            scan_sets_recursive(value, new_path, results, item_cache, depth + 1)
        end
    end
end

--- Build the item cache once, reporting whichever way it fails.
--- @return table|nil Cache, or nil when it could not be built
local function build_cache_or_report()
    if DEBUG then
        MessageEquipment.show_building_cache()
    end

    local success, item_cache = pcall(build_item_cache)
    if not success then
        MessageEquipment.show_cache_build_failed(item_cache)
        return nil
    end

    if DEBUG then
        local cache_size = 0
        for _ in pairs(item_cache) do
            cache_size = cache_size + 1
        end
        MessageEquipment.show_cache_built(cache_size)
    end

    return item_cache
end

--- Walk the whole `sets` tree once.
--- @return table|nil Results, or nil when the scan raised
local function scan_all_sets(item_cache)
    local results = {
        sets = {},
        valid_count = 0,
        storage_count = 0,
        missing_count = 0
    }

    visited_tables = {}

    if DEBUG then
        MessageEquipment.show_starting_scan()
    end

    local scan_success, scan_error = pcall(scan_sets_recursive, sets, 'sets', results, item_cache, 0)
    if not scan_success then
        MessageEquipment.show_scan_failed(scan_error)
        return nil
    end

    if DEBUG then
        MessageEquipment.show_scan_complete(#results.sets)
    end

    return results
end

--- Only invalid sets are reported: a set whose items are all reachable says
--- nothing, so the output is the list of things to fix and nothing else.
local function report_set_issues(results)
    for _, set_data in ipairs(results.sets) do
        if not set_data.valid then
            for _, issue in ipairs(set_data.issues) do
                if issue.in_storage then
                    MessageEquipment.show_storage_item(
                        set_data.path,
                        issue.slot,
                        issue.item,
                        issue.bag_name or 'Unknown'
                    )
                else
                    MessageEquipment.show_missing_item(
                        set_data.path,
                        issue.slot,
                        issue.item
                    )
                end
            end
        end
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PUBLIC API
---  ═══════════════════════════════════════════════════════════════════════════

--- Check equipment for a specific job
--- @param job_name string Job name (WAR, RDM, etc.)
--- @return boolean Success status
function EquipmentChecker.check_job_equipment(job_name)
    if not job_name then
        MessageEquipment.show_check_error('Unknown', 'Job name not provided')
        return false
    end

    -- Display header
    MessageEquipment.show_check_header(job_name)

    -- Try to access global sets table
    if not sets or type(sets) ~= 'table' then
        MessageEquipment.show_no_sets_found(job_name)
        return false
    end

    local item_cache = build_cache_or_report()
    if not item_cache then
        return false
    end

    local results = scan_all_sets(item_cache)
    if not results then
        return false
    end

    -- Check if any sets were found
    if #results.sets == 0 then
        MessageEquipment.show_no_sets_found(job_name)
        return false
    end

    report_set_issues(results)

    -- Display summary
    MessageEquipment.show_check_summary(
        #results.sets,
        results.valid_count,
        results.storage_count,
        results.missing_count
    )

    return true
end

return EquipmentChecker

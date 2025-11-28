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
local function build_item_cache()
    local cache = {}
    local items = windower.ffxi.get_items()

    if not items then
        return cache
    end

    -- List of all name fields to check (multi-language support)
    local name_fields = {
        'en', 'english', 'enl', 'english_log',
        'ja', 'japanese', 'jal', 'japanese_log',
        'fr', 'french', 'frl', 'french_log',
        'de', 'german', 'del', 'german_log'
    }

    --- Helper to add all name variants of an item to cache
    --- @param item_id number Item resource ID
    --- @param available boolean Item is equippable (inventory/wardrobes)
    --- @param in_storage boolean Item is in storage (not equippable)
    --- @param bag_name string Bag location name
    local function add_to_cache(item_id, available, in_storage, bag_name)
        if not res.items[item_id] then
            return
        end

        local item_data = res.items[item_id]
        local status = {
            available = available,
            in_storage = in_storage,
            bag_name = bag_name
        }

        -- Add all name variants as cache keys for fast lookup
        for _, field in ipairs(name_fields) do
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

    -- PHASE 1: Equipped items (highest priority)
    if items.equipment then
        for slot_name, item_id in pairs(items.equipment) do
            if type(item_id) == 'number' and item_id > 0 and not slot_name:match('_bag$') then
                add_to_cache(item_id, true, false, 'equipped')
            end
        end
    end

    -- PHASE 2: Equippable bags (inventory + wardrobes 1-8)
    for _, bag_name in ipairs(EQUIPPABLE_BAGS) do
        local bag_items = items[bag_name]
        if bag_items and type(bag_items) == 'table' then
            for slot, item in pairs(bag_items) do
                if type(item) == 'table' and item.id and item.id > 0 then
                    add_to_cache(item.id, true, false, bag_name)
                end
            end
        end
    end

    -- PHASE 3: Storage bags (safe, locker, etc.)
    local storage_bag_names = {
        'safe', 'safe2', 'storage', 'locker', 'satchel', 'sack', 'case', 'temporary'
    }

    for _, bag_name in ipairs(storage_bag_names) do
        local bag_items = items[bag_name]
        if bag_items and type(bag_items) == 'table' then
            for slot, item in pairs(bag_items) do
                if type(item) == 'table' and item.id and item.id > 0 then
                    add_to_cache(item.id, false, true, bag_name)
                end
            end
        end
    end

    -- PHASE 4: Storage Slips (requires slips library)
    if slips then
        local slip_storages = slips.get_player_items()
        if slip_storages then
            for _, slip_id in ipairs(slips.storages) do
                local slip_number = slips.get_slip_number_by_id(slip_id)
                if slip_number then
                    local slip_name = string.format('Slip %02d', slip_number)
                    local items_in_slip = slip_storages[slip_id]

                    if items_in_slip then
                        for _, item_id in ipairs(items_in_slip) do
                            add_to_cache(item_id, false, true, slip_name)
                        end
                    end
                end
            end
        end
    end

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
local function scan_sets_recursive(sets_table, path, results, item_cache, depth)
    depth = depth or 0

    -- Safety: Prevent stack overflow from circular references
    if depth > MAX_RECURSION_DEPTH then
        MessageEquipment.show_max_recursion_error(MAX_RECURSION_DEPTH, path)
        return
    end

    if not sets_table or type(sets_table) ~= 'table' then
        return
    end

    -- Safety: Detect circular references (table already visited)
    -- NOTE: Aliases (sets.X = sets.Y) will trigger this, which is normal and harmless
    if visited_tables[sets_table] then
        if DEBUG then
            MessageEquipment.show_alias_detected(path)
        end
        return
    end
    visited_tables[sets_table] = true

    if DEBUG then
        MessageEquipment.show_scanning(path, depth)
    end

    -- Skip known empty/default sets
    if path and (path:match('%.naked$') or path == 'sets.naked') then
        return
    end

    -- Check if this is an equipment set (contains valid slots)
    local is_equipment_set = false
    for slot_name, _ in pairs(sets_table) do
        if VALID_SLOTS[slot_name] then
            is_equipment_set = true
            break
        end
    end

    if is_equipment_set then
        local set_valid = true
        local set_issues = {}
        local has_items = false

        for slot, item_entry in pairs(sets_table) do
            if VALID_SLOTS[slot] then
                local item_name = get_item_name(item_entry)
                if item_name then
                    has_items = true
                    local status = check_item_status(item_name, item_cache)

                    if not status.available then
                        set_valid = false
                        table.insert(set_issues, {
                            slot = slot,
                            item = item_name,
                            in_storage = status.in_storage,
                            bag_name = status.bag_name
                        })
                    end
                end
            end
        end

        if has_items then
            table.insert(results.sets, {
                path = path,
                valid = set_valid,
                issues = set_issues
            })

            if set_valid then
                results.valid_count = results.valid_count + 1
            else
                for _, issue in ipairs(set_issues) do
                    if issue.in_storage then
                        results.storage_count = results.storage_count + 1
                    else
                        results.missing_count = results.missing_count + 1
                    end
                end
            end
        end
    end

    -- ALWAYS continue recursion to find nested sets (whether this is an equipment set or not)
    for key, value in pairs(sets_table) do
        -- Skip naked set and skip slots (avoid infinite recursion)
        if key ~= 'naked' and not VALID_SLOTS[key] and type(value) == 'table' then
            local new_path = path and (path .. '.' .. key) or key
            scan_sets_recursive(value, new_path, results, item_cache, depth + 1)
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

    -- Build item cache ONCE (scan all bags for fast lookups)
    if DEBUG then
        MessageEquipment.show_building_cache()
    end

    local success, item_cache = pcall(build_item_cache)
    if not success then
        MessageEquipment.show_cache_build_failed(item_cache)
        return false
    end

    if DEBUG then
        local cache_size = 0
        for _ in pairs(item_cache) do
            cache_size = cache_size + 1
        end
        MessageEquipment.show_cache_built(cache_size)
    end

    -- Initialize results
    local results = {
        sets = {},
        valid_count = 0,
        storage_count = 0,
        missing_count = 0
    }

    -- Reset visited tables tracker
    visited_tables = {}

    if DEBUG then
        MessageEquipment.show_starting_scan()
    end

    -- Scan all sets using pre-built cache (with error protection)
    local scan_success, scan_error = pcall(scan_sets_recursive, sets, 'sets', results, item_cache, 0)
    if not scan_success then
        MessageEquipment.show_scan_failed(scan_error)
        return false
    end

    if DEBUG then
        MessageEquipment.show_scan_complete(#results.sets)
    end

    -- Check if any sets were found
    if #results.sets == 0 then
        MessageEquipment.show_no_sets_found(job_name)
        return false
    end

    -- Display issues for invalid sets only (valid sets are silent)
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

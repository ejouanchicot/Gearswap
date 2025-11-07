---============================================================================
--- Message Equipment - Equipment check formatting and display (NEW SYSTEM)
---============================================================================
--- Uses template-based messaging via MessageRenderer
--- Migrated from old system to new system: 2025-11-06
---
--- @file    messages/message_equipment.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageEquipment = {}
local M = require('shared/utils/messages/api/messages')

---============================================================================
--- EQUIPMENT CHECK MESSAGES
---============================================================================

--- Display equipment check header
--- @param job_name string Job name (WAR, RDM, etc.)
function MessageEquipment.show_check_header(job_name)
    local separator = string.rep("=", 50)

    M.send('EQUIPMENT', 'check_header_separator', {separator = separator})
    M.send('EQUIPMENT', 'check_header_title', {job_name = job_name:upper()})
    M.send('EQUIPMENT', 'check_header_separator', {separator = separator})
end

--- Display a valid set (all items available)
--- @param set_path string Full path to set (e.g., "sets.precast.WS.Upheaval")
function MessageEquipment.show_set_valid(set_path)
    M.send('EQUIPMENT', 'set_valid', {set_path = set_path})
end

--- Display a missing item
--- @param set_path string Full path to set
--- @param slot string Equipment slot
--- @param item_name string Item name
function MessageEquipment.show_missing_item(set_path, slot, item_name)
    M.send('EQUIPMENT', 'missing_item', {
        slot = slot:upper(),
        item_name = item_name
    })
    M.send('EQUIPMENT', 'missing_item_set', {set_path = set_path})
end

--- Display an item in storage
--- @param set_path string Full path to set
--- @param slot string Equipment slot
--- @param item_name string Item name
--- @param bag_name string Storage bag name
function MessageEquipment.show_storage_item(set_path, slot, item_name, bag_name)
    M.send('EQUIPMENT', 'storage_item', {
        slot = slot:upper(),
        item_name = item_name,
        bag_name = bag_name
    })
    M.send('EQUIPMENT', 'storage_item_set', {set_path = set_path})
end

--- Display equipment check summary
--- @param total_sets number Total sets checked
--- @param valid_sets number Sets with all items available
--- @param storage_count number Items found in storage
--- @param missing_count number Items not found
function MessageEquipment.show_check_summary(total_sets, valid_sets, storage_count, missing_count)
    local separator = string.rep("=", 50)

    M.send('EQUIPMENT', 'summary_separator', {separator = separator})

    -- Valid sets
    M.send('EQUIPMENT', 'summary_valid_sets', {
        valid_sets = tostring(valid_sets),
        total_sets = tostring(total_sets)
    })

    -- Storage items
    if storage_count > 0 then
        M.send('EQUIPMENT', 'summary_storage', {storage_count = tostring(storage_count)})
    end

    -- Missing items
    if missing_count > 0 then
        M.send('EQUIPMENT', 'summary_missing', {missing_count = tostring(missing_count)})
    end

    M.send('EQUIPMENT', 'summary_separator', {separator = separator})
end

--- Display error message when sets cannot be loaded
--- @param job_name string Job name
--- @param error_msg string Error message
function MessageEquipment.show_check_error(job_name, error_msg)
    M.send('EQUIPMENT', 'check_error', {
        job_name = job_name,
        error_msg = error_msg
    })
end

--- Display no sets found message
--- @param job_name string Job name
function MessageEquipment.show_no_sets_found(job_name)
    M.send('EQUIPMENT', 'no_sets_found', {job_name = job_name})
end

---============================================================================
--- DEBUG MESSAGES (Equipment Checker)
---============================================================================

--- Show max recursion depth error
--- @param max_depth number Maximum recursion depth
--- @param path string Path where error occurred
function MessageEquipment.show_max_recursion_error(max_depth, path)
    M.send('EQUIPMENT', 'max_recursion_error', {
        max_depth = tostring(max_depth),
        path = path or "unknown"
    })
end

--- Show alias detected skip message
--- @param path string Path where alias was detected
function MessageEquipment.show_alias_detected(path)
    M.send('EQUIPMENT', 'alias_detected', {path = path or "unknown"})
end

--- Show scanning debug message
--- @param path string Path being scanned
--- @param depth number Current recursion depth
function MessageEquipment.show_scanning(path, depth)
    M.send('EQUIPMENT', 'scanning', {
        path = path or "root",
        depth = tostring(depth)
    })
end

--- Show building item cache debug message
function MessageEquipment.show_building_cache()
    M.send('EQUIPMENT', 'building_cache')
end

--- Show item cache built debug message
--- @param cache_size number Number of entries in cache
function MessageEquipment.show_cache_built(cache_size)
    M.send('EQUIPMENT', 'cache_built', {cache_size = tostring(cache_size)})
end

--- Show starting set scan debug message
function MessageEquipment.show_starting_scan()
    M.send('EQUIPMENT', 'starting_scan')
end

--- Show scan complete debug message
--- @param set_count number Number of sets found
function MessageEquipment.show_scan_complete(set_count)
    M.send('EQUIPMENT', 'scan_complete', {set_count = tostring(set_count)})
end

--- Show failed to build item cache error
--- @param error_msg string Error message
function MessageEquipment.show_cache_build_failed(error_msg)
    M.send('EQUIPMENT', 'cache_build_failed', {error_msg = tostring(error_msg)})
end

--- Show set scan failed error
--- @param error_msg string Error message
function MessageEquipment.show_scan_failed(error_msg)
    M.send('EQUIPMENT', 'scan_failed', {error_msg = tostring(error_msg)})
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageEquipment

---============================================================================
--- Message Equipment - Equipment check formatting and display
---============================================================================
--- Handles all equipment validation messages with proper color coding
--- and professional formatting.
---
--- @file utils/messages/message_equipment.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-01-02
---============================================================================

local MessageEquipment = {}

-- Load core message utilities
local MessageCore = require('shared/utils/messages/message_core')
local Colors = MessageCore.COLORS

-- Color constants
local GRAY_COLOR = 160  -- Gray for secondary information

---============================================================================
--- EQUIPMENT CHECK MESSAGES
---============================================================================

--- Display equipment check header
--- @param job_name string Job name (WAR, RDM, etc.)
function MessageEquipment.show_check_header(job_name)
    local header_color = Colors.INFO_HEADER
    local separator = string.rep("=", 50)

    add_to_chat(header_color, separator)
    add_to_chat(header_color, string.format("    %s EQUIPMENT CHECK", job_name:upper()))
    add_to_chat(header_color, separator)
end

--- Display a valid set (all items available)
--- @param set_path string Full path to set (e.g., "sets.precast.WS.Upheaval")
function MessageEquipment.show_set_valid(set_path)
    local success_color = Colors.SUCCESS
    add_to_chat(success_color, string.format("[OK] %s", set_path))
end

--- Display a missing item
--- @param set_path string Full path to set
--- @param slot string Equipment slot
--- @param item_name string Item name
function MessageEquipment.show_missing_item(set_path, slot, item_name)
    local error_color = Colors.ERROR

    add_to_chat(error_color, string.format("[MISSING] [%s] %s", slot:upper(), item_name))
    add_to_chat(GRAY_COLOR, string.format("  Set: %s", set_path))
end

--- Display an item in storage
--- @param set_path string Full path to set
--- @param slot string Equipment slot
--- @param item_name string Item name
--- @param bag_name string Storage bag name
function MessageEquipment.show_storage_item(set_path, slot, item_name, bag_name)
    local warning_color = Colors.WARNING

    add_to_chat(warning_color, string.format("[STORAGE] [%s] %s - Found in %s", slot:upper(), item_name, bag_name))
    add_to_chat(GRAY_COLOR, string.format("  Set: %s", set_path))
end

--- Display equipment check summary
--- @param total_sets number Total sets checked
--- @param valid_sets number Sets with all items available
--- @param storage_count number Items found in storage
--- @param missing_count number Items not found
function MessageEquipment.show_check_summary(total_sets, valid_sets, storage_count, missing_count)
    local separator = string.rep("=", 50)
    local header_color = Colors.INFO_HEADER

    add_to_chat(header_color, separator)

    -- Valid sets
    local success_color = Colors.SUCCESS
    add_to_chat(success_color, string.format("[OK] %d/%d sets complete", valid_sets, total_sets))

    -- Storage items
    if storage_count > 0 then
        local warning_color = Colors.WARNING
        add_to_chat(warning_color, string.format("[STORAGE] %d items need to be retrieved", storage_count))
    end

    -- Missing items
    if missing_count > 0 then
        local error_color = Colors.ERROR
        add_to_chat(error_color, string.format("[MISSING] %d items not found", missing_count))
    end

    add_to_chat(header_color, separator)
end

--- Display error message when sets cannot be loaded
--- @param job_name string Job name
--- @param error_msg string Error message
function MessageEquipment.show_check_error(job_name, error_msg)
    local error_color = Colors.ERROR
    add_to_chat(error_color, string.format("[ERROR] Failed to check %s equipment: %s", job_name, error_msg))
end

--- Display no sets found message
--- @param job_name string Job name
function MessageEquipment.show_no_sets_found(job_name)
    local warning_color = Colors.WARNING
    add_to_chat(warning_color, string.format("[WARNING] No equipment sets found for %s", job_name))
end

return MessageEquipment

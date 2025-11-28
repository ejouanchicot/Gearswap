---============================================================================
--- Info Message Formatter - Centralized Info Command Messages
---============================================================================
--- Provides formatted messages for the info command (JA/Spell/WS display).
--- Handles all info-related output including headers, fields, and errors.
---
--- @file    messages/message_info.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageInfo = {}

---============================================================================
--- DEPENDENCIES
---============================================================================

local MessageColors = require('shared/utils/messages/message_colors')

---============================================================================
--- CONSTANTS
---============================================================================

local CHAT_DEFAULT = 1
local CHAT_ERROR   = 167

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Create color code for inline use
--- @param color_code number FFXI color code
--- @return string Formatted color code
local function color(color_code)
    return string.char(0x1F, color_code)
end

---============================================================================
--- INFO DISPLAY MESSAGES
---============================================================================

--- Show entity header (JA/Spell/WS)
--- @param header_text string Header title (e.g., "Job Ability Information")
function MessageInfo.show_entity_header(header_text)
    local gray = string.char(0x1F, 160)
    local yellow = string.char(0x1F, 50)
    local separator = string.rep("=", 74)
    add_to_chat(121, gray .. separator)
    add_to_chat(121, yellow .. header_text)
    add_to_chat(121, gray .. separator)
end

--- Show entity name
--- @param name string Entity name
--- @param name_color number Color code for name (JA=yellow, Spell=cyan, WS=yellow)
function MessageInfo.show_entity_name(name, name_color)
    local gray = string.char(0x1F, 160)
    local entity_color = string.char(0x1F, name_color)
    add_to_chat(121, gray .. "Name: " .. entity_color .. name)
end

--- Show entity field (key-value pair)
--- @param line string Formatted field line
function MessageInfo.show_entity_field(line)
    add_to_chat(CHAT_DEFAULT, line)
end

--- Show entity footer separator
function MessageInfo.show_entity_footer()
    local gray = string.char(0x1F, 160)
    local separator = string.rep("=", 74)
    add_to_chat(121, gray .. separator)
end

---============================================================================
--- INFO COMMAND ERROR MESSAGES
---============================================================================

--- Show info usage help
function MessageInfo.show_usage()
    local c_error = color(MessageColors.ERROR)
    add_to_chat(CHAT_ERROR, c_error .. "[INFO] Usage: //gs c info <name>")
    add_to_chat(CHAT_ERROR, c_error .. "[INFO] Example: //gs c info Last Resort")
    add_to_chat(CHAT_ERROR, c_error .. "[INFO] Example: //gs c info Haste")
    add_to_chat(CHAT_ERROR, c_error .. "[INFO] Example: //gs c info Torcleaver")
end

--- Show info not found error
--- @param name string Entity name that was not found
function MessageInfo.show_not_found(name)
    local c_error = color(MessageColors.ERROR)
    add_to_chat(CHAT_ERROR, c_error .. "[INFO] Not found: " .. name)
    add_to_chat(CHAT_ERROR, c_error .. "[INFO] Searched: Job Abilities, Spells, Weaponskills")
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageInfo

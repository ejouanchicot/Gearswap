---============================================================================
--- Midcast Message Formatter - MidcastManager Debug Messages (NEW SYSTEM)
---============================================================================
--- Uses template-based messaging via MessageRenderer
--- Migrated from old system to new system: 2025-11-06
---
--- @file    messages/message_midcast.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageMidcast = {}
local M = require('shared/utils/messages/api/messages')

---============================================================================
--- DEBUG MODE MESSAGES
---============================================================================

--- Show debug mode enabled message
function MessageMidcast.show_debug_enabled()
    M.send('MIDCAST', 'debug_enabled_separator')
    M.send('MIDCAST', 'debug_enabled_title')
    M.send('MIDCAST', 'debug_enabled_separator')
end

--- Show debug mode disabled message
function MessageMidcast.show_debug_disabled()
    M.send('MIDCAST', 'debug_disabled')
end

---============================================================================
--- DEBUG HEADER (spell + skill + target)
---============================================================================

--- Show debug header with spell info
--- @param spell string Spell name
--- @param skill string Skill name
--- @param target string Target name
function MessageMidcast.show_debug_header(spell, skill, target)
    M.send('MIDCAST', 'debug_header_separator')
    M.send('MIDCAST', 'debug_header_spell', {
        spell = spell,
        skill = skill,
        target = target or "Unknown"
    })
    M.send('MIDCAST', 'debug_header_separator')
end

---============================================================================
--- DEBUG STEPS (compact format with colors)
---============================================================================

--- Show debug step with status (OK/WARN/FAIL/INFO)
--- @param step number Step number
--- @param label string Step label (e.g., "Mode", "Type (DB)")
--- @param status string Status type: "ok", "warn", "fail", "info"
--- @param value string Value to display
function MessageMidcast.show_debug_step(step, label, status, value)
    local template_key = 'debug_step_' .. status:lower()
    M.send('MIDCAST', template_key, {
        step = tostring(step),
        label = label,
        value = value
    })
end

---============================================================================
--- DEBUG TARGET DETAILS (spell.target inspection)
---============================================================================

--- Show target details header
function MessageMidcast.show_target_details_header()
    M.send('MIDCAST', 'debug_target_header')
end

--- Show target property
--- @param property string Property name (e.g., "type", "name", "raw_type")
--- @param value any Property value
function MessageMidcast.show_target_property(property, value)
    local value_str = tostring(value)
    if value == nil then
        value_str = "nil"
    elseif type(value) == "boolean" then
        value_str = value and "true" or "false"
    end

    M.send('MIDCAST', 'debug_target_property', {
        property = property,
        value = value_str
    })
end

---============================================================================
--- DEBUG PRIORITIES (P0-P5 checks)
---============================================================================

--- Show priorities header
function MessageMidcast.show_priorities_header()
    M.send('MIDCAST', 'debug_priorities_header')
end

--- Show priority check result
--- @param priority number Priority level (0-5)
--- @param label string Priority label (e.g., "Haste II", "Target (self)")
--- @param found boolean Whether the set was found
function MessageMidcast.show_priority_check(priority, label, found)
    local template_key = found and 'debug_priority_found' or 'debug_priority_missing'
    M.send('MIDCAST', template_key, {
        priority = tostring(priority),
        label = label
    })
end

---============================================================================
--- DEBUG RESULT (final equipment)
---============================================================================

--- Show result header
function MessageMidcast.show_result_header()
    M.send('MIDCAST', 'debug_result_header')
end

--- Show result success
--- @param set_type string Set type (e.g., "self", "Enhancing Magic")
--- @param is_fallback boolean Whether this is a fallback set
function MessageMidcast.show_result(set_type, is_fallback)
    local template_key = is_fallback and 'debug_result_fallback' or 'debug_result_success'
    M.send('MIDCAST', template_key, {set_type = set_type})
end

--- Show equipment line (2 items per line)
--- @param slot1 string First slot name
--- @param item1 string First item name
--- @param slot2 string|nil Second slot name
--- @param item2 string|nil Second item name
function MessageMidcast.show_equipment_line(slot1, item1, slot2, item2)
    if slot2 and item2 then
        M.send('MIDCAST', 'debug_equipment_line', {
            slot1 = slot1,
            item1 = item1,
            slot2 = slot2,
            item2 = item2
        })
    else
        M.send('MIDCAST', 'debug_equipment_single', {
            slot = slot1,
            item = item1
        })
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageMidcast

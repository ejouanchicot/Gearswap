---============================================================================
--- Precast Message Formatter - Debug Messages for Precast System
---============================================================================
--- Uses template-based messaging via MessageRenderer
---
--- @file    messages/formatters/magic/message_precast.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-11-09
---============================================================================

local MessagePrecast = {}
local M = require('shared/utils/messages/api/messages')

---============================================================================
--- DEBUG MODE MESSAGES
---============================================================================

--- Show debug mode enabled message
function MessagePrecast.show_debug_enabled()
    M.send('PRECAST', 'debug_enabled_separator')
    M.send('PRECAST', 'debug_enabled_title')
    M.send('PRECAST', 'debug_enabled_separator')
end

--- Show debug mode disabled message
function MessagePrecast.show_debug_disabled()
    M.send('PRECAST', 'debug_disabled')
end

---============================================================================
--- DEBUG HEADER (action + type)
---============================================================================

--- Show debug header with action info
--- @param action string Action name
--- @param action_type string Action type (WeaponSkill, JobAbility, Magic, etc.)
function MessagePrecast.show_debug_header(action, action_type)
    M.send('PRECAST', 'debug_header_separator')
    M.send('PRECAST', 'debug_header_action', {
        action = action,
        type = action_type
    })
    M.send('PRECAST', 'debug_header_separator')
end

---============================================================================
--- DEBUG STEPS (compact format with colors)
---============================================================================

--- Show debug step with status (OK/WARN/FAIL/INFO)
--- @param step number Step number
--- @param label string Step label (e.g., "PrecastGuard", "Cooldown")
--- @param status string Status type: "ok", "warn", "fail", "info"
--- @param value string Value to display
function MessagePrecast.show_debug_step(step, label, status, value)
    local template_key = 'debug_step_' .. status:lower()
    M.send('PRECAST', template_key, {
        step = tostring(step),
        label = label,
        value = value or ""
    })
end

---============================================================================
--- COMPLETION MESSAGE
---============================================================================

--- Show precast completion message
function MessagePrecast.show_completion()
    M.send('PRECAST', 'debug_completion_separator')
    M.send('PRECAST', 'debug_completion')
    M.send('PRECAST', 'debug_completion_separator')
end

---============================================================================
--- EQUIPMENT DISPLAY
---============================================================================

--- Show equipped set info
--- @param set_type string Type of set (e.g., "FC", "JA.Convert", "WS.Savage Blade")
function MessagePrecast.show_equipped_set(set_type)
    M.send('PRECAST', 'debug_set_equipped', {
        set = set_type
    })
end

--- Show equipment details from set table (only slots that exist in the set)
--- @param gear_set table The gear set table to display
function MessagePrecast.show_equipment(gear_set)
    if not gear_set then
        return
    end

    local slots = {
        'main', 'sub', 'range', 'ammo',
        'head', 'body', 'hands', 'legs', 'feet',
        'neck', 'waist', 'left_ear', 'right_ear',
        'left_ring', 'right_ring', 'back'
    }

    -- Display one item per line (only if slot exists in set)
    for _, slot in ipairs(slots) do
        local item = gear_set[slot]

        -- Only show slots that are defined in the set
        if item then
            -- Handle table format (augmented items)
            if type(item) == "table" then
                item = item.name or "table"
            end

            -- Convert slot names for display
            local display_slot = slot
            if slot == "left_ear" then display_slot = "ear1"
            elseif slot == "right_ear" then display_slot = "ear2"
            elseif slot == "left_ring" then display_slot = "ring1"
            elseif slot == "right_ring" then display_slot = "ring2"
            end

            M.send('PRECAST', 'debug_equipment_single', {
                slot = display_slot,
                item = tostring(item)
            })
        end
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessagePrecast

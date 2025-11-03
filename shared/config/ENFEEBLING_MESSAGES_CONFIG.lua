---============================================================================
--- Enfeebling Magic Messages Configuration
---============================================================================
--- Controls how Enfeebling Magic spell messages are displayed.
---
--- Display Modes:
---   • 'full'        - Show spell name + description
---                     Example: [RDM/DNC] Slow II -> Reduces target attack speed. Potency varies with skill.
---
---   • 'on'          - Show spell name only (no description)
---                     Example: [RDM/DNC] Slow II
---
---   • 'off'         - No messages at all (silent mode)
---                     Example: (nothing displayed)
---
--- @file ENFEEBLING_MESSAGES_CONFIG.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30
---============================================================================

local ENFEEBLING_MESSAGES_CONFIG = {}

---============================================================================
--- CONFIGURATION
---============================================================================

--- Display mode for Enfeebling Magic spell messages
--- @type string 'full' | 'on' | 'off'
--- • 'full' = Show spell name + description
--- • 'on'   = Show spell name only
--- • 'off'  = No messages (silent)
ENFEEBLING_MESSAGES_CONFIG.display_mode = 'full'

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Check if messages are enabled
--- @return boolean true if any messages should be shown
function ENFEEBLING_MESSAGES_CONFIG.is_enabled()
    local mode = ENFEEBLING_MESSAGES_CONFIG.display_mode
    return mode ~= 'off' and mode ~= 'disabled' and mode ~= 'disable'
end

--- Check if descriptions should be shown
--- @return boolean true if descriptions should be included
function ENFEEBLING_MESSAGES_CONFIG.show_description()
    return ENFEEBLING_MESSAGES_CONFIG.display_mode == 'full'
end

--- Check if only name should be shown
--- @return boolean true if only spell name should be shown
function ENFEEBLING_MESSAGES_CONFIG.is_name_only()
    local mode = ENFEEBLING_MESSAGES_CONFIG.display_mode
    return mode == 'on' or mode == 'name_only' or mode == 'name'
end

--- Validate and set display mode
--- @param mode string 'full' | 'on' | 'off'
--- @return boolean true if mode is valid and was set
function ENFEEBLING_MESSAGES_CONFIG.set_display_mode(mode)
    local valid_modes = {
        -- Primary modes (simple)
        ['full'] = true,
        ['on'] = true,
        ['off'] = true,
        -- Backward compatibility aliases
        ['name_only'] = true,
        ['name'] = true,
        ['disabled'] = true,
        ['disable'] = true
    }

    if valid_modes[mode] then
        ENFEEBLING_MESSAGES_CONFIG.display_mode = mode
        return true
    else
        add_to_chat(167, '[ENFEEBLING_CONFIG] Invalid mode: ' .. tostring(mode))
        add_to_chat(167, '[ENFEEBLING_CONFIG] Valid modes: full, on, off')
        return false
    end
end

---============================================================================
--- EXPORT
---============================================================================

return ENFEEBLING_MESSAGES_CONFIG

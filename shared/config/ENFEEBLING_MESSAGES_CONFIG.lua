---============================================================================
--- Enfeebling Magic Messages Configuration
---============================================================================
--- Controls how Enfeebling Magic spell messages are displayed.
---
--- Display Modes:
---   • 'full' - Show spell name + description
---              Example: [RDM/DNC] Slow II -> Reduces target attack speed.
---   • 'on'   - Show spell name only (no description)
---              Example: [RDM/DNC] Slow II
---   • 'off'  - No messages at all (silent mode)
---
--- @file ENFEEBLING_MESSAGES_CONFIG.lua
--- @author Tetsouo
--- @version 1.1 - Refactored layout
--- @date Created: 2025-10-30 | Updated: 2025-11-06
---============================================================================

local ENFEEBLING_MESSAGES_CONFIG = {}

---============================================================================
--- CONFIGURATION
---============================================================================

--- Display mode: 'full' | 'on' | 'off'
ENFEEBLING_MESSAGES_CONFIG.display_mode = 'full'

--- Valid mode lookup (internal)
ENFEEBLING_MESSAGES_CONFIG.VALID_MODES = {
    -- Primary modes
    full        = true,
    on          = true,
    off         = true,
    -- Backward compatibility aliases
    name_only   = true,
    name        = true,
    disabled    = true,
    disable     = true
}

---============================================================================
--- HELPER FUNCTIONS - Display Mode Checks
---============================================================================

--- Check if messages are enabled (not 'off')
function ENFEEBLING_MESSAGES_CONFIG.is_enabled()
    local mode = ENFEEBLING_MESSAGES_CONFIG.display_mode
    return mode ~= 'off' and mode ~= 'disabled' and mode ~= 'disable'
end

--- Check if descriptions should be shown (mode = 'full')
function ENFEEBLING_MESSAGES_CONFIG.show_description()
    return ENFEEBLING_MESSAGES_CONFIG.display_mode == 'full'
end

--- Check if only name should be shown (mode = 'on')
function ENFEEBLING_MESSAGES_CONFIG.is_name_only()
    local mode = ENFEEBLING_MESSAGES_CONFIG.display_mode
    return mode == 'on' or mode == 'name_only' or mode == 'name'
end

---============================================================================
--- HELPER FUNCTIONS - Mode Validation
---============================================================================

--- Validate and set display mode
--- @param mode string 'full' | 'on' | 'off'
--- @return boolean true if mode is valid
function ENFEEBLING_MESSAGES_CONFIG.set_display_mode(mode)
    if ENFEEBLING_MESSAGES_CONFIG.VALID_MODES[mode] then
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

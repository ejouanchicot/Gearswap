---============================================================================
--- Job Ability Messages Configuration
---============================================================================
--- Controls how Job Ability activation messages are displayed.
---
--- Display Modes:
---   • 'full' - Show ability name + description
---              Example: [DNC/SAM] Haste Samba activated! Attack speed +10%
---   • 'on'   - Show ability name only (no description)
---              Example: [DNC/SAM] Haste Samba activated!
---   • 'off'  - No messages at all (silent mode)
---
--- @file JA_MESSAGES_CONFIG.lua
--- @author Tetsouo
--- @version 1.1 - Refactored layout
--- @date Created: 2025-10-30 | Updated: 2025-11-06
---============================================================================

local JA_MESSAGES_CONFIG = {}

---============================================================================
--- CONFIGURATION
---============================================================================

--- Display mode: 'full' | 'on' | 'off'
JA_MESSAGES_CONFIG.display_mode = 'full'

--- Valid mode lookup (internal)
JA_MESSAGES_CONFIG.VALID_MODES = {
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
function JA_MESSAGES_CONFIG.is_enabled()
    local mode = JA_MESSAGES_CONFIG.display_mode
    return mode ~= 'off' and mode ~= 'disabled' and mode ~= 'disable'
end

--- Check if descriptions should be shown (mode = 'full')
function JA_MESSAGES_CONFIG.show_description()
    return JA_MESSAGES_CONFIG.display_mode == 'full'
end

--- Check if only name should be shown (mode = 'on')
function JA_MESSAGES_CONFIG.is_name_only()
    local mode = JA_MESSAGES_CONFIG.display_mode
    return mode == 'on' or mode == 'name_only' or mode == 'name'
end

---============================================================================
--- HELPER FUNCTIONS - Mode Validation
---============================================================================

--- Validate and set display mode
--- @param mode string 'full' | 'on' | 'off'
--- @return boolean true if mode is valid
function JA_MESSAGES_CONFIG.set_display_mode(mode)
    if JA_MESSAGES_CONFIG.VALID_MODES[mode] then
        JA_MESSAGES_CONFIG.display_mode = mode
        return true
    else
        add_to_chat(167, '[JA_CONFIG] Invalid mode: ' .. tostring(mode))
        add_to_chat(167, '[JA_CONFIG] Valid modes: full, on, off')
        return false
    end
end

---============================================================================
--- EXPORT
---============================================================================

return JA_MESSAGES_CONFIG

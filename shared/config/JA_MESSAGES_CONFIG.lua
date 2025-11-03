---============================================================================
--- Job Ability Messages Configuration
---============================================================================
--- Controls how Job Ability activation messages are displayed.
---
--- Display Modes:
---   • 'full'        - Show ability name + description
---                     Example: [DNC/SAM] Haste Samba activated! Attack speed +10%
---
---   • 'name_only'   - Show only ability name (no description)
---                     Example: [DNC/SAM] Haste Samba activated!
---
---   • 'disabled'    - No messages at all (silent mode)
---                     Example: (nothing displayed)
---
--- @file JA_MESSAGES_CONFIG.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30
---============================================================================

local JA_MESSAGES_CONFIG = {}

---============================================================================
--- CONFIGURATION
---============================================================================

--- Display mode for Job Ability activation messages
--- @type string 'full' | 'on' | 'off'
--- • 'full' = Show ability name + description
--- • 'on'   = Show ability name only
--- • 'off'  = No messages (silent)
JA_MESSAGES_CONFIG.display_mode = 'full'

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Check if messages are enabled
--- @return boolean true if any messages should be shown
function JA_MESSAGES_CONFIG.is_enabled()
    local mode = JA_MESSAGES_CONFIG.display_mode
    return mode ~= 'off' and mode ~= 'disabled' and mode ~= 'disable'
end

--- Check if descriptions should be shown
--- @return boolean true if descriptions should be included
function JA_MESSAGES_CONFIG.show_description()
    return JA_MESSAGES_CONFIG.display_mode == 'full'
end

--- Check if only name should be shown
--- @return boolean true if only ability name should be shown
function JA_MESSAGES_CONFIG.is_name_only()
    local mode = JA_MESSAGES_CONFIG.display_mode
    return mode == 'on' or mode == 'name_only' or mode == 'name'
end

--- Validate and set display mode
--- @param mode string 'full' | 'on' | 'off'
--- @return boolean true if mode is valid and was set
function JA_MESSAGES_CONFIG.set_display_mode(mode)
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

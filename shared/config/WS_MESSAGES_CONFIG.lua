---============================================================================
--- Weapon Skills Messages Configuration
---============================================================================
--- Controls how Weapon Skill activation messages are displayed.
---
--- Display Modes:
---   • 'full'        - Show WS name + description + TP
---                     Example: [WAR/SAM] [Upheaval] -> Four hits. Damage varies with TP.
---                              [Upheaval] (2290 TP)
---
---   • 'on'          - Show WS name + TP only (no description)
---                     Example: [Upheaval] (2290 TP)
---
---   • 'off'         - No messages at all (silent mode)
---                     Example: (nothing displayed)
---
--- @file WS_MESSAGES_CONFIG.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30
---============================================================================

local WS_MESSAGES_CONFIG = {}

---============================================================================
--- CONFIGURATION
---============================================================================

--- Display mode for Weapon Skill activation messages
--- @type string 'full' | 'on' | 'off'
--- • 'full' = Show WS name + description + TP (2 messages)
--- • 'on'   = Show WS name + TP only (1 message)
--- • 'off'  = No messages (silent)
WS_MESSAGES_CONFIG.display_mode = 'full'

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Check if messages are enabled
--- @return boolean true if any messages should be shown
function WS_MESSAGES_CONFIG.is_enabled()
    local mode = WS_MESSAGES_CONFIG.display_mode
    return mode ~= 'off' and mode ~= 'disabled' and mode ~= 'disable'
end

--- Check if descriptions should be shown
--- @return boolean true if descriptions should be included
function WS_MESSAGES_CONFIG.show_description()
    return WS_MESSAGES_CONFIG.display_mode == 'full'
end

--- Check if only TP should be shown (no description)
--- @return boolean true if only TP message should be shown
function WS_MESSAGES_CONFIG.is_tp_only()
    local mode = WS_MESSAGES_CONFIG.display_mode
    return mode == 'on' or mode == 'tp_only' or mode == 'tp'
end

--- Validate and set display mode
--- @param mode string 'full' | 'on' | 'off'
--- @return boolean true if mode is valid and was set
function WS_MESSAGES_CONFIG.set_display_mode(mode)
    local valid_modes = {
        -- Primary modes (simple)
        ['full'] = true,
        ['on'] = true,
        ['off'] = true,
        -- Backward compatibility aliases
        ['tp_only'] = true,
        ['tp'] = true,
        ['disabled'] = true,
        ['disable'] = true
    }

    if valid_modes[mode] then
        WS_MESSAGES_CONFIG.display_mode = mode
        return true
    else
        add_to_chat(167, '[WS_CONFIG] Invalid mode: ' .. tostring(mode))
        add_to_chat(167, '[WS_CONFIG] Valid modes: full, on, off')
        return false
    end
end

---============================================================================
--- EXPORT
---============================================================================

return WS_MESSAGES_CONFIG

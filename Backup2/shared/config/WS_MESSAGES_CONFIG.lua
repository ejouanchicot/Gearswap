---  ═══════════════════════════════════════════════════════════════════════════
---   Weapon Skills Messages Configuration - WS Activation Display Control
---  ═══════════════════════════════════════════════════════════════════════════
---   Controls how Weapon Skill activation messages are displayed.
---
---   Display Modes:
---     • 'full' - Show WS name + description + TP
---                Example: [WAR/SAM] [Upheaval] >> Four hits. Damage varies with TP.
---                         [Upheaval] (2290 TP)
---     • 'on'   - Show WS name + TP only (no description)
---                Example: [Upheaval] (2290 TP)
---     • 'off'  - No messages at all (silent mode)
---
---   Architecture:
---     • Persistent settings via message_settings.lua
---     • Survives //lua reload and game restarts
---     • Mode validation with backward compatibility
---     • Helper functions for mode checks
---
---   Settings File:
---     • shared/config/message_modes.lua (per-character)
---
---   @file    shared/config/WS_MESSAGES_CONFIG.lua
---   @author  Tetsouo
---   @version 1.3 - Refactored with new header style
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

local WS_MESSAGES_CONFIG = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   PERSISTENT SETTINGS
---  ═══════════════════════════════════════════════════════════════════════════

-- Load persistent settings manager
local MessageSettings = require('shared/config/message_settings')

--- Display mode loaded from persistent settings (survives reload/restart)
WS_MESSAGES_CONFIG.display_mode = MessageSettings.get_ws_mode()

--- Valid mode lookup (internal)
WS_MESSAGES_CONFIG.VALID_MODES = {
    -- Primary modes
    full        = true,
    on          = true,
    off         = true,
    -- Backward compatibility aliases
    tp_only     = true,
    tp          = true,
    disabled    = true,
    disable     = true
}

---  ═══════════════════════════════════════════════════════════════════════════
---   HELPER FUNCTIONS - Display Mode Checks
---  ═══════════════════════════════════════════════════════════════════════════

--- Check if messages are enabled (not 'off')
function WS_MESSAGES_CONFIG.is_enabled()
    -- Always read current mode from persistent settings
    local mode = MessageSettings.get_ws_mode()
    return mode ~= 'off' and mode ~= 'disabled' and mode ~= 'disable'
end

--- Check if descriptions should be shown (mode = 'full')
function WS_MESSAGES_CONFIG.show_description()
    -- Always read current mode from persistent settings
    return MessageSettings.get_ws_mode() == 'full'
end

--- Check if only TP should be shown (mode = 'on')
function WS_MESSAGES_CONFIG.is_tp_only()
    -- Always read current mode from persistent settings
    local mode = MessageSettings.get_ws_mode()
    return mode == 'on' or mode == 'tp_only' or mode == 'tp'
end

---  ═══════════════════════════════════════════════════════════════════════════
---   HELPER FUNCTIONS - Mode Validation
---  ═══════════════════════════════════════════════════════════════════════════

--- Validate and set display mode
--- @param mode string 'full' | 'on' | 'off'
--- @return boolean true if mode is valid
function WS_MESSAGES_CONFIG.set_display_mode(mode)
    if WS_MESSAGES_CONFIG.VALID_MODES[mode] then
        -- Save to persistent settings file ([CharName]/config/message_modes.lua)
        MessageSettings.set_ws_mode(mode)
        WS_MESSAGES_CONFIG.display_mode = mode
        return true
    else
        add_to_chat(167, '[WS_CONFIG] Invalid mode: ' .. tostring(mode))
        add_to_chat(167, '[WS_CONFIG] Valid modes: full, on, off')
        return false
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return WS_MESSAGES_CONFIG

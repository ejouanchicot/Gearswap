---  ═══════════════════════════════════════════════════════════════════════════
---   Enhancing Magic Messages Configuration - Buff Spell Display Control
---  ═══════════════════════════════════════════════════════════════════════════
---   Controls how Enhancing Magic spell messages are displayed.
---
---   Display Modes:
---     • 'full' - Show spell name + description
---                Example: [WHM/DNC] Haste >> Increases attack speed.
---     • 'on'   - Show spell name only (no description)
---                Example: [WHM/DNC] Haste
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
---   @file    shared/config/ENHANCING_MESSAGES_CONFIG.lua
---   @author  Tetsouo
---   @version 1.3 - Refactored with new header style
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

local ENHANCING_MESSAGES_CONFIG = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   PERSISTENT SETTINGS
---  ═══════════════════════════════════════════════════════════════════════════

-- Load persistent settings manager
local MessageSettings = require('shared/config/message_settings')

--- Display mode loaded from persistent settings (survives reload/restart)
ENHANCING_MESSAGES_CONFIG.display_mode = MessageSettings.get_enhancing_mode()

--- Valid mode lookup (internal)
ENHANCING_MESSAGES_CONFIG.VALID_MODES = {
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

---  ═══════════════════════════════════════════════════════════════════════════
---   HELPER FUNCTIONS - Display Mode Checks
---  ═══════════════════════════════════════════════════════════════════════════

--- Check if messages are enabled (not 'off')
function ENHANCING_MESSAGES_CONFIG.is_enabled()
    -- Always read current mode from persistent settings
    local mode = MessageSettings.get_enhancing_mode()
    return mode ~= 'off' and mode ~= 'disabled' and mode ~= 'disable'
end

--- Check if descriptions should be shown (mode = 'full')
function ENHANCING_MESSAGES_CONFIG.show_description()
    -- Always read current mode from persistent settings
    return MessageSettings.get_enhancing_mode() == 'full'
end

--- Check if only name should be shown (mode = 'on')
function ENHANCING_MESSAGES_CONFIG.is_name_only()
    -- Always read current mode from persistent settings
    local mode = MessageSettings.get_enhancing_mode()
    return mode == 'on' or mode == 'name_only' or mode == 'name'
end

---  ═══════════════════════════════════════════════════════════════════════════
---   HELPER FUNCTIONS - Mode Validation
---  ═══════════════════════════════════════════════════════════════════════════

--- Validate and set display mode
--- @param mode string 'full' | 'on' | 'off'
--- @return boolean true if mode is valid
function ENHANCING_MESSAGES_CONFIG.set_display_mode(mode)
    if ENHANCING_MESSAGES_CONFIG.VALID_MODES[mode] then
        -- Save to persistent settings file ([CharName]/config/message_modes.lua)
        MessageSettings.set_enhancing_mode(mode)
        ENHANCING_MESSAGES_CONFIG.display_mode = mode
        return true
    else
        add_to_chat(167, '[ENHANCING_CONFIG] Invalid mode: ' .. tostring(mode))
        add_to_chat(167, '[ENHANCING_CONFIG] Valid modes: full, on, off')
        return false
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return ENHANCING_MESSAGES_CONFIG

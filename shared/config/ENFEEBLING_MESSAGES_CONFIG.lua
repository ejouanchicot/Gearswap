---  ═══════════════════════════════════════════════════════════════════════════
---   Enfeebling Magic Messages Configuration - Debuff Spell Display Control
---  ═══════════════════════════════════════════════════════════════════════════
---   Controls how Enfeebling Magic spell messages are displayed.
---
---   Display Modes:
---     • 'full' - Show spell name + description
---                Example: [RDM/DNC] Slow II >> Reduces target attack speed.
---     • 'on'   - Show spell name only (no description)
---                Example: [RDM/DNC] Slow II
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
---   @file    shared/config/ENFEEBLING_MESSAGES_CONFIG.lua
---   @author  Tetsouo
---   @version 1.3 - Refactored with new header style
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

local ENFEEBLING_MESSAGES_CONFIG = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   PERSISTENT SETTINGS
---  ═══════════════════════════════════════════════════════════════════════════

-- Load persistent settings manager
local MessageSettings = require('shared/config/message_settings')

--- Display mode loaded from persistent settings (survives reload/restart)
ENFEEBLING_MESSAGES_CONFIG.display_mode = MessageSettings.get_enfeebling_mode()

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

---  ═══════════════════════════════════════════════════════════════════════════
---   HELPER FUNCTIONS - Display Mode Checks
---  ═══════════════════════════════════════════════════════════════════════════

--- Check if messages are enabled (not 'off')
function ENFEEBLING_MESSAGES_CONFIG.is_enabled()
    -- Always read current mode from persistent settings
    local mode = MessageSettings.get_enfeebling_mode()
    return mode ~= 'off' and mode ~= 'disabled' and mode ~= 'disable'
end

--- Check if descriptions should be shown (mode = 'full')
function ENFEEBLING_MESSAGES_CONFIG.show_description()
    -- Always read current mode from persistent settings
    return MessageSettings.get_enfeebling_mode() == 'full'
end

--- Check if only name should be shown (mode = 'on')
function ENFEEBLING_MESSAGES_CONFIG.is_name_only()
    -- Always read current mode from persistent settings
    local mode = MessageSettings.get_enfeebling_mode()
    return mode == 'on' or mode == 'name_only' or mode == 'name'
end

---  ═══════════════════════════════════════════════════════════════════════════
---   HELPER FUNCTIONS - Mode Validation
---  ═══════════════════════════════════════════════════════════════════════════

--- Validate and set display mode
--- @param mode string 'full' | 'on' | 'off'
--- @return boolean true if mode is valid
function ENFEEBLING_MESSAGES_CONFIG.set_display_mode(mode)
    if ENFEEBLING_MESSAGES_CONFIG.VALID_MODES[mode] then
        -- Save to persistent settings file ([CharName]/config/message_modes.lua)
        MessageSettings.set_enfeebling_mode(mode)
        ENFEEBLING_MESSAGES_CONFIG.display_mode = mode
        return true
    else
        add_to_chat(167, '[ENFEEBLING_CONFIG] Invalid mode: ' .. tostring(mode))
        add_to_chat(167, '[ENFEEBLING_CONFIG] Valid modes: full, on, off')
        return false
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return ENFEEBLING_MESSAGES_CONFIG

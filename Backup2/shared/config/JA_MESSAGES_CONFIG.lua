---  ═══════════════════════════════════════════════════════════════════════════
---   Job Ability Messages Configuration - JA Activation Display Control
---  ═══════════════════════════════════════════════════════════════════════════
---   Controls how Job Ability activation messages are displayed.
---
---   Display Modes:
---     • 'full' - Show ability name + description
---                Example: [DNC/SAM] Haste Samba activated! >> Attack speed +10%
---     • 'on'   - Show ability name only (no description)
---                Example: [DNC/SAM] Haste Samba activated!
---     • 'off'  - No messages at all (silent mode)
---
---   Note: 'full' mode shows ONLY the description, not recast/level info
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
---   @file    shared/config/JA_MESSAGES_CONFIG.lua
---   @author  Tetsouo
---   @version 1.3 - Refactored with new header style
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

local JA_MESSAGES_CONFIG = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   PERSISTENT SETTINGS
---  ═══════════════════════════════════════════════════════════════════════════

-- Load persistent settings manager
local MessageSettings = require('shared/config/message_settings')

--- Display mode loaded from persistent settings (survives reload/restart)
JA_MESSAGES_CONFIG.display_mode = MessageSettings.get_ja_mode()

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

---  ═══════════════════════════════════════════════════════════════════════════
---   HELPER FUNCTIONS - Display Mode Checks
---  ═══════════════════════════════════════════════════════════════════════════

--- Check if messages are enabled (not 'off')
function JA_MESSAGES_CONFIG.is_enabled()
    -- Always read current mode from persistent settings
    local mode = MessageSettings.get_ja_mode()
    return mode ~= 'off' and mode ~= 'disabled' and mode ~= 'disable'
end

--- Check if descriptions should be shown (mode = 'full')
function JA_MESSAGES_CONFIG.show_description()
    -- Always read current mode from persistent settings
    return MessageSettings.get_ja_mode() == 'full'
end

--- Check if only name should be shown (mode = 'on')
function JA_MESSAGES_CONFIG.is_name_only()
    -- Always read current mode from persistent settings
    local mode = MessageSettings.get_ja_mode()
    return mode == 'on' or mode == 'name_only' or mode == 'name'
end

---  ═══════════════════════════════════════════════════════════════════════════
---   HELPER FUNCTIONS - Mode Validation
---  ═══════════════════════════════════════════════════════════════════════════

--- Validate and set display mode
--- @param mode string 'full' | 'on' | 'off'
--- @return boolean true if mode is valid
function JA_MESSAGES_CONFIG.set_display_mode(mode)
    if JA_MESSAGES_CONFIG.VALID_MODES[mode] then
        -- Save to persistent settings file ([CharName]/config/message_modes.lua)
        MessageSettings.set_ja_mode(mode)
        JA_MESSAGES_CONFIG.display_mode = mode
        return true
    else
        add_to_chat(167, '[JA_CONFIG] Invalid mode: ' .. tostring(mode))
        add_to_chat(167, '[JA_CONFIG] Valid modes: full, on, off')
        return false
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return JA_MESSAGES_CONFIG

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
---     • [CharName]/config/message_modes.lua (written by message_settings.lua)
---
---   @file    shared/config/WS_MESSAGES_CONFIG.lua
---   @author  Tetsouo
---   @version 1.3 - Refactored with new header style
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

local MessageModeConfig = require('shared/config/message_mode_config')

return MessageModeConfig.create({
    getter        = 'get_ws_mode',
    setter        = 'set_ws_mode',
    tag           = 'WS_CONFIG',
    short_check   = 'is_tp_only',
    short_aliases = { 'tp_only', 'tp' },
})

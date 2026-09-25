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
---     • [CharName]/config/message_modes.lua (written by message_settings.lua)
---
---   @file    shared/config/JA_MESSAGES_CONFIG.lua
---   @author  Tetsouo
---   @version 1.3 - Refactored with new header style
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

local MessageModeConfig = require('shared/config/message_mode_config')

return MessageModeConfig.create({
    getter        = 'get_ja_mode',
    setter        = 'set_ja_mode',
    tag           = 'JA_CONFIG',
    short_check   = 'is_name_only',
    short_aliases = { 'name_only', 'name' },
})

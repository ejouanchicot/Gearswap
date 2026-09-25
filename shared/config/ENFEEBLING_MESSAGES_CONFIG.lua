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
---     • Shares spell_mode with ENHANCING_MESSAGES_CONFIG: changing one changes both
---     • Survives //lua reload and game restarts
---     • Mode validation with backward compatibility
---     • Helper functions for mode checks
---
---   Settings File:
---     • [CharName]/config/message_modes.lua (written by message_settings.lua)
---
---   @file    shared/config/ENFEEBLING_MESSAGES_CONFIG.lua
---   @author  Tetsouo
---   @version 1.3 - Refactored with new header style
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

local MessageModeConfig = require('shared/config/message_mode_config')

return MessageModeConfig.create({
    getter        = 'get_enfeebling_mode',
    setter        = 'set_enfeebling_mode',
    tag           = 'ENFEEBLING_CONFIG',
    short_check   = 'is_name_only',
    short_aliases = { 'name_only', 'name' },
})

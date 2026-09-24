---============================================================================
--- DRG Message Formatter - Dragoon-Specific Messages
---============================================================================
--- Templates: data/jobs/drg_messages.lua, sent through M.job.
---
--- @file    shared/utils/messages/formatters/jobs/message_drg.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageDRG = {}

local M = require('shared/utils/messages/api/messages')

---============================================================================
--- JUMP ERROR MESSAGES
---============================================================================

--- Show DRG subjob required error
function MessageDRG.show_drg_subjob_required()
    M.job('DRG', 'drg_subjob_required', {})
end

--- Show subjob disabled error (Odyssey)
function MessageDRG.show_subjob_disabled()
    M.job('DRG', 'subjob_disabled', {})
end

--- Show Jump on cooldown error
--- @param recast_time number Recast time remaining in seconds
function MessageDRG.show_jump_on_cooldown(recast_time)
    M.job('DRG', 'jump_on_cooldown', {
        recast = string.format('%.1f', recast_time)
    })
end

--- Show High Jump on cooldown error
--- @param recast_time number Recast time remaining in seconds
function MessageDRG.show_high_jump_on_cooldown(recast_time)
    M.job('DRG', 'high_jump_on_cooldown', {
        recast = string.format('%.1f', recast_time)
    })
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageDRG

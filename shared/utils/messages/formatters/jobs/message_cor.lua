---============================================================================
--- COR Message Formatter - Centralized COR Messages
---============================================================================
--- Templates: data/jobs/cor_messages.lua, sent through M.job.
---
--- @file    shared/utils/messages/formatters/jobs/message_cor.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageCOR = {}

local M = require('shared/utils/messages/api/messages')

---============================================================================
--- PARTYTRACKER MODULE LOAD ERRORS
---============================================================================

--- Show RollTracker failed to load warning
function MessageCOR.show_rolltracker_load_failed()
    M.job('COR', 'rolltracker_load_failed', {})
end

--- Show packets library failed to load error
function MessageCOR.show_packets_load_failed()
    M.job('COR', 'packets_load_failed', {})
end

--- Show resources library failed to load error
function MessageCOR.show_resources_load_failed()
    M.job('COR', 'resources_load_failed', {})
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageCOR

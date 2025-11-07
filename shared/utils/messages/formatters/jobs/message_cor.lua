---============================================================================
--- COR Message Formatter - Centralized COR Messages
---============================================================================
--- Uses NEW message system with inline colors
--- Delegates to api/messages.lua for all formatting
---
--- @file    messages/message_cor.lua
--- @author  Tetsouo
--- @version 2.0 (NEW SYSTEM)
--- @date    Created: 2025-11-06 | Migrated: 2025-11-06
---============================================================================

local MessageCOR = {}

-- NEW message system
local M = require('shared/utils/messages/api/messages')

---============================================================================
--- PARTYTRACKER MODULE LOAD ERRORS (NEW SYSTEM)
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

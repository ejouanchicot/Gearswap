---============================================================================
--- WHM Message Formatter - Centralized WHM Messages
---============================================================================
--- Templates: data/jobs/whm_messages.lua, sent through M.job.
---
--- @file    shared/utils/messages/formatters/jobs/message_whm.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageWHM = {}

local M = require('shared/utils/messages/api/messages')

---============================================================================
--- MODULE LOAD WARNINGS
---============================================================================

--- Show CureManager failed to load warning
function MessageWHM.show_curemanager_not_loaded()
    M.job('WHM', 'curemanager_not_loaded', {})
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageWHM

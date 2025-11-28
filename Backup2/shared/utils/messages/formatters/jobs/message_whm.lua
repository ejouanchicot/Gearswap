---============================================================================
--- WHM Message Formatter - Centralized WHM Messages
---============================================================================
--- Uses NEW message system with inline colors
--- Delegates to api/messages.lua for all formatting
---
--- @file    messages/message_whm.lua
--- @author  Tetsouo
--- @version 2.0 (NEW SYSTEM)
--- @date    Created: 2025-11-06 | Migrated: 2025-11-06
---============================================================================

local MessageWHM = {}

-- NEW message system
local M = require('shared/utils/messages/api/messages')

---============================================================================
--- MODULE LOAD WARNINGS (NEW SYSTEM)
---============================================================================

--- Show CureManager failed to load warning
function MessageWHM.show_curemanager_not_loaded()
    M.job('WHM', 'curemanager_not_loaded', {})
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageWHM

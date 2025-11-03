---============================================================================
--- BRD Status Module - Player Status Change Management
---============================================================================
--- Handles player status changes (Idle, Engaged, Resting, Dead).
---
--- @file BRD_STATUS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-13
---============================================================================

--- Handle player status changes
--- @param newStatus string New status
--- @param oldStatus string Previous status
--- @param eventArgs table Event arguments
function job_status_change(newStatus, oldStatus, eventArgs)
    -- No special BRD status change logic needed
    -- Mote-Include handles idle/engaged transitions automatically
end

-- Export to global scope
_G.job_status_change = job_status_change

-- Export module
local BRD_STATUS = {}
BRD_STATUS.job_status_change = job_status_change

return BRD_STATUS

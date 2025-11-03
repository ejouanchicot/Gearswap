---============================================================================
--- RDM Status Module - Player Status Change Management
---============================================================================
--- Handles status changes (Idle, Engaged, Resting, Dead, etc.)
---
--- @file RDM_STATUS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-12
---============================================================================

--- Handle status change events
--- @param newStatus string New status (Idle, Engaged, Resting, Dead, etc.)
--- @param oldStatus string Previous status
--- @param eventArgs table Event arguments
function job_status_change(newStatus, oldStatus, eventArgs)
    -- RDM-specific status change logic can be added here
    -- Example: Re-apply enspell when returning from dead
end

-- Export to global scope
_G.job_status_change = job_status_change

-- Export module
local RDM_STATUS = {}
RDM_STATUS.job_status_change = job_status_change

return RDM_STATUS

---============================================================================
--- SAM Status Module - Status Change Handling
---============================================================================
--- @file SAM_STATUS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-21
---============================================================================

function job_status_change(newStatus, oldStatus, eventArgs)
    -- Handle status changes (Idle, Engaged, Dead, etc.)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

_G.job_status_change = job_status_change

local SAM_STATUS = {}
SAM_STATUS.job_status_change = job_status_change

return SAM_STATUS

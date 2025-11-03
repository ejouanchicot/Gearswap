---============================================================================
--- COR Status Module - Status Change Management
---============================================================================
--- Handles player status changes for Corsair job (Idle, Engaged, Resting, Dead).
--- Triggers appropriate gear changes based on status transitions.
---
--- @file COR_STATUS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-07
---============================================================================

---============================================================================
--- STATUS CHANGE HOOKS
---============================================================================

--- Called when player status changes
--- @param newStatus string New status (Idle, Engaged, Resting, Dead)
--- @param oldStatus string Old status
--- @param eventArgs table Event arguments
--- @return void
function job_status_change(newStatus, oldStatus, eventArgs)
    -- COR-specific status change logic

    -- Handle status transitions
    if newStatus == 'Engaged' then
        -- Entering combat
    elseif oldStatus == 'Engaged' then
        -- Exiting combat
    elseif newStatus == 'Resting' then
        -- Started resting
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export global for GearSwap (Mote-Include)
_G.job_status_change = job_status_change

-- Export module
local COR_STATUS = {}
COR_STATUS.job_status_change = job_status_change

return COR_STATUS

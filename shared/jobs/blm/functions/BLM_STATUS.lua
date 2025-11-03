---============================================================================
--- BLM Status Module - Player Status Change Handling
---============================================================================
--- Handles player status changes for Black Mage job.
--- Status types: Idle, Engaged, Resting, Dead
---
--- @file BLM_STATUS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-15
---============================================================================

---============================================================================
--- STATUS HOOKS
---============================================================================

function job_status_change(newStatus, oldStatus, eventArgs)
    -- BLM-SPECIFIC STATUS CHANGE LOGIC
    -- Currently none - Mote handles status changes automatically
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export global for GearSwap (Mote-Include)
_G.job_status_change = job_status_change

-- Export module
local BLM_STATUS = {}
BLM_STATUS.job_status_change = job_status_change

return BLM_STATUS

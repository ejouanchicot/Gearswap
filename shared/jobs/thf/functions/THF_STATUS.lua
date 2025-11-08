---============================================================================
--- THF Status Module - Player Status Change Handling
---============================================================================
--- Handles player status transitions for Thief job.
---
--- Features:
---   • Status change detection (Idle >> Engaged, Engaged >> Idle, etc.)
---   • Dead/Resting state handling
---   • Automatic gear swapping based on new status
---   • Future: THF-specific status logic
---
--- Dependencies:
---   • Mote-Include (provides base status change handling)
---
--- @file    jobs/thf/functions/THF_STATUS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-06
---============================================================================

---============================================================================
--- STATUS HOOKS
---============================================================================

--- Called when player status changes (Idle/Engaged/Dead/etc.)
--- @param newStatus string New status
--- @param oldStatus string Old status
--- @param eventArgs table Event arguments with handled flag
function job_status_change(newStatus, oldStatus, eventArgs)
    -- THF-specific status change logic here
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Make job_status_change available globally for GearSwap
_G.job_status_change = job_status_change

-- Also export as module
local THF_STATUS = {}
THF_STATUS.job_status_change = job_status_change

return THF_STATUS

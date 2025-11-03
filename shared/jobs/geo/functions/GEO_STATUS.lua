---============================================================================
--- GEO Status Module - Status Change Handling
---============================================================================
--- Handles player status changes for Geomancer job (Idle/Engaged/Resting/Dead).
--- Triggers appropriate gear swaps when status changes.
---
--- @file GEO_STATUS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-09
---============================================================================

---============================================================================
--- STATUS HOOKS
---============================================================================

function job_status_change(newStatus, oldStatus, eventArgs)
    -- GEO-SPECIFIC STATUS CHANGE LOGIC
    -- Currently none - Mote handles status changes automatically
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export global for GearSwap (Mote-Include)
_G.job_status_change = job_status_change

-- Export module
local GEO_STATUS = {}
GEO_STATUS.job_status_change = job_status_change

return GEO_STATUS

---============================================================================
--- DRK Status Module - Status Change Handling
---============================================================================
--- Handles player status changes for Dark Knight job:
---   • Player status transitions (Idle/Engaged/Resting/Dead)
---   • Combat state detection
---   • Status-based equipment swaps
---
--- @file    DRK_STATUS.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-10-23
--- @requires Tetsouo architecture
---============================================================================

---============================================================================
--- STATUS CHANGE HOOK
---============================================================================
--- Called when player status changes
--- Mote-Include automatically handles idle/engaged/resting gear swaps.
--- DRK currently doesn't need custom status change logic.
---
--- @param newStatus string New status ("Idle", "Engaged", "Resting", "Dead")
--- @param oldStatus string Previous status
--- @param eventArgs table Event arguments with handled flag
--- @return void
function job_status_change(newStatus, oldStatus, eventArgs)
    -- DRK-specific status change logic here
    -- Examples:
    --   • Cancel buffs on death
    --   • Auto-rebuff on resurrection
    --   • Status-specific gear adjustments

    -- Currently: Mote handles all status transitions
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.job_status_change = job_status_change

-- Export as module (for future require() usage)
return {
    job_status_change = job_status_change
}

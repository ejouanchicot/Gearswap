---============================================================================
--- WHM Status Module - Status Change Handling
---============================================================================
--- Handles player status changes for White Mage:
---   • Idle → Engaged transitions
---   • Engaged → Idle transitions
---   • Dead → Alive transitions (reraise detection)
---   • Resting state management
---
--- @file WHM_STATUS.lua
--- @author Tetsouo
--- @version 1.0.0
--- @date Created: 2025-10-21
---============================================================================

---============================================================================
--- STATUS CHANGE HOOK
---============================================================================

--- Called when player status changes (Idle, Engaged, Dead, Resting, etc.)
---
--- @param newStatus string New status ('Idle', 'Engaged', 'Dead', 'Resting', etc.)
--- @param oldStatus string Previous status
--- @param eventArgs table Event arguments
--- @return void
function job_status_change(newStatus, oldStatus, eventArgs)
    -- WHM-specific status change handling

    -- Examples:
    --   • Re-equip idle gear when coming out of combat
    --   • Apply special gear when entering rest mode
    --   • Handle weapon locks for offense mode transitions
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.job_status_change = job_status_change

-- Export as module
return {
    job_status_change = job_status_change
}

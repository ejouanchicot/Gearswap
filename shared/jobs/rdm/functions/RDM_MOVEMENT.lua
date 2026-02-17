---  ═══════════════════════════════════════════════════════════════════════════
---   RDM Movement Module - Movement Detection & Speed Gear
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles movement detection and automatic speed gear application.
---   Integrates with AutoMove system for universal movement handling.
---
---   @file    shared/jobs/rdm/functions/RDM_MOVEMENT.lua
---   @author  Tetsouo
---   @version 1.0.0
---   @date    Created: 2026-02-16
---   @requires shared/utils/movement/automove.lua
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   AUTOMOVE INTEGRATION (PERFORMANCE OPTIMIZED - No Startup Cost)
---  ═══════════════════════════════════════════════════════════════════════════
-- AutoMove (if available) automatically handles:
--   • Movement detection
--   • Speed gear swapping (sets.MoveSpeed from rdm_sets.lua)
--   • Idle gear restoration when stopped
--
-- No explicit registration needed - AutoMove auto-detects job modules.
-- If AutoMove is not loaded, movement speed gear is simply not available.

---  ═══════════════════════════════════════════════════════════════════════════
---   EQUIPPING GEAR HANDLER
---  ═══════════════════════════════════════════════════════════════════════════

--- Called when gear is being equipped (movement speed check)
--- AutoMove handles movement detection automatically, but this hook
--- allows for job-specific overrides if needed.
---
--- @param playerStatus string Player status ('Idle', 'Engaged', etc.)
--- @param eventArgs table Event arguments
--- @return void
function job_handle_equipping_gear(playerStatus, eventArgs)
    -- AutoMove handles movement speed automatically
    -- This function is here for RDM-specific movement logic if needed
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export globally for GearSwap
_G.job_handle_equipping_gear = job_handle_equipping_gear

-- Export as module
return {
    job_handle_equipping_gear = job_handle_equipping_gear
}

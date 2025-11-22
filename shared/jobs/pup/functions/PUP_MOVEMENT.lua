---============================================================================
--- PUP Movement Module - Movement Gear Handling
---============================================================================
--- Handles movement speed gear for Beastmaster.
--- Registers with AutoMove for automatic movement detection.
---
--- @file jobs/pup/functions/PUP_MOVEMENT.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-17
---============================================================================

---============================================================================
--- AUTOMOVE INTEGRATION (PERFORMANCE OPTIMIZED - No Startup Cost)
---============================================================================
-- AutoMove (if available) automatically handles:
--   • Movement detection
--   • Speed gear swapping (sets.MoveSpeed from pup_sets.lua)
--   • Idle gear restoration when stopped
--
-- No explicit registration needed - AutoMove auto-detects job modules.
-- Movement gear applied in SetBuilder.build_idle_set().
--
-- PERFORMANCE NOTE: Previous version loaded MessageFormatter at startup and
-- showed a warning (~46ms cost). This version does nothing at startup (0ms cost).
-- AutoMove will work if present, otherwise no-op.

---============================================================================
--- MOVEMENT GEAR HOOK
---============================================================================

--- Called when equipping gear (before actual equip)
--- Not needed for PUP - SetBuilder handles movement gear in build_idle_set()
---
--- @param playerStatus string Player status ("Idle", "Engaged", etc.)
--- @param eventArgs table Event arguments (not used)
--- @return void
function job_handle_equipping_gear(playerStatus, eventArgs)
    -- Movement gear handled by SetBuilder.build_idle_set()
    -- No additional logic required
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.job_handle_equipping_gear = job_handle_equipping_gear

-- Export as module
return {
    job_handle_equipping_gear = job_handle_equipping_gear
}

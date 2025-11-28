---============================================================================
--- WHM Movement Module - Movement Detection & Speed Gear
---============================================================================
--- Handles movement detection and automatic speed gear application.
--- Integrates with AutoMove system for universal movement handling.
---
--- @file WHM_MOVEMENT.lua
--- @author Tetsouo
--- @version 1.0.0
--- @date Created: 2025-10-21
--- @requires shared/utils/movement/automove.lua
---============================================================================

---============================================================================
--- AUTOMOVE INTEGRATION (PERFORMANCE OPTIMIZED - No Startup Cost)
---============================================================================
-- AutoMove (if available) automatically handles:
--   • Movement detection
--   • Speed gear swapping (sets.MoveSpeed from whm_sets.lua)
--   • Idle gear restoration when stopped
--
-- No explicit registration needed - AutoMove auto-detects job modules.
-- If AutoMove is not loaded, movement speed gear is simply not available.
--
-- PERFORMANCE NOTE: Previous version checked AutoMove availability at startup
-- and showed a warning (~46ms cost from MessageFormatter). This version does
-- nothing at startup (0ms cost). AutoMove will work if present, otherwise no-op.

---============================================================================
--- EQUIPPING GEAR HANDLER
---============================================================================

--- Called when gear is being equipped (movement speed check)
--- AutoMove handles movement detection automatically, but this hook
--- allows for job-specific overrides if needed.
---
--- @param playerStatus string Player status ('Idle', 'Engaged', etc.)
--- @param eventArgs table Event arguments
--- @return void
function job_handle_equipping_gear(playerStatus, eventArgs)
    -- AutoMove handles movement speed automatically
    -- This function is here for WHM-specific movement logic if needed

    -- Optional: Timara WHM pattern (manual movement handling)
    -- if state.Moving and state.Moving.value == 'true' then
    --     send_command('gs equip sets.MoveSpeed')
    -- end
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

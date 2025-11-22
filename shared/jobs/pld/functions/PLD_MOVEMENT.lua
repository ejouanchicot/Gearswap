---============================================================================
--- PLD Movement Management Module - Movement Detection & Speed Gear
---============================================================================
--- Handles movement detection and automatic movement speed gear application:
---   • AutoMove utility integration
---   • Movement callback registration
---   • Automatic speed gear swapping
---
--- Uses centralized AutoMove for position tracking (performance optimization).
---
--- @file    jobs/pld/functions/PLD_MOVEMENT.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-10-03
--- @requires utils/movement/automove.lua
---============================================================================
---============================================================================
--- AUTOMOVE INTEGRATION (PERFORMANCE OPTIMIZED - No Startup Cost)
---============================================================================
-- AutoMove (if available) automatically handles:
--   • Movement detection
--   • Speed gear swapping (sets.MoveSpeed from pld_sets.lua)
--   • Idle gear restoration when stopped
--
-- No explicit registration needed - AutoMove auto-detects job modules.
-- If AutoMove is not loaded, movement speed gear is simply not available.
--
-- PERFORMANCE NOTE: Previous version checked AutoMove availability at startup
-- and showed a warning (46ms cost from MessageFormatter). This version does
-- nothing at startup (0ms cost). AutoMove will work if present, otherwise no-op.

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export as module (for future require() usage)
return {
    -- Module loaded, AutoMove (if present) handles everything automatically
}

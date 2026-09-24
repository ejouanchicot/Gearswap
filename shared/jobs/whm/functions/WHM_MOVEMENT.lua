---  ═══════════════════════════════════════════════════════════════════════════
---   WHM Movement Module - Movement Detection & Speed Gear
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles movement detection and automatic speed gear application.
---   Integrates with AutoMove system for universal movement handling.
---
---   @file    shared/jobs/whm/functions/WHM_MOVEMENT.lua
---   @author  Tetsouo
---   @version 1.0.0
---   @date    Created: 2025-10-21
---   @requires shared/utils/movement/automove.lua
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   AUTOMOVE INTEGRATION (PERFORMANCE OPTIMIZED - No Startup Cost)
---  ═══════════════════════════════════════════════════════════════════════════
-- AutoMove sets state.Moving and triggers a gear update; logic/set_builder.lua
-- lays sets.MoveSpeed over the idle set. If AutoMove is not loaded, movement
-- speed gear is simply not available.

---  ═══════════════════════════════════════════════════════════════════════════
---   EQUIPPING GEAR HANDLER
---  ═══════════════════════════════════════════════════════════════════════════

---   Mote hook called before gear is equipped. Empty on WHM.
---
---   @param playerStatus string Player status ('Idle', 'Engaged', etc.)
---   @param eventArgs table Event arguments
---   @return void
function job_handle_equipping_gear(playerStatus, eventArgs)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export globally for GearSwap
_G.job_handle_equipping_gear = job_handle_equipping_gear


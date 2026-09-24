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
-- AutoMove is started for every job by INIT_SYSTEMS and handles:
--   • Movement detection
--   • Speed gear swapping (sets.MoveSpeed from rdm_sets.lua)
--   • Idle gear restoration when stopped
--
-- If AutoMove is not loaded, movement speed gear is simply not available.

---  ═══════════════════════════════════════════════════════════════════════════
---   EQUIPPING GEAR HANDLER
---  ═══════════════════════════════════════════════════════════════════════════

---   Mote hook called before gear is equipped. Empty on purpose: AutoMove
---   handles movement speed; add RDM-specific overrides here if needed.
---
---   @param playerStatus string Player status ('Idle', 'Engaged', etc.)
---   @param eventArgs table Event arguments
function job_handle_equipping_gear(playerStatus, eventArgs)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export globally for GearSwap
_G.job_handle_equipping_gear = job_handle_equipping_gear


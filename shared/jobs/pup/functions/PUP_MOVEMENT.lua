---  ═══════════════════════════════════════════════════════════════════════════
---   PUP Movement Module - Movement Gear Handling
---  ═══════════════════════════════════════════════════════════════════════════
---   Movement hook for Puppetmaster. AutoMove (started for every job by
---   INIT_SYSTEMS) handles movement detection and speed gear.
---
---   @file    shared/jobs/pup/functions/PUP_MOVEMENT.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-17
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   AUTOMOVE INTEGRATION (PERFORMANCE OPTIMIZED - No Startup Cost)
---  ═══════════════════════════════════════════════════════════════════════════
-- AutoMove (if loaded) handles:
--   • Movement detection
--   • Speed gear swapping (sets.MoveSpeed from pup_sets.lua)
--   • Idle gear restoration when stopped

---  ═══════════════════════════════════════════════════════════════════════════
---   MOVEMENT GEAR HOOK
---  ═══════════════════════════════════════════════════════════════════════════

---   Mote hook called before gear is equipped. Empty on purpose: movement
---   gear is handled by AutoMove.
---
---   @param playerStatus string Player status ("Idle", "Engaged", etc.)
---   @param eventArgs table Event arguments (not used)
function job_handle_equipping_gear(playerStatus, eventArgs)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export globally for GearSwap
_G.job_handle_equipping_gear = job_handle_equipping_gear


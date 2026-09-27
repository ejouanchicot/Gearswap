---  ═══════════════════════════════════════════════════════════════════════════
---   SAM Movement Module - Movement Handling
---  ═══════════════════════════════════════════════════════════════════════════
---   Movement hook for Samurai (empty). AutoMove tracks movement for every
---   job (INIT_SYSTEMS); SAM's set builder applies no movement gear.
---
---   @file    shared/jobs/sam/functions/SAM_MOVEMENT.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2025-10-21
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   GEAR HOOK
---  ═══════════════════════════════════════════════════════════════════════════

---   Mote hook called before gear is equipped. Empty on SAM.
---   @param playerStatus string Current player status
---   @param eventArgs table Event arguments
function job_handle_equipping_gear(playerStatus, eventArgs)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_handle_equipping_gear = job_handle_equipping_gear


---  ═══════════════════════════════════════════════════════════════════════════
---   COR Movement Module - Movement Tracking & Speed Gear
---  ═══════════════════════════════════════════════════════════════════════════
---   Movement hooks for Corsair. AutoMove tracks movement; the speed gear is
---   added by SetBuilder.build_idle_set (apply_movement).
---
---   @file    shared/jobs/cor/functions/COR_MOVEMENT.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2025-10-07
---   @requires shared/utils/movement/automove.lua
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   MOVEMENT HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

---   Gear update (AutoMove, status change, gs c update): held while a
---   Phantom Roll or Double-Up is under way, so the roll set stays on until
---   the roll lands (roll_hold.lua)
---   @param playerStatus string Current player status
---   @param eventArgs table Event arguments
---   @return void
function job_handle_equipping_gear(playerStatus, eventArgs)
    require('shared/jobs/cor/functions/logic/roll_hold').hold_update(eventArgs)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export global for GearSwap (Mote-Include)
_G.job_handle_equipping_gear = job_handle_equipping_gear


---  ═══════════════════════════════════════════════════════════════════════════
---   SAM Movement Module - Movement Handling
---  ═══════════════════════════════════════════════════════════════════════════
---   Movement status API over the centralized AutoMove (moving flag,
---   last distance, position). SAM's set builder applies no movement gear.
---
---   @file    shared/jobs/sam/functions/SAM_MOVEMENT.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-21
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   MOVEMENT STATUS API
---  ═══════════════════════════════════════════════════════════════════════════

---   Get current movement status (delegates to AutoMove)
---   @return table movement_info
function get_sam_movement_status()
    if not AutoMove then
        return {
            is_moving = false,
            distance = 0,
            position = { x = 0, y = 0, z = 0 }
        }
    end

    return {
        is_moving = AutoMove.is_moving(),
        distance = AutoMove.get_last_distance(),
        position = AutoMove.get_position()
    }
end

---   Mote hook called before gear is equipped. Empty on SAM.
---   @param playerStatus string Current player status
---   @param eventArgs table Event arguments
function job_handle_equipping_gear(playerStatus, eventArgs)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.get_sam_movement_status = get_sam_movement_status
_G.job_handle_equipping_gear = job_handle_equipping_gear


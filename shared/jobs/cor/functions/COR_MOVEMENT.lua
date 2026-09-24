---  ═══════════════════════════════════════════════════════════════════════════
---   COR Movement Module - Movement Tracking & Speed Gear
---  ═══════════════════════════════════════════════════════════════════════════
---   Movement hooks for Corsair. AutoMove tracks movement; the speed gear is
---   added by SetBuilder.build_idle_set (apply_movement).
---
---   @file    shared/jobs/cor/functions/COR_MOVEMENT.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-07
---   @requires shared/utils/movement/automove.lua
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   MOVEMENT STATUS API
---  ═══════════════════════════════════════════════════════════════════════════

---   Get current movement status (delegates to AutoMove)
---   @return table { is_moving, distance, position }
function get_cor_movement_status()
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

---  ═══════════════════════════════════════════════════════════════════════════
---   MOVEMENT HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

---   Handle gear equipping during movement (empty: nothing COR-specific)
---   @param playerStatus string Current player status
---   @param eventArgs table Event arguments
---   @return void
function job_handle_equipping_gear(playerStatus, eventArgs)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export global for GearSwap (Mote-Include)
_G.job_handle_equipping_gear = job_handle_equipping_gear


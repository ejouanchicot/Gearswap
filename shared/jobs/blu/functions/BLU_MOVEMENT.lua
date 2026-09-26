---  ═══════════════════════════════════════════════════════════════════════════
---   BLU Movement Module - Movement Status API
---  ═══════════════════════════════════════════════════════════════════════════
---   AutoMove (started for every job by INIT_SYSTEMS) tracks movement; the
---   speed gear itself (sets.MoveSpeed) is laid by logic/set_builder.lua,
---   idle only. This module exposes the movement status.
---
---   @file    shared/jobs/blu/functions/BLU_MOVEMENT.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-09-26
---   @requires shared/utils/movement/automove.lua
---  ═══════════════════════════════════════════════════════════════════════════

--- Current movement status (delegates to AutoMove)
--- @return table {is_moving, distance, position}
function get_blu_movement_status()
    if not AutoMove then
        return { is_moving = false, distance = 0, position = { x = 0, y = 0, z = 0 } }
    end
    return {
        is_moving = AutoMove.is_moving(),
        distance = AutoMove.get_last_distance(),
        position = AutoMove.get_position()
    }
end

_G.get_blu_movement_status = get_blu_movement_status

return { get_blu_movement_status = get_blu_movement_status }

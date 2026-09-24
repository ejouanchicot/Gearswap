---  ═══════════════════════════════════════════════════════════════════════════
---   DNC Movement Management Module
---  ═══════════════════════════════════════════════════════════════════════════
---   Movement status accessor for Dancer, delegating to the global AutoMove.
---   Movement speed gear itself is applied by AutoMove and the set builder;
---   nothing in the project calls get_dnc_movement_status today.
---
---   @file    shared/jobs/dnc/functions/DNC_MOVEMENT.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-04
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   MOVEMENT STATUS API
---  ═══════════════════════════════════════════════════════════════════════════

---   Get current movement status (delegates to AutoMove)
---   @return table { is_moving = boolean, distance = number, position = {x, y, z} }
function get_dnc_movement_status()
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
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.get_dnc_movement_status = get_dnc_movement_status

---  ═══════════════════════════════════════════════════════════════════════════
---   GEO Movement Management Module
---  ═══════════════════════════════════════════════════════════════════════════
---   Exposes the AutoMove movement status for Geomancer. Movement gear itself
---   is applied by the shared AutoMove system and the GEO set builder.
---
---   @file    shared/jobs/geo/functions/GEO_MOVEMENT.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-09
---   @requires shared/utils/movement/automove.lua
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   MOVEMENT STATUS API
---  ═══════════════════════════════════════════════════════════════════════════

---   Get current movement status (delegates to AutoMove)
---   @return table { is_moving = boolean, distance = number, position = {x, y, z} }
function get_geo_movement_status()
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

_G.get_geo_movement_status = get_geo_movement_status

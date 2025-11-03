---============================================================================
--- GEO Movement Management Module
---============================================================================
--- Handles movement-based gear management for Geomancer.
--- Uses centralized AutoMove position tracking for performance.
---
--- @file jobs/geo/functions/GEO_MOVEMENT.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-09
--- @requires utils/movement/automove.lua
---============================================================================

---============================================================================
--- MOVEMENT STATUS API
---============================================================================

--- Get current movement status (delegates to AutoMove)
--- @return table movement_info
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

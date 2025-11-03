---============================================================================
--- THF Movement Management Module - Movement Detection & Speed Gear
---============================================================================
--- Handles movement-based equipment optimization for Thief using centralized
--- AutoMove position tracking for performance.
---
--- Features:
---   • AutoMove integration (centralized movement tracking)
---   • Movement speed gear application (via SetBuilder)
---   • Position tracking (x/y/z coordinates)
---   • Distance calculation (movement detection)
---   • Future: Hide auto-cancel on extended movement
---   • Future: TH optimization based on movement patterns
---
--- Dependencies:
---   • AutoMove (centralized movement tracking system)
---   • SetBuilder (applies MoveSpeed sets)
---
--- @file    jobs/thf/functions/THF_MOVEMENT.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-06
---============================================================================

---============================================================================
--- AUTOMOVE REGISTRATION
---============================================================================

--- Register callback with AutoMove for THF-specific movement logic
if AutoMove then
    AutoMove.register_callback(function(is_moving, distance, player_status)
        -- Future: THF-specific movement logic
        -- - Hide cancellation on extended movement
        -- - Treasure Hunter optimization based on movement
    end)
end

---============================================================================
--- MOVEMENT STATUS API
---============================================================================

--- Get current movement status (delegates to AutoMove)
--- @return table movement_info
function get_thf_movement_status()
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

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Make functions available globally
_G.get_thf_movement_status = get_thf_movement_status

-- Also export as module
local THF_MOVEMENT = {}
THF_MOVEMENT.get_thf_movement_status = get_thf_movement_status

return THF_MOVEMENT

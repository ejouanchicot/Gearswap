---============================================================================
--- SAM Movement Module - Movement Handling
---============================================================================
--- Handles movement-based gear management for Samurai with AutoMove integration.
---
--- Features:
---   • Movement status API (delegates to centralized AutoMove)
---   • Distance tracking (determines movement speed gear triggers)
---   • Position tracking (X/Y/Z coordinates)
---
--- @file SAM_MOVEMENT.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-21
---============================================================================

---============================================================================
--- MOVEMENT STATUS API
---============================================================================

--- Get current movement status (delegates to AutoMove)
--- @return table movement_info
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

function job_handle_equipping_gear(playerStatus, eventArgs)
    -- Movement gear handling if needed
end

---============================================================================
--- MODULE EXPORT
---============================================================================

_G.get_sam_movement_status = get_sam_movement_status
_G.job_handle_equipping_gear = job_handle_equipping_gear

local SAM_MOVEMENT = {}
SAM_MOVEMENT.get_sam_movement_status = get_sam_movement_status
SAM_MOVEMENT.job_handle_equipping_gear = job_handle_equipping_gear

return SAM_MOVEMENT

---============================================================================
--- BLM Movement Management Module
---============================================================================
--- Handles movement-based gear management for Black Mage.
--- Uses centralized AutoMove position tracking for performance.
---
--- @file jobs/blm/functions/BLM_MOVEMENT.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-15
--- @requires utils/movement/automove.lua
---============================================================================

---============================================================================
--- MOVEMENT STATUS API
---============================================================================

--- Get current movement status (delegates to AutoMove)
--- @return table movement_info
function get_blm_movement_status()
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

--- Handle equipping gear during movement
--- @param playerStatus string Current player status
--- @param eventArgs table Event arguments
function job_handle_equipping_gear(playerStatus, eventArgs)
    -- AutoMove handles speed gear automatically
    -- This function can be used for additional BLM-specific gear logic
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export to global scope for GearSwap
_G.job_handle_equipping_gear = job_handle_equipping_gear

-- Export module
local BLM_MOVEMENT = {}
BLM_MOVEMENT.job_handle_equipping_gear = job_handle_equipping_gear
BLM_MOVEMENT.get_blm_movement_status = get_blm_movement_status

return BLM_MOVEMENT

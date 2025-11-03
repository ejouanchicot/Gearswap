---============================================================================
--- COR Movement Module - Movement Tracking & Speed Gear
---============================================================================
--- Handles movement detection and automatic speed gear equipping for Corsair.
--- Integrates with AutoMove system for consistent movement gear management.
---
--- @file COR_MOVEMENT.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-07
--- @requires utils/movement/automove.lua
---============================================================================

---============================================================================
--- MOVEMENT STATUS API
---============================================================================

--- Get current movement status (delegates to AutoMove)
--- @return table movement_info
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

---============================================================================
--- MOVEMENT HOOKS
---============================================================================

--- Handle gear equipping during movement
--- @param playerStatus string Current player status
--- @param eventArgs table Event arguments
--- @return void
function job_handle_equipping_gear(playerStatus, eventArgs)
    -- COR-specific movement gear handling
    -- AutoMove system handles most movement gear automatically
    -- This is for job-specific movement gear logic if needed
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export global for GearSwap (Mote-Include)
_G.job_handle_equipping_gear = job_handle_equipping_gear

-- Export module
local COR_MOVEMENT = {}
COR_MOVEMENT.job_handle_equipping_gear = job_handle_equipping_gear

return COR_MOVEMENT

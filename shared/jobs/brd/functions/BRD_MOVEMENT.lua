---============================================================================
--- BRD Movement Management Module
---============================================================================
--- Handles movement-based gear management for Bard.
--- Uses centralized AutoMove position tracking for performance.
---
--- @file jobs/brd/functions/BRD_MOVEMENT.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-13
--- @requires utils/movement/automove.lua
---============================================================================

---============================================================================
--- MOVEMENT STATUS API
---============================================================================

--- Get current movement status (delegates to AutoMove)
--- @return table movement_info
function get_brd_movement_status()
    if not AutoMove then
        return {
            is_moving = false,
            distance = 0,
            position = {x = 0, y = 0, z = 0}
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
    -- CRITICAL: Protect instrument lock - maintain locked instrument throughout cast
    if _G.casting_locked_song and _G.locked_instrument then
        -- Force locked instrument to stay equipped during song cast
        equip({range = _G.locked_instrument})
        return
    end

    -- AutoMove handles speed gear automatically
    -- This function can be used for additional BRD-specific gear logic
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- DO NOT EXPORT job_handle_equipping_gear to _G - it interferes with warp ring fix
-- The function exists for module use but should NOT be registered as GearSwap hook
-- _G.job_handle_equipping_gear = job_handle_equipping_gear

-- Export module (for internal use only, not as GearSwap hook)
local BRD_MOVEMENT = {}
BRD_MOVEMENT.job_handle_equipping_gear = job_handle_equipping_gear
BRD_MOVEMENT.get_brd_movement_status = get_brd_movement_status

return BRD_MOVEMENT

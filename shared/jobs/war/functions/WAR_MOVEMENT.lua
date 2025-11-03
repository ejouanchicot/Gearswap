---============================================================================
--- WAR Movement Management Module - Movement Tracking & Buff Cancellation
---============================================================================
--- Handles movement-based buff cancellation for Warrior:
---   • Retaliation auto-cancel after 5s continuous movement
---   • Movement status API for external queries
---
--- Uses centralized AutoMove for position tracking (performance optimization).
---
--- @file    jobs/war/functions/WAR_MOVEMENT.lua
--- @author  Tetsouo
--- @version 3.0.0
--- @date    Created: 2025-09-29
--- @requires utils/movement/automove.lua
---============================================================================
---============================================================================
--- RETALIATION AUTO-CANCEL SYSTEM
---============================================================================
-- Configuration
local retaliation_config = {
    move_duration_needed = 5, -- Seconds of continuous movement to cancel
    time_moving = 0 -- Accumulated movement time
}

-- Register callback with AutoMove for automatic Retaliation cancellation
if AutoMove then
    AutoMove.register_callback(function(is_moving, distance, player_status)
        -- Get fresh buff data (buffactive may be stale during movement)
        local player_data = windower.ffxi.get_player()
        local has_retaliation = false

        -- Check for Retaliation buff (ID: 405)
        if player_data and player_data.buffs then
            for _, buff_id in ipairs(player_data.buffs) do
                if buff_id == 405 then
                    has_retaliation = true
                    break
                end
            end
        end

        -- Track movement time only when: NOT engaged + Retaliation active + moving
        if player_status ~= 'Engaged' and has_retaliation and is_moving then
            retaliation_config.time_moving = retaliation_config.time_moving + 0.5

            -- Cancel after 5 seconds of continuous movement
            if retaliation_config.time_moving >= retaliation_config.move_duration_needed then
                send_command('cancel Retaliation')
                retaliation_config.time_moving = 0
            end
        else
            -- Reset counter (stopped, engaged, or no Retaliation)
            retaliation_config.time_moving = 0
        end
    end)
end

---============================================================================
--- MOVEMENT STATUS API
---============================================================================

--- Get current movement status
--- Delegates to AutoMove for centralized movement tracking.
---
--- @return table Movement info with fields:
---   • is_moving (boolean): True if player is moving
---   • distance  (number):  Distance traveled in last tick
---   • position  (table):   Current position {x, y, z}
function get_war_movement_status()
    if not AutoMove then
        return {
            is_moving = false,
            distance = 0,
            position = {
                x = 0,
                y = 0,
                z = 0
            }
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

-- Export globally for GearSwap
_G.get_war_movement_status = get_war_movement_status

-- Export as module (for future require() usage)
return {
    get_war_movement_status = get_war_movement_status
}

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

-- Lazy-loaded dependencies
local MessageFormatter = nil

---============================================================================
--- RETALIATION AUTO-CANCEL SYSTEM
---============================================================================

-- Configuration
local retaliation_config = {
    move_duration_needed = 5,     -- Seconds of continuous movement to cancel
    movement_start_time = nil,    -- Time when continuous movement started
    debug_mode = false            -- Toggle with //gs c debugretaliation
}

-- Debug helper
local function debug_print(msg)
    if retaliation_config.debug_mode then
        if not MessageFormatter then
            MessageFormatter = require('shared/utils/messages/message_formatter')
        end
        MessageFormatter.show_debug('WAR_MOVEMENT', msg)
    end
end

-- DEFERRED REGISTRATION: Wait for AutoMove to load (it loads with 0.5s delay in INIT_SYSTEMS)
-- We wait 0.6s (AutoMove at 0.5s + 100ms margin) for faster callback registration
coroutine.schedule(function()
    if not AutoMove then
        -- Silent failure - AutoMove is optional
        return
    end

    -- AutoMove is available - register Retaliation callback (silent init)
    AutoMove.register_callback(function(is_moving, distance, player_status)

        -- Check for Retaliation buff using both methods (for compatibility)
        local has_retaliation = false
        local detection_method = nil

        -- Method 1: Use buffactive (faster, but may be stale)
        if buffactive and buffactive['Retaliation'] then
            has_retaliation = true
            detection_method = 'buffactive'
        end

        -- Method 2: Get fresh buff data from player (more reliable during movement)
        if not has_retaliation then
            local player_data = windower.ffxi.get_player()
            if player_data and player_data.buffs then
                for _, buff_id in ipairs(player_data.buffs) do
                    if buff_id == 405 then  -- Retaliation buff ID
                        has_retaliation = true
                        detection_method = 'player.buffs[405]'
                        break
                    end
                end
            end
        end

        -- Get current time
        local current_time = os.clock()

        -- CONDITION CHECK: Track movement time only when ALL conditions are met
        local should_track = (player_status ~= 'Engaged' and has_retaliation and is_moving)

        -- Debug: Show detailed conditions
        if retaliation_config.debug_mode then
            debug_print(string.format('engaged=%s, has_retal=%s (%s), moving=%s -> TRACK=%s',
                tostring(player_status == 'Engaged'),
                tostring(has_retaliation),
                detection_method or 'none',
                tostring(is_moving),
                tostring(should_track)))
        end

        if should_track then
            -- START tracking if not already started
            if not retaliation_config.movement_start_time then
                retaliation_config.movement_start_time = current_time
                debug_print('Started tracking movement')
            end

            -- Calculate elapsed time since movement started
            local elapsed_time = current_time - retaliation_config.movement_start_time

            debug_print('Tracking: ' .. string.format('%.1f', elapsed_time) .. '/' .. retaliation_config.move_duration_needed .. 's')

            -- Cancel after 5 seconds of continuous movement
            if elapsed_time >= retaliation_config.move_duration_needed then
                send_command('cancel Retaliation')
                retaliation_config.movement_start_time = nil
            end
        else
            -- RESET tracking (stopped, engaged, or no Retaliation)
            if retaliation_config.movement_start_time and retaliation_config.debug_mode then
                local elapsed = current_time - retaliation_config.movement_start_time
                debug_print(string.format('Reset after %.1fs (engaged=%s, no_buff=%s, stopped=%s)',
                    elapsed,
                    tostring(player_status == 'Engaged'),
                    tostring(not has_retaliation),
                    tostring(not is_moving)))
            end
            retaliation_config.movement_start_time = nil
        end
    end)
end, 0.6)  -- Wait 0.6s for AutoMove to load (it loads at 0.5s in INIT_SYSTEMS)

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

--- Toggle Retaliation debug mode
--- @return boolean New debug mode state
function toggle_retaliation_debug()
    retaliation_config.debug_mode = not retaliation_config.debug_mode
    local status = retaliation_config.debug_mode and 'ENABLED' or 'DISABLED'
    if not MessageFormatter then
        MessageFormatter = require('shared/utils/messages/message_formatter')
    end
    MessageFormatter.show_info('WAR', 'Retaliation debug mode: ' .. status)
    return retaliation_config.debug_mode
end

--- Get Retaliation tracking status (for debugging)
--- @return table Status info
function get_retaliation_status()
    local elapsed = 0
    if retaliation_config.movement_start_time then
        elapsed = os.clock() - retaliation_config.movement_start_time
    end

    return {
        debug_mode = retaliation_config.debug_mode,
        tracking = retaliation_config.movement_start_time ~= nil,
        elapsed_time = elapsed,
        move_duration_needed = retaliation_config.move_duration_needed
    }
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.get_war_movement_status = get_war_movement_status
_G.toggle_retaliation_debug = toggle_retaliation_debug
_G.get_retaliation_status = get_retaliation_status

-- Export as module (for future require() usage)
return {
    get_war_movement_status = get_war_movement_status,
    toggle_retaliation_debug = toggle_retaliation_debug,
    get_retaliation_status = get_retaliation_status
}

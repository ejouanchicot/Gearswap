---============================================================================
--- Auto Movement Speed Gear Module
---============================================================================
--- Automatically detects player movement and equips movement speed gear.
--- Provides centralized position tracking for all movement-based systems.
---
--- @file utils/movement/automove.lua
--- @author Tetsouo
--- @version 2.0.0
--- @date Created: 2025-09-30
---
--- Features:
---   - Centralized position tracking (shared by all modules)
---   - Automatic movement detection via position tracking
---   - Combat-aware movement gear (idle only, never in combat)
---   - Performance optimized (single prerender event)
---   - Callback system for job-specific movement logic
---
--- Requirements:
---   - Define sets.MoveSpeed in your job file
---
--- @usage
---   include('../shared/utils/movement/automove.lua')
---   sets.MoveSpeed = { legs="Carmine Cuisses +1" }
---   AutoMove.register_callback(function(is_moving, distance) ... end)
---============================================================================

local MessageCore = require('shared/utils/messages/message_core')

-- Global AutoMove API
AutoMove = AutoMove or {}

---============================================================================
--- CONFIGURATION
---============================================================================

local config = {
    movement_threshold = 0.3,      -- Distance threshold to detect movement
    check_interval = 0.08          -- Time in seconds between position checks (FPS-independent)
}

---============================================================================
--- CALLBACK SYSTEM
---============================================================================

local callbacks = {}

--- Register a callback for movement events
--- @param callback function Function(is_moving, distance, player_status)
function AutoMove.register_callback(callback)
    table.insert(callbacks, callback)
end

--- Call all registered callbacks
local function trigger_callbacks(is_moving, distance, player_status)
    for _, callback in ipairs(callbacks) do
        local success, err = pcall(callback, is_moving, distance, player_status)
        if not success then
            MessageCore.show_automove_error(err)
        end
    end
end

---============================================================================
--- STATE INITIALIZATION
---============================================================================

-- Create movement state if it doesn't exist
if not state.Moving then
    state.Moving = M('false', 'true')
end

---============================================================================
--- MOVEMENT TRACKING
---============================================================================

-- Movement tracking variables
local mov = {
    last_check_time = os.clock(),  -- Track time instead of frames
    x = 0,
    y = 0,
    z = 0
}

local moving = false

-- Initialize starting position
local function init_position()
    if player and player.index then
        local mob = windower.ffxi.get_mob_by_index(player.index)
        if mob and mob.x and mob.y and mob.z then
            mov.x = mob.x
            mov.y = mob.y
            mov.z = mob.z
            return true
        end
    end
    return false
end

-- Try to initialize position
init_position()

---============================================================================
--- PUBLIC API
---============================================================================

--- Check if player is currently moving
--- @return boolean True if moving
function AutoMove.is_moving()
    return moving
end

--- Get last calculated distance
--- @return number Distance moved since last check
function AutoMove.get_last_distance()
    return mov.last_distance or 0
end

--- Get current position
--- @return table {x, y, z} Current position
function AutoMove.get_position()
    return { x = mov.x, y = mov.y, z = mov.z }
end

---============================================================================
--- MOVEMENT DETECTION
---============================================================================

windower.raw_register_event('prerender', function()
    local current_time = os.clock()

    -- Check at configured time interval (FPS-independent)
    if (current_time - mov.last_check_time) >= config.check_interval then
        mov.last_check_time = current_time

        -- Validate player exists
        if not player or not player.index then
            return
        end

        -- Get current position
        local pl = windower.ffxi.get_mob_by_index(player.index)
        if not pl or not pl.x or not pl.y or not pl.z or not mov.x then
            return
        end

        -- Calculate distance moved
        local dx = pl.x - mov.x
        local dy = pl.y - mov.y
        local dz = pl.z - mov.z
        local dist = math.sqrt(dx * dx + dy * dy + dz * dz)

        -- Store last distance for API
        mov.last_distance = dist

        -- Update position
        mov.x = pl.x
        mov.y = pl.y
        mov.z = pl.z

        -------------------------------------------------------------------
        -- MOVEMENT DETECTED
        -------------------------------------------------------------------
        if dist > config.movement_threshold then
            -- Check if we should equip movement gear
            -- NEVER equip movement gear in combat (Engaged status)
            local should_move = (player.status ~= 'Engaged')

            -- Equip movement gear if conditions met
            if should_move and not moving then
                state.Moving.value = 'true'
                moving = true
                send_command('gs c update')
            end

            -- Always trigger callbacks while moving (for continuous tracking)
            trigger_callbacks(true, dist, player.status)

            -------------------------------------------------------------------
            -- STOPPED
            -------------------------------------------------------------------
        elseif dist < config.movement_threshold then
            if moving then
                state.Moving.value = 'false'
                moving = false
                send_command('gs c update')

                -- Trigger callbacks once when stopping
                trigger_callbacks(false, dist, player.status)
            end
        end
    end
end)

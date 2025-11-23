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

--- Clear all registered callbacks (called during job change cleanup)
function AutoMove.clear_callbacks()
    callbacks = {}
end

--- Stop the movement detection loop (called during job change cleanup)
--- Increments sequence counter to invalidate all running coroutines
function AutoMove.stop()
    _G.AUTOMOVE_RUNNING = false
    -- Increment sequence to invalidate old coroutines (prevents ghost coroutines)
    _G._automove_sequence = (_G._automove_sequence or 0) + 1
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
    x = 0,
    y = 0,
    z = 0,
    last_distance = 0
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

--- Reinitialize position (called after job change to prevent false positives)
--- @return boolean True if position was successfully reinitialized
function AutoMove.reinit_position()
    return init_position()
end

---============================================================================
--- MOVEMENT DETECTION (FPS-INDEPENDENT TIMER)
---============================================================================

--- Check movement status (called on timer, not FPS-dependent)
local function check_movement()
    -- Capture current sequence at function start (prevents race conditions)
    local my_sequence = _G._automove_sequence or 0

    -- Guard: Stop if AutoMove was disabled during job change
    if not _G.AUTOMOVE_RUNNING then
        return
    end

    -- Guard: Stop if this coroutine is from an old sequence (prevents ghost coroutines)
    if my_sequence ~= (_G._automove_sequence or 0) then
        return  -- This coroutine is outdated, don't reschedule
    end

    -- Validate player exists
    if not player or not player.index then
        -- Reschedule check only if still valid sequence
        if my_sequence == (_G._automove_sequence or 0) and _G.AUTOMOVE_RUNNING then
            coroutine.schedule(check_movement, config.check_interval)
        end
        return
    end

    -- Get current position
    local pl = windower.ffxi.get_mob_by_index(player.index)
    if not pl or not pl.x or not pl.y or not pl.z or not mov.x then
        -- Reschedule check only if still valid sequence
        if my_sequence == (_G._automove_sequence or 0) and _G.AUTOMOVE_RUNNING then
            coroutine.schedule(check_movement, config.check_interval)
        end
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

    -- Reschedule next check ONLY if still valid sequence (prevents ghost coroutines)
    if my_sequence == (_G._automove_sequence or 0) and _G.AUTOMOVE_RUNNING then
        coroutine.schedule(check_movement, config.check_interval)
    end
end

---============================================================================
--- START/STOP API
---============================================================================

--- Start the movement detection loop (called after job change)
--- Safe to call multiple times - will only start if not already running
--- MUST be defined AFTER check_movement function
function AutoMove.start()
    if not _G.AUTOMOVE_RUNNING then
        -- Increment sequence to start new generation (invalidates any old coroutines)
        _G._automove_sequence = (_G._automove_sequence or 0) + 1
        _G.AUTOMOVE_RUNNING = true
        coroutine.schedule(check_movement, config.check_interval)
    end
end

---============================================================================
--- INITIALIZATION
---============================================================================

-- Initialize sequence counter (global to survive reloads)
if not _G._automove_sequence then
    _G._automove_sequence = 0
end

-- Start movement detection timer on first load (only if not already running)
AutoMove.start()

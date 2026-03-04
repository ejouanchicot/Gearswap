---============================================================================
--- Auto Movement Speed Gear Module
---============================================================================
--- Automatically detects player movement and equips movement speed gear.
--- Provides centralized position tracking for all movement-based systems.
---
--- @file utils/movement/automove.lua
--- @author Tetsouo
--- @version 2.1.0 - FIX: Ghost coroutine accumulation across gs reload
--- @date Created: 2025-09-30 | Updated: 2026-03-03
---
--- Features:
---   - Centralized position tracking (shared by all modules)
---   - Automatic movement detection via position tracking
---   - Combat-aware movement gear (idle only, never in combat)
---   - Performance optimized (single timer chain per start() call)
---   - Callback system for job-specific movement logic
---
--- FIX v2.1.0: Ghost coroutine accumulation
---   ROOT CAUSE: _G._automove_sequence resets on each gs reload.
---   Old coroutines captured my_sequence at run-time AFTER start() reset seq=1,
---   so the guard (my_sequence ~= _G._automove_sequence) always passed → N chains
---   for N job changes → N×gs_c_update simultaneously.
---   SOLUTION: Sequence captured ONCE via closure at AutoMove.start() time.
---   windower._automove_seq persists across reloads and truly increments.
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
    movement_threshold  = 0.3,   -- Distance threshold to detect movement
    check_interval      = 0.08,  -- Time in seconds between position checks
    update_debounce     = 0.3,   -- Minimum time between gs c update calls
    job_change_cooldown = 2.0    -- Cooldown after job change before sending commands
}

-- Track last update time for debouncing
local last_update_time = 0

-- Track when AutoMove was started (for job change cooldown)
local start_time = 0

-- Track if an update was blocked and needs to be sent later
local pending_update = false

---============================================================================
--- PERSISTENT SEQUENCE COUNTER (survives gs reload)
---============================================================================
-- windower._automove_seq is a C++ object field - never reset by gs reload.
-- Each start() and stop() increments it. Closures capture it once at start()
-- time, so ghost coroutines from previous chains always see a stale my_seq.

windower._automove_seq = windower._automove_seq or 0

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
--- Increments windower sequence to invalidate ALL running closures
function AutoMove.stop()
    _G.AUTOMOVE_RUNNING = false
    windower._automove_seq = windower._automove_seq + 1
    _G._automove_sequence = windower._automove_seq  -- keep _G in sync for debug tools
    if _G.LagDebugger then _G.LagDebugger.on_automove_stop(windower._automove_seq) end
    if _G.AUTOMOVE_DEBUG then
        add_to_chat(207, string.format('[AutoMove] STOP called | seq=%d', windower._automove_seq))
    end
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
--- START API (creates isolated closure chain - one per call)
---============================================================================

--- Start the movement detection loop.
--- Creates a NEW closure chain with a unique sequence ID captured at call time.
--- Old chains from previous start() calls are instantly invalidated when
--- windower._automove_seq increments, regardless of _G state after gs reload.
function AutoMove.start()
    -- Increment BEFORE closure creation → old chains see a stale my_seq
    windower._automove_seq = windower._automove_seq + 1
    local my_seq = windower._automove_seq  -- captured ONCE in closure

    -- Sync _G for debug tools / LagDebugger
    _G._automove_sequence = my_seq
    _G.AUTOMOVE_RUNNING   = true

    -- Reset movement state for clean start
    start_time    = os.clock()
    moving        = false
    pending_update = false
    last_update_time = 0
    init_position()

    if _G.LagDebugger then _G.LagDebugger.on_automove_start(my_seq) end
    if _G.AUTOMOVE_DEBUG then
        add_to_chat(207, string.format('[AutoMove] START | seq=%d', my_seq))
    end

    -------------------------------------------------------------------
    -- CLOSURE: my_seq is fixed for the lifetime of this chain.
    -- Two guards kill this closure immediately when outdated:
    --   1. windower._automove_seq changed  (stop() or new start() called)
    --   2. _G.AUTOMOVE_RUNNING is false    (stop() called in same reload)
    -------------------------------------------------------------------
    local function run()
        -- Guard 1: windower seq changed → this chain is a ghost, die
        if my_seq ~= windower._automove_seq then return end
        -- Guard 2: explicitly stopped
        if not _G.AUTOMOVE_RUNNING then return end

        -- Player not ready: reschedule and wait
        if not player or not player.index then
            coroutine.schedule(run, config.check_interval)
            return
        end

        -- Get current position
        local pl = windower.ffxi.get_mob_by_index(player.index)
        if not pl or not pl.x or not pl.y or not pl.z or mov.x == nil then
            coroutine.schedule(run, config.check_interval)
            return
        end

        -- Calculate distance moved
        local dx = pl.x - mov.x
        local dy = pl.y - mov.y
        local dz = pl.z - mov.z
        local dist = math.sqrt(dx * dx + dy * dy + dz * dz)

        mov.last_distance = dist
        mov.x = pl.x
        mov.y = pl.y
        mov.z = pl.z

        -------------------------------------------------------------------
        -- MOVEMENT DETECTED
        -------------------------------------------------------------------
        if dist > config.movement_threshold then
            local should_move = (player.status ~= 'Engaged')

            if should_move and not moving then
                state.Moving.value = 'true'
                moving = true
                pending_update = true
            end

            local now = os.clock()
            if pending_update and should_move then
                if (now - start_time) < config.job_change_cooldown then
                    if _G.AUTOMOVE_DEBUG then
                        add_to_chat(207, string.format('[AutoMove] COOLDOWN moving (%.1fs left)',
                            config.job_change_cooldown - (now - start_time)))
                    end
                elseif (now - last_update_time) >= config.update_debounce then
                    last_update_time = now
                    pending_update   = false
                    if _G.AUTOMOVE_DEBUG then add_to_chat(207, '[AutoMove] moving') end
                    if _G.UPDATE_DEBUG then
                        _G._update_sent_time = os.clock()
                        add_to_chat(207, string.format('[UPDATE_DEBUG] 1. AutoMove SEND gs c update | t=%.3f',
                            _G._update_sent_time))
                    end
                    if _G.LagDebugger then _G.LagDebugger.on_automove_update('moving', dist, moving) end
                    windower.send_command('gs c update')
                end
            end

            trigger_callbacks(true, dist, player.status)

        -------------------------------------------------------------------
        -- STOPPED
        -------------------------------------------------------------------
        elseif dist < config.movement_threshold then
            if moving then
                state.Moving.value = 'false'
                moving = false
                pending_update = true
                trigger_callbacks(false, dist, player.status)
            end

            local now = os.clock()
            if pending_update and not moving then
                if (now - start_time) < config.job_change_cooldown then
                    if _G.AUTOMOVE_DEBUG then
                        add_to_chat(207, string.format('[AutoMove] COOLDOWN stopping (%.1fs left)',
                            config.job_change_cooldown - (now - start_time)))
                    end
                elseif (now - last_update_time) >= config.update_debounce then
                    last_update_time = now
                    pending_update   = false
                    if _G.AUTOMOVE_DEBUG then add_to_chat(207, '[AutoMove] stopping') end
                    if _G.UPDATE_DEBUG then
                        _G._update_sent_time = os.clock()
                        add_to_chat(207, string.format('[UPDATE_DEBUG] 1. AutoMove SEND gs c update | t=%.3f',
                            _G._update_sent_time))
                    end
                    if _G.LagDebugger then _G.LagDebugger.on_automove_update('stopping', dist, moving) end
                    windower.send_command('gs c update')
                end
            end
        end

        -- Reschedule via closure (my_seq preserved automatically)
        coroutine.schedule(run, config.check_interval)
    end

    coroutine.schedule(run, config.check_interval)
end

---============================================================================
--- NOTE: AutoMove.start() is called explicitly by INIT_SYSTEMS.lua
--- It is NOT auto-started on include to prevent double-start on reload.
---============================================================================

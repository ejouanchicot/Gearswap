---============================================================================
--- Midcast Watchdog - Recovery from a lost aftercast
---============================================================================
--- Jobs report every midcast (on_midcast_start) and every aftercast
--- (on_aftercast, directly or through LifecycleManager). A 0.5 s loop checks
--- the tracked action: when no aftercast has arrived within cast time (Fast
--- Cast from state.FastCast applied) + WATCHDOG_BUFFER, it clears the
--- tracking and sends `gs c update` so the idle/engaged set comes back. Only spells and items
--- are tracked; job abilities, waltzes, steps... are ignored.
---
--- Started by INIT_SYSTEMS 2 s after a load, stopped by JobChangeManager's
--- cleanup. Settings changed with //gs c watchdog live in module locals and
--- are lost at the next job file load.
---
--- @file    shared/utils/core/midcast_watchdog.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-11-03
---============================================================================

local MidcastWatchdog = {}

-- cast_time for spells, cast_delay for usable items (Warp Ring...)
local res_spells = require('resources').spells
local res_items = require('resources').items

local MessageWatchdog = require('shared/utils/messages/formatters/system/message_watchdog')

-- CONFIGURATION

-- Safety buffer added to cast time (in seconds)
-- Timeout = adjusted_cast_time + WATCHDOG_BUFFER
-- 1.5s recommended to account for network latency
local WATCHDOG_BUFFER = 1.5

-- Fallback timeout for unknown spells (in seconds)
local WATCHDOG_FALLBACK_TIMEOUT = 5.0

-- Fast Cast cap (80% maximum reduction per FFXI mechanics)
local FAST_CAST_CAP = 80

-- Enable/disable watchdog (can be toggled via command)
local watchdog_enabled = true

-- Debug mode (shows detailed info)
local debug_enabled = false

-- STATE TRACKING

-- Current midcast tracking
local current_midcast = {
    active             = false,
    spell_name         = nil,
    spell_id           = nil,
    item_id            = nil,      -- Item ID for usable items (Warp Ring, etc.)
    action_type        = nil,      -- 'spell' or 'item'
    start_time         = nil,
    timeout            = nil,      -- Dynamic timeout for this spell/item
    base_cast_time     = nil,      -- Original cast time (before FC)
    adjusted_cast_time = nil,      -- Cast time after FC reduction
    fast_cast_percent  = nil       -- FC% applied
}

-- Test mode flag (prevents aftercast from clearing when testing)
local test_mode_active = false

-- HELPER FUNCTIONS

--- Fast Cast percentage from state.FastCast (defined per job), capped at 80.
--- @return number Fast Cast percent, 0 when the job has no FastCast state
local function get_fast_cast_percent()
    if state and state.FastCast then
        -- Get current value (Mote state objects use .value or .current)
        local fc_value = state.FastCast.value or state.FastCast.current or 0
        local fc_percent = tonumber(fc_value) or 0
        return math.min(fc_percent, FAST_CAST_CAP)
    end
    return 0
end

--- Calculate timeout for a spell or item based on its cast time/delay.
--- Fast Cast applies to spells only.
--- @param spell_id number|nil Spell id (res.spells)
--- @param item_id number|nil Item id (res.items), checked first
--- @return number timeout, number base_cast_time, number adjusted_cast_time
local function calculate_timeout(spell_id, item_id)
    local base_cast_time = 0

    -- PRIORITY 1: Check if it's an item (use cast_delay) - NO FC reduction for items
    if item_id and res_items[item_id] then
        local item_data = res_items[item_id]
        base_cast_time = item_data.cast_delay or item_data.cast_time or 0
        local timeout = base_cast_time + WATCHDOG_BUFFER
        return timeout, base_cast_time, base_cast_time

    -- PRIORITY 2: Check if it's a spell (use cast_time) - Apply FC reduction
    elseif spell_id and res_spells[spell_id] then
        local spell_data = res_spells[spell_id]
        base_cast_time = spell_data.cast_time or 0

    -- FALLBACK: Unknown action
    else
        return WATCHDOG_FALLBACK_TIMEOUT, 0, 0
    end

    -- Apply Fast Cast reduction: adjusted = base × (1 - FC%/100)
    local fc_percent = get_fast_cast_percent()
    local adjusted_cast_time = base_cast_time * (1 - fc_percent / 100)

    local timeout = adjusted_cast_time + WATCHDOG_BUFFER

    return timeout, base_cast_time, adjusted_cast_time
end

--- Clear midcast state tracking
local function clear_midcast_state()
    current_midcast.active             = false
    current_midcast.spell_name         = nil
    current_midcast.spell_id           = nil
    current_midcast.item_id            = nil
    current_midcast.action_type        = nil
    current_midcast.start_time         = nil
    current_midcast.timeout            = nil
    current_midcast.base_cast_time     = nil
    current_midcast.adjusted_cast_time = nil
    current_midcast.fast_cast_percent  = nil
end

--- Base cast time of the tracked action, and a label for the messages.
--- @return number cast_time, string action_label
local function get_current_cast_time()
    local cast_time = 0
    local action_label = 'spell'

    if current_midcast.action_type == 'item' and current_midcast.item_id then
        if res_items[current_midcast.item_id] then
            cast_time = res_items[current_midcast.item_id].cast_delay or
                        res_items[current_midcast.item_id].cast_time or 0
        end
        action_label = 'item (cast_delay)'
    elseif current_midcast.spell_id then
        if res_spells[current_midcast.spell_id] then
            cast_time = res_spells[current_midcast.spell_id].cast_time or 0
        end
        action_label = 'spell (cast_time)'
    end

    return cast_time, action_label
end

-- CORE FUNCTIONS

-- Spell types that should be monitored (actual magic spells)
local MONITORED_SPELL_TYPES = {
    ['WhiteMagic']    = true,
    ['BlackMagic']    = true,
    ['BlueMagic']     = true,
    ['Ninjutsu']      = true,
    ['SummonerPact']  = true,
    ['BardSong']      = true,
    ['Geomancy']      = true,
    ['Trust']         = true,
}

--- Start tracking an action (called from the jobs' midcast).
--- @param spell table GearSwap spell table
function MidcastWatchdog.on_midcast_start(spell)
    if not watchdog_enabled then
        return
    end

    local spell_name  = spell and spell.english or 'Unknown'
    local spell_type  = spell and spell.type or 'Unknown'
    local spell_id    = nil
    local item_id     = nil
    local action_type = 'spell'

    if spell_type == 'Item' then
        item_id     = spell.id
        action_type = 'item'
    elseif MONITORED_SPELL_TYPES[spell_type] then
        spell_id    = spell and spell.id or nil
        action_type = 'spell'
    else
        -- Job abilities, waltzes, steps...: not tracked
        if debug_enabled then
            MessageWatchdog.show_debug_ignored_action(spell_name, spell_type)
        end
        return
    end

    local timeout, base_cast_time, adjusted_cast_time = calculate_timeout(spell_id, item_id)
    local fc_percent = get_fast_cast_percent()

    current_midcast.active             = true
    current_midcast.spell_name         = spell_name
    current_midcast.spell_id           = spell_id
    current_midcast.item_id            = item_id
    current_midcast.action_type        = action_type
    current_midcast.start_time         = os.clock()
    current_midcast.timeout            = timeout
    current_midcast.base_cast_time     = base_cast_time
    current_midcast.adjusted_cast_time = adjusted_cast_time
    current_midcast.fast_cast_percent  = fc_percent

    if debug_enabled then
        if action_type == 'item' then
            MessageWatchdog.show_debug_midcast_item(spell_name, base_cast_time, timeout)
        else
            MessageWatchdog.show_debug_midcast_spell_fc(spell_name, base_cast_time, fc_percent, adjusted_cast_time, timeout)
        end
    end
end

--- Stop tracking (called from the jobs' aftercast).
function MidcastWatchdog.on_aftercast()
    if not watchdog_enabled then
        return
    end

    -- BLOCK aftercast cleanup in test mode (simulates packet loss)
    if test_mode_active then
        return
    end

    clear_midcast_state()
end

--- Check for stuck midcast (called every 0.5 s by the loop started in start()).
function MidcastWatchdog.check_stuck()
    if not watchdog_enabled then
        if debug_enabled then
            MessageWatchdog.show_debug_scanner_disabled()
        end
        return
    end

    if not current_midcast.active then
        if debug_enabled then
            MessageWatchdog.show_debug_no_active()
        end
        return
    end

    local current_time = os.clock()
    local age          = current_time - current_midcast.start_time
    local timeout      = current_midcast.timeout or WATCHDOG_FALLBACK_TIMEOUT

    if debug_enabled then
        MessageWatchdog.show_debug_scan(current_midcast.spell_name, age, timeout)
    end

    if age > timeout then
        local cast_time, action_label = get_current_cast_time()
        MessageWatchdog.show_stuck_detected(current_midcast.spell_name, action_label, cast_time, age)

        clear_midcast_state()

        if test_mode_active then
            test_mode_active = false
            MessageWatchdog.show_test_deactivated()
        end

        send_command('gs c update')
    end
end

-- CONTROL FUNCTIONS

--- Enable watchdog
function MidcastWatchdog.enable()
    watchdog_enabled = true
    MessageWatchdog.show_enabled()
end

--- Disable watchdog
function MidcastWatchdog.disable()
    watchdog_enabled = false
    MessageWatchdog.show_disabled()
end

--- Toggle watchdog on/off
function MidcastWatchdog.toggle()
    if watchdog_enabled then
        MidcastWatchdog.disable()
    else
        MidcastWatchdog.enable()
    end
end

--- @return boolean True when the watchdog is enabled
function MidcastWatchdog.is_enabled()
    return watchdog_enabled
end

--- Set the buffer added to the cast time (0..10 s, else an error message).
--- @param seconds number|nil New buffer
function MidcastWatchdog.set_buffer(seconds)
    if seconds and seconds >= 0 and seconds <= 10 then
        WATCHDOG_BUFFER = seconds
        MessageWatchdog.show_buffer_set(seconds)
    else
        MessageWatchdog.show_invalid_buffer()
    end
end

--- @return number Current buffer in seconds
function MidcastWatchdog.get_buffer()
    return WATCHDOG_BUFFER
end

--- Set the timeout used for unknown spells ((0..30] s, else an error message).
--- @param seconds number|nil New fallback timeout
function MidcastWatchdog.set_fallback_timeout(seconds)
    if seconds and seconds > 0 and seconds <= 30 then
        WATCHDOG_FALLBACK_TIMEOUT = seconds
        MessageWatchdog.show_fallback_set(seconds)
    else
        MessageWatchdog.show_invalid_fallback()
    end
end

--- @return number Current fallback timeout in seconds
function MidcastWatchdog.get_fallback_timeout()
    return WATCHDOG_FALLBACK_TIMEOUT
end

--- Enable debug mode
function MidcastWatchdog.enable_debug()
    debug_enabled = true
    MessageWatchdog.show_debug_enabled()
end

--- Disable debug mode
function MidcastWatchdog.disable_debug()
    debug_enabled = false
    MessageWatchdog.show_debug_disabled()
end

--- Toggle debug mode on/off
function MidcastWatchdog.toggle_debug()
    if debug_enabled then
        MidcastWatchdog.disable_debug()
    else
        MidcastWatchdog.enable_debug()
    end
end

--- @return boolean True when debug output is on
function MidcastWatchdog.is_debug_enabled()
    return debug_enabled
end

--- Snapshot of the tracked action and the settings, for the status displays.
--- @return table active, spell_name, spell_id, item_id, action_type, cast_time,
---   base_cast_time, adjusted_cast_time, fast_cast, age, enabled, timeout,
---   buffer, fallback_timeout, debug
function MidcastWatchdog.get_stats()
    local age = 0
    if current_midcast.active and current_midcast.start_time then
        age = os.clock() - current_midcast.start_time
    end

    local cast_time = get_current_cast_time()

    return {
        active             = current_midcast.active,
        spell_name         = current_midcast.spell_name or 'None',
        spell_id           = current_midcast.spell_id or 0,
        item_id            = current_midcast.item_id or 0,
        action_type        = current_midcast.action_type or 'spell',
        cast_time          = cast_time,
        base_cast_time     = current_midcast.base_cast_time or 0,
        adjusted_cast_time = current_midcast.adjusted_cast_time or 0,
        fast_cast          = current_midcast.fast_cast_percent or 0,
        age                = age,
        enabled            = watchdog_enabled,
        timeout            = current_midcast.timeout or WATCHDOG_FALLBACK_TIMEOUT,
        buffer             = WATCHDOG_BUFFER,
        fallback_timeout   = WATCHDOG_FALLBACK_TIMEOUT,
        debug              = debug_enabled
    }
end

--- Clear current midcast tracking and send `gs c update` (emergency cleanup).
--- Does not leave test mode.
function MidcastWatchdog.clear_all()
    if current_midcast.active then
        MessageWatchdog.show_force_clearing(current_midcast.spell_name)
    end

    clear_midcast_state()

    send_command('gs c update')
    MessageWatchdog.show_all_cleared()
end

--- TEST MODE: track a fake midcast whose aftercast is ignored, so the next
--- scan past its timeout reports it stuck.
--- @param spell_name string|nil Label shown in the messages
--- @param spell_id number|nil Spell id used for the timeout (nil = fallback)
function MidcastWatchdog.simulate_stuck(spell_name, spell_id)
    spell_name = spell_name or 'Test Spell'
    spell_id   = spell_id or nil

    local timeout, base_cast_time = calculate_timeout(spell_id, nil)

    MessageWatchdog.show_test_simulating(spell_name)
    if spell_id then
        MessageWatchdog.show_test_cast_time(base_cast_time, timeout, WATCHDOG_BUFFER)
    else
        MessageWatchdog.show_test_fallback(timeout)
    end
    MessageWatchdog.show_test_aftercast_blocked()

    test_mode_active = true

    current_midcast.active      = true
    current_midcast.spell_name  = spell_name
    current_midcast.spell_id    = spell_id
    current_midcast.item_id     = nil
    current_midcast.action_type = 'spell'
    current_midcast.start_time  = os.clock()
    current_midcast.timeout     = timeout

    if not debug_enabled then
        MessageWatchdog.show_test_started()
    end
end

-- STARTUP

-- Scan loop generation. It lives on `windower` because scheduled coroutines
-- outlive their environment: a load replaced within 2 s runs its deferred
-- start() after the new load, on a second instance of this module, and a flag
-- on `_G` would then keep the new load's own instance - the one the jobs
-- report to - from scanning. Every start() and stop() bumps the generation, so
-- only the newest loop keeps running.
windower._midcast_wd_seq = windower._midcast_wd_seq or 0

--- One scan, with errors reported instead of ending the loop.
local function background_check()
    local success, err = pcall(MidcastWatchdog.check_stuck)
    if not success then
        MessageWatchdog.show_error_in_check(err)
    end
end

--- Start the watchdog background check, replacing any loop already running
function MidcastWatchdog.start()
    windower._midcast_wd_seq = windower._midcast_wd_seq + 1
    local my_seq = windower._midcast_wd_seq

    -- Use self-rescheduling coroutine (avoids prerender spam in debugmode)
    local function watchdog_check_and_reschedule()
        if my_seq ~= windower._midcast_wd_seq then
            return -- Stopped, or a newer start() owns the scan
        end

        background_check()

        coroutine.schedule(watchdog_check_and_reschedule, 0.5)
    end

    -- Does not control the loop (the generation above does); stop() only
    -- reads it to decide whether to clear the tracked midcast.
    _G.MIDCAST_WATCHDOG_TIMER = true
    coroutine.schedule(watchdog_check_and_reschedule, 0.5)
end

--- Stop the watchdog background check (called during job change cleanup)
function MidcastWatchdog.stop()
    windower._midcast_wd_seq = windower._midcast_wd_seq + 1
    if _G.MIDCAST_WATCHDOG_TIMER then
        _G.MIDCAST_WATCHDOG_TIMER = nil
        clear_midcast_state()
    end
end

return MidcastWatchdog
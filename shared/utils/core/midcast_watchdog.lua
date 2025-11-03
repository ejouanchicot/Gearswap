---============================================================================
--- Midcast Watchdog - Stuck Midcast Detection and Recovery
---============================================================================
--- Detects and recovers from stuck midcast states caused by packet loss.
--- Uses GearSwap event hooks instead of command_registry scanning.
---
--- @file midcast_watchdog.lua
--- @author Tetsouo
--- @version 2.0 - Hook-based approach
--- @date Created: 2025-10-25
---============================================================================

local MidcastWatchdog = {}

---============================================================================
--- CONFIGURATION
---============================================================================

-- Timeout threshold (in seconds) before forcing cleanup
local WATCHDOG_TIMEOUT = 3.5

-- Enable/disable watchdog (can be toggled via command)
local watchdog_enabled = true

-- Debug mode (shows detailed info)
local debug_enabled = false

---============================================================================
--- STATE TRACKING
---============================================================================

-- Current midcast tracking
local current_midcast = {
    active = false,
    spell_name = nil,
    start_time = nil
}

-- Test mode flag (prevents aftercast from clearing when testing)
local test_mode_active = false

---============================================================================
--- CORE FUNCTIONS
---============================================================================

--- Called when midcast starts
--- @param spell table Spell data
function MidcastWatchdog.on_midcast_start(spell)
    if not watchdog_enabled then
        return
    end

    local spell_name = spell and spell.english or 'Unknown'
    current_midcast.active = true
    current_midcast.spell_name = spell_name
    current_midcast.start_time = os.clock()
end

--- Called when aftercast happens
function MidcastWatchdog.on_aftercast()
    if not watchdog_enabled then
        return
    end

    -- BLOCK aftercast cleanup in test mode (simulates packet loss)
    if test_mode_active then
        return
    end

    current_midcast.active = false
    current_midcast.spell_name = nil
    current_midcast.start_time = nil
end

--- Check for stuck midcast (called every 0.5s)
function MidcastWatchdog.check_stuck()
    if not watchdog_enabled then
        if debug_enabled then
            add_to_chat(167, '[Watchdog DEBUG] Scanner disabled')
        end
        return
    end

    if not current_midcast.active then
        if debug_enabled then
            add_to_chat(158, '[Watchdog DEBUG] Scan: No active midcast')
        end
        return
    end

    local current_time = os.clock()
    local age = current_time - current_midcast.start_time

    if debug_enabled then
        add_to_chat(207, '[Watchdog DEBUG] Scan: Active midcast "' .. current_midcast.spell_name .. '" (age: ' .. string.format("%.2f", age) .. 's, timeout: ' .. WATCHDOG_TIMEOUT .. 's)')
    end

    if age > WATCHDOG_TIMEOUT then
        -- STUCK! Force cleanup
        add_to_chat(167, '[Watchdog] Midcast stuck detected - recovering from: ' .. current_midcast.spell_name .. ' (stuck for ' .. string.format("%.1f", age) .. 's)')

        -- Reset tracking
        current_midcast.active = false
        current_midcast.spell_name = nil
        current_midcast.start_time = nil

        -- Disable test mode if it was active
        if test_mode_active then
            test_mode_active = false
            add_to_chat(158, '[Watchdog TEST] Test mode deactivated after cleanup')
        end

        -- Force gear refresh
        send_command('gs c update')
    end
end

---============================================================================
--- CONTROL FUNCTIONS
---============================================================================

--- Enable watchdog
function MidcastWatchdog.enable()
    watchdog_enabled = true
    add_to_chat(158, '[Watchdog] Enabled')
end

--- Disable watchdog
function MidcastWatchdog.disable()
    watchdog_enabled = false
    add_to_chat(167, '[Watchdog] Disabled')
end

--- Toggle watchdog on/off
function MidcastWatchdog.toggle()
    if watchdog_enabled then
        MidcastWatchdog.disable()
    else
        MidcastWatchdog.enable()
    end
end

--- Get current watchdog status
--- @return boolean enabled status
function MidcastWatchdog.is_enabled()
    return watchdog_enabled
end

--- Set timeout value
--- @param seconds number New timeout in seconds
function MidcastWatchdog.set_timeout(seconds)
    if seconds and seconds > 0 and seconds <= 10 then
        WATCHDOG_TIMEOUT = seconds
        add_to_chat(158, '[Watchdog] Timeout set to: ' .. seconds .. 's')
    else
        add_to_chat(167, '[Watchdog] Invalid timeout (must be 0-10s)')
    end
end

--- Get current timeout value
--- @return number timeout in seconds
function MidcastWatchdog.get_timeout()
    return WATCHDOG_TIMEOUT
end

--- Enable debug mode
function MidcastWatchdog.enable_debug()
    debug_enabled = true
    add_to_chat(158, '[Watchdog] Debug mode ENABLED - will show scan details every 0.5s')
end

--- Disable debug mode
function MidcastWatchdog.disable_debug()
    debug_enabled = false
    add_to_chat(167, '[Watchdog] Debug mode DISABLED')
end

--- Toggle debug mode on/off
function MidcastWatchdog.toggle_debug()
    if debug_enabled then
        MidcastWatchdog.disable_debug()
    else
        MidcastWatchdog.enable_debug()
    end
end

--- Get debug status
--- @return boolean debug enabled status
function MidcastWatchdog.is_debug_enabled()
    return debug_enabled
end

--- Get stats
--- @return table Stats {active, spell_name, age, enabled, timeout, debug}
function MidcastWatchdog.get_stats()
    local age = 0
    if current_midcast.active and current_midcast.start_time then
        age = os.clock() - current_midcast.start_time
    end

    return {
        active = current_midcast.active,
        spell_name = current_midcast.spell_name or 'None',
        age = age,
        enabled = watchdog_enabled,
        timeout = WATCHDOG_TIMEOUT,
        debug = debug_enabled
    }
end

--- Clear current midcast tracking (emergency cleanup)
function MidcastWatchdog.clear_all()
    if current_midcast.active then
        add_to_chat(167, '[Watchdog] Force clearing: ' .. current_midcast.spell_name)
    end

    current_midcast.active = false
    current_midcast.spell_name = nil
    current_midcast.start_time = nil

    send_command('gs c update')
    add_to_chat(158, '[Watchdog] All midcast tracking cleared')
end

--- TEST MODE: Simulate stuck midcast (for debugging)
--- @param spell_name string Name of spell to simulate
function MidcastWatchdog.simulate_stuck(spell_name)
    spell_name = spell_name or 'Test Spell'

    add_to_chat(167, '[Watchdog TEST] Simulating stuck midcast: ' .. spell_name)
    add_to_chat(167, '[Watchdog TEST] Aftercast will be BLOCKED - watchdog should cleanup after ' .. WATCHDOG_TIMEOUT .. 's')

    -- Enable test mode (blocks aftercast)
    test_mode_active = true

    -- Simulate midcast start
    current_midcast.active = true
    current_midcast.spell_name = spell_name
    current_midcast.start_time = os.clock()

    if not debug_enabled then
        add_to_chat(158, '[Watchdog TEST] Stuck simulation started - use "//gs c watchdog debug" to see scans')
    end
end

---============================================================================
--- STARTUP
---============================================================================

local watchdog_timer = nil

--- Background check function (called by timer)
local function background_check()
    local success, err = pcall(MidcastWatchdog.check_stuck)
    if not success then
        add_to_chat(167, '[Watchdog] Error in check: ' .. tostring(err))
    end
end

--- Start the watchdog background check
function MidcastWatchdog.start()
    if watchdog_timer then
        return -- Already running
    end

    -- Use self-rescheduling coroutine (avoids prerender spam in debugmode)
    local function watchdog_check_and_reschedule()
        if not watchdog_timer then
            return -- Watchdog was stopped
        end

        background_check()

        -- Reschedule next check
        coroutine.schedule(watchdog_check_and_reschedule, 0.5)
    end

    -- Start the loop
    watchdog_timer = true
    coroutine.schedule(watchdog_check_and_reschedule, 0.5)

    -- Silent start - no message displayed
end

--- Stop the watchdog background check
function MidcastWatchdog.stop()
    if watchdog_timer then
        watchdog_timer = nil -- This will break the while loop
    end
    add_to_chat(167, '[Watchdog] Stopped')
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MidcastWatchdog

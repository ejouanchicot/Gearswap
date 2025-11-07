---============================================================================
--- Midcast Watchdog - Stuck Midcast Detection and Recovery
---============================================================================
--- Detects and recovers from stuck midcast states caused by packet loss.
--- Uses dynamic timeout based on spell cast time from res/spells.lua
--- and item cast_delay from res/items.lua.
---
--- @file midcast_watchdog.lua
--- @author Tetsouo
--- @version 3.1 - Item support (cast_delay)
--- @date Created: 2025-10-25 | Updated: 2025-11-06 | Updated: 2025-11-04
---============================================================================

local MidcastWatchdog = {}

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Load spell resource data (contains cast_time for all spells)
local res_spells = require('resources').spells

-- Load item resource data (contains cast_delay for usable items like Warp Ring)
local res_items = require('resources').items

-- Message formatter for watchdog messages
local MessageWatchdog = require('shared/utils/messages/formatters/system/message_watchdog')

---============================================================================
--- CONFIGURATION
---============================================================================

-- Safety buffer added to cast time (in seconds)
-- Timeout = spell_cast_time + WATCHDOG_BUFFER
-- Example: Teleport (20s) + 2.0s buffer = 22s timeout
local WATCHDOG_BUFFER = 2.0

-- Fallback timeout for unknown spells (in seconds)
local WATCHDOG_FALLBACK_TIMEOUT = 5.0

-- Enable/disable watchdog (can be toggled via command)
local watchdog_enabled = true

-- Debug mode (shows detailed info)
local debug_enabled = false

---============================================================================
--- CONSTANTS
---============================================================================

local CHAT_DEFAULT = 1
local CHAT_ERROR = 167

---============================================================================
--- STATE TRACKING
---============================================================================

-- Current midcast tracking
local current_midcast = {
    active      = false,
    spell_name  = nil,
    spell_id    = nil,
    item_id     = nil,     -- Item ID for usable items (Warp Ring, etc.)
    action_type = nil,     -- 'spell' or 'item'
    start_time  = nil,
    timeout     = nil      -- Dynamic timeout for this spell/item
}

-- Test mode flag (prevents aftercast from clearing when testing)
local test_mode_active = false

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Calculate timeout for a spell or item based on its cast time/delay
--- @param spell_id number Spell ID from res/spells.lua (optional)
--- @param item_id number Item ID from res/items.lua (optional)
--- @return number timeout in seconds (cast_time/cast_delay + buffer)
--- @return number base_cast_time Base cast time before buffer
local function calculate_timeout(spell_id, item_id)
    local base_cast_time = 0

    -- PRIORITY 1: Check if it's an item (use cast_delay)
    if item_id and res_items[item_id] then
        local item_data = res_items[item_id]
        -- Items use cast_delay (priority) or cast_time as fallback
        base_cast_time = item_data.cast_delay or item_data.cast_time or 0

    -- PRIORITY 2: Check if it's a spell (use cast_time)
    elseif spell_id and res_spells[spell_id] then
        local spell_data = res_spells[spell_id]
        base_cast_time = spell_data.cast_time or 0

    -- FALLBACK: Unknown action
    else
        return WATCHDOG_FALLBACK_TIMEOUT, 0
    end

    -- Timeout = base cast time + safety buffer
    local timeout = base_cast_time + WATCHDOG_BUFFER

    return timeout, base_cast_time
end

---============================================================================
--- CORE FUNCTIONS
---============================================================================

--- Called when midcast starts
--- @param spell table Spell/item data
function MidcastWatchdog.on_midcast_start(spell)
    if not watchdog_enabled then
        return
    end

    local spell_name  = spell and spell.english or 'Unknown'
    local spell_id    = nil
    local item_id     = nil
    local action_type = 'spell'  -- Default to spell

    -- Detect action type: spell vs item
    if spell and spell.type == 'Item' then
        -- It's an item (Warp Ring, etc.)
        item_id     = spell.id
        action_type = 'item'
    else
        -- It's a spell or ability
        spell_id    = spell and spell.id or nil
        action_type = 'spell'
    end

    -- Calculate dynamic timeout based on spell cast_time or item cast_delay
    local timeout, base_cast_time = calculate_timeout(spell_id, item_id)

    current_midcast.active      = true
    current_midcast.spell_name  = spell_name
    current_midcast.spell_id    = spell_id
    current_midcast.item_id     = item_id
    current_midcast.action_type = action_type
    current_midcast.start_time  = os.clock()
    current_midcast.timeout     = timeout

    if debug_enabled then
        if action_type == 'item' then
            MessageWatchdog.show_debug_midcast_item(spell_name, base_cast_time, timeout)
        else
            MessageWatchdog.show_debug_midcast_spell(spell_name, base_cast_time, timeout)
        end
    end
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

    current_midcast.active      = false
    current_midcast.spell_name  = nil
    current_midcast.spell_id    = nil
    current_midcast.item_id     = nil
    current_midcast.action_type = nil
    current_midcast.start_time  = nil
    current_midcast.timeout     = nil
end

--- Check for stuck midcast (called every 0.5s)
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
        -- STUCK! Force cleanup
        local cast_time = 0
        local action_label = 'spell'

        if current_midcast.action_type == 'item' and current_midcast.item_id then
            -- Item: use cast_delay
            if res_items[current_midcast.item_id] then
                cast_time = res_items[current_midcast.item_id].cast_delay or
                            res_items[current_midcast.item_id].cast_time or 0
            end
            action_label = 'item (cast_delay)'
        elseif current_midcast.spell_id then
            -- Spell: use cast_time
            if res_spells[current_midcast.spell_id] then
                cast_time = res_spells[current_midcast.spell_id].cast_time or 0
            end
            action_label = 'spell (cast_time)'
        end

        MessageWatchdog.show_stuck_detected(current_midcast.spell_name, action_label, cast_time, age)

        -- Reset tracking
        current_midcast.active      = false
        current_midcast.spell_name  = nil
        current_midcast.spell_id    = nil
        current_midcast.item_id     = nil
        current_midcast.action_type = nil
        current_midcast.start_time  = nil
        current_midcast.timeout     = nil

        -- Disable test mode if it was active
        if test_mode_active then
            test_mode_active = false
            MessageWatchdog.show_test_deactivated()
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

--- Get current watchdog status
--- @return boolean enabled status
function MidcastWatchdog.is_enabled()
    return watchdog_enabled
end

--- Set buffer value (added to cast time)
--- @param seconds number New buffer in seconds
function MidcastWatchdog.set_buffer(seconds)
    if seconds and seconds >= 0 and seconds <= 10 then
        WATCHDOG_BUFFER = seconds
        MessageWatchdog.show_buffer_set(seconds)
    else
        MessageWatchdog.show_invalid_buffer()
    end
end

--- Get current buffer value
--- @return number buffer in seconds
function MidcastWatchdog.get_buffer()
    return WATCHDOG_BUFFER
end

--- Set fallback timeout for unknown spells
--- @param seconds number New fallback timeout in seconds
function MidcastWatchdog.set_fallback_timeout(seconds)
    if seconds and seconds > 0 and seconds <= 30 then
        WATCHDOG_FALLBACK_TIMEOUT = seconds
        MessageWatchdog.show_fallback_set(seconds)
    else
        MessageWatchdog.show_invalid_fallback()
    end
end

--- Get current fallback timeout value
--- @return number fallback timeout in seconds
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

--- Get debug status
--- @return boolean debug enabled status
function MidcastWatchdog.is_debug_enabled()
    return debug_enabled
end

--- Get stats
--- @return table Stats {active, spell_name, spell_id, item_id, action_type, age, enabled, timeout, buffer, fallback_timeout, debug}
function MidcastWatchdog.get_stats()
    local age = 0
    if current_midcast.active and current_midcast.start_time then
        age = os.clock() - current_midcast.start_time
    end

    local cast_time = 0
    if current_midcast.action_type == 'item' and current_midcast.item_id then
        -- Item: use cast_delay
        if res_items[current_midcast.item_id] then
            cast_time = res_items[current_midcast.item_id].cast_delay or
                        res_items[current_midcast.item_id].cast_time or 0
        end
    elseif current_midcast.spell_id and res_spells[current_midcast.spell_id] then
        -- Spell: use cast_time
        cast_time = res_spells[current_midcast.spell_id].cast_time or 0
    end

    return {
        active           = current_midcast.active,
        spell_name       = current_midcast.spell_name or 'None',
        spell_id         = current_midcast.spell_id or 0,
        item_id          = current_midcast.item_id or 0,
        action_type      = current_midcast.action_type or 'spell',
        cast_time        = cast_time,
        age              = age,
        enabled          = watchdog_enabled,
        timeout          = current_midcast.timeout or WATCHDOG_FALLBACK_TIMEOUT,
        buffer           = WATCHDOG_BUFFER,
        fallback_timeout = WATCHDOG_FALLBACK_TIMEOUT,
        debug            = debug_enabled
    }
end

--- Clear current midcast tracking (emergency cleanup)
function MidcastWatchdog.clear_all()
    if current_midcast.active then
        MessageWatchdog.show_force_clearing(current_midcast.spell_name)
    end

    current_midcast.active      = false
    current_midcast.spell_name  = nil
    current_midcast.spell_id    = nil
    current_midcast.item_id     = nil
    current_midcast.action_type = nil
    current_midcast.start_time  = nil
    current_midcast.timeout     = nil

    send_command('gs c update')
    MessageWatchdog.show_all_cleared()
end

--- TEST MODE: Simulate stuck midcast (for debugging)
--- @param spell_name string Name of spell to simulate (optional)
--- @param spell_id number Spell ID from res/spells.lua (optional)
function MidcastWatchdog.simulate_stuck(spell_name, spell_id)
    spell_name = spell_name or 'Test Spell'
    spell_id   = spell_id or nil

    -- Calculate timeout for this test spell
    local timeout, base_cast_time = calculate_timeout(spell_id, nil)

    MessageWatchdog.show_test_simulating(spell_name)
    if spell_id then
        MessageWatchdog.show_test_cast_time(base_cast_time, timeout, WATCHDOG_BUFFER)
    else
        MessageWatchdog.show_test_fallback(timeout)
    end
    MessageWatchdog.show_test_aftercast_blocked()

    -- Enable test mode (blocks aftercast)
    test_mode_active = true

    -- Simulate midcast start
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

---============================================================================
--- STARTUP
---============================================================================

local watchdog_timer = nil

--- Background check function (called by timer)
local function background_check()
    local success, err = pcall(MidcastWatchdog.check_stuck)
    if not success then
        MessageWatchdog.show_error_in_check(err)
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
    MessageWatchdog.show_stopped()
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MidcastWatchdog

---  ═══════════════════════════════════════════════════════════════════════════
---   Midcast Watchdog - Stuck Midcast Detection and Recovery
---  ═══════════════════════════════════════════════════════════════════════════
---   Detects and recovers from stuck midcast states caused by packet loss.
---   Uses dynamic timeout based on spell cast time from res/spells.lua
---   and item cast_delay from res/items.lua.
---
---   @file    shared/utils/core/midcast_watchdog.lua
---   @author  Tetsouo
---   @version 3.4 - Refactoring (DRY helpers: clear_midcast_state + get_current_cast_time)
---   @date    Created: 2025-10-25 | Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

local MidcastWatchdog = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES
---  ═══════════════════════════════════════════════════════════════════════════

-- Load spell resource data (contains cast_time for all spells)
local res_spells = require('resources').spells

-- Load item resource data (contains cast_delay for usable items like Warp Ring)
local res_items = require('resources').items

-- Message formatter for watchdog messages
local MessageWatchdog = require('shared/utils/messages/formatters/system/message_watchdog')

---  ═══════════════════════════════════════════════════════════════════════════
---   CONFIGURATION
---  ═══════════════════════════════════════════════════════════════════════════

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

---  ═══════════════════════════════════════════════════════════════════════════
---   STATE TRACKING
---  ═══════════════════════════════════════════════════════════════════════════

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

---  ═══════════════════════════════════════════════════════════════════════════
---   HELPER FUNCTIONS
---  ═══════════════════════════════════════════════════════════════════════════

--- Get Fast Cast percentage from state.FastCast
--- @return number fc_percent Fast Cast percentage (0-80, capped)
local function get_fast_cast_percent()
    -- Check if state.FastCast exists (defined in job config)
    if state and state.FastCast then
        -- Get current value (Mote state objects use .value or .current)
        local fc_value = state.FastCast.value or state.FastCast.current or 0
        local fc_percent = tonumber(fc_value) or 0
        -- Cap at 80% (FFXI mechanics)
        return math.min(fc_percent, FAST_CAST_CAP)
    end
    return 0
end

--- Calculate timeout for a spell or item based on its cast time/delay
--- Applies Fast Cast reduction from state.FastCast
--- @param spell_id number Spell ID from res/spells.lua (optional)
--- @param item_id number Item ID from res/items.lua (optional)
--- @return number timeout in seconds (adjusted_cast_time + buffer)
--- @return number base_cast_time Base cast time before FC reduction
--- @return number adjusted_cast_time Cast time after FC reduction
local function calculate_timeout(spell_id, item_id)
    local base_cast_time = 0

    -- PRIORITY 1: Check if it's an item (use cast_delay) - NO FC reduction for items
    if item_id and res_items[item_id] then
        local item_data = res_items[item_id]
        -- Items use cast_delay (priority) or cast_time as fallback
        base_cast_time = item_data.cast_delay or item_data.cast_time or 0
        -- Items don't benefit from Fast Cast
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

    -- Timeout = adjusted cast time + safety buffer
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

--- Get cast time for current midcast action
--- @return number cast_time Cast time in seconds
--- @return string action_label Label describing the action type
local function get_current_cast_time()
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

    return cast_time, action_label
end

---  ═══════════════════════════════════════════════════════════════════════════
---   CORE FUNCTIONS
---  ═══════════════════════════════════════════════════════════════════════════

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

--- Called when midcast starts
--- @param spell table Spell/item data
function MidcastWatchdog.on_midcast_start(spell)
    if not watchdog_enabled then
        return
    end

    local spell_name  = spell and spell.english or 'Unknown'
    local spell_type  = spell and spell.type or 'Unknown'
    local spell_id    = nil
    local item_id     = nil
    local action_type = 'spell'  -- Default to spell

    -- Detect action type: spell vs item vs ability
    if spell_type == 'Item' then
        -- It's an item (Warp Ring, etc.)
        item_id     = spell.id
        action_type = 'item'
    elseif MONITORED_SPELL_TYPES[spell_type] then
        -- It's a real spell (magic) - monitor it
        spell_id    = spell and spell.id or nil
        action_type = 'spell'
    else
        -- It's a Job Ability, Waltz, Step, etc. - IGNORE
        if debug_enabled then
            MessageWatchdog.show_debug_ignored_action(spell_name, spell_type)
        end
        return
    end

    -- Calculate dynamic timeout based on spell cast_time or item cast_delay
    -- For spells: applies Fast Cast reduction
    -- For items: no FC reduction
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
            -- Show FC info for spells
            MessageWatchdog.show_debug_midcast_spell_fc(spell_name, base_cast_time, fc_percent, adjusted_cast_time, timeout)
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

    clear_midcast_state()
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
        local cast_time, action_label = get_current_cast_time()
        MessageWatchdog.show_stuck_detected(current_midcast.spell_name, action_label, cast_time, age)

        -- Reset tracking
        clear_midcast_state()

        -- Disable test mode if it was active
        if test_mode_active then
            test_mode_active = false
            MessageWatchdog.show_test_deactivated()
        end

        -- Force gear refresh
        send_command('gs c update')
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   CONTROL FUNCTIONS
---  ═══════════════════════════════════════════════════════════════════════════

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
--- @return table Stats {active, spell_name, spell_id, item_id, action_type, age, enabled, timeout, buffer, fallback_timeout, debug, fast_cast, base_cast_time, adjusted_cast_time}
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

--- Clear current midcast tracking (emergency cleanup)
function MidcastWatchdog.clear_all()
    if current_midcast.active then
        MessageWatchdog.show_force_clearing(current_midcast.spell_name)
    end

    clear_midcast_state()

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

---  ═══════════════════════════════════════════════════════════════════════════
---   STARTUP
---  ═══════════════════════════════════════════════════════════════════════════

-- Use global flag to prevent multiple watchdog instances across job changes
if not _G.MIDCAST_WATCHDOG_TIMER then
    _G.MIDCAST_WATCHDOG_TIMER = nil
end

--- Background check function (called by timer)
local function background_check()
    local success, err = pcall(MidcastWatchdog.check_stuck)
    if not success then
        MessageWatchdog.show_error_in_check(err)
    end
end

--- Start the watchdog background check
function MidcastWatchdog.start()
    if _G.MIDCAST_WATCHDOG_TIMER then
        return -- Already running
    end

    -- Use self-rescheduling coroutine (avoids prerender spam in debugmode)
    local function watchdog_check_and_reschedule()
        if not _G.MIDCAST_WATCHDOG_TIMER then
            return -- Watchdog was stopped
        end

        background_check()

        -- Reschedule next check
        coroutine.schedule(watchdog_check_and_reschedule, 0.5)
    end

    -- Start the loop
    _G.MIDCAST_WATCHDOG_TIMER = true
    coroutine.schedule(watchdog_check_and_reschedule, 0.5)

    -- Silent start - no message displayed
end

--- Stop the watchdog background check (called during job change cleanup)
function MidcastWatchdog.stop()
    if _G.MIDCAST_WATCHDOG_TIMER then
        _G.MIDCAST_WATCHDOG_TIMER = nil -- This will stop the recursive coroutine
        clear_midcast_state() -- Clear any tracked midcast
    end
    -- Silent stop - no message during job change
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return MidcastWatchdog

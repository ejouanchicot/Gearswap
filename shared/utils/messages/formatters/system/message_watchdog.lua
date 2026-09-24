---============================================================================
--- Watchdog Message Formatter - Midcast Watchdog Messages
---============================================================================
--- Status, configuration, debug and test lines of the midcast watchdog.
--- Templates: data/systems/watchdog_messages.lua.
---
--- @file    shared/utils/messages/formatters/system/message_watchdog.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageWatchdog = {}
local MessageCore = require('shared/utils/messages/message_core')
local M = require('shared/utils/messages/api/messages')

---============================================================================
--- STATUS MESSAGES
---============================================================================

--- Show the WATCHDOG.enabled message
function MessageWatchdog.show_enabled()
    M.send('WATCHDOG', 'enabled')
end

--- Show the WATCHDOG.disabled message
function MessageWatchdog.show_disabled()
    M.send('WATCHDOG', 'disabled')
end

--- Show the WATCHDOG.stopped message
function MessageWatchdog.show_stopped()
    M.send('WATCHDOG', 'stopped')
end

--- Show the WATCHDOG.not_loaded message
function MessageWatchdog.show_not_loaded()
    M.send('WATCHDOG', 'not_loaded')
end

--- Show watchdog status
--- @param stats table Statistics from MidcastWatchdog.get_stats()
function MessageWatchdog.show_status(stats)
    local gray = string.char(0x1F, 160)
    local yellow = string.char(0x1F, 50)
    local separator = string.rep("=", MessageCore.SEPARATOR_WIDTH)
    add_to_chat(121, gray .. separator)
    add_to_chat(121, yellow .. "Midcast Watchdog Status")
    add_to_chat(121, gray .. separator)

    M.send('WATCHDOG', 'status_enabled', {enabled = tostring(stats.enabled)})
    M.send('WATCHDOG', 'status_debug', {debug = tostring(stats.debug)})
    M.send('WATCHDOG', 'status_buffer', {buffer = string.format("%.1f", stats.buffer)})
    M.send('WATCHDOG', 'status_fallback', {fallback = string.format("%.1f", stats.fallback_timeout)})
    M.send('WATCHDOG', 'status_active', {active = tostring(stats.active)})

    if stats.active then
        local action_type_label = stats.action_type == 'item' and 'status_item' or 'status_spell'

        M.send('WATCHDOG', action_type_label, {
            spell_name = stats.spell_name,
            spell_id = tostring(stats.spell_id or 0),
            item_id = tostring(stats.item_id or 0)
        })
        M.send('WATCHDOG', 'status_cast_time', {cast_time = string.format("%.1f", stats.cast_time)})
        M.send('WATCHDOG', 'status_timeout', {timeout = string.format("%.1f", stats.timeout)})
        M.send('WATCHDOG', 'status_age', {age = string.format("%.2f", stats.age)})
    end
end

--- Show detailed watchdog statistics
--- @param stats table Statistics from MidcastWatchdog.get_stats()
function MessageWatchdog.show_stats(stats)
    local gray = string.char(0x1F, 160)
    local yellow = string.char(0x1F, 50)
    local separator = string.rep("=", MessageCore.SEPARATOR_WIDTH)
    add_to_chat(121, gray .. separator)
    add_to_chat(121, yellow .. "Midcast Watchdog Statistics")
    add_to_chat(121, gray .. separator)

    M.send('WATCHDOG', 'status_enabled', {enabled = tostring(stats.enabled)})
    M.send('WATCHDOG', 'status_debug', {debug = tostring(stats.debug)})
    M.send('WATCHDOG', 'status_buffer', {buffer = string.format("%.1f", stats.buffer)})
    M.send('WATCHDOG', 'status_fallback', {fallback = string.format("%.1f", stats.fallback_timeout)})
    M.send('WATCHDOG', 'status_active_midcast', {active = tostring(stats.active)})

    if stats.active then
        local action_type_label = stats.action_type == 'item' and 'status_current_item' or 'status_current_spell'

        M.send('WATCHDOG', action_type_label, {
            spell_name = stats.spell_name,
            spell_id = tostring(stats.spell_id or 0),
            item_id = tostring(stats.item_id or 0)
        })
        M.send('WATCHDOG', 'status_cast_time', {cast_time = string.format("%.1f", stats.cast_time)})
        M.send('WATCHDOG', 'status_timeout', {timeout = string.format("%.1f", stats.timeout)})
        M.send('WATCHDOG', 'status_age', {age = string.format("%.2f", stats.age)})
    end
end

---============================================================================
--- CONFIGURATION MESSAGES
---============================================================================

--- @param seconds number New buffer
function MessageWatchdog.show_buffer_set(seconds)
    M.send('WATCHDOG', 'buffer_set', {seconds = tostring(seconds)})
    M.send('WATCHDOG', 'buffer_formula', {seconds = tostring(seconds)})
end

--- Show the WATCHDOG.invalid_buffer message
function MessageWatchdog.show_invalid_buffer()
    M.send('WATCHDOG', 'invalid_buffer')
end

--- @param seconds number New fallback timeout
function MessageWatchdog.show_fallback_set(seconds)
    M.send('WATCHDOG', 'fallback_set', {seconds = tostring(seconds)})
end

--- Show the WATCHDOG.invalid_fallback message
function MessageWatchdog.show_invalid_fallback()
    M.send('WATCHDOG', 'invalid_fallback')
end

---============================================================================
--- DEBUG MESSAGES
---============================================================================

--- Show the WATCHDOG.debug_enabled message
function MessageWatchdog.show_debug_enabled()
    M.send('WATCHDOG', 'debug_enabled')
end

--- Show the WATCHDOG.debug_disabled message
function MessageWatchdog.show_debug_disabled()
    M.send('WATCHDOG', 'debug_disabled')
end

--- @param spell_name string Item name
--- @param cast_delay number Item cast delay (s)
--- @param timeout number Watchdog timeout (s)
function MessageWatchdog.show_debug_midcast_item(spell_name, cast_delay, timeout)
    M.send('WATCHDOG', 'debug_midcast_item', {
        spell_name = spell_name,
        cast_delay = string.format("%.2f", cast_delay),
        timeout = string.format("%.2f", timeout)
    })
end

--- @param spell_name string Spell name
--- @param cast_time number Cast time (s)
--- @param timeout number Watchdog timeout (s)
function MessageWatchdog.show_debug_midcast_spell(spell_name, cast_time, timeout)
    M.send('WATCHDOG', 'debug_midcast_spell', {
        spell_name = spell_name,
        cast_time = string.format("%.2f", cast_time),
        timeout = string.format("%.2f", timeout)
    })
end

--- Show debug info for spell midcast with Fast Cast
--- @param spell_name string Spell name
--- @param base_cast_time number Original cast time (before FC)
--- @param fc_percent number Fast Cast percentage applied
--- @param adjusted_cast_time number Cast time after FC reduction
--- @param timeout number Calculated timeout
function MessageWatchdog.show_debug_midcast_spell_fc(spell_name, base_cast_time, fc_percent, adjusted_cast_time, timeout)
    M.send('WATCHDOG', 'debug_midcast_spell_fc', {
        spell_name = spell_name,
        base_cast = string.format("%.2f", base_cast_time),
        fc_percent = string.format("%d", fc_percent),
        adjusted_cast = string.format("%.2f", adjusted_cast_time),
        timeout = string.format("%.2f", timeout)
    })
end

--- Show the WATCHDOG.debug_scanner_disabled message
function MessageWatchdog.show_debug_scanner_disabled()
    M.send('WATCHDOG', 'debug_scanner_disabled')
end

--- Show debug info for ignored action (JA, Waltz, etc.)
--- @param action_name string Action name
--- @param action_type string Action type (JobAbility, Waltz, etc.)
function MessageWatchdog.show_debug_ignored_action(action_name, action_type)
    M.send('WATCHDOG', 'debug_ignored_action', {
        action_name = action_name,
        action_type = action_type
    })
end

--- Show the WATCHDOG.debug_no_active message
function MessageWatchdog.show_debug_no_active()
    M.send('WATCHDOG', 'debug_no_active')
end

--- @param spell_name string Tracked action
--- @param age number Seconds since midcast
--- @param timeout number Watchdog timeout (s)
function MessageWatchdog.show_debug_scan(spell_name, age, timeout)
    M.send('WATCHDOG', 'debug_scan', {
        spell_name = spell_name,
        age = string.format("%.2f", age),
        timeout = string.format("%.2f", timeout)
    })
end

---============================================================================
--- ERROR/ALERT MESSAGES
---============================================================================

--- @param spell_name string Stuck action
--- @param action_label string Action kind shown to the player
--- @param cast_time number Expected cast time (s)
--- @param age number Seconds since midcast
function MessageWatchdog.show_stuck_detected(spell_name, action_label, cast_time, age)
    M.send('WATCHDOG', 'stuck_detected', {
        spell_name = spell_name,
        action_label = action_label
    })
    M.send('WATCHDOG', 'stuck_timing', {
        cast_time = string.format("%.2f", cast_time),
        age = string.format("%.2f", age)
    })
end

--- @param err any Error raised by the check
function MessageWatchdog.show_error_in_check(err)
    M.send('WATCHDOG', 'error_in_check', {error = tostring(err)})
end

---============================================================================
--- MANUAL CONTROL MESSAGES
---============================================================================

--- @param spell_name string Action being cleared
function MessageWatchdog.show_force_clearing(spell_name)
    M.send('WATCHDOG', 'force_clearing', {spell_name = spell_name})
end

--- Show the WATCHDOG.all_cleared message
function MessageWatchdog.show_all_cleared()
    M.send('WATCHDOG', 'all_cleared')
end

---============================================================================
--- TEST MODE MESSAGES
---============================================================================

--- @param spell_name string Simulated spell
function MessageWatchdog.show_test_simulating(spell_name)
    M.send('WATCHDOG', 'test_simulating', {spell_name = spell_name})
end

--- @param cast_time number Cast time (s)
--- @param timeout number Watchdog timeout (s)
--- @param buffer number Buffer (s)
function MessageWatchdog.show_test_cast_time(cast_time, timeout, buffer)
    M.send('WATCHDOG', 'test_cast_time', {
        cast_time = string.format("%.2f", cast_time),
        timeout = string.format("%.2f", timeout),
        buffer = string.format("%.2f", buffer)
    })
end

--- @param timeout number Fallback timeout (s)
function MessageWatchdog.show_test_fallback(timeout)
    M.send('WATCHDOG', 'test_fallback', {timeout = string.format("%.2f", timeout)})
end

--- Show the WATCHDOG.test_aftercast_blocked message
function MessageWatchdog.show_test_aftercast_blocked()
    M.send('WATCHDOG', 'test_aftercast_blocked')
end

--- Show the WATCHDOG.test_started message
function MessageWatchdog.show_test_started()
    M.send('WATCHDOG', 'test_started')
end

--- Show the WATCHDOG.test_deactivated message
function MessageWatchdog.show_test_deactivated()
    M.send('WATCHDOG', 'test_deactivated')
end

---============================================================================
--- HELP MESSAGE
---============================================================================

--- Show the WATCHDOG.help message
function MessageWatchdog.show_help()
    M.send('WATCHDOG', 'help')
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageWatchdog

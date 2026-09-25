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

--- Fields of the watchdog block, from MidcastWatchdog.get_stats().
--- @param stats table
--- @return table {{label, value, kind}, ...}
local function stats_fields(stats)
    local fields = {
        {'Enabled', stats.enabled == true},
        {'Debug', stats.debug == true},
        {'Buffer', ('%.1f s (added to cast time)'):format(stats.buffer)},
        {'Fallback', ('%.1f s (unknown spells)'):format(stats.fallback_timeout)},
        {'Midcast tracked', stats.active and 'Yes' or 'No', stats.active and 'warn' or nil},
    }
    if stats.active then
        local is_item = stats.action_type == 'item'
        fields[#fields + 1] = {is_item and 'Item' or 'Spell',
            ('%s (ID %s)'):format(stats.spell_name, tostring((is_item and stats.item_id or stats.spell_id) or 0)),
            'spell'}
        fields[#fields + 1] = {'Cast time', ('%.1f s'):format(stats.cast_time)}
        fields[#fields + 1] = {'Timeout', ('%.1f s'):format(stats.timeout)}
        fields[#fields + 1] = {'Age', ('%.2f s'):format(stats.age)}
    end
    return fields
end

--- Show watchdog status (//gs c watchdog), as a data block.
--- @param stats table Statistics from MidcastWatchdog.get_stats()
function MessageWatchdog.show_status(stats)
    require('shared/utils/messages/info_block').show({tag = 'WATCHDOG', title = 'Status',
        fields = stats_fields(stats)})
end

--- Show watchdog statistics (//gs c watchdog stats), as a data block.
--- @param stats table Statistics from MidcastWatchdog.get_stats()
function MessageWatchdog.show_stats(stats)
    require('shared/utils/messages/info_block').show({tag = 'WATCHDOG', title = 'Statistics',
        fields = stats_fields(stats)})
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
    require('shared/utils/messages/help_screen').show({
        title = 'WATCHDOG', subtitle = 'Recovers a lost aftercast',
        groups = {{title = 'COMMANDS', rows = {
            {'//gs c watchdog', '', 'Status'},
            {'//gs c watchdog ', 'on|off|toggle', 'Enable / disable'},
            {'//gs c watchdog stats', '', 'Statistics'},
            {'//gs c watchdog buffer ', '<0-10>', 'Seconds added to cast time'},
            {'//gs c watchdog fallback ', '<1-30>', 'Timeout of unknown spells'},
            {'//gs c watchdog clear', '', 'Clear tracking, re-equip'},
            {'//gs c watchdog test ', '[spell] [id]', 'Simulate a stuck midcast'},
            {'//gs c watchdog debug', '', 'Toggle debug messages'},
        }}},
        notes = {'Settings last until the next job load.'},
    })
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageWatchdog

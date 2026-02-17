---============================================================================
--- Watchdog Message Formatter - Midcast Watchdog Messages (NEW SYSTEM)
---============================================================================
--- Uses template-based messaging via MessageRenderer
--- Migrated from old system to new system: 2025-11-06
---
--- @file    messages/message_watchdog.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageWatchdog = {}
local M = require('shared/utils/messages/api/messages')

---============================================================================
--- STATUS MESSAGES
---============================================================================

function MessageWatchdog.show_enabled()
    M.send('WATCHDOG', 'enabled')
end

function MessageWatchdog.show_disabled()
    M.send('WATCHDOG', 'disabled')
end

function MessageWatchdog.show_stopped()
    M.send('WATCHDOG', 'stopped')
end

function MessageWatchdog.show_not_loaded()
    M.send('WATCHDOG', 'not_loaded')
end

--- Show watchdog status
--- @param stats table Statistics from MidcastWatchdog.get_stats()
function MessageWatchdog.show_status(stats)
    -- Header with separators (like testcolors/detectregion/info)
    local gray = string.char(0x1F, 160)
    local yellow = string.char(0x1F, 50)
    local separator = string.rep("=", 74)
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
        local id_label = stats.action_type == 'item' and stats.item_id or stats.spell_id

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
    -- Header with separators (like testcolors/detectregion/info)
    local gray = string.char(0x1F, 160)
    local yellow = string.char(0x1F, 50)
    local separator = string.rep("=", 74)
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

function MessageWatchdog.show_buffer_set(seconds)
    M.send('WATCHDOG', 'buffer_set', {seconds = tostring(seconds)})
    M.send('WATCHDOG', 'buffer_formula', {seconds = tostring(seconds)})
end

function MessageWatchdog.show_invalid_buffer()
    M.send('WATCHDOG', 'invalid_buffer')
end

function MessageWatchdog.show_fallback_set(seconds)
    M.send('WATCHDOG', 'fallback_set', {seconds = tostring(seconds)})
end

function MessageWatchdog.show_invalid_fallback()
    M.send('WATCHDOG', 'invalid_fallback')
end

---============================================================================
--- DEBUG MESSAGES
---============================================================================

function MessageWatchdog.show_debug_enabled()
    M.send('WATCHDOG', 'debug_enabled')
end

function MessageWatchdog.show_debug_disabled()
    M.send('WATCHDOG', 'debug_disabled')
end

function MessageWatchdog.show_debug_midcast_item(spell_name, cast_delay, timeout)
    M.send('WATCHDOG', 'debug_midcast_item', {
        spell_name = spell_name,
        cast_delay = string.format("%.2f", cast_delay),
        timeout = string.format("%.2f", timeout)
    })
end

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

function MessageWatchdog.show_debug_no_active()
    M.send('WATCHDOG', 'debug_no_active')
end

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

function MessageWatchdog.show_error_in_check(err)
    M.send('WATCHDOG', 'error_in_check', {error = tostring(err)})
end

---============================================================================
--- MANUAL CONTROL MESSAGES
---============================================================================

function MessageWatchdog.show_force_clearing(spell_name)
    M.send('WATCHDOG', 'force_clearing', {spell_name = spell_name})
end

function MessageWatchdog.show_all_cleared()
    M.send('WATCHDOG', 'all_cleared')
end

---============================================================================
--- TEST MODE MESSAGES
---============================================================================

function MessageWatchdog.show_test_simulating(spell_name)
    M.send('WATCHDOG', 'test_simulating', {spell_name = spell_name})
end

function MessageWatchdog.show_test_cast_time(cast_time, timeout, buffer)
    M.send('WATCHDOG', 'test_cast_time', {
        cast_time = string.format("%.2f", cast_time),
        timeout = string.format("%.2f", timeout),
        buffer = string.format("%.2f", buffer)
    })
end

function MessageWatchdog.show_test_fallback(timeout)
    M.send('WATCHDOG', 'test_fallback', {timeout = string.format("%.2f", timeout)})
end

function MessageWatchdog.show_test_aftercast_blocked()
    M.send('WATCHDOG', 'test_aftercast_blocked')
end

function MessageWatchdog.show_test_started()
    M.send('WATCHDOG', 'test_started')
end

function MessageWatchdog.show_test_deactivated()
    M.send('WATCHDOG', 'test_deactivated')
end

---============================================================================
--- HELP MESSAGE
---============================================================================

function MessageWatchdog.show_help()
    M.send('WATCHDOG', 'help')
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageWatchdog

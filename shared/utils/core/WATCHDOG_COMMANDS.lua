---============================================================================
--- Watchdog Commands - Command Handler Module
---============================================================================
--- Provides command handling for Midcast Watchdog.
--- Import this module in job *_COMMANDS.lua files.
---
--- @file WATCHDOG_COMMANDS.lua
--- @author Tetsouo
--- @version 3.1 - Item support (cast_delay)
--- @date Created: 2025-10-25 | Updated: 2025-11-04
---============================================================================

local WatchdogCommands = {}

--- Check if command is a watchdog command
--- @param command string Command name
--- @return boolean True if watchdog command
function WatchdogCommands.is_watchdog_command(command)
    return command == 'watchdog'
end

--- Handle watchdog command
--- @param cmdParams table Command parameters array
--- @param eventArgs table Event arguments
--- @return boolean True if command was handled
function WatchdogCommands.handle_command(cmdParams, eventArgs)
    if not cmdParams or #cmdParams == 0 then
        return false
    end

    local command = cmdParams[1]:lower()

    if command ~= 'watchdog' then
        return false
    end

    -- Get MidcastWatchdog from global
    local MidcastWatchdog = _G.MidcastWatchdog
    if not MidcastWatchdog then
        add_to_chat(167, '[Watchdog] Error: Watchdog not loaded')
        return true
    end

    -- Extract sub-command args
    local cmd_args = {}
    for i = 2, #cmdParams do
        table.insert(cmd_args, cmdParams[i])
    end

    -- Handle sub-commands
    if #cmd_args == 0 then
        -- Show status
        local stats = MidcastWatchdog.get_stats()
        add_to_chat(158, '=== Midcast Watchdog Status ===')
        add_to_chat(158, '  Enabled: ' .. tostring(stats.enabled))
        add_to_chat(158, '  Debug: ' .. tostring(stats.debug))
        add_to_chat(158, '  Buffer: ' .. string.format("%.1f", stats.buffer) .. 's (added to cast time)')
        add_to_chat(158, '  Fallback Timeout: ' .. string.format("%.1f", stats.fallback_timeout) .. 's (unknown spells)')
        add_to_chat(158, '  Active: ' .. tostring(stats.active))
        if stats.active then
            local action_type_label = stats.action_type == 'item' and 'Item' or 'Spell'
            local id_label = stats.action_type == 'item' and stats.item_id or stats.spell_id
            add_to_chat(158, '  ' .. action_type_label .. ': ' .. stats.spell_name .. ' (ID: ' .. id_label .. ')')
            add_to_chat(158, '  Cast Time: ' .. string.format("%.1f", stats.cast_time) .. 's')
            add_to_chat(158, '  Timeout: ' .. string.format("%.1f", stats.timeout) .. 's')
            add_to_chat(158, '  Age: ' .. string.format("%.2f", stats.age) .. 's')
        end
    elseif cmd_args[1] == 'on' then
        MidcastWatchdog.enable()
    elseif cmd_args[1] == 'off' then
        MidcastWatchdog.disable()
    elseif cmd_args[1] == 'toggle' then
        MidcastWatchdog.toggle()
    elseif cmd_args[1] == 'debug' then
        MidcastWatchdog.toggle_debug()
    elseif cmd_args[1] == 'buffer' and cmd_args[2] then
        local buffer = tonumber(cmd_args[2])
        if buffer then
            MidcastWatchdog.set_buffer(buffer)
        end
    elseif cmd_args[1] == 'fallback' and cmd_args[2] then
        local fallback = tonumber(cmd_args[2])
        if fallback then
            MidcastWatchdog.set_fallback_timeout(fallback)
        end
    elseif cmd_args[1] == 'clear' then
        MidcastWatchdog.clear_all()
    elseif cmd_args[1] == 'test' then
        -- Test mode: simulate stuck midcast with specific spell ID
        local spell_name = cmd_args[2] or 'Teleport-Holla'
        local spell_id = tonumber(cmd_args[3]) or 262  -- Default: Teleport-Holla (ID 262, 20s cast)
        MidcastWatchdog.simulate_stuck(spell_name, spell_id)
    elseif cmd_args[1] == 'stats' then
        local stats = MidcastWatchdog.get_stats()
        add_to_chat(158, '=== Midcast Watchdog Stats ===')
        add_to_chat(158, '  Enabled: ' .. tostring(stats.enabled))
        add_to_chat(158, '  Debug: ' .. tostring(stats.debug))
        add_to_chat(158, '  Buffer: ' .. string.format("%.1f", stats.buffer) .. 's')
        add_to_chat(158, '  Fallback Timeout: ' .. string.format("%.1f", stats.fallback_timeout) .. 's')
        add_to_chat(158, '  Active Midcast: ' .. tostring(stats.active))
        if stats.active then
            local action_type_label = stats.action_type == 'item' and 'Current Item' or 'Current Spell'
            local id_label = stats.action_type == 'item' and stats.item_id or stats.spell_id
            add_to_chat(158, '  ' .. action_type_label .. ': ' .. stats.spell_name .. ' (ID: ' .. id_label .. ')')
            add_to_chat(158, '  Cast Time: ' .. string.format("%.1f", stats.cast_time) .. 's')
            add_to_chat(158, '  Timeout: ' .. string.format("%.1f", stats.timeout) .. 's')
            add_to_chat(158, '  Age: ' .. string.format("%.2f", stats.age) .. 's')
        end
    else
        add_to_chat(167, '[Watchdog] Commands:')
        add_to_chat(167, '  //gs c watchdog - Show status')
        add_to_chat(167, '  //gs c watchdog on/off - Enable/disable')
        add_to_chat(167, '  //gs c watchdog toggle - Toggle on/off')
        add_to_chat(167, '  //gs c watchdog debug - Toggle debug mode (shows scans)')
        add_to_chat(167, '  //gs c watchdog buffer <sec> - Set buffer (0-10s, added to cast time)')
        add_to_chat(167, '  //gs c watchdog fallback <sec> - Set fallback timeout (0-30s, unknown spells)')
        add_to_chat(167, '  //gs c watchdog clear - Clear all tracked')
        add_to_chat(167, '  //gs c watchdog test [spell] [id] - Simulate stuck midcast (TEST)')
        add_to_chat(167, '  //gs c watchdog stats - Show detailed stats')
        add_to_chat(167, ' ')
        add_to_chat(167, 'Examples:')
        add_to_chat(167, '  //gs c watchdog buffer 2.5 - Use 2.5s safety buffer')
        add_to_chat(167, '  //gs c watchdog test "Teleport-Holla" 262 - Test with Teleport (20s cast)')
        add_to_chat(167, '  //gs c watchdog stats - Show detailed stats')
    end

    if eventArgs then
        eventArgs.handled = true
    end
    return true
end

return WatchdogCommands

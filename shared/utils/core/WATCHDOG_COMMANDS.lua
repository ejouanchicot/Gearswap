---  ═══════════════════════════════════════════════════════════════════════════
---   Watchdog Commands - Command Handler Module
---  ═══════════════════════════════════════════════════════════════════════════
---   Provides command handling for Midcast Watchdog.
---   Import this module in job *_COMMANDS.lua files.
---
---   @file    shared/utils/core/WATCHDOG_COMMANDS.lua
---   @author  Tetsouo
---   @version 3.2 - Style standardization (BRD headers) + remove dead code
---   @date    Created: 2025-10-25 | Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

local WatchdogCommands = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES
---  ═══════════════════════════════════════════════════════════════════════════

local MessageWatchdog = require('shared/utils/messages/formatters/system/message_watchdog')

---  ═══════════════════════════════════════════════════════════════════════════
---   COMMAND CHECKS
---  ═══════════════════════════════════════════════════════════════════════════

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
        MessageWatchdog.show_not_loaded()
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
        MessageWatchdog.show_status(stats)
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
        MessageWatchdog.show_stats(stats)
    else
        MessageWatchdog.show_help()
    end

    if eventArgs then
        eventArgs.handled = true
    end
    return true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return WatchdogCommands

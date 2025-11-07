---============================================================================
--- Watchdog Integration - Mote-Include Hook Integration
---============================================================================
--- Integrates MidcastWatchdog into user job files via Mote hooks.
--- This module should be loaded in each job's main file.
---
--- @file watchdog_integration.lua
--- @author Tetsouo
--- @version 1.1 - Improved formatting
--- @date Created: 2025-10-25 | Updated: 2025-11-06
---============================================================================

local MidcastWatchdog = require('shared/utils/core/midcast_watchdog')
local MessageWatchdog = require('shared/utils/messages/formatters/system/message_watchdog')

local WatchdogIntegration = {}

---============================================================================
--- CONSTANTS
---============================================================================

local CHAT_DEFAULT = 1
local CHAT_ERROR   = 167

---============================================================================
--- STATE
---============================================================================

-- Track if we've already hooked the functions
local hooks_installed = false

---============================================================================
--- HOOK INSTALLATION
---============================================================================

--- Install watchdog hooks into user_env
--- This hooks into midcast/aftercast to track actions
function WatchdogIntegration.install_hooks()
    if hooks_installed then
        return
    end

    -- Start the background watchdog coroutine
    MidcastWatchdog.start()

    hooks_installed = true
end

---============================================================================
--- MANUAL REGISTRATION (called from job files)
---============================================================================

--- Register a midcast action manually
--- Call this from job_post_midcast() to track the action
--- @param spell table Spell/ability data
function WatchdogIntegration.register_midcast(spell)
    if not spell then
        return
    end

    -- Try to find the timestamp in command_registry
    -- This is a bit hacky but necessary since we can't modify GearSwap core
    if _G.command_registry and _G.command_registry.find_by_spell then
        local ts = _G.command_registry:find_by_spell(spell)
        if ts then
            MidcastWatchdog.register_midcast(ts, spell)
        end
    end
end

--- Unregister a midcast action manually
--- Call this from job_aftercast() to stop tracking
--- @param spell table Spell/ability data
function WatchdogIntegration.unregister_midcast(spell)
    if not spell then
        return
    end

    -- Try to find the timestamp in command_registry
    if _G.command_registry and _G.command_registry.find_by_spell then
        local ts = _G.command_registry:find_by_spell(spell)
        if ts then
            MidcastWatchdog.unregister_midcast(ts)
        end
    end
end

---============================================================================
--- COMMAND HANDLERS
---============================================================================

--- Handle watchdog commands
--- @param command string Command name
--- @param args table Command arguments
--- @return boolean handled True if command was handled
function WatchdogIntegration.handle_command(command, args)
    if command == 'watchdog' then
        if not args or #args == 0 then
            -- Show status
            local stats = MidcastWatchdog.get_stats()
            MessageWatchdog.show_status(stats)
        elseif args[1] == 'on' then
            MidcastWatchdog.enable()
        elseif args[1] == 'off' then
            MidcastWatchdog.disable()
        elseif args[1] == 'toggle' then
            MidcastWatchdog.toggle()
        elseif args[1] == 'timeout' and args[2] then
            local timeout = tonumber(args[2])
            if timeout then
                MidcastWatchdog.set_fallback_timeout(timeout)
            end
        elseif args[1] == 'clear' then
            MidcastWatchdog.clear_all()
        elseif args[1] == 'stats' then
            local stats = MidcastWatchdog.get_stats()
            MessageWatchdog.show_stats(stats)
        else
            MessageWatchdog.show_help()
        end
        return true
    end

    return false
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return WatchdogIntegration

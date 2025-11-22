---============================================================================
--- WAR Commands - Custom Command Handling
---============================================================================
--- Handles job-specific custom commands for Warrior job:
---   • Common commands (reload, checksets, waltz, jump, etc.)
---   • UI commands (toggle, update, reload UI)
---   • WAR buff commands (berserk, defender, thirdeye)
---   • State change UI synchronization
---
--- Uses centralized command handlers for consistency across all jobs.
---
--- @file    jobs/war/functions/WAR_COMMANDS.lua
--- @author  Tetsouo
--- @version 2.0.0
--- @date    Created: 2025-09-29
--- @requires utils/ui/UI_COMMANDS, utils/core/COMMON_COMMANDS
---============================================================================
---============================================================================
--- DEPENDENCIES (LAZY LOADING for performance)
---============================================================================
-- Command handlers loaded on first command (saves ~50ms at startup)
local UICommands = nil
local CommonCommands = nil
local WatchdogCommands = nil
local MessageFormatter = nil
local CycleHandler = nil
local MessageCommands = nil

local function ensure_commands_loaded()
    if not UICommands then
        UICommands = require('shared/utils/ui/UI_COMMANDS')
        CommonCommands = require('shared/utils/core/COMMON_COMMANDS')
        WatchdogCommands = require('shared/utils/core/WATCHDOG_COMMANDS')
        CycleHandler = require('shared/utils/core/CYCLE_HANDLER')
MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageCommands = require('shared/utils/messages/formatters/ui/message_commands')
    end
end

---============================================================================
--- COMMAND HANDLER HOOK
---============================================================================

--- Handle job-specific self commands
--- Processes commands in order: Common >> UI >> WAR-specific buffs
---
--- Common commands:
---   • reload         - Reload GearSwap
---   • checksets      - Validate equipment sets
---   • waltz <target> - Perform waltz on target
---   • jump           - Use DRG subjob Jump
---
--- UI commands:
---   • ui             - Toggle UI visibility
---
--- WAR buff commands:
---   • berserk        - Buff with Berserk-focused abilities
---   • defender       - Buff with Defender-focused abilities
---   • thirdeye       - SAM subjob abilities (Hasso/Seigan + Third Eye)
---
--- @param cmdParams table Command parameters array (e.g., {"berserk"})
--- @param eventArgs table Event arguments with handled flag
--- @return void
function job_self_command(cmdParams, eventArgs)
    if not cmdParams[1] then
        return
    end

    -- Lazy load command handlers on first command
    ensure_commands_loaded()

    local command = cmdParams[1]:lower()

    -- ==========================================================================
    -- WATCHDOG COMMANDS
    -- ==========================================================================
    if WatchdogCommands.is_watchdog_command(command) then
        WatchdogCommands.handle_command(cmdParams, eventArgs)
        return
    end

    -- ==========================================================================
    -- DUAL-BOXING: Receive alt job update
    -- ==========================================================================
    if command == 'altjobupdate' then
        local DualBoxManager = require('shared/utils/dualbox/dualbox_manager')
        if cmdParams[2] and cmdParams[3] then
            DualBoxManager.receive_alt_job(cmdParams[2], cmdParams[3])
        end
        eventArgs.handled = true
        return
    end

    -- DUAL-BOXING: Handle job request from MAIN
    -- ==========================================================================
    if command == 'requestjob' then
        local DualBoxManager = require('shared/utils/dualbox/dualbox_manager')
        DualBoxManager.handle_job_request()
        eventArgs.handled = true
        return
    end

    -- ==========================================================================
    -- COMMON COMMANDS (reload, checksets, waltz, etc.)
    -- ==========================================================================
    if CommonCommands.is_common_command(command) then
        -- Extract arguments after command
        local args = {}
        for i = 2, #cmdParams do
            table.insert(args, cmdParams[i])
        end

        if CommonCommands.handle_command(command, 'WAR', table.unpack(args)) then
            eventArgs.handled = true
        end
        return
    end

    -- ==========================================================================
    -- UI COMMANDS (ui toggle, update, reload)
    -- ==========================================================================
    if UICommands.is_ui_command(command) then
        UICommands.handle_ui_command(cmdParams)
        eventArgs.handled = true
        return
    end

    -- ==========================================================================
    -- DEBUG COMMANDS
    -- ==========================================================================
    if command == 'debugmidcast' then
        -- Toggle MidcastManager debug mode
        local MidcastManager = require('shared/utils/midcast/midcast_manager')
        MidcastManager.toggle_debug()

        -- Confirmation message
        MessageCommands.show_debugmidcast_toggled('WAR', _G.MidcastManagerDebugState)

        eventArgs.handled = true
        return
    end

    if command == 'debugretaliation' or command == 'debugretal' then
        -- Toggle Retaliation auto-cancel debug mode
        if toggle_retaliation_debug then
            toggle_retaliation_debug()
        else
            MessageFormatter.show_error('WAR', 'ERROR: Retaliation debug function not available')
        end

        eventArgs.handled = true
        return
    end

    if command == 'retalstatus' then
        -- Show Retaliation tracking status
        if get_retaliation_status then
            local status = get_retaliation_status()
            MessageFormatter.show_info('WAR', 'Retaliation Status:')
            MessageFormatter.show_info('WAR', '  Debug Mode: ' .. tostring(status.debug_mode))
            MessageFormatter.show_info('WAR', '  Tracking: ' .. tostring(status.tracking))
            MessageFormatter.show_info('WAR', '  Elapsed Time: ' .. string.format('%.2f', status.elapsed_time) .. 's / ' .. status.move_duration_needed .. 's')
        else
            MessageFormatter.show_error('WAR', 'ERROR: Retaliation status function not available')
        end

        eventArgs.handled = true
        return
    end

    -- ==========================================================================
    -- CUSTOM CYCLE STATE (UI-aware cycle)
    -- ==========================================================================
    -- Intercepts cycle commands to check UI visibility
    -- If UI visible: custom cycle + UI update (no message)
    -- If UI invisible: delegate to Mote-Include (shows message)

    if command == 'cyclestate' then
        eventArgs.handled = CycleHandler.handle_cyclestate(cmdParams, eventArgs)
        return
    end

    -- ==========================================================================
    -- PERFORMANCE PROFILING COMMANDS
    -- ==========================================================================
    if command == 'perf' then
        local Profiler = require('shared/utils/debug/performance_profiler')
        local M = require('shared/utils/messages/api/messages')
        local subcommand = cmdParams[2] and cmdParams[2]:lower() or 'status'

        if subcommand == 'start' or subcommand == 'on' or subcommand == 'enable' then
            Profiler.enable()
        elseif subcommand == 'stop' or subcommand == 'off' or subcommand == 'disable' then
            Profiler.disable()
        elseif subcommand == 'toggle' then
            Profiler.toggle()
        elseif subcommand == 'status' then
            Profiler.status()
        else
            M.send('PROFILER', 'usage')
        end

        eventArgs.handled = true
        return
    end

    -- ==========================================================================
    -- WAR-SPECIFIC BUFF COMMANDS
    -- ==========================================================================

    -- Berserk mode: Buff WAR abilities excluding Defender
    if command == 'berserk' then
        if buff_war then
            buff_war('Berserk')
            eventArgs.handled = true
        end
        return
    end

    -- Defender mode: Buff WAR abilities excluding Berserk
    if command == 'defender' then
        if buff_war then
            buff_war('Defender')
            eventArgs.handled = true
        end
        return
    end

    -- SAM subjob: Hasso/Seigan + Third Eye
    if command == 'thirdeye' then
        if buff_sam_sub then
            buff_sam_sub()
            eventArgs.handled = true
        end
        return
    end
end

---============================================================================
--- STATE CHANGE HOOK
---============================================================================

--- Update UI when state changes (MainWeapon, HybridMode, etc.)
--- Called by Mote-Include after any state change.
---
--- @param stateField string State that changed (e.g., "MainWeapon")
--- @param newValue   string New value
--- @param oldValue   string Previous value
--- @return void
function job_state_change(stateField, newValue, oldValue)
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        KeybindUI.update()
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.job_self_command = job_self_command
_G.job_state_change = job_state_change

-- Export as module (for future require() usage)
return {
    job_self_command = job_self_command,
    job_state_change = job_state_change
}

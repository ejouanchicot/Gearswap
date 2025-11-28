---============================================================================
--- SAM Commands Module - Command Handling
---============================================================================
--- Handles job-specific custom commands for Samurai job:
---   • Common commands (reload, checksets, waltz, jump, etc.)
---   • UI commands (toggle, update, reload UI)
---   • SAM buff commands (hasso, seigan, thirdeye)
---   • State change UI synchronization
---
--- @file SAM_COMMANDS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-21
---============================================================================

---============================================================================
--- DEPENDENCIES (LAZY LOADING for performance)
---============================================================================
-- Command handlers loaded on first command (saves ~50ms at startup)
local UICommands = nil
local CommonCommands = nil
local WatchdogCommands = nil
local CycleHandler = nil
local MessageCommands = nil

local function ensure_commands_loaded()
    if not UICommands then
        UICommands = require('shared/utils/ui/UI_COMMANDS')
        CommonCommands = require('shared/utils/core/COMMON_COMMANDS')
        WatchdogCommands = require('shared/utils/core/WATCHDOG_COMMANDS')
        CycleHandler = require('shared/utils/core/CYCLE_HANDLER')
        MessageCommands = require('shared/utils/messages/formatters/ui/message_commands')
    end
end

---============================================================================
--- COMMAND HANDLER HOOK
---============================================================================

--- Handle job-specific self commands
--- @param cmdParams table Command parameters array
--- @param eventArgs table Event arguments with handled flag
function job_self_command(cmdParams, eventArgs)
    if not cmdParams or #cmdParams == 0 then
        return
    end

    -- Lazy load command handlers on first command
    ensure_commands_loaded()

    local command = cmdParams[1]:lower()

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
    -- WATCHDOG COMMANDS
    -- ==========================================================================
    if WatchdogCommands.is_watchdog_command(command) then
        if WatchdogCommands.handle_command(cmdParams, eventArgs) then
            eventArgs.handled = true
        end
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

        if CommonCommands.handle_command(command, 'SAM', table.unpack(args)) then
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
        MessageCommands.show_debugmidcast_toggled('SAM', _G.MidcastManagerDebugState)

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
    -- SAM-SPECIFIC COMMANDS
    -- ==========================================================================
    -- Add SAM-specific commands here if needed
end

---============================================================================
--- STATE CHANGE HOOK
---============================================================================

--- Update UI when state changes (MainWeapon, SubWeapon, HybridMode, etc.)
--- Called by Mote-Include after any state change.
---
--- @param stateField string State that changed (e.g., "MainWeapon")
--- @param newValue   string New value
--- @param oldValue   string Previous value
function job_state_change(stateField, newValue, oldValue)
    -- Skip UI update for Moving state (handled by AutoMove with flag)
    if stateField == 'Moving' then
        return
    end

    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        KeybindUI.update()
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

_G.job_self_command = job_self_command
_G.job_state_change = job_state_change

local SAM_COMMANDS = {}
SAM_COMMANDS.job_self_command = job_self_command
SAM_COMMANDS.job_state_change = job_state_change

return SAM_COMMANDS

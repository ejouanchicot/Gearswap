---  ═══════════════════════════════════════════════════════════════════════════
---   DNC Commands - Custom Command Handling
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles job-specific custom commands for Dancer job.
---
---   Features:
---   • Common commands integration (reload, checksets, waltz, aoewaltz, jump)
---   • UI commands (ui, showbinds)
---   • Smartbuff command (selected dance + subjob buff automation)
---   • Step command with Presto integration
---   • Dance command (state.Dance: Saber Dance / Fan Dance)
---   • State change UI updates
---
---   Dependencies:
---   • UICommands - centralized UI command handling
---   • CommonCommands - universal job commands
---   • StepManager (logic) - Step + Presto management
---   • SmartbuffManager (logic) - Dance + subjob buff automation
---
---   @file    jobs/dnc/functions/DNC_COMMANDS.lua
---   @author  Tetsouo
---   @version 2.0 - Logic Extracted to logic/
---   @date    Created: 2025-10-04
---   @date    Updated: 2025-10-06
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════
-- Command handlers loaded on first command
local UICommands = nil
local CommonCommands = nil
local WatchdogCommands = nil
local CycleHandler = nil
local MessageCommands = nil
local StepManager = nil
local SmartbuffManager = nil

local function ensure_commands_loaded()
    if not UICommands then
        UICommands = require('shared/utils/ui/UI_COMMANDS')
        CommonCommands = require('shared/utils/core/COMMON_COMMANDS')
        WatchdogCommands = require('shared/utils/core/WATCHDOG_COMMANDS')
        CycleHandler = require('shared/utils/core/CYCLE_HANDLER')
        MessageCommands = require('shared/utils/messages/formatters/ui/message_commands')

        -- Load DNC logic modules
        StepManager = require('shared/jobs/dnc/functions/logic/step_manager')
        SmartbuffManager = require('shared/jobs/dnc/functions/logic/smartbuff_manager')
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   JOB SELF COMMAND HANDLER
---  ═══════════════════════════════════════════════════════════════════════════

---   Handle job-specific self commands
---   @param cmdParams table Command parameters array
---   @param eventArgs table Event arguments with handled flag
function job_self_command(cmdParams, eventArgs)
    if not cmdParams[1] then return end

    -- Lazy load command handlers on first command
    ensure_commands_loaded()

    local command = cmdParams[1]:lower()

    -- ══════════════════════════════════════════════════════════════════════════
    -- DUAL-BOXING: Receive alt job update
    -- ══════════════════════════════════════════════════════════════════════════
    if command == 'altjobupdate' then
        local DualBoxManager = require('shared/utils/dualbox/dualbox_manager')
        if cmdParams[2] and cmdParams[3] then
            DualBoxManager.receive_alt_job(cmdParams[2], cmdParams[3], cmdParams[4], cmdParams[5])
        end
        eventArgs.handled = true
        return
    end

    -- DUAL-BOXING: Handle job request from MAIN
    -- ══════════════════════════════════════════════════════════════════════════
    if command == 'requestjob' then
        local DualBoxManager = require('shared/utils/dualbox/dualbox_manager')
        DualBoxManager.handle_job_request()
        eventArgs.handled = true
        return
    end

    -- Watchdog commands
    if WatchdogCommands.is_watchdog_command(command) then
        if WatchdogCommands.handle_command(cmdParams, eventArgs) then
            eventArgs.handled = true
        end
        return
    end

    -- Common commands (reload, checksets, etc.)
    if CommonCommands.is_common_command(command) then
        -- Pass all arguments after command
        local args = {}
        for i = 2, #cmdParams do
            table.insert(args, cmdParams[i])
        end
        if CommonCommands.handle_command(command, 'DNC', table.unpack(args)) then
            eventArgs.handled = true
        end
        return
    end

    -- UI commands (centralized handler)
    if UICommands.is_ui_command(command) then
        UICommands.handle_ui_command(cmdParams)
        eventArgs.handled = true
        return
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- DEBUG COMMANDS
    -- ══════════════════════════════════════════════════════════════════════════
    if command == 'debugmidcast' then
        -- Toggle MidcastManager debug mode
        local MidcastManager = require('shared/utils/midcast/midcast_manager')
        MidcastManager.toggle_debug()

        -- Confirmation message
        MessageCommands.show_debugmidcast_toggled('DNC', _G.MidcastManagerDebugState)

        eventArgs.handled = true
        return
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- CUSTOM CYCLE STATE (UI-aware cycle)
    -- ══════════════════════════════════════════════════════════════════════════
    -- Intercepts cycle commands to check UI visibility
    -- If UI visible: custom cycle + UI update (no message)
    -- If UI invisible: delegate to Mote-Include (shows message)

    if command == 'cyclestate' then
        eventArgs.handled = CycleHandler.handle_cyclestate(cmdParams, eventArgs)
        return
    end

    -- DNC-specific commands
    if command == 'smartbuff' or command == 'buffself' then
        SmartbuffManager.apply()
        eventArgs.handled = true
        return
    end

    -- Step command with Presto integration
    if command == 'step' then
        StepManager.execute_step()
        eventArgs.handled = true
        return
    end

    -- Dance command (uses state.Dance to determine which dance to activate)
    if command == 'fandance' or command == 'dance' then
        SmartbuffManager.apply_dance()
        eventArgs.handled = true
        return
    end

    -- Waltz commands are now handled by COMMON_COMMANDS (centralized for all jobs with DNC main/sub)
    -- This allows WAR/DNC, NIN/DNC, etc. to use //gs c waltz and //gs c aoewaltz

    -- Additional DNC commands can be added here
    -- Example: samba rotation, etc.
end

---  ═══════════════════════════════════════════════════════════════════════════
---   STATE CHANGE HANDLER
---  ═══════════════════════════════════════════════════════════════════════════

---   Update UI when state changes
---   Called after state changes to update UI display
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

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Make functions available globally for GearSwap
_G.job_self_command = job_self_command
_G.job_state_change = job_state_change


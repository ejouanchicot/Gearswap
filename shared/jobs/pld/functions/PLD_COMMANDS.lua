---============================================================================
--- PLD Commands - Custom Command Handling
---============================================================================
--- Handles job-specific custom commands for Paladin job:
---   • Common commands (reload, checksets, waltz, jump, etc.)
---   • UI commands (toggle, update, reload UI)
---   • PLD-specific commands (aoe, rune)
---   • State change UI synchronization
---
--- Uses centralized command handlers for consistency across all jobs.
---
--- @file    jobs/pld/functions/PLD_COMMANDS.lua
--- @author  Tetsouo
--- @version 3.0.0 - Logic Extracted to logic/
--- @date    Created: 2025-10-03 | Updated: 2025-10-06
--- @requires utils/ui/UI_COMMANDS, utils/core/COMMON_COMMANDS
---============================================================================
---============================================================================
--- DEPENDENCIES
---============================================================================
-- Centralized command handlers
local UICommands = require('shared/utils/ui/UI_COMMANDS')
local CommonCommands = require('shared/utils/core/COMMON_COMMANDS')
local WatchdogCommands = require('shared/utils/core/WATCHDOG_COMMANDS')

-- PLD logic modules
local AOEManager = require('shared/jobs/pld/functions/logic/aoe_manager')
local RuneManager = require('shared/jobs/pld/functions/logic/rune_manager')

---============================================================================
--- COMMAND HANDLER HOOK
---============================================================================

--- Handle job-specific self commands
--- Processes commands in order: Common → UI → PLD-specific
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
--- PLD-specific commands:
---   • aoe            - Execute Blue Magic AOE spell rotation (PLD/BLU)
---   • rune           - Execute Rune ability (PLD/RUN)
---
--- @param cmdParams table Command parameters array (e.g., {"aoe"})
--- @param eventArgs table Event arguments with handled flag
--- @return void
function job_self_command(cmdParams, eventArgs)
    if not cmdParams[1] then
        return
    end

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

        if CommonCommands.handle_command(command, 'PLD', table.unpack(args)) then
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
        add_to_chat(159, '[PLD_COMMANDS] Debug toggled! Current state: ' .. tostring(_G.MidcastManagerDebugState))

        eventArgs.handled = true
        return
    end


    -- ==========================================================================
    -- PLD-SPECIFIC COMMANDS
    -- ==========================================================================

    -- AOE: Execute Blue Magic AOE spell rotation (PLD/BLU)
    if command == 'aoe' then
        if AOEManager then
            AOEManager.execute_aoe()
            eventArgs.handled = true
        end
        return
    end

    -- Rune: Execute Rune ability (PLD/RUN)
    if command == 'rune' then
        if RuneManager then
            RuneManager.execute_rune()
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

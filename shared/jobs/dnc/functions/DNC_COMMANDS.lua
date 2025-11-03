---============================================================================
--- DNC Commands - Custom Command Handling
---============================================================================
--- Handles job-specific custom commands for Dancer job.
---
--- Features:
---   • Common commands integration (reload, checksets, waltz, aoewaltz, jump)
---   • UI commands (ui, showbinds)
---   • Smartbuff command (subjob buff automation)
---   • Step command with Presto integration
---   • Fan Dance toggle command
---   • State change UI updates
---
--- Dependencies:
---   • UICommands - centralized UI command handling
---   • CommonCommands - universal job commands
---   • StepManager (logic) - Step + Presto management
---
--- @file    jobs/dnc/functions/DNC_COMMANDS.lua
--- @author  Tetsouo
--- @version 2.0 - Logic Extracted to logic/
--- @date    Created: 2025-10-04
--- @date    Updated: 2025-10-06
---============================================================================

-- Load centralized command handlers
local UICommands = require('shared/utils/ui/UI_COMMANDS')
local CommonCommands = require('shared/utils/core/COMMON_COMMANDS')
local WatchdogCommands = require('shared/utils/core/WATCHDOG_COMMANDS')

-- Load DNC logic modules
local StepManager = require('shared/jobs/dnc/functions/logic/step_manager')

---============================================================================
--- JOB SELF COMMAND HANDLER
---============================================================================

--- Handle job-specific self commands
--- @param cmdParams table Command parameters array
--- @param eventArgs table Event arguments with handled flag
function job_self_command(cmdParams, eventArgs)
    if not cmdParams[1] then return end

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

    -- Watchdog commands
    if WatchdogCommands.is_watchdog_command(command) then
        if WatchdogCommands.handle_command(cmdParams, eventArgs) then
            eventArgs.handled = true
        end
        return
    end

    -- Common commands (reload, checksets, setregion, etc.)
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

    -- ==========================================================================
    -- DEBUG COMMANDS
    -- ==========================================================================
    if command == 'debugmidcast' then
        -- Toggle MidcastManager debug mode
        local MidcastManager = require('shared/utils/midcast/midcast_manager')
        MidcastManager.toggle_debug()

        -- Confirmation message
        add_to_chat(159, '[DNC_COMMANDS] Debug toggled! Current state: ' .. tostring(_G.MidcastManagerDebugState))

        eventArgs.handled = true
        return
    end

    -- DNC-specific commands
    if command == 'smartbuff' then
        if apply_smartbuff then
            apply_smartbuff()
            eventArgs.handled = true
        else
            local MessageFormatter = require('shared/utils/messages/message_formatter')
            MessageFormatter.show_error('Smartbuff function not loaded')
        end
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
        local dance_name = (state.Dance and state.Dance.current) or "Fan Dance"

        -- Check cooldown before activating
        local recast_id = 0
        if dance_name == "Saber Dance" then
            recast_id = 191  -- Saber Dance recast ID
        elseif dance_name == "Fan Dance" then
            recast_id = 192  -- Fan Dance recast ID
        end

        -- Get recast time
        local recast = windower.ffxi.get_ability_recasts()[recast_id]

        if recast and recast > 0 then
            -- Ability on cooldown, show cooldown warning and DO NOT execute
            local MessageFormatter = require('shared/utils/messages/message_formatter')
            MessageFormatter.show_ability_cooldown(dance_name, recast)
            -- DO NOT send command - ability is on cooldown
        else
            -- Ability ready, execute (game will show native feedback)
            send_command('input /ja "' .. dance_name .. '" <me>')
        end

        eventArgs.handled = true
        return
    end

    -- Waltz commands are now handled by COMMON_COMMANDS (centralized for all jobs with DNC main/sub)
    -- This allows WAR/DNC, NIN/DNC, etc. to use //gs c waltz and //gs c aoewaltz

    -- Additional DNC commands can be added here
    -- Example: samba rotation, etc.
end

---============================================================================
--- STATE CHANGE HANDLER
---============================================================================

--- Update UI when state changes
--- Called after state changes to update UI display
function job_state_change(stateField, newValue, oldValue)
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        KeybindUI.update()
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Make functions available globally for GearSwap
_G.job_self_command = job_self_command
_G.job_state_change = job_state_change

-- Also export as module for potential future use
local DNC_COMMANDS = {}
DNC_COMMANDS.job_self_command = job_self_command
DNC_COMMANDS.job_state_change = job_state_change

return DNC_COMMANDS

---============================================================================
--- WHM Commands Module - Command Handling & State Change Monitoring
---============================================================================
--- Handles user commands for White Mage:
---   • UI commands (ui, ui h, ui show, ui hide, ui toggle, ui update, ui reload)
---   • Common commands (reload, checksets, waltz, aoewaltz)
---   • WHM-specific commands (if any)
---   • State cycling commands (automatically handled by Mote-Include)
---   • State change monitoring (updates UI when states change)
---
--- @file WHM_COMMANDS.lua
--- @author Tetsouo
--- @version 1.0.0
--- @date Created: 2025-10-21
---============================================================================

---============================================================================
--- DEPENDENCIES (LAZY LOADING for performance)
---============================================================================
-- Command handlers loaded on first command (saves ~60ms at startup)
local UICommands = nil
local CommonCommands = nil
local WatchdogCommands = nil
local CycleHandler = nil
local MessageCommands = nil
local WHMMessageFormatter = nil

local function ensure_commands_loaded()
    if not UICommands then
        UICommands = require('shared/utils/ui/UI_COMMANDS')
        CommonCommands = require('shared/utils/core/COMMON_COMMANDS')
        WatchdogCommands = require('shared/utils/core/WATCHDOG_COMMANDS')
        CycleHandler = require('shared/utils/core/CYCLE_HANDLER')
        MessageCommands = require('shared/utils/messages/formatters/ui/message_commands')

        -- WHM message formatter
        local formatter_success
        formatter_success, WHMMessageFormatter = pcall(require, 'shared/utils/whm/whm_message_formatter')
        if not formatter_success then
            WHMMessageFormatter = nil
        end
    end
end

---============================================================================
--- COMMAND HANDLER
---============================================================================

--- Handle user commands via //gs c <command>
---
--- @param cmdParams table Command parameters (cmdParams[1] = command name)
--- @param eventArgs table Event arguments (contains .handled flag)
--- @return void
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
    -- COMMON COMMANDS (reload, checksets, waltz, aoewaltz, jump)
    -- ==========================================================================
    if CommonCommands.is_common_command(command) then
        if CommonCommands.handle_command(command, 'WHM') then
            eventArgs.handled = true
        end
        return
    end

    -- ==========================================================================
    -- UI COMMANDS (ui, ui h, ui show, ui hide, ui toggle, ui update, ui reload)
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
        MessageCommands.show_debugmidcast_toggled('WHM', _G.MidcastManagerDebugState)

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
    -- WHM-SPECIFIC COMMANDS
    -- ==========================================================================

    -- Afflatus: Auto-cast current Afflatus stance
    if command == 'afflatus' then
        local stance = state.AfflatusMode.value

        if stance == 'Solace' then
            send_command('input /ja "Afflatus Solace" <me>')
            if WHMMessageFormatter then
                WHMMessageFormatter.show_afflatus_change('Solace')
            end
        elseif stance == 'Misery' then
            send_command('input /ja "Afflatus Misery" <me>')
            if WHMMessageFormatter then
                WHMMessageFormatter.show_afflatus_change('Misery')
            end
        end
        eventArgs.handled = true
        return
    end
end

---============================================================================
--- STATE CHANGE HOOK
---============================================================================

--- Called when a state variable changes (OffenseMode, IdleMode, etc.)
--- Handles weapon locking for melee mode AND updates UI.
---
--- @param stateField string State field that changed ('Offense Mode', 'Idle Mode', etc.)
--- @param newValue string New value of the state
--- @param oldValue string Old value of the state
--- @return void
function job_state_change(stateField, newValue, oldValue)
    -- ==========================================================================
    -- COMBAT MODE - WEAPON LOCK (RDM-style)
    -- ==========================================================================
    -- When CombatMode = 'On', lock weapons to prevent accidental swaps
    if stateField == 'Combat Mode' then
        if newValue == 'On' then
            disable('main', 'sub', 'range', 'ammo')
        else
            enable('main', 'sub', 'range', 'ammo')
        end
    end

    -- ==========================================================================
    -- OFFENSE MODE - WEAPON LOCK (Legacy - kept for compatibility)
    -- ==========================================================================
    -- When switching to Melee ON, lock weapons to prevent accidental swaps
    if stateField == 'Offense Mode' then
        if newValue == 'Melee ON' then
            disable('main', 'sub', 'range')
        else
            enable('main', 'sub', 'range')
        end
    end

    -- ==========================================================================
    -- UI UPDATE (for all state changes)
    -- ==========================================================================
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

-- Export as module
return {
    job_self_command = job_self_command,
    job_state_change = job_state_change
}

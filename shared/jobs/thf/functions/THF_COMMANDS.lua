---============================================================================
--- THF Commands Module - Custom Command Handling
---============================================================================
--- Handles custom commands for Thief job via //gs c syntax.
---
--- Features:
---   • Common commands (reload, checksets, setregion via COMMON_COMMANDS)
---   • UI commands (ui toggle, visibility via UI_COMMANDS)
---   • THF-specific commands (smartbuff, fbc, range)
---   • Ranged weapon lock with auto-attack (one-way: equip → lock → /ra)
---   • State change UI updates (automatic refresh)
---   • Future: TH tracking commands, SA/TA management commands
---
--- Commands:
---   • //gs c reload         - Reload THF configuration
---   • //gs c checksets      - Validate equipment sets
---   • //gs c smartbuff      - Apply subjob-specific buffs
---   • //gs c fbc            - Apply Fighter's Buff Combo (Feint/Bully/Conspirator)
---   • //gs c range          - Equip + lock ranged + attack <stnpc> (one-way)
---   • //gs c ui             - Toggle UI visibility
---
--- Dependencies:
---   • CommonCommands (universal commands: reload, checksets, etc.)
---   • UICommands (UI toggle and management)
---   • SmartbuffManager (subjob-specific buff automation)
---
--- @file    jobs/thf/functions/THF_COMMANDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-06
---============================================================================

-- Load centralized command handlers
local UICommands = require('shared/utils/ui/UI_COMMANDS')
local CommonCommands = require('shared/utils/core/COMMON_COMMANDS')
local WatchdogCommands = require('shared/utils/core/WATCHDOG_COMMANDS')

-- Load THF logic modules
local SmartbuffManager = require('shared/jobs/thf/functions/logic/smartbuff_manager')

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
        if CommonCommands.handle_command(command, 'THF', table.unpack(args)) then
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
        add_to_chat(159, '[THF_COMMANDS] Debug toggled! Current state: ' .. tostring(_G.MidcastManagerDebugState))

        eventArgs.handled = true
        return
    end

    -- THF-specific commands
    if command == 'smartbuff' then
        SmartbuffManager.apply()
        eventArgs.handled = true
        return
    end

    if command == 'fbc' then
        SmartbuffManager.apply_fbc()
        eventArgs.handled = true
        return
    end

    -- Range weapon lock with auto-attack (one-way, no toggle)
    if command == 'range' then
        -- CRITICAL ORDER: Equip → Lock → State → UI Update → Attack
        -- 1. Equip ranged setup FIRST (before locking slots)
        equip({ range = "Exalted Crossbow", ammo = "Acid Bolt" })

        -- 2. Lock slots AFTER equipping (prevents future swaps)
        disable('range', 'ammo')

        -- 3. Set RangeLock state to ON
        if state.RangeLock then
            state.RangeLock:set(true)
        end

        -- 4. Update UI to reflect state change
        local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
        if ui_success and KeybindUI then
            KeybindUI.update()
        end

        -- 5. Auto-attack sub-target (0.1s delay - minimal for equipment swap)
        send_command('wait 0.1; input /ra <stnpc>')

        local MessageFormatter_success, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if MessageFormatter_success and MessageFormatter then
            MessageFormatter.show_success("Ranged attack: Exalted Crossbow + Acid Bolt → <stnpc>")
        end

        eventArgs.handled = true
        return
    end

    -- Future: Additional THF-specific commands
    -- - 'th' for Treasure Hunter tracking
    -- - 'sata' for SA/TA management
end

--- Update UI when state changes
--- Called after state changes to update UI display
function job_state_change(stateField, newValue, oldValue)
    -- Handle RangeLock state changes
    if stateField == 'Range Lock' then
        if newValue == false or newValue == 'false' then
            -- Unlock ranged weapon slots when state toggled to OFF
            enable('range', 'ammo')
            local MessageFormatter_success, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
            if MessageFormatter_success and MessageFormatter then
                MessageFormatter.show_success("Ranged weapons unlocked")
            end
        end
    end

    -- Update UI
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

-- Also export as module
local THF_COMMANDS = {}
THF_COMMANDS.job_self_command = job_self_command
THF_COMMANDS.job_state_change = job_state_change

return THF_COMMANDS

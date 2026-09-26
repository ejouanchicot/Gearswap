---  ═══════════════════════════════════════════════════════════════════════════
---   BLU Commands Module - Custom Command Handling
---  ═══════════════════════════════════════════════════════════════════════════
---   //gs c commands for Blue Mage. BLU has no command of its own: this
---   routes to the shared handlers.
---
---   Order: dual-box (altjobupdate, requestjob) >> watchdog >> common
---   (reload, checksets, warp...) >> UI >> debugmidcast >> cyclestate.
---
---   @file    shared/jobs/blu/functions/BLU_COMMANDS.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-09-26
---  ═══════════════════════════════════════════════════════════════════════════

local UICommands = nil
local CommonCommands = nil
local WatchdogCommands = nil
local CycleHandler = nil
local MessageCommands = nil

local function ensure_commands_loaded()
    if UICommands then return end
    UICommands = require('shared/utils/ui/UI_COMMANDS')
    CommonCommands = require('shared/utils/core/COMMON_COMMANDS')
    WatchdogCommands = require('shared/utils/core/WATCHDOG_COMMANDS')
    CycleHandler = require('shared/utils/core/CYCLE_HANDLER')
    MessageCommands = require('shared/utils/messages/formatters/ui/message_commands')
end

---  ═══════════════════════════════════════════════════════════════════════════
---   JOB SELF COMMAND HANDLER
---  ═══════════════════════════════════════════════════════════════════════════

---   Handle job self commands (router)
---   @param cmdParams table Command parameters array
---   @param eventArgs table Event arguments with handled flag
function job_self_command(cmdParams, eventArgs)
    if not cmdParams[1] then return end
    ensure_commands_loaded()
    local command = cmdParams[1]:lower()

    if command == 'altjobupdate' then
        local DualBoxManager = require('shared/utils/dualbox/dualbox_manager')
        if cmdParams[2] and cmdParams[3] then
            DualBoxManager.receive_alt_job(cmdParams[2], cmdParams[3], cmdParams[4], cmdParams[5], cmdParams[6], cmdParams[7])
        end
        eventArgs.handled = true
        return
    end

    if command == 'requestjob' then
        require('shared/utils/dualbox/dualbox_manager').handle_job_request()
        eventArgs.handled = true
        return
    end

    if WatchdogCommands.is_watchdog_command(command) then
        if WatchdogCommands.handle_command(cmdParams, eventArgs) then
            eventArgs.handled = true
        end
        return
    end

    if CommonCommands.is_common_command(command) then
        local args = {}
        for i = 2, #cmdParams do
            args[#args + 1] = cmdParams[i]
        end
        if CommonCommands.handle_command(command, 'BLU', table.unpack(args)) then
            eventArgs.handled = true
        end
        return
    end

    if UICommands.is_ui_command(command) then
        UICommands.handle_ui_command(cmdParams)
        eventArgs.handled = true
        return
    end

    if command == 'debugmidcast' then
        require('shared/utils/midcast/midcast_manager').toggle_debug()
        MessageCommands.show_debugmidcast_toggled('BLU', _G.MidcastManagerDebugState)
        eventArgs.handled = true
        return
    end

    -- UI-aware cycle: silent HUD update when the HUD is shown, Mote's message otherwise
    if command == 'cyclestate' then
        eventArgs.handled = CycleHandler.handle_cyclestate(cmdParams, eventArgs)
        return
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   STATE CHANGE HOOK
---  ═══════════════════════════════════════════════════════════════════════════

--- BLU adds nothing of its own: the shared handler repaints the HUD.
local LifecycleManager = require('shared/utils/core/lifecycle_manager')

job_state_change = LifecycleManager.state_change()

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_self_command = job_self_command
_G.job_state_change = job_state_change

return {
    job_self_command = job_self_command,
    job_state_change = job_state_change,
}

---  ═══════════════════════════════════════════════════════════════════════════
---   PUP Commands Module - Custom Command Handling
---  ═══════════════════════════════════════════════════════════════════════════
---   //gs c commands for Puppetmaster.
---
---   Job command:
---     petmode          automaton head / frame, the Pet Mode they give, the
---                      Pet Mode in use, Pet WS, the automaton's TP
---     petmode auto     set Pet Mode from the head again (ends a value
---                      cycled by hand)
---
---   Order: dual-box (altjobupdate, requestjob) >> petmode >> watchdog >>
---   common (reload, checksets, warp...) >> UI >> debugmidcast >> cyclestate.
---
---   @file    shared/jobs/pup/functions/PUP_COMMANDS.lua
---   @author  ejouanchicot
---   @version 2.0
---   @date    Created: 2026-09-29
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
---   PETMODE
---  ═══════════════════════════════════════════════════════════════════════════

--- //gs c petmode [auto]: show the automaton block, after re-detecting when
--- asked.
--- @param arg string|nil 'auto' to set Pet Mode from the head again
local function handle_petmode_command(arg)
    local Automaton = require('shared/jobs/pup/functions/logic/automaton')
    local PetWS = require('shared/jobs/pup/functions/logic/pet_ws')
    if arg and arg:lower() == 'auto' then
        Automaton.refresh_mode(true)
        send_command('gs c update')
    end
    local head, frame = Automaton.parts()
    local detected = Automaton.mode_for(head, frame)
    local out = Automaton.is_out()
    require('shared/utils/messages/info_block').show({
        tag = 'PUP', title = 'Automaton',
        fields = {
            {'Head', head or 'unknown', not head and 'dim' or nil},
            {'Frame', frame or 'unknown', not frame and 'dim' or nil},
            {'Head gives', detected or 'no mode', detected and 'good' or 'warn'},
            {'Pet Mode', state.PetMode and state.PetMode.current or '?'},
            {'Pet WS', PetWS.enabled()},
            {'Automaton', out and (Automaton.is_engaged() and 'fighting' or 'out') or 'not out', not out and 'dim' or nil},
            {'TP', out and (Automaton.tp() .. ' / ' .. PetWS.threshold()) or '-', PetWS.is_due() and 'good' or nil},
        },
        lines = {{'//gs c petmode auto: Pet Mode from the head again', 'dim'}},
    })
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

    if command == 'petmode' then
        handle_petmode_command(cmdParams[2])
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
        if CommonCommands.handle_command(command, 'PUP', table.unpack(args)) then
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
        MessageCommands.show_debugmidcast_toggled('PUP', _G.MidcastManagerDebugState)
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

--- PUP adds nothing of its own: the shared handler repaints the HUD.
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

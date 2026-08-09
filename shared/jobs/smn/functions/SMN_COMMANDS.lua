---  ═══════════════════════════════════════════════════════════════════════════
---   SMN Commands Module - //gs c dispatcher
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles SMN-specific commands plus standard infrastructure (common
---   commands, watchdog, UI commands, cycle handler, dual-box IPC).
---
---   SMN-specific commands:
---     smn summon <Avatar>     - Cast a summon spell
---     smn astralflow          - /ja "Astral Flow" <me>
---     smn astralconduit       - /ja "Astral Conduit" <me>
---     smn apogee              - /ja "Apogee" <me>
---     smn siphon              - /ja "Elemental Siphon" <me>
---     smn manacede            - /ja "Mana Cede" <me>
---     smn favor               - /ja "Avatar's Favor" <me>
---     smn release             - /ja "Release" <me>
---     smn assault             - /ja "Assault" <t>
---     smn retreat             - /ja "Retreat" <me>
---     smn bp <Name>           - Generic Blood Pact trigger (/pet "<Name>" <t> or <me>)
---
---   @file    shared/jobs/smn/functions/SMN_COMMANDS.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-28
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING
---  ═══════════════════════════════════════════════════════════════════════════

local MessageFormatter = nil
local CommonCommands = nil
local WatchdogCommands = nil
local UICommands = nil
local CycleHandler = nil
local MessageCommands = nil
local BloodPactClassifier = nil

local function ensure_commands_loaded()
    if MessageFormatter then return end

    MessageFormatter = require('shared/utils/messages/message_formatter')

    local _, cc = pcall(require, 'shared/utils/core/COMMON_COMMANDS')
    CommonCommands = cc

    local _, wd = pcall(require, 'shared/utils/core/WATCHDOG_COMMANDS')
    WatchdogCommands = wd

    local _, ui = pcall(require, 'shared/utils/ui/UI_COMMANDS')
    UICommands = ui

    local _, ch = pcall(require, 'shared/utils/core/CYCLE_HANDLER')
    CycleHandler = ch

    MessageCommands = require('shared/utils/messages/formatters/ui/message_commands')

    local _, bpc = pcall(require, 'shared/jobs/smn/functions/logic/blood_pact_classifier')
    BloodPactClassifier = bpc
end

---  ═══════════════════════════════════════════════════════════════════════════
---   STATIC DATA
---  ═══════════════════════════════════════════════════════════════════════════

-- Known avatar names (canonical form for /ma summon spell)
local KNOWN_AVATARS = {
    ['carbuncle'] = 'Carbuncle',
    ['ifrit']     = 'Ifrit',
    ['shiva']     = 'Shiva',
    ['garuda']    = 'Garuda',
    ['titan']     = 'Titan',
    ['ramuh']     = 'Ramuh',
    ['leviathan'] = 'Leviathan',
    ['fenrir']    = 'Fenrir',
    ['diabolos']  = 'Diabolos',
    ['cait sith'] = 'Cait Sith',
    ['caitsith']  = 'Cait Sith',
    ['siren']     = 'Siren',
    ['atomos']    = 'Atomos',
    ['alexander'] = 'Alexander',
    ['odin']      = 'Odin',

    -- Spirits
    ['light spirit']    = 'Light Spirit',
    ['fire spirit']     = 'Fire Spirit',
    ['ice spirit']      = 'Ice Spirit',
    ['air spirit']      = 'Air Spirit',
    ['earth spirit']    = 'Earth Spirit',
    ['thunder spirit']  = 'Thunder Spirit',
    ['water spirit']    = 'Water Spirit',
    ['dark spirit']     = 'Dark Spirit',
}

-- Single-word JA shortcuts -> full action command
local JA_SHORTCUTS = {
    astralflow    = { name = 'Astral Flow',     target = '<me>' },
    astralconduit = { name = 'Astral Conduit',  target = '<me>' },
    apogee        = { name = 'Apogee',          target = '<me>' },
    siphon        = { name = 'Elemental Siphon', target = '<me>' },
    manacede      = { name = 'Mana Cede',       target = '<me>' },
    favor         = { name = "Avatar's Favor",  target = '<me>' },
    release       = { name = 'Release',         target = '<me>' },
    assault       = { name = 'Assault',         target = '<t>'  },
    retreat       = { name = 'Retreat',         target = '<me>' },
}

---  ═══════════════════════════════════════════════════════════════════════════
---   SUMMONING MAGIC SKILLUP LOOP
---  ═══════════════════════════════════════════════════════════════════════════
---   Toggleable skill-up loop: Summon Siren -> Release -> Summon -> Release...
---
---   The counter pattern (incremented on every stop) invalidates any pending
---   coroutines so a stop+restart cannot result in two parallel loops.
---  ═══════════════════════════════════════════════════════════════════════════

local SKILLUP_STATE = {
    active  = false,
    counter = 0,    -- incremented every stop to invalidate scheduled coroutines
    -- Tunable timing knobs:
    cast_to_release_delay  = 5.0,  -- summon cast time + buffer
    release_to_next_delay  = 1.5,  -- recast is near-instant after Release, just buffer the queue
}

--- Check that the current iteration is still the one the user started
local function skillup_valid(my_counter)
    return SKILLUP_STATE.active
        and SKILLUP_STATE.counter == my_counter
        and player
        and player.main_job == 'SMN'
        and player.status ~= 'Dead'
end

--- One iteration of the loop: cast Siren, schedule Release, then schedule the
--- next iteration relative to the Release (not relative to the cast). This
--- keeps the resummon as tight as possible once the avatar has been released.
local function skillup_iteration(my_counter)
    if not skillup_valid(my_counter) then return end

    send_command('input /ma "Siren" <me>')

    -- Release after the summon has resolved, then chain into the next cycle
    coroutine.schedule(function()
        if not skillup_valid(my_counter) then return end
        send_command('input /ja "Release" <me>')

        coroutine.schedule(function()
            skillup_iteration(my_counter)
        end, SKILLUP_STATE.release_to_next_delay)
    end, SKILLUP_STATE.cast_to_release_delay)
end

local function start_skillup()
    if SKILLUP_STATE.active then
        MessageFormatter.show_info('[SMN] Skillup loop already running')
        return
    end
    SKILLUP_STATE.active = true
    SKILLUP_STATE.counter = SKILLUP_STATE.counter + 1
    local my_counter = SKILLUP_STATE.counter

    local cycle = SKILLUP_STATE.cast_to_release_delay + SKILLUP_STATE.release_to_next_delay
    MessageFormatter.show_success(
        '[SMN] Skillup loop started (Siren -> Release every ~'
        .. string.format('%.1f', cycle) .. 's, '
        .. tostring(SKILLUP_STATE.release_to_next_delay) .. 's after release). '
        .. '//gs c skillup stop to halt.'
    )
    skillup_iteration(my_counter)
end

local function stop_skillup()
    if not SKILLUP_STATE.active then
        MessageFormatter.show_info('[SMN] Skillup loop is not running')
        return
    end
    SKILLUP_STATE.active = false
    SKILLUP_STATE.counter = SKILLUP_STATE.counter + 1  -- invalidate pending coroutines
    MessageFormatter.show_success('[SMN] Skillup loop stopped')
end

--- Dispatch for `//gs c skillup [start|stop|status|<seconds>]`
local function handle_skillup(args)
    local sub = (args and args[1]) and args[1]:lower() or nil

    if sub == 'stop' or sub == 'off' then
        stop_skillup()
        return
    end

    if sub == 'start' or sub == 'on' then
        start_skillup()
        return
    end

    if sub == 'status' then
        MessageFormatter.show_info(
            '[SMN] Skillup: ' .. (SKILLUP_STATE.active and 'ACTIVE' or 'STOPPED')
            .. ' (cast->release=' .. tostring(SKILLUP_STATE.cast_to_release_delay) .. 's, '
            .. 'release->next=' .. tostring(SKILLUP_STATE.release_to_next_delay) .. 's)'
        )
        return
    end

    -- Numeric arg = set `release_to_next_delay` and (re)start.
    -- This is the knob the user actually cares about: how soon after Release
    -- we try the next summon.
    local n = sub and tonumber(sub) or nil
    if n and n >= 1 and n <= 60 then
        SKILLUP_STATE.release_to_next_delay = n
        if SKILLUP_STATE.active then
            stop_skillup()
        end
        start_skillup()
        return
    end

    -- No arg: toggle
    if SKILLUP_STATE.active then
        stop_skillup()
    else
        start_skillup()
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   COMMAND HANDLERS
---  ═══════════════════════════════════════════════════════════════════════════

--- Summon an avatar by name (case-insensitive, accepts "cait sith" / "caitsith")
local function handle_summon(args)
    if not args or #args == 0 then
        MessageFormatter.show_info('Usage: //gs c smn summon <Avatar>')
        return
    end

    local raw = table.concat(args, ' '):lower()
    local canonical = KNOWN_AVATARS[raw]
    if not canonical then
        MessageFormatter.show_error('Unknown avatar: ' .. raw)
        return
    end

    send_command('input /ma "' .. canonical .. '" <me>')
end

--- Trigger a JA by shortcut name
local function handle_ja_shortcut(shortcut)
    local ja = JA_SHORTCUTS[shortcut]
    if not ja then
        MessageFormatter.show_error('Unknown SMN JA shortcut: ' .. shortcut)
        return
    end
    send_command('input /ja "' .. ja.name .. '" ' .. ja.target)
end

--- Trigger an arbitrary Blood Pact by name, picking the correct default target
--- (Ward Buff/Heal -> <me>, Rage / Ward Debuff -> <t>)
local function handle_bp(args)
    if not args or #args == 0 then
        MessageFormatter.show_info('Usage: //gs c smn bp <Blood Pact Name>')
        return
    end

    local bp_name = table.concat(args, ' ')
    local _, category = BloodPactClassifier and BloodPactClassifier.resolve(bp_name) or nil, nil

    -- Default target: <t> for damage/debuff pacts, <me> for self-buffs/heals
    local target = '<t>'
    if category == 'BPWard.Buff' or category == 'BPWard.Heal' then
        target = '<me>'
    end

    send_command('input /pet "' .. bp_name .. '" ' .. target)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   COMMAND HOOK
---  ═══════════════════════════════════════════════════════════════════════════

--- Handle //gs c <command> ...
--- @param cmdParams table {'command', 'arg1', 'arg2', ...}
--- @param eventArgs table Event arguments; set .handled = true when consumed
function job_self_command(cmdParams, eventArgs)
    if not cmdParams or #cmdParams == 0 then return end

    ensure_commands_loaded()

    local command = cmdParams[1]:lower()

    -- ==========================================================================
    -- DUAL-BOX IPC
    -- ==========================================================================
    if command == 'altjobupdate' then
        local DualBoxManager = require('shared/utils/dualbox/dualbox_manager')
        if cmdParams[2] and cmdParams[3] then
            DualBoxManager.receive_alt_job(cmdParams[2], cmdParams[3], cmdParams[4], cmdParams[5])
        end
        eventArgs.handled = true
        return
    end

    if command == 'requestjob' then
        local DualBoxManager = require('shared/utils/dualbox/dualbox_manager')
        DualBoxManager.handle_job_request()
        eventArgs.handled = true
        return
    end

    -- ==========================================================================
    -- UI COMMANDS
    -- ==========================================================================
    if UICommands and UICommands.is_ui_command(command) then
        UICommands.handle_ui_command(cmdParams)
        eventArgs.handled = true
        return
    end

    -- ==========================================================================
    -- DEBUG COMMANDS
    -- ==========================================================================
    if command == 'debugmidcast' then
        local MidcastManager = require('shared/utils/midcast/midcast_manager')
        MidcastManager.toggle_debug()
        MessageCommands.show_debugmidcast_toggled('SMN', _G.MidcastManagerDebugState)
        eventArgs.handled = true
        return
    end

    -- ==========================================================================
    -- CYCLE STATE
    -- ==========================================================================
    if command == 'cyclestate' then
        if CycleHandler then
            eventArgs.handled = CycleHandler.handle_cyclestate(cmdParams, eventArgs)
        end
        return
    end

    -- ==========================================================================
    -- WATCHDOG
    -- ==========================================================================
    if WatchdogCommands and WatchdogCommands.is_watchdog_command(command) then
        if WatchdogCommands.handle_command(cmdParams, eventArgs) then
            eventArgs.handled = true
        end
        return
    end

    -- ==========================================================================
    -- SUMMONING MAGIC SKILLUP LOOP
    -- ==========================================================================
    if command == 'skillup' then
        local args = {}
        for i = 2, #cmdParams do table.insert(args, cmdParams[i]) end
        handle_skillup(args)
        eventArgs.handled = true
        return
    end

    -- ==========================================================================
    -- COMMON COMMANDS (reload, checksets, etc.)
    -- ==========================================================================
    if CommonCommands and CommonCommands.is_common_command(command) then
        local args = {}
        for i = 2, #cmdParams do
            table.insert(args, cmdParams[i])
        end
        if CommonCommands.handle_command(command, 'SMN', table.unpack(args)) then
            eventArgs.handled = true
        end
        return
    end

    -- ==========================================================================
    -- SMN-SPECIFIC: smn <subcommand> [args]
    -- ==========================================================================
    if command == 'smn' then
        if #cmdParams < 2 then
            MessageFormatter.show_info('Usage: //gs c smn <summon|astralflow|astralconduit|apogee|siphon|manacede|favor|release|assault|retreat|bp> [args]')
            eventArgs.handled = true
            return
        end

        local sub = cmdParams[2]:lower()
        local rest = {}
        for i = 3, #cmdParams do table.insert(rest, cmdParams[i]) end

        if sub == 'summon' then
            handle_summon(rest)
            eventArgs.handled = true
            return
        end

        if sub == 'bp' then
            handle_bp(rest)
            eventArgs.handled = true
            return
        end

        if JA_SHORTCUTS[sub] then
            handle_ja_shortcut(sub)
            eventArgs.handled = true
            return
        end

        MessageFormatter.show_error('Unknown smn subcommand: ' .. sub)
        eventArgs.handled = true
        return
    end
end

--- Called when a Mote state field changes value
function job_state_change(stateField, newValue, oldValue)
    if stateField == 'Moving' then return end

    local ui_ok, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_ok and KeybindUI and KeybindUI.update then
        KeybindUI.update()
    end

    -- Avatar's Favor toggle changed -> refresh idle gear
    if stateField == 'AvatarFavor' or stateField == 'IdleMode' then
        send_command('gs c update')
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_self_command = job_self_command
_G.job_state_change = job_state_change

-- Expose skillup stop globally so Tetsouo_SMN.file_unload() can halt the loop
-- before the SMN module is unloaded on job change (otherwise orphan coroutines
-- captured by the old closure would keep spamming Siren).
_G.cancel_smn_skillup_loop = stop_skillup

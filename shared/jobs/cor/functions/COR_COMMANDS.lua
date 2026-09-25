---  ═══════════════════════════════════════════════════════════════════════════
---   COR Commands Module - Custom Command Handler
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles custom commands for Corsair job via //gs c [command].
---   Provides job-specific commands and integrates with common commands.
---   Integrates with UICommands for UI management.
---
---   COR commands: track_roll <short> <value>, rolls, doubleup (du),
---   clearrolls, party, clearparty, shot / roll1 / roll2 (ability selected in
---   QuickDraw / MainRoll / SubRoll), testcolors (colors).
---   Note: testcolors / colors are also common commands, and the common
---   handler runs first.
---   job_state_change re-equips gear when MainWeapon / RangeWeapon changes.
---
---   @file    shared/jobs/cor/functions/COR_COMMANDS.lua
---   @author  Tetsouo
---   @version 1.1 - Added UICommands integration
---   @date    Created: 2025-10-07
---   @date    Updated: 2025-10-10
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
local MessageFormatter = nil
local RollTracker = nil

local function ensure_commands_loaded()
    if not UICommands then
        UICommands = require('shared/utils/ui/UI_COMMANDS')
        CommonCommands = require('shared/utils/core/COMMON_COMMANDS')
        WatchdogCommands = require('shared/utils/core/WATCHDOG_COMMANDS')
        CycleHandler = require('shared/utils/core/CYCLE_HANDLER')
        MessageCommands = require('shared/utils/messages/formatters/ui/message_commands')

        -- Load message formatter for standardized messages
        MessageFormatter = require('shared/utils/messages/message_formatter')

        -- Load roll tracker for roll commands
        local roll_tracker_loaded
        roll_tracker_loaded, RollTracker = pcall(require, 'shared/jobs/cor/functions/logic/roll_tracker')
        if not roll_tracker_loaded then
            RollTracker = nil
        end
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SELECTED ABILITY COMMANDS
---  ═══════════════════════════════════════════════════════════════════════════

-- Commands that use the ability selected in a state: the state value plus the
-- suffix is the ability name ('Light' -> 'Light Shot', 'Chaos Roll' as is).
local SELECTED_ABILITY_COMMANDS = {
    shot  = { state = 'QuickDraw', suffix = ' Shot', target = '<t>' },
    roll1 = { state = 'MainRoll',  suffix = '',      target = '<me>' },
    roll2 = { state = 'SubRoll',   suffix = '',      target = '<me>' },
}

--- Use the ability selected in a state. Sent as a normal /ja, so it goes
--- through precast like a macro would (debuff guard, recast check, gear).
--- @param entry table One SELECTED_ABILITY_COMMANDS entry
--- @return void
local function use_selected_ability(entry)
    local selection = state[entry.state]
    if not selection then
        MessageFormatter.show_error(entry.state .. ' state is not configured')
        return
    end

    send_command(string.format('input /ja "%s%s" %s', selection.value, entry.suffix, entry.target))
end

---  ═══════════════════════════════════════════════════════════════════════════
---   COMMAND HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

---   Handle custom job commands
---   @param cmdParams table Command parameters
---   @param eventArgs table Event arguments
---   @return void
function job_self_command(cmdParams, eventArgs)
    if not cmdParams or #cmdParams == 0 then
        return
    end

    -- Lazy load command handlers on first command
    ensure_commands_loaded()

    local command = cmdParams[1]:lower()

    -- ══════════════════════════════════════════════════════════════════════════
    -- DUAL-BOXING: Receive alt job update
    -- ══════════════════════════════════════════════════════════════════════════
    if command == 'altjobupdate' then
        local DualBoxManager = require('shared/utils/dualbox/dualbox_manager')
        if cmdParams[2] and cmdParams[3] then
            DualBoxManager.receive_alt_job(cmdParams[2], cmdParams[3], cmdParams[4], cmdParams[5], cmdParams[6])
        end
        eventArgs.handled = true
        return
    end

    -- DUAL-BOXING: Handle job request from MAIN
    if command == 'requestjob' then
        local DualBoxManager = require('shared/utils/dualbox/dualbox_manager')
        DualBoxManager.handle_job_request()
        eventArgs.handled = true
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
        MessageCommands.show_debugmidcast_toggled('COR', _G.MidcastManagerDebugState)

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

    -- Watchdog commands
    if WatchdogCommands.is_watchdog_command(command) then
        if WatchdogCommands.handle_command(cmdParams, eventArgs) then
            eventArgs.handled = true
        end
        return
    end

    -- Common commands (reload, checksets, lockstyle, etc.)
    if CommonCommands.is_common_command(command) then
        -- Pass all arguments after command (cmdParams[2], cmdParams[3], etc.)
        local args = {}
        for i = 2, #cmdParams do
            table.insert(args, cmdParams[i])
        end
        if CommonCommands.handle_command(command, 'COR', table.unpack(args)) then
            eventArgs.handled = true
        end
        return
    end

    -- COR-specific commands
    if command == 'track_roll' or command == 'trackroll' then
        -- Manual roll tracking (for testing or when auto-detect fails)
        -- Example: //gs c track_roll chaos 7
        -- Accepts short names: chaos, sam, hunters, etc.
        eventArgs.handled = true

        if not RollTracker then
            MessageFormatter.show_error('RollTracker not loaded')
            return
        end

        if #cmdParams < 3 then
            MessageFormatter.show_error('Usage: //gs c track_roll <roll_short_name> <value>')
            MessageFormatter.show_info('Examples: chaos, sam, hunters, tactician, allies')
            return
        end

        -- Map short names to full roll names
        local roll_shortcuts = {
            chaos = "Chaos Roll",
            sam = "Samurai Roll",
            samurai = "Samurai Roll",
            hunters = "Hunter's Roll",
            hunter = "Hunter's Roll",
            tactician = "Tactician's Roll",
            tact = "Tactician's Roll",
            allies = "Allies' Roll",
            wizard = "Wizard's Roll",
            wiz = "Wizard's Roll",
            warlock = "Warlock's Roll",
            lock = "Warlock's Roll",
            corsair = "Corsair's Roll",
            cor = "Corsair's Roll",
            caster = "Caster's Roll",
            cast = "Caster's Roll",
            courser = "Courser's Roll",
            course = "Courser's Roll",
            blitzer = "Blitzer's Roll",
            blitz = "Blitzer's Roll",
            fighter = "Fighter's Roll",
            fight = "Fighter's Roll",
            rogue = "Rogue's Roll",
            gallant = "Gallant's Roll",
            gal = "Gallant's Roll",
            evoker = "Evoker's Roll",
            evo = "Evoker's Roll",
            bolter = "Bolter's Roll",
            bolt = "Bolter's Roll",
            miser = "Miser's Roll",
            companion = "Companion's Roll",
            comp = "Companion's Roll",
            avenger = "Avenger's Roll",
            ave = "Avenger's Roll",
            naturalist = "Naturalist's Roll",
            nat = "Naturalist's Roll"
        }

        local roll_short = cmdParams[2]:lower()
        local roll_name = roll_shortcuts[roll_short]

        if not roll_name then
            MessageFormatter.show_error('Unknown roll shortcut: ' .. cmdParams[2])
            MessageFormatter.show_info('Use: chaos, sam, hunters, tactician, allies, etc.')
            return
        end

        local roll_value = tonumber(cmdParams[3])

        if not roll_value or roll_value < 1 or roll_value > 12 then
            MessageFormatter.show_invalid_roll_value(roll_value or 0)
            return
        end

        RollTracker.on_roll_cast(roll_name, roll_value)

    elseif command == 'rolls' then
        -- Display active rolls
        eventArgs.handled = true

        if not RollTracker then
            MessageFormatter.show_error('RollTracker not loaded')
            return
        end

        if _G.cor_active_rolls and #_G.cor_active_rolls > 0 then
            MessageFormatter.show_active_rolls(_G.cor_active_rolls)
        else
            MessageFormatter.show_info('No active rolls')
        end

    elseif command == 'doubleup' or command == 'du' then
        -- Display Double-Up window status
        eventArgs.handled = true

        if not RollTracker then
            MessageFormatter.show_error('RollTracker not loaded')
            return
        end

        RollTracker.display_double_up_status()

    elseif command == 'clearrolls' then
        -- Clear all roll tracking
        eventArgs.handled = true

        if not RollTracker then
            MessageFormatter.show_error('RollTracker not loaded')
            return
        end

        RollTracker.clear_all()
        MessageFormatter.show_rolls_cleared()

    elseif command == 'party' then
        -- Display detected party members and their jobs
        eventArgs.handled = true

        MessageFormatter.show_party_members(_G.cor_party_jobs)

    elseif command == 'clearparty' then
        -- Clear party job cache (useful when members change jobs)
        eventArgs.handled = true

        if _G.cor_party_jobs then
            for k in pairs(_G.cor_party_jobs) do _G.cor_party_jobs[k] = nil end
            MessageFormatter.show_info('Party job cache cleared - will refresh automatically')
        else
            MessageFormatter.show_error('Party tracking not initialized')
        end

    elseif SELECTED_ABILITY_COMMANDS[command] then
        -- shot / roll1 / roll2: the ability selected in QuickDraw / MainRoll / SubRoll
        eventArgs.handled = true
        use_selected_ability(SELECTED_ABILITY_COMMANDS[command])

    elseif command == 'testcolors' or command == 'colors' then
        -- Display all FFXI color codes to find which ones work
        -- Example: //gs c testcolors
        eventArgs.handled = true

        MessageFormatter.show_color_test_header()

        -- Test every code from 1 to 255
        for i = 1, 255 do
            MessageFormatter.show_color_test_sample(i)
        end

        MessageFormatter.show_color_test_footer()

    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   STATE CHANGE HOOK
---  ═══════════════════════════════════════════════════════════════════════════

local LifecycleManager = require('shared/utils/core/lifecycle_manager')

-- Weapon states whose change re-equips gear
local WEAPON_STATES = { MainWeapon = true, RangeWeapon = true }

--- Re-equip when a weapon state changes.
---
--- The field is compared with spaces stripped, so the state key ('MainWeapon')
--- and the description Mote passes ('Main Weapon') both match.
---
---   @param stateField string State key or description of what changed
---   @return void
local function on_state_change(stateField)
    if type(stateField) ~= 'string' or not WEAPON_STATES[stateField:gsub(' ', '')] then
        return
    end

    if player and player.status then
        handle_equipping_gear(player.status)
    end
end

job_state_change = LifecycleManager.state_change(on_state_change)

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export global for GearSwap (Mote-Include)
_G.job_self_command = job_self_command
_G.job_state_change = job_state_change


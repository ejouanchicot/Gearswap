---  ═══════════════════════════════════════════════════════════════════════════
---   PLD Commands - Custom Command Handling
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles job-specific custom commands for Paladin job:
---   • Common commands (reload, checksets, waltz, jump, etc.)
---   • UI commands (toggle, update, reload UI)
---   • PLD-specific commands (aoe, rune)
---   • SCH subjob commands (lightarts, aoe sneak/invi/erase)
---   • State change UI synchronization
---
---   Uses centralized command handlers for consistency across all jobs.
---
---   @file    jobs/pld/functions/PLD_COMMANDS.lua
---   @author  Tetsouo
---   @version 3.0.0 - Logic Extracted to logic/
---   @date    Created: 2025-10-03 | Updated: 2025-10-06
---   @requires utils/ui/UI_COMMANDS, utils/core/COMMON_COMMANDS
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

-- PLD logic modules
local AOEManager = nil
local RuneManager = nil
local ScholarActions = nil

local function ensure_commands_loaded()
    if not UICommands then
        UICommands = require('shared/utils/ui/UI_COMMANDS')
        CommonCommands = require('shared/utils/core/COMMON_COMMANDS')
        WatchdogCommands = require('shared/utils/core/WATCHDOG_COMMANDS')
        CycleHandler = require('shared/utils/core/CYCLE_HANDLER')
        MessageCommands = require('shared/utils/messages/formatters/ui/message_commands')

        -- PLD logic modules
        AOEManager = require('shared/jobs/pld/functions/logic/aoe_manager')
        RuneManager = require('shared/jobs/pld/functions/logic/rune_manager')
        ScholarActions = require('shared/utils/scholar/scholar_actions')
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   COMMAND HANDLER HOOK
---  ═══════════════════════════════════════════════════════════════════════════

---   Handle job-specific self commands
---   Processes commands in order: Common >> UI >> PLD-specific
---
---   Common commands:
---   • reload         - Reload GearSwap
---   • checksets      - Validate equipment sets
---   • waltz <target> - Perform waltz on target
---   • jump           - Use DRG subjob Jump
---
---   UI commands:
---   • ui             - Toggle UI visibility
---
---   PLD-specific commands:
---   • aoe            - Execute Blue Magic AOE spell rotation (PLD/BLU)
---   • rune           - Execute Rune ability (PLD/RUN)
---
---   SCH subjob commands:
---   • lightarts      - Light Arts, then Addendum: White
---   • aoe sneak      - Sneak (Light Arts + Accession when SneakInviAOE is On)
---   • aoe invi       - Invisible (Light Arts + Accession when SneakInviAOE is On)
---   • aoe erase      - Erase (Light Arts + Accession whenever a charge is left)
---
---   @param cmdParams table Command parameters array (e.g., {"aoe"})
---   @param eventArgs table Event arguments with handled flag
---   @return void
function job_self_command(cmdParams, eventArgs)
    if not cmdParams[1] then
        return
    end

    -- Lazy load command handlers on first command
    ensure_commands_loaded()

    local command = cmdParams[1]:lower()

    -- ══════════════════════════════════════════════════════════════════════════
    -- WATCHDOG COMMANDS
    -- ══════════════════════════════════════════════════════════════════════════
    if WatchdogCommands.is_watchdog_command(command) then
        WatchdogCommands.handle_command(cmdParams, eventArgs)
        return
    end

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

    -- ══════════════════════════════════════════════════════════════════════════
    -- COMMON COMMANDS (reload, checksets, waltz, etc.)
    -- ══════════════════════════════════════════════════════════════════════════
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

    -- ══════════════════════════════════════════════════════════════════════════
    -- UI COMMANDS (ui toggle, update, reload)
    -- ══════════════════════════════════════════════════════════════════════════
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
        MessageCommands.show_debugmidcast_toggled('PLD', _G.MidcastManagerDebugState)

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

    -- ══════════════════════════════════════════════════════════════════════════
    -- PLD-SPECIFIC COMMANDS
    -- ══════════════════════════════════════════════════════════════════════════

    -- AOE: bare word runs the Blue Magic rotation (PLD/BLU); followed by
    -- sneak/invi/erase it runs the /SCH Accession chain instead. Those three
    -- ride under 'aoe' because the alt-command configs claim their own names,
    -- and CommonCommands answers before this block, so '//gs c sneak' would
    -- cast on the dual-box partner rather than here.
    if command == 'aoe' then
        if ScholarActions.try_aoe_subcommand(cmdParams[2], state.SneakInviAOE) then
            eventArgs.handled = true
            return
        end
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

    -- ══════════════════════════════════════════════════════════════════════════
    -- SCH SUBJOB COMMANDS
    -- ══════════════════════════════════════════════════════════════════════════

    if command == 'lightarts' then
        ScholarActions.light_arts()
        eventArgs.handled = true
        return
    end

    -- Weaponskill slots: 'ws' is slot 1, 'ws1'/'ws2' name theirs. Each fires
    -- whatever the weapon currently in hand put in that slot.
    local slot = command == 'ws' and '1' or command:match('^ws([1-9])$')
    if slot then
        local ok, WSSlots = pcall(require, 'shared/utils/weaponskill/ws_slots')
        if ok and WSSlots then
            WSSlots.cast(tonumber(slot))
            eventArgs.handled = true
        end
        return
    end
end

---   Rebuild the weaponskill slots for the weapon now in hand
---   Both the weapon choice and the stance can change it: under /SCH the
---   Tanking stance holds Burtgang whatever state.MainWeapon says, so a
---   HybridMode change moves the main hand as surely as Ctrl+Numpad1 does.
---   @return void
local function rebuild_ws_slots()
    local ws_ok, WSSlots = pcall(require, 'shared/utils/weaponskill/ws_slots')
    local sb_ok, SetBuilder = pcall(require, 'shared/jobs/pld/functions/logic/set_builder')
    local config = _G.PLDWSConfig

    if not (ws_ok and sb_ok and WSSlots and SetBuilder and config) then
        return
    end

    WSSlots.rebuild(config.get(SetBuilder.current_weapon()), config.max_slots)
end

_G.pld_rebuild_ws_slots = rebuild_ws_slots

---  ═══════════════════════════════════════════════════════════════════════════
---   STATE CHANGE HOOK
---  ═══════════════════════════════════════════════════════════════════════════

local LifecycleManager = require('shared/utils/core/lifecycle_manager')

--- React to a HybridMode change by reshaping the states that depend on it
--- (rune list, Phalanx default). The profile itself lives in the character's
--- PLD_STATES config, reached through _G because its path carries the
--- character name; a config without it simply gets nothing.
---
--- The two cycle paths disagree on what they pass: the UI-aware handler sends
--- the state key ('HybridMode'), Mote sends the description ('Hybrid Mode').
--- Stripping spaces accepts both.
---
---   @param stateField string State key or description of what changed
---   @param newValue string New value of that state
---   @return void
local function on_state_change(stateField, newValue)
    if type(stateField) ~= 'string' then
        return
    end

    local field = stateField:gsub(' ', '')

    if field == 'MainWeapon' then
        rebuild_ws_slots()
        return
    end

    if field ~= 'HybridMode' then
        return
    end

    local PLDStates = _G.PLDStates
    if PLDStates and type(PLDStates.apply_hybrid_profile) == 'function' then
        PLDStates.apply_hybrid_profile(newValue)
    end

    rebuild_ws_slots()

    -- The Hoxne stance holds the ammo slot on its Ampulla; every other stance
    -- gives the slot back. Kept here rather than in the profile because it
    -- equips gear, which a states config has no business doing.
    local ok, AmpullaLock = pcall(require, 'shared/utils/equipment/ampulla_lock')
    if ok and AmpullaLock then
        AmpullaLock.apply(newValue)
    end

    -- A stance change can add or remove a bind: /SCH Tanking holds the weapon,
    -- so MainWeapon has nothing to cycle there. The HUD re-reads the bind list
    -- on every refresh; the keys themselves are only laid down by bind_all.
    if _G.PLDKeybinds and type(_G.PLDKeybinds.refresh) == 'function' then
        _G.PLDKeybinds.refresh()
    end
end

job_state_change = LifecycleManager.state_change(on_state_change)

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export globally for GearSwap
_G.job_self_command = job_self_command
_G.job_state_change = job_state_change

---  ═══════════════════════════════════════════════════════════════════════════
---   RDM Commands Module - Custom Command Handler
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles custom commands for Red Mage job via //gs c [command].
---   Provides job-specific commands and integrates with common commands.
---
---   @file    shared/jobs/rdm/functions/RDM_COMMANDS.lua
---   @author  Tetsouo
---   @version 1.1 - Refactored: removed code duplication + dead code
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local CommonCommands = nil
local UICommands = nil
local WatchdogCommands = nil
local CycleHandler = nil
local MessageFormatter = nil
local MessageCommands = nil
local JA_DB = nil
local WS_DB = nil
local MA_DB = nil

local function ensure_commands_loaded()
    if not UICommands then
        CommonCommands = require('shared/utils/core/COMMON_COMMANDS')
        UICommands = require('shared/utils/ui/UI_COMMANDS')
        WatchdogCommands = require('shared/utils/core/WATCHDOG_COMMANDS')
        CycleHandler = require('shared/utils/core/CYCLE_HANDLER')
        MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageCommands = require('shared/utils/messages/formatters/ui/message_commands')
        JA_DB = require('shared/data/job_abilities/UNIVERSAL_JA_DATABASE')
        WS_DB = require('shared/data/weaponskills/UNIVERSAL_WS_DATABASE')
        local MA_DB_MODULE = require('shared/data/magic/UNIVERSAL_SPELL_DATABASE')
        MA_DB = MA_DB_MODULE.spells or {}
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   HELPER TABLES (Reduce code duplication)
---  ═══════════════════════════════════════════════════════════════════════════

-- Quick JA commands (simple one-to-one mapping)
local quick_ja_commands = {
    convert = 'Convert',
    chainspell = 'Chainspell',
    saboteur = 'Saboteur',
    composure = 'Composure'
}

-- Cast spell from state (spell states with error handling)
local spell_state_commands = {
    castenspell = {
        state_name = 'EnSpell',
        target = '<me>',
        check_off = true,
        error_func = function() MessageFormatter.show_no_enspell_selected() end
    },
    castgain = {
        state_name = 'GainSpell',
        target = '<me>',
        error_func = function() MessageFormatter.show_gain_spell_not_configured() end
    },
    castbar = {
        state_name = 'Barspell',
        target = '<me>',
        error_func = function() MessageFormatter.show_bar_element_not_configured() end
    },
    castbarailment = {
        state_name = 'BarAilment',
        target = '<me>',
        error_func = function() MessageFormatter.show_bar_ailment_not_configured() end
    },
    castspike = {
        state_name = 'Spike',
        target = '<me>',
        error_func = function() MessageFormatter.show_spike_not_configured() end
    },
    caststorm = {
        state_name = 'Storm',
        target = '<me>',
        error_func = function() MessageFormatter.show_storm_requires_sch() end
    }
}

-- Nuke commands with tier (element + tier state combinations)
local nuke_commands = {
    castlight = {
        state_name = 'MainLightSpell',
        error_msg = 'Light spell states not configured'
    },
    castsublight = {
        state_name = 'SubLightSpell',
        error_msg = 'Sub Light spell states not configured'
    },
    castdark = {
        state_name = 'MainDarkSpell',
        error_msg = 'Dark spell states not configured'
    },
    castsubdark = {
        state_name = 'SubDarkSpell',
        error_msg = 'Sub Dark spell states not configured'
    }
}

---  ═══════════════════════════════════════════════════════════════════════════
---   COMMAND HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

--- Handle custom job commands
--- @param cmdParams table Command parameters
--- @param eventArgs table Event arguments
--- @return void
function job_self_command(cmdParams, eventArgs)
    if not cmdParams or #cmdParams == 0 then
        return
    end

    -- Lazy load command handlers on first command
    ensure_commands_loaded()

    local command = cmdParams[1]:lower()

    ---  ─────────────────────────────────────────────────────────────────────────
    ---   DUAL-BOXING COMMANDS
    ---  ─────────────────────────────────────────────────────────────────────────

    if command == 'altjobupdate' then
        -- Receive alt job update
        local DualBoxManager = require('shared/utils/dualbox/dualbox_manager')
        if cmdParams[2] and cmdParams[3] then
            DualBoxManager.receive_alt_job(cmdParams[2], cmdParams[3])
        end
        eventArgs.handled = true
        return
    end

    if command == 'requestjob' then
        -- Handle job request from MAIN
        local DualBoxManager = require('shared/utils/dualbox/dualbox_manager')
        DualBoxManager.handle_job_request()
        eventArgs.handled = true
        return
    end

    ---  ─────────────────────────────────────────────────────────────────────────
    ---   SYSTEM COMMANDS (UI, Watchdog, Common)
    ---  ─────────────────────────────────────────────────────────────────────────

    -- UI commands (ui save, ui hide, etc.)
    if UICommands.is_ui_command(command) then
        UICommands.handle_ui_command(cmdParams)
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

    -- Common commands (reload, checksets, lockstyle, etc.)
    if CommonCommands.is_common_command(command) then
        -- Pass all arguments after command
        local args = {}
        for i = 2, #cmdParams do
            table.insert(args, cmdParams[i])
        end
        if CommonCommands.handle_command(command, 'RDM', table.unpack(args)) then
            eventArgs.handled = true
        end
        return
    end

    ---  ─────────────────────────────────────────────────────────────────────────
    ---   MOTE-INCLUDE NATIVE COMMANDS (prevent fallback)
    ---  ─────────────────────────────────────────────────────────────────────────

    if command == 'update' or command == 'cycle' or command == 'cycleback' or command == 'set' or command == 'reset' or command == 'toggle' then
        -- Mote-Include native commands (update, cycle, set, etc.)
        -- Don't handle these - let Mote process them after job_self_command returns
        -- Just exit early to prevent fallback from trying to cast them
        return
    end

    ---  ─────────────────────────────────────────────────────────────────────────
    ---   DEBUG COMMANDS
    ---  ─────────────────────────────────────────────────────────────────────────

    if command == 'debugmidcast' then
        -- Toggle MidcastManager debug mode
        local MidcastManager = require('shared/utils/midcast/midcast_manager')
        MidcastManager.toggle_debug()

        -- Confirmation message
        MessageCommands.show_debugmidcast_toggled('RDM', _G.MidcastManagerDebugState)

        eventArgs.handled = true
        return
    end

    ---  ─────────────────────────────────────────────────────────────────────────
    ---   CUSTOM CYCLE STATE (UI-aware cycle)
    ---  ─────────────────────────────────────────────────────────────────────────
    -- Intercepts cycle commands to check UI visibility
    -- If UI visible: custom cycle + UI update (no message)
    -- If UI invisible: delegate to Mote-Include (shows message)

    if command == 'cyclestate' then
        eventArgs.handled = CycleHandler.handle_cyclestate(cmdParams, eventArgs)
        return
    end

    ---  ─────────────────────────────────────────────────────────────────────────
    ---   RDM-SPECIFIC COMMANDS
    ---  ─────────────────────────────────────────────────────────────────────────

    if command == 'enspell' then
        -- Cycle through enspells or cast specific enspell
        -- Example: //gs c enspell fire
        eventArgs.handled = true

        if #cmdParams >= 2 then
            local element = cmdParams[2]:lower()
            local enspell_map = {
                fire = 'Enfire',
                blizzard = 'Enblizzard',
                ice = 'Enblizzard',
                aero = 'Enaero',
                wind = 'Enaero',
                stone = 'Enstone',
                earth = 'Enstone',
                thunder = 'Enthunder',
                water = 'Enwater'
            }

            local spell = enspell_map[element]
            if spell then
                send_command('input /ma "' .. spell .. '" <me>')
                -- MessageFormatter.show_spell_casting(spell)  -- Removed: duplicate message (universal spell system shows activation)
            else
                MessageFormatter.show_error('Unknown element: ' .. cmdParams[2])
                MessageFormatter.show_element_list()
            end
        else
            -- Cycle through enspell state (silent - no message needed)
            if state.EnSpell then
                state.EnSpell:cycle()
                -- Update UI manually (Mote doesn't trigger job_update for custom commands)
                if job_update then
                    job_update()
                end
            end
        end

    elseif quick_ja_commands[command] then
        -- Quick JA commands (Convert, Chainspell, Saboteur, Composure)
        eventArgs.handled = true
        send_command('input /ja "' .. quick_ja_commands[command] .. '" <me>')

    elseif nuke_commands[command] then
        -- Cast elemental nuke with tier (castlight, castsublight, castdark, castsubdark)
        eventArgs.handled = true

        local config = nuke_commands[command]
        local element_state = state[config.state_name]

        if element_state and state.NukeTier then
            local element = element_state.value
            local tier = state.NukeTier.value

            local spell_name = element
            if tier ~= 'I' then
                spell_name = element .. ' ' .. tier
            end

            send_command('input /ma "' .. spell_name .. '" <t>')
            -- MessageFormatter.show_spell_casting(spell_name)  -- Removed: duplicate message (universal spell system shows activation)
        else
            MessageFormatter.show_error(config.error_msg)
        end

    elseif spell_state_commands[command] then
        -- Cast spell from state (castenspell, castgain, castbar, castbarailment, castspike, caststorm)
        eventArgs.handled = true

        local config = spell_state_commands[command]
        local spell_state = state[config.state_name]

        if spell_state then
            -- Check if EnSpell is 'Off' (special case)
            if config.check_off and spell_state.value == 'Off' then
                config.error_func()
            else
                send_command('input /ma "' .. spell_state.value .. '" ' .. config.target)
                -- MessageFormatter.show_spell_casting(spell_state.value)  -- Removed: duplicate message (universal spell system shows activation)
            end
        else
            config.error_func()
        end

    elseif command == 'cyclestorm' then
        -- Cycle Storm spell (SCH subjob only)
        eventArgs.handled = true

        if state.Storm then
            state.Storm:cycle()
            MessageFormatter.show_storm_current(state.Storm.value)
        else
            MessageFormatter.show_storm_requires_sch()
        end

    else
        ---  ─────────────────────────────────────────────────────────────────────────
        ---   FALLBACK: Auto-cast from command name
        ---  ─────────────────────────────────────────────────────────────────────────
        -- This allows users to bind spells without creating explicit commands
        -- Example: { key = "^5", command = "Refresh II", desc = "Refresh II", state = nil }
        -- Will cast: /ma "Refresh II" <stpc>

        -- Reconstruct full spell name from cmdParams (handles multi-word spells)
        local spell_name = table.concat(cmdParams, " ")

        if spell_name and spell_name ~= "" then
            eventArgs.handled = true

            -- Default target: <me> (self - avoids sub-target cursor)
            -- Can be overridden by adding target after spell name (e.g., <stpc>, <t>)
            local target = '<me>'

            -- Check if last parameter looks like a target (<me>, <t>, <stpc>, etc.)
            if #cmdParams >= 2 and cmdParams[#cmdParams]:match('^<.*>$') then
                target = cmdParams[#cmdParams]
                -- Rebuild spell name without target
                local spell_parts = {}
                for i = 1, #cmdParams - 1 do
                    table.insert(spell_parts, cmdParams[i])
                end
                spell_name = table.concat(spell_parts, " ")
            end

            -- Auto-detect action type (JA, WS, or Magic)
            local action_type = nil
            local action_found = false

            -- Check if it's a Job Ability
            if JA_DB[spell_name] then
                action_type = '/ja'
                action_found = true
            -- Check if it's a Weaponskill
            elseif WS_DB[spell_name] then
                action_type = '/ws'
                action_found = true
            -- Check if it's a Magic spell
            elseif MA_DB[spell_name] then
                action_type = '/ma'
                action_found = true
            else
                -- Command not recognized - show error message
                MessageFormatter.show_error(string.format("Command not recognized: '%s'", spell_name))
                MessageFormatter.show_info("Valid types: Job Abilities, Weaponskills, Magic Spells")
                action_found = false
            end

            -- Execute command if valid
            if action_found and action_type then
                send_command('input ' .. action_type .. ' "' .. spell_name .. '" ' .. target)
            end
        end
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   STATE CHANGE HANDLER
---  ═══════════════════════════════════════════════════════════════════════════

--- Update UI when state changes
--- Called after state changes to update UI display
--- @param stateField string The state field that changed
--- @param newValue any The new value
--- @param oldValue any The old value
function job_state_change(stateField, newValue, oldValue)
    -- Skip UI update for Moving state (handled by AutoMove with flag)
    if stateField == 'Moving' then
        return
    end

    -- Update UI display
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        KeybindUI.update()
    end

    -- Force equipment refresh when weapon states change
    if stateField == 'MainWeapon' or stateField == 'SubWeapon' then
        -- Re-equip gear with new weapons
        if player and player.status then
            handle_equipping_gear(player.status)
        end
    end
end

-- Export to global scope (used by Mote-Include via include())
_G.job_self_command = job_self_command
_G.job_state_change = job_state_change

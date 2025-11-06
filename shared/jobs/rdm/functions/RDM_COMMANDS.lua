---============================================================================
--- RDM Commands Module - Custom Command Handler
---============================================================================
--- Handles custom commands for Red Mage job via //gs c [command].
--- Provides job-specific commands and integrates with common commands.
---
--- @file RDM_COMMANDS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-12
---============================================================================

-- Load centralized command handlers
local CommonCommands = require('shared/utils/core/COMMON_COMMANDS')
local UICommands = require('shared/utils/ui/UI_COMMANDS')
local WatchdogCommands = require('shared/utils/core/WATCHDOG_COMMANDS')

-- Load message formatter for standardized messages
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Load action databases for auto-detection
local JA_DB = require('shared/data/job_abilities/UNIVERSAL_JA_DATABASE')
local WS_DB = require('shared/data/weaponskills/UNIVERSAL_WS_DATABASE')

---============================================================================
--- COMMAND HOOKS
---============================================================================

--- Handle custom job commands
--- @param cmdParams table Command parameters
--- @param eventArgs table Event arguments
--- @return void
function job_self_command(cmdParams, eventArgs)
    if not cmdParams or #cmdParams == 0 then
        return
    end

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

    -- ==========================================================================
    -- MOTE-INCLUDE NATIVE COMMANDS (prevent fallback from trying to cast them)
    -- ==========================================================================

    if command == 'update' or command == 'cycle' or command == 'cycleback' or command == 'set' or command == 'reset' or command == 'toggle' then
        -- Mote-Include native commands (update, cycle, set, etc.)
        -- Don't handle these - let Mote process them after job_self_command returns
        -- Just exit early to prevent fallback from trying to cast them
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
        add_to_chat(159, '[RDM_COMMANDS] Debug toggled! Current state: ' .. tostring(_G.MidcastManagerDebugState))

        eventArgs.handled = true
        return
    end

    -- ==========================================================================
    -- RDM-SPECIFIC COMMANDS
    -- ==========================================================================

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
                MessageFormatter.show_spell_casting(spell)
            else
                MessageFormatter.show_error('Unknown element: ' .. cmdParams[2])
                MessageFormatter.show_element_list()
            end
        else
            -- Cycle through enspell state
            if state.Enspell then
                state.Enspell:cycle()
                MessageFormatter.show_enspell_current(state.Enspell.value)
            end
        end

    elseif command == 'convert' then
        -- Quick convert command
        eventArgs.handled = true
        send_command('input /ja "Convert" <me>')

    elseif command == 'chainspell' then
        -- Quick chainspell command
        eventArgs.handled = true
        send_command('input /ja "Chainspell" <me>')

    elseif command == 'saboteur' then
        -- Quick saboteur command
        eventArgs.handled = true
        send_command('input /ja "Saboteur" <me>')

    elseif command == 'composure' then
        -- Quick composure command
        eventArgs.handled = true
        send_command('input /ja "Composure" <me>')

    elseif command == 'castlight' then
        -- Cast Main Light elemental spell with tier
        eventArgs.handled = true

        if state.MainLightSpell and state.NukeTier then
            local element = state.MainLightSpell.value
            local tier = state.NukeTier.value

            local spell_name = element
            if tier ~= 'I' then
                spell_name = element .. ' ' .. tier
            end

            send_command('input /ma "' .. spell_name .. '" <t>')
            MessageFormatter.show_spell_casting(spell_name)
        else
            MessageFormatter.show_error('Light spell states not configured')
        end

    elseif command == 'castsublight' then
        -- Cast Sub Light elemental spell with tier
        eventArgs.handled = true

        if state.SubLightSpell and state.NukeTier then
            local element = state.SubLightSpell.value
            local tier = state.NukeTier.value

            local spell_name = element
            if tier ~= 'I' then
                spell_name = element .. ' ' .. tier
            end

            send_command('input /ma "' .. spell_name .. '" <t>')
            MessageFormatter.show_spell_casting(spell_name)
        else
            MessageFormatter.show_error('Sub Light spell states not configured')
        end

    elseif command == 'castdark' then
        -- Cast Main Dark elemental spell with tier
        eventArgs.handled = true

        if state.MainDarkSpell and state.NukeTier then
            local element = state.MainDarkSpell.value
            local tier = state.NukeTier.value

            local spell_name = element
            if tier ~= 'I' then
                spell_name = element .. ' ' .. tier
            end

            send_command('input /ma "' .. spell_name .. '" <t>')
            MessageFormatter.show_spell_casting(spell_name)
        else
            MessageFormatter.show_error('Dark spell states not configured')
        end

    elseif command == 'castsubdark' then
        -- Cast Sub Dark elemental spell with tier
        eventArgs.handled = true

        if state.SubDarkSpell and state.NukeTier then
            local element = state.SubDarkSpell.value
            local tier = state.NukeTier.value

            local spell_name = element
            if tier ~= 'I' then
                spell_name = element .. ' ' .. tier
            end

            send_command('input /ma "' .. spell_name .. '" <t>')
            MessageFormatter.show_spell_casting(spell_name)
        else
            MessageFormatter.show_error('Sub Dark spell states not configured')
        end

    elseif command == 'castenspell' then
        -- Cast current selected Enspell
        eventArgs.handled = true

        if state.Enspell and state.Enspell.value ~= 'Off' then
            send_command('input /ma "' .. state.Enspell.value .. '" <me>')
            MessageFormatter.show_spell_casting(state.Enspell.value)
        else
            MessageFormatter.show_no_enspell_selected()
        end

    elseif command == 'castgain' then
        -- Cast current selected Gain spell
        eventArgs.handled = true

        if state.GainSpell then
            send_command('input /ma "' .. state.GainSpell.value .. '" <me>')
            MessageFormatter.show_spell_casting(state.GainSpell.value)
        else
            MessageFormatter.show_gain_spell_not_configured()
        end

    elseif command == 'castbar' then
        -- Cast current selected Bar Element spell
        eventArgs.handled = true

        if state.Barspell then
            send_command('input /ma "' .. state.Barspell.value .. '" <me>')
            MessageFormatter.show_spell_casting(state.Barspell.value)
        else
            MessageFormatter.show_bar_element_not_configured()
        end

    elseif command == 'castbarailment' then
        -- Cast current selected Bar Ailment spell
        eventArgs.handled = true

        if state.BarAilment then
            send_command('input /ma "' .. state.BarAilment.value .. '" <me>')
            MessageFormatter.show_spell_casting(state.BarAilment.value)
        else
            MessageFormatter.show_bar_ailment_not_configured()
        end

    elseif command == 'castspike' then
        -- Cast current selected Spike spell
        eventArgs.handled = true

        if state.Spike then
            send_command('input /ma "' .. state.Spike.value .. '" <me>')
            MessageFormatter.show_spell_casting(state.Spike.value)
        else
            MessageFormatter.show_spike_not_configured()
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

    elseif command == 'caststorm' then
        -- Cast current selected Storm spell (SCH subjob required)
        eventArgs.handled = true

        if state.Storm then
            send_command('input /ma "' .. state.Storm.value .. '" <me>')
            MessageFormatter.show_spell_casting(state.Storm.value)
        else
            MessageFormatter.show_storm_requires_sch()
        end

    else
        -- FALLBACK: Try to cast spell directly from command name
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
            local action_type = '/ma'  -- Default: magic

            -- Check if it's a Job Ability
            if JA_DB[spell_name] then
                action_type = '/ja'
            -- Check if it's a Weaponskill
            elseif WS_DB[spell_name] then
                action_type = '/ws'
            end

            send_command('input ' .. action_type .. ' "' .. spell_name .. '" ' .. target)
        end
    end
end

--- Update UI when state changes
--- Called after state changes to update UI display
--- @param stateField string The state field that changed
--- @param newValue any The new value
--- @param oldValue any The old value
function job_state_change(stateField, newValue, oldValue)
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

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export global for GearSwap (Mote-Include)
_G.job_self_command = job_self_command
_G.job_state_change = job_state_change

-- Export module
local RDM_COMMANDS = {}
RDM_COMMANDS.job_self_command = job_self_command
RDM_COMMANDS.job_state_change = job_state_change

return RDM_COMMANDS

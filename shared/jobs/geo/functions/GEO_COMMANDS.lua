---============================================================================
--- GEO Commands Module - Self Command Handling
---============================================================================
--- Handles custom commands for Geomancer job.
--- Integrates with CommonCommands for shared functionality (reload, checksets).
--- Integrates with UICommands for UI management.
---
--- @file GEO_COMMANDS.lua
--- @author Tetsouo
--- @version 1.1 - Added UICommands integration
--- @date Created: 2025-10-09
--- @date Updated: 2025-10-10
---============================================================================

-- Load centralized command handlers
local UICommands = require('shared/utils/ui/UI_COMMANDS')
local CommonCommands = require('shared/utils/core/COMMON_COMMANDS')
local WatchdogCommands = require('shared/utils/core/WATCHDOG_COMMANDS')

-- Load GEO spell refiner for intelligent tier fallback
local GeoSpellRefiner = require('shared/jobs/geo/functions/logic/geo_spell_refiner')

---============================================================================
--- COMMAND HOOKS
---============================================================================

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
        add_to_chat(159, '[GEO_COMMANDS] Debug toggled! Current state: ' .. tostring(_G.MidcastManagerDebugState))

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

    -- Common commands (reload, checksets, waltz, aoewaltz, jump, setregion, detectregion)
    if CommonCommands.is_common_command(command) then
        -- Pass all arguments after command
        local args = {}
        for i = 2, #cmdParams do
            table.insert(args, cmdParams[i])
        end
        if CommonCommands.handle_command(command, 'GEO', table.unpack(args)) then
            eventArgs.handled = true
        end
        return
    end

    -- GEO-SPECIFIC COMMANDS

    -- Cast primary Indi spell
    if command == 'indi' then
        if state.MainIndi and state.MainIndi.current then
            send_command('input /ma "' .. state.MainIndi.current .. '" <me>')
            eventArgs.handled = true
        end
        return
    end

    -- Cast primary Geo spell
    if command == 'geo' then
        if state.MainGeo and state.MainGeo.current then
            send_command('input /ma "' .. state.MainGeo.current .. '" <t>')
            eventArgs.handled = true
        end
        return
    end

    -- Cast Indi with Entrust
    if command == 'entrust' then
        send_command('input /ja "Entrust" <me>')
        -- Wait for Entrust buff, then cast Indi on party member
        if state.MainIndi and state.MainIndi.current then
            coroutine.schedule(function()
                send_command('input /ma "' .. state.MainIndi.current .. '" <stpt>')
            end, 1.5)
        end
        eventArgs.handled = true
        return
    end

    -- Cast Light Elemental spell (Fire/Aero/Thunder) with intelligent tier fallback
    if command == 'lightspell' then
        if state.MainLightSpell and state.MainLightSpell.current and state.SpellTier and state.SpellTier.current then
            local base_spell = state.MainLightSpell.current
            local desired_tier = state.SpellTier.current

            -- Use spell refiner for automatic tier fallback
            GeoSpellRefiner.refine_and_cast(base_spell, desired_tier, false, '<t>')
            eventArgs.handled = true
        end
        return
    end

    -- Cast Dark Elemental spell (Blizzard/Stone/Water) with intelligent tier fallback
    if command == 'darkspell' then
        if state.MainDarkSpell and state.MainDarkSpell.current and state.SpellTier and state.SpellTier.current then
            local base_spell = state.MainDarkSpell.current
            local desired_tier = state.SpellTier.current

            -- Use spell refiner for automatic tier fallback
            GeoSpellRefiner.refine_and_cast(base_spell, desired_tier, false, '<t>')
            eventArgs.handled = true
        end
        return
    end

    -- Cast Light AOE spell (Fira/Aera/Thundara) with intelligent tier fallback
    if command == 'lightaoe' then
        if state.MainLightAOE and state.MainLightAOE.current and state.AOETier and state.AOETier.current then
            local base_spell = state.MainLightAOE.current
            local desired_tier = state.AOETier.current

            -- Use spell refiner for automatic tier fallback (is_aoe = true)
            GeoSpellRefiner.refine_and_cast(base_spell, desired_tier, true, '<t>')
            eventArgs.handled = true
        end
        return
    end

    -- Cast Dark AOE spell (Blizzara/Stonera/Watera) with intelligent tier fallback
    if command == 'darkaoe' then
        if state.MainDarkAOE and state.MainDarkAOE.current and state.AOETier and state.AOETier.current then
            local base_spell = state.MainDarkAOE.current
            local desired_tier = state.AOETier.current

            -- Use spell refiner for automatic tier fallback (is_aoe = true)
            GeoSpellRefiner.refine_and_cast(base_spell, desired_tier, true, '<t>')
            eventArgs.handled = true
        end
        return
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export global for GearSwap (Mote-Include)
_G.job_self_command = job_self_command

-- Export module
local GEO_COMMANDS = {}
GEO_COMMANDS.job_self_command = job_self_command

return GEO_COMMANDS

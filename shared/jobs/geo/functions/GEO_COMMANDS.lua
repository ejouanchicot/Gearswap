---  ═══════════════════════════════════════════════════════════════════════════
---   GEO Commands Module - Self Command Handling
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles custom commands for Geomancer job (indi, geo, escort, entrust,
---   nukes with tier fallback, /SCH arts and aoe, dispel).
---   Integrates with CommonCommands for shared functionality (reload, checksets).
---   Integrates with UICommands for UI management.
---
---   @file    shared/jobs/geo/functions/GEO_COMMANDS.lua
---   @author  Tetsouo
---   @version 1.1 - Added UICommands integration
---   @date    Created: 2025-10-09 | Updated: 2025-10-10
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
local GeoSpellRefiner = nil

--- `//gs c escort` timings, in seconds.
local ESCORT_JA_DELAY = 2          -- Full Circle -> Indi- (job ability delay)
local ESCORT_DEFAULT_CAST = 3      -- cast time when the spell is not found
local ESCORT_FOLLOW_MARGIN = 3     -- safety net: follow anyway this long after the cast

--- Follow waiting for the escort Indi- to finish: {spell, leader, seq}.
local escort_pending = nil
local escort_seq = 0

--- Called from job_aftercast: follow the leader once the escort Indi- is over
--- (interrupted or not - the escort goes on either way).
--- @param spell table GearSwap spell
function geo_escort_on_aftercast(spell)
    if escort_pending and spell and spell.english == escort_pending.spell then
        local leader = escort_pending.leader
        escort_pending = nil
        send_command('sm follow ' .. leader)
    end
end
_G.geo_escort_on_aftercast = geo_escort_on_aftercast

local function ensure_commands_loaded()
    if not UICommands then
        UICommands = require('shared/utils/ui/UI_COMMANDS')
        CommonCommands = require('shared/utils/core/COMMON_COMMANDS')
        WatchdogCommands = require('shared/utils/core/WATCHDOG_COMMANDS')
        CycleHandler = require('shared/utils/core/CYCLE_HANDLER')
        MessageCommands = require('shared/utils/messages/formatters/ui/message_commands')

        -- Load GEO spell refiner for intelligent tier fallback
        GeoSpellRefiner = require('shared/jobs/geo/functions/logic/geo_spell_refiner')
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   GEO SPELL CLASSIFICATION (Buff vs Debuff)
---  ═══════════════════════════════════════════════════════════════════════════

---   List of Geo buffs (party support) - target: <stpc>
---   Based on spell descriptions: "Boosts", "Restores"
local GEO_BUFFS = {
    ['Geo-Acumen'] = true,      -- Boosts magic atk.
    ['Geo-AGI'] = true,          -- Boosts agility.
    ['Geo-Attunement'] = true,   -- Boosts magic evasion.
    ['Geo-Barrier'] = true,      -- Boosts defense.
    ['Geo-CHR'] = true,          -- Boosts charisma.
    ['Geo-DEX'] = true,          -- Boosts dexterity.
    ['Geo-Fend'] = true,         -- Boosts magic def.
    ['Geo-Focus'] = true,        -- Boosts magic acc.
    ['Geo-Fury'] = true,         -- Boosts attack.
    ['Geo-Haste'] = true,        -- Boosts attack speed.
    ['Geo-INT'] = true,          -- Boosts intelligence.
    ['Geo-MND'] = true,          -- Boosts mind.
    ['Geo-Precision'] = true,    -- Boosts accuracy.
    ['Geo-Refresh'] = true,      -- Restores MP.
    ['Geo-Regen'] = true,        -- Restores HP.
    ['Geo-STR'] = true,          -- Boosts strength.
    ['Geo-VIT'] = true,          -- Boosts vitality.
    ['Geo-Voidance'] = true,     -- Boosts evasion.
}

---   Check if Geo spell is a buff (party support)
---   @param spell_name string Geo spell name (e.g., "Geo-Haste")
---   @return boolean True if buff (use <stpc>), false if debuff (use <stnpc>)
local function is_geo_buff(spell_name)
    return GEO_BUFFS[spell_name] == true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   COMMAND HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

---   Handle //gs c commands (command router)
---   @param cmdParams table Command words; cmdParams[1] is the command name
---   @param eventArgs table Event arguments (handled = true stops Mote's handling)
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

    -- ══════════════════════════════════════════════════════════════════════════
    -- DUAL-BOXING: Handle job request from MAIN
    -- ══════════════════════════════════════════════════════════════════════════
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
        MessageCommands.show_debugmidcast_toggled('GEO', _G.MidcastManagerDebugState)

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

    -- Common commands (reload, checksets, waltz, aoewaltz, jump, etc.)
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

    -- Cast primary Geo spell with intelligent targeting
    -- Buffs (party support) >> <stpc> (sub-target party)
    -- Debuffs (enemy) >> <stnpc> (sub-target NPC)
    if command == 'geo' then
        if state.MainGeo and state.MainGeo.current then
            local spell_name = state.MainGeo.current
            local target = is_geo_buff(spell_name) and '<stpc>' or '<stnpc>'

            send_command('input /ma "' .. spell_name .. '" ' .. target)
            eventArgs.handled = true
        end
        return
    end

    -- Escort: //gs c escort [Indi-X] [leader]
    -- Dismiss the luopan if there is one, put up an Indi- on self, and only
    -- once the cast is over start following the leader: moving cancels the
    -- cast. Without a luopan the Indi- goes out at once, since waiting after
    -- a Full Circle that has nothing to dismiss only delays it.
    if command == 'escort' then
        local indi = cmdParams[2] or 'Indi-Regen'
        local leader = cmdParams[3]
        local cast = 'input /ma "' .. indi .. '" <me>'
        local cast_start = 0
        if pet and pet.isvalid then
            send_command('input /ja "Full Circle" <me>')
            -- A spell right after a job ability is refused until the ability
            -- delay has passed.
            cast_start = ESCORT_JA_DELAY
            coroutine.schedule(function() send_command(cast) end, cast_start)
        else
            send_command(cast)
        end
        if leader then
            -- Follow as soon as the Indi- is done: job_aftercast calls
            -- geo_escort_on_aftercast. The timer is only a safety net in case
            -- no aftercast comes (cast refused before it started).
            -- `res` is not a global in every job sandbox (it crashed here on GEO).
            local resources = rawget(_G, 'res') or windower.res or require('resources')
            local spell = resources.spells:with('en', indi)
            local cast_time = spell and spell.cast_time or ESCORT_DEFAULT_CAST
            escort_seq = escort_seq + 1
            local my_seq = escort_seq
            escort_pending = {spell = indi, leader = leader, seq = my_seq}
            coroutine.schedule(function()
                if escort_pending and escort_pending.seq == my_seq then
                    escort_pending = nil
                    send_command('sm follow ' .. leader)
                end
            end, cast_start + cast_time + ESCORT_FOLLOW_MARGIN)
        end
        local ok, MessageSortie = pcall(require, 'shared/utils/messages/formatters/system/message_sortie')
        if ok and MessageSortie then
            MessageSortie.show_alt_escort(indi, cast_start > 0, leader)
        end
        eventArgs.handled = true
        return
    end

    -- Cast Indi with Entrust
    if command == 'entrust' then
        send_command('input /ja "Entrust" <me>')
        -- Wait for the buff, not for a fixed delay. Entrust has a five minute
        -- recast, so pressing this while it is down used to put the Indi- on an
        -- ally anyway a second and a half later - a targeting cursor followed by
        -- a refusal. Nothing was cancelled here, so giving up is the right
        -- answer: an Indi- aimed at an ally does nothing without Entrust.
        if state.MainIndi and state.MainIndi.current then
            local AbilityHelper = require('shared/utils/precast/ability_helper')
            AbilityHelper.follow_up_or_abort('Entrust',
                'input /ma "' .. state.MainIndi.current .. '" <stal>', 1.5)
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

    -- ══════════════════════════════════════════════════════════════════════════
    -- SCH SUBJOB COMMANDS (Arts / Addendum / Accession-based utility)
    -- ══════════════════════════════════════════════════════════════════════════
    -- Same pattern as BLM/SCH: intelligent toggles for Light/Dark Arts and
    -- party-wide Sneak/Invi via Accession. Will fail gracefully in-game if
    -- subjob is not /SCH (FFXI will reject the JA).

    -- LightArts: toggle Light Arts / Addendum: White
    -- NOTE: Addendum: White REPLACES the Light Arts buff icon (mutually exclusive
    -- in buffactive), so we check Addendum FIRST to avoid re-casting Light Arts.
    if command == 'lightarts' then
        if buffactive and buffactive['Addendum: White'] then
            local MC = require('shared/utils/messages/message_core')
            MC.info('Light Arts + Addendum: White already active')
        elseif buffactive and buffactive['Light Arts'] then
            send_command('input /ja "Addendum: White" <me>')
        else
            send_command('input /ja "Light Arts" <me>')
        end
        eventArgs.handled = true
        return
    end

    -- DarkArts: toggle Dark Arts / Addendum: Black (same logic as lightarts)
    if command == 'darkarts' then
        if buffactive and buffactive['Addendum: Black'] then
            local MC = require('shared/utils/messages/message_core')
            MC.info('Dark Arts + Addendum: Black already active')
        elseif buffactive and buffactive['Dark Arts'] then
            send_command('input /ja "Addendum: Black" <me>')
        else
            send_command('input /ja "Dark Arts" <me>')
        end
        eventArgs.handled = true
        return
    end

    -- Sneak / Invi: Light Arts + Accession + the spell, party-wide
    -- ('//gs c aoe sneak', '//gs c aoe invi').
    if command == 'aoe' then
        local ScholarActions = require('shared/utils/scholar/scholar_actions')
        if ScholarActions.try_aoe_subcommand(cmdParams[2], nil) then
            eventArgs.handled = true
        end
        return
    end

    -- Dispel: GEO needs /SCH (Addendum: Black) or /RDM for native Dispel.
    --   /RDM                          -> direct cast
    --   /SCH + Addendum: Black active -> cast directly
    --   /SCH + Dark Arts only         -> Addendum: Black, then Dispel
    --   /SCH neither active           -> Dark Arts, Addendum: Black, then Dispel
    if command == 'dispel' then
        local sub = (player and player.sub_job) or 'NON'
        if sub == 'RDM' then
            send_command('input /ma "Dispel" <stnpc>')
        elseif sub == 'SCH' then
            local ScholarActions = require('shared/utils/scholar/scholar_actions')
            ScholarActions.cast_under_black_addendum('Dispel', '<stnpc>')
        else
            local MC = require('shared/utils/messages/message_core')
            MC.warning(('Dispel unavailable on GEO/%s. Need /RDM or /SCH.'):format(sub))
        end
        eventArgs.handled = true
        return
    end
end

--- GEO adds nothing of its own: the shared handler is the whole
--- behaviour. Pass a function to state_change() to extend it.
local LifecycleManager = require('shared/utils/core/lifecycle_manager')

job_state_change = LifecycleManager.state_change()

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export global for GearSwap (Mote-Include)
_G.job_self_command = job_self_command
_G.job_state_change = job_state_change


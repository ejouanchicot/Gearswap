---============================================================================
--- BLM Commands - Custom Command Handling
---============================================================================
--- Handles job-specific custom commands for Black Mage job:
---   • Common commands (reload, checksets, waltz, jump, etc.)
---   • UI commands (ui toggle, reload UI)
---   • BLM element cycling (MainLight, MainDark, SubLight, SubDark)
---   • BLM spell cycling (Storm, Tier)
---   • BLM-specific commands (buff, storm, lightarts, darkarts, sneak, invi)
---   • State change UI synchronization with colored element messages
---
--- Uses centralized command handlers for consistency across all jobs.
--- Movement gear handled passively via customize_idle_set() like other jobs.
---
--- @file    jobs/blm/functions/BLM_COMMANDS.lua
--- @author  Tetsouo
--- @version 2.3.0 - Added party Sneak/Invi commands (Accession automation)
--- @date    Created: 2025-10-15 | Updated: 2025-10-17
--- @requires utils/ui/UI_COMMANDS, utils/core/COMMON_COMMANDS
---============================================================================

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Centralized command handlers
local UICommands = require('shared/utils/ui/UI_COMMANDS')
local CommonCommands = require('shared/utils/core/COMMON_COMMANDS')
local WatchdogCommands = require('shared/utils/core/WATCHDOG_COMMANDS')

-- BLM message formatter (handles all colored messages)
local BLMMessages = require('shared/utils/messages/message_blm')

-- NOTE: BLM logic functions are loaded globally via blm_functions.lua:
--   • BuffSelf() - Automated self-buffing
--   • CastStorm() - Storm + Klimaform automation
--   • refine_various_spells() - Spell refinement (tier downgrading)
-- These functions are available in _G scope and called directly

---============================================================================
--- BLM CYCLE COMMAND HANDLERS
---============================================================================

--- Handle custom BLM cycle commands with colored element messages
--- @param command string The cycle command to execute
--- @param eventArgs table Event arguments with handled flag
--- @return boolean true if command was handled
local function handle_blm_cycle_commands(command, eventArgs)
    -- MainLight: Fire/Thunder/Aero
    if command == 'cyclemainlight' then
        if state and state.MainLightSpell then
            state.MainLightSpell:cycle()
            BLMMessages.show_element_cycle('MainLight', state.MainLightSpell.value)

            -- Update UI after state change
            local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
            if ui_success and KeybindUI then
                KeybindUI.update()
            end

            eventArgs.handled = true
            return true
        end
    end

    -- MainDark: Stone/Blizzard/Water
    if command == 'cyclemaindark' then
        if state and state.MainDarkSpell then
            state.MainDarkSpell:cycle()
            BLMMessages.show_element_cycle('MainDark', state.MainDarkSpell.value)

            -- Update UI after state change
            local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
            if ui_success and KeybindUI then
                KeybindUI.update()
            end

            eventArgs.handled = true
            return true
        end
    end

    -- SubLight: Thunder/Fire/Aero
    if command == 'cyclesublight' then
        if state and state.SubLightSpell then
            state.SubLightSpell:cycle()
            BLMMessages.show_element_cycle('SubLight', state.SubLightSpell.value)

            -- Update UI after state change
            local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
            if ui_success and KeybindUI then
                KeybindUI.update()
            end

            eventArgs.handled = true
            return true
        end
    end

    -- SubDark: Blizzard/Stone/Water
    if command == 'cyclesubdark' then
        if state and state.SubDarkSpell then
            state.SubDarkSpell:cycle()
            BLMMessages.show_element_cycle('SubDark', state.SubDarkSpell.value)

            -- Update UI after state change
            local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
            if ui_success and KeybindUI then
                KeybindUI.update()
            end

            eventArgs.handled = true
            return true
        end
    end

    return false
end

--- Handle standard cycle commands with colored messages (Storm, TierSpell)
--- @param cmdParams table Command parameters array
--- @param eventArgs table Event arguments with handled flag
--- @return boolean true if command was handled
local function handle_blm_standard_cycles(cmdParams, eventArgs)
    if cmdParams[1] ~= 'cycle' or not cmdParams[2] then
        return false
    end

    local stateName = cmdParams[2]

    -- Storm: FireStorm/Sandstorm/Thunderstorm/HailStorm/Rainstorm/Windstorm/Voidstorm/Aurorastorm
    if stateName == 'Storm' then
        if state and state.Storm then
            state.Storm:cycle()
            BLMMessages.show_storm_cycle(state.Storm.value)

            -- Update UI after state change
            local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
            if ui_success and KeybindUI then
                KeybindUI.update()
            end

            eventArgs.handled = true
            return true
        end
    end

    -- TierSpell: 6/5/4/3/2/base
    if stateName == 'TierSpell' then
        if state and state.TierSpell then
            state.TierSpell:cycle()
            BLMMessages.show_tier_cycle(state.TierSpell.value)
            eventArgs.handled = true
            return true
        end
    end

    return false
end

---============================================================================
--- COMMAND HANDLER HOOK
---============================================================================

--- Handle job-specific self commands
--- Processes commands in order: Common → UI → BLM cycles → BLM-specific
---
--- Common commands:
---   • reload         - Reload GearSwap
---   • checksets      - Validate equipment sets
---   • waltz <target> - Perform waltz on target
---   • jump           - Use DRG subjob Jump
---
--- UI commands:
---   • ui             - Toggle UI visibility
---
--- BLM cycle commands:
---   • cyclemainlight  - Cycle MainLight (Fire/Thunder/Aero)
---   • cyclemaindark   - Cycle MainDark (Stone/Blizzard/Water)
---   • cyclesublight   - Cycle SubLight
---   • cyclesubdark    - Cycle SubDark
---   • cycle Storm     - Cycle Storm spells
---   • cycle TierSpell - Cycle spell tiers
---
--- BLM-specific commands:
---   • buff           - Automated self-buffing (Stoneskin, Blink, Aquaveil, Ice Spikes)
---   • lightarts      - Smart Light Arts / Addendum: White (SCH subjob)
---   • darkarts       - Smart Dark Arts / Addendum: Black (SCH subjob)
---   • sneak          - Party-wide Sneak (Light Arts + Accession + Sneak)
---   • invi           - Party-wide Invisible (Light Arts + Accession + Invisible)
---
--- @param cmdParams table Command parameters array (e.g., {"buff"})
--- @param eventArgs table Event arguments with handled flag
--- @return void
function job_self_command(cmdParams, eventArgs)
    if not cmdParams[1] then
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

    -- ==========================================================================
    -- WATCHDOG COMMANDS
    -- ==========================================================================
    if WatchdogCommands.is_watchdog_command(command) then
        if WatchdogCommands.handle_command(cmdParams, eventArgs) then
            eventArgs.handled = true
        end
        return
    end

    -- ==========================================================================
    -- COMMON COMMANDS (reload, checksets, waltz, etc.)
    -- ==========================================================================
    if CommonCommands.is_common_command(command) then
        -- Extract arguments after command
        local args = {}
        for i = 2, #cmdParams do
            table.insert(args, cmdParams[i])
        end

        if CommonCommands.handle_command(command, 'BLM', table.unpack(args)) then
            eventArgs.handled = true
        end
        return
    end

    -- ==========================================================================
    -- UI COMMANDS (ui toggle, reload)
    -- ==========================================================================
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
        add_to_chat(159, '[BLM_COMMANDS] Debug toggled! Current state: ' .. tostring(_G.MidcastManagerDebugState))

        eventArgs.handled = true
        return
    end

    -- ==========================================================================
    -- BLM CUSTOM CYCLE COMMANDS (cyclemainlight, cyclemaindark, etc.)
    -- ==========================================================================
    if handle_blm_cycle_commands(command, eventArgs) then
        return
    end

    -- ==========================================================================
    -- BLM STANDARD CYCLE COMMANDS (cycle Aja, cycle Storm, etc.)
    -- ==========================================================================
    if handle_blm_standard_cycles(cmdParams, eventArgs) then
        return
    end

    -- ==========================================================================
    -- BLM-SPECIFIC COMMANDS
    -- ==========================================================================

    -- Buff: Automated self-buffing (Stoneskin, Blink, Aquaveil, Ice Spikes)
    if command == 'buff' then
        -- Function loaded globally via blm_functions.lua
        if BuffSelf then
            BuffSelf()
            eventArgs.handled = true
        else
            BLMMessages.show_buffself_error()
        end
        return
    end

    -- LightArts: Intelligent Light Arts / Addendum: White toggling (SCH subjob)
    if command == 'lightarts' then
        if buffactive and buffactive['Light Arts'] then
            -- Light Arts active -> Use Addendum: White (if not already active)
            if not buffactive['Addendum: White'] then
                -- Don't check charges - FFXI will block if unavailable (Stratagems have multiple charges)
                send_command('input /ja "Addendum: White" <me>')
            else
                BLMMessages.show_arts_already_active('Light Arts + Addendum: White')
            end
        else
            -- Light Arts not active -> Activate it
            send_command('input /ja "Light Arts" <me>')
        end
        eventArgs.handled = true
        return
    end

    -- DarkArts: Intelligent Dark Arts / Addendum: Black toggling (SCH subjob)
    if command == 'darkarts' then
        if buffactive and buffactive['Dark Arts'] then
            -- Dark Arts active -> Use Addendum: Black (if not already active)
            if not buffactive['Addendum: Black'] then
                -- Don't check charges - FFXI will block if unavailable (Stratagems have multiple charges)
                send_command('input /ja "Addendum: Black" <me>')
            else
                BLMMessages.show_arts_already_active('Dark Arts + Addendum: Black')
            end
        else
            -- Dark Arts not active -> Activate it
            send_command('input /ja "Dark Arts" <me>')
        end
        eventArgs.handled = true
        return
    end

    -- Sneak: Intelligent Light Arts + Accession + Sneak (party-wide)
    if command == 'sneak' then
        if buffactive and buffactive['Light Arts'] then
            -- Light Arts active -> Just use Accession + Sneak
            send_command('input /ja "Accession" <me>; wait 2; input /ma "Sneak" <me>')
        else
            -- Light Arts not active -> Activate it first, then Accession + Sneak
            send_command('input /ja "Light Arts" <me>; wait 2; input /ja "Accession" <me>; wait 2; input /ma "Sneak" <me>')
        end
        eventArgs.handled = true
        return
    end

    -- Invi: Intelligent Light Arts + Accession + Invisible (party-wide)
    if command == 'invi' then
        if buffactive and buffactive['Light Arts'] then
            -- Light Arts active -> Just use Accession + Invisible
            send_command('input /ja "Accession" <me>; wait 2; input /ma "Invisible" <me>')
        else
            -- Light Arts not active -> Activate it first, then Accession + Invisible
            send_command('input /ja "Light Arts" <me>; wait 2; input /ja "Accession" <me>; wait 2; input /ma "Invisible" <me>')
        end
        eventArgs.handled = true
        return
    end

    -- ==========================================================================
    -- BLM INTELLIGENT NUKE COMMANDS (with validation + refinement)
    -- ==========================================================================

    -- Light: Cast light element nuke (uses MainLightSpell + SpellTier)
    if command == 'light' then
        if state and state.MainLightSpell and state.SpellTier then
            local element = state.MainLightSpell.current
            local tier = state.SpellTier.current
            local spell_name = element .. (tier ~= "I" and (" " .. tier) or "")

            -- Use windower.ffxi.cast_spell to trigger refinement via precast
            windower.chat.input('/ma "' .. spell_name .. '" <stnpc>')
            eventArgs.handled = true
        end
        return
    end

    -- Dark: Cast dark element nuke (uses MainDarkSpell + SpellTier)
    if command == 'dark' then
        if state and state.MainDarkSpell and state.SpellTier then
            local element = state.MainDarkSpell.current
            local tier = state.SpellTier.current
            local spell_name = element .. (tier ~= "I" and (" " .. tier) or "")

            windower.chat.input('/ma "' .. spell_name .. '" <stnpc>')
            eventArgs.handled = true
        end
        return
    end

    -- AOE Light: Cast light element AOE (uses MainLightAOE + AOETier)
    -- AOETier: Aja (Firaja) → III (Firaga III) → II (Firaga II) → I (Firaga I)
    if command == 'aoelight' then
        if state and state.MainLightAOE and state.AOETier then
            local element = state.MainLightAOE.current  -- "Firaga", "Aeroga", "Thundaga"
            local tier = state.AOETier.current
            local spell_name

            if tier == "Aja" then
                -- Tier Aja: Convert "Firaga" → "Firaja"
                local base_element = element:match("(%a+)ga")  -- Extract "Fir" from "Firaga"
                spell_name = base_element .. "ja"  -- "Firaja"
            else
                -- Tier III/II/I: "Firaga III", "Firaga II", "Firaga I"
                spell_name = element .. (tier ~= "I" and (" " .. tier) or "")
            end

            windower.chat.input('/ma "' .. spell_name .. '" <stnpc>')
            eventArgs.handled = true
        end
        return
    end

    -- AOE Dark: Cast dark element AOE (uses MainDarkAOE + AOETier)
    -- AOETier: Aja (Blizzaja) → III (Blizzaga III) → II (Blizzaga II) → I (Blizzaga I)
    if command == 'aoedark' then
        if state and state.MainDarkAOE and state.AOETier then
            local element = state.MainDarkAOE.current  -- "Blizzaga", "Stonega", "Waterga"
            local tier = state.AOETier.current
            local spell_name

            if tier == "Aja" then
                -- Tier Aja: Convert "Blizzaga" → "Blizzaja"
                local base_element = element:match("(%a+)ga")  -- Extract "Blizz" from "Blizzaga"
                spell_name = base_element .. "ja"  -- "Blizzaja"
            else
                -- Tier III/II/I: "Blizzaga III", "Blizzaga II", "Blizzaga I"
                spell_name = element .. (tier ~= "I" and (" " .. tier) or "")
            end

            windower.chat.input('/ma "' .. spell_name .. '" <stnpc>')
            eventArgs.handled = true
        end
        return
    end

    -- SubLight: Cast sub light element nuke (uses SubLightSpell + SpellTier)
    if command == 'sublight' then
        if state and state.SubLightSpell and state.SpellTier then
            local element = state.SubLightSpell.current
            local tier = state.SpellTier.current
            local spell_name = element .. (tier ~= "I" and (" " .. tier) or "")

            windower.chat.input('/ma "' .. spell_name .. '" <stnpc>')
            eventArgs.handled = true
        end
        return
    end

    -- SubDark: Cast sub dark element nuke (uses SubDarkSpell + SpellTier)
    if command == 'subdark' then
        if state and state.SubDarkSpell and state.SpellTier then
            local element = state.SubDarkSpell.current
            local tier = state.SpellTier.current
            local spell_name = element .. (tier ~= "I" and (" " .. tier) or "")

            windower.chat.input('/ma "' .. spell_name .. '" <stnpc>')
            eventArgs.handled = true
        end
        return
    end

    -- Storm: Cast current storm spell with automatic Klimaform (for SCH subjob)
    if command == 'storm' then
        if state and state.Storm then
            local storm_name = state.Storm.current
            -- Function loaded globally via blm_functions.lua
            if CastStorm then
                CastStorm(storm_name)
                eventArgs.handled = true
            else
                -- Fallback: cast Storm without Klimaform check
                send_command('input /ma "' .. storm_name .. '" <me>')
                eventArgs.handled = true
            end
        end
        return
    end
end

---============================================================================
--- STATE CHANGE HOOK
---============================================================================

--- Update UI when state changes (MainWeapon, HybridMode, etc.)
--- Called by Mote-Include after any state change.
---
--- @param stateField string State that changed (e.g., "MainWeapon")
--- @param newValue   string New value
--- @param oldValue   string Previous value
--- @return void
function job_state_change(stateField, newValue, oldValue)
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        KeybindUI.update()
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.job_self_command = job_self_command
_G.job_state_change = job_state_change

-- Export as module (for future require() usage)
return {
    job_self_command = job_self_command,
    job_state_change = job_state_change
}

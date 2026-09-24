---  ═══════════════════════════════════════════════════════════════════════════
---   BLM Commands - Custom Command Handling
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles job-specific custom commands for Black Mage job:
---   • Common commands (reload, checksets, waltz, jump, etc.)
---   • UI commands (ui toggle, reload UI)
---   • BLM element cycling (MainLight, MainDark, SubLight, SubDark)
---   • BLM spell cycling (Storm, TierSpell)
---   • BLM-specific commands (buff, storm, klima, dispel, lightarts, darkarts,
---     aoe sneak/invi, light/dark/aoe nukes)
---   • CombatMode weapon lock (job_state_change)
---   • State change UI synchronization with colored element messages
---
---   Uses centralized command handlers for consistency across all jobs.
---   Movement gear handled passively via customize_idle_set() like other jobs.
---
---   @file    shared/jobs/blm/functions/BLM_COMMANDS.lua
---   @author  Tetsouo
---   @version 2.3.0 - Added party Sneak/Invi commands (Accession automation)
---   @date    Created: 2025-10-15 | Updated: 2025-10-17
---   @requires shared/utils/ui/UI_COMMANDS, shared/utils/core/COMMON_COMMANDS
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
local BLMMessages = nil
local MessageFormatter = nil
local StratagemCharges = nil
local ScholarActions = nil

--- Dark Arts has its own recast slot and costs no stratagem charge.
local DARK_ARTS_RECAST_ID = 232

local function ensure_commands_loaded()
    if not UICommands then
        UICommands = require('shared/utils/ui/UI_COMMANDS')
        CommonCommands = require('shared/utils/core/COMMON_COMMANDS')
        WatchdogCommands = require('shared/utils/core/WATCHDOG_COMMANDS')
        CycleHandler = require('shared/utils/core/CYCLE_HANDLER')
        MessageCommands = require('shared/utils/messages/formatters/ui/message_commands')
        MessageFormatter = require('shared/utils/messages/message_formatter')

        -- BLM message formatter (handles all colored messages)
        BLMMessages = require('shared/utils/messages/formatters/jobs/message_blm')

        StratagemCharges = require('shared/utils/scholar/stratagem_charges')
        ScholarActions = require('shared/utils/scholar/scholar_actions')
    end
end

---   Build a single-target nuke name ('Fire' + 'V' -> 'Fire V')
---   Tier I casts the base spell, which carries no numeral.
---   @param element string Element name from the spell state
---   @param tier string    Tier from state.SpellTier
---   @return string Spell name
local function build_nuke_name(element, tier)
    return element .. ((tier ~= 'I') and (' ' .. tier) or '')
end

---   Build an AOE nuke name ('Firaga' + 'III' -> 'Firaga III')
---   Tier 'Aja' swaps the -ga family for its -ja counterpart (Firaga -> Firaja).
---   @param element string -ga spell name from the AOE state
---   @param tier string    Tier from state.AOETier
---   @return string Spell name
local function build_aoe_name(element, tier)
    if tier == 'Aja' then
        return element:match('(%a+)ga') .. 'ja'
    end

    return build_nuke_name(element, tier)
end

---   Cast the spell described by an element state and a tier state
---   @param element_state table Mote state holding the element
---   @param tier_state table    Mote state holding the tier
---   @param builder function    build_nuke_name or build_aoe_name
---   @return boolean True when the cast was issued
local function cast_from_states(element_state, tier_state, builder)
    if not (element_state and tier_state) then
        return false
    end

    windower.chat.input('/ma "' .. builder(element_state.current, tier_state.current) .. '" <stnpc>')

    return true
end

---   Refresh the keybind UI after a state change
local function update_ui()
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        KeybindUI.update()
    end
end

-- NOTE: BLM logic functions are loaded globally via blm_functions.lua:
--   • BuffSelf() - Automated self-buffing
--   • CastStorm() - Storm + Klimaform automation
--   • refine_various_spells() - Spell refinement (tier downgrading)
-- These functions are available in _G scope and called directly

---  ═══════════════════════════════════════════════════════════════════════════
---   BLM CYCLE COMMAND HANDLERS
---  ═══════════════════════════════════════════════════════════════════════════

---   Handle custom BLM cycle commands with colored element messages
---   @param command string The cycle command to execute
---   @param eventArgs table Event arguments with handled flag
---   @return boolean true if command was handled
local function handle_blm_cycle_commands(command, eventArgs)
    -- Lazy load on first cycle command
    ensure_commands_loaded()
    -- MainLight: Fire/Thunder/Aero
    if command == 'cyclemainlight' then
        if state and state.MainLightSpell then
            state.MainLightSpell:cycle()
            BLMMessages.show_element_cycle('MainLight', state.MainLightSpell.value)
            update_ui()
            eventArgs.handled = true
            return true
        end
    end

    -- MainDark: Stone/Blizzard/Water
    if command == 'cyclemaindark' then
        if state and state.MainDarkSpell then
            state.MainDarkSpell:cycle()
            BLMMessages.show_element_cycle('MainDark', state.MainDarkSpell.value)
            update_ui()
            eventArgs.handled = true
            return true
        end
    end

    -- SubLight: Thunder/Fire/Aero
    if command == 'cyclesublight' then
        if state and state.SubLightSpell then
            state.SubLightSpell:cycle()
            BLMMessages.show_element_cycle('SubLight', state.SubLightSpell.value)
            update_ui()
            eventArgs.handled = true
            return true
        end
    end

    -- SubDark: Blizzard/Stone/Water
    if command == 'cyclesubdark' then
        if state and state.SubDarkSpell then
            state.SubDarkSpell:cycle()
            BLMMessages.show_element_cycle('SubDark', state.SubDarkSpell.value)
            update_ui()
            eventArgs.handled = true
            return true
        end
    end

    return false
end

---   Handle standard cycle commands with colored messages (Storm, TierSpell)
---   @param cmdParams table Command parameters array
---   @param eventArgs table Event arguments with handled flag
---   @return boolean true if command was handled
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
            update_ui()
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

---  ═══════════════════════════════════════════════════════════════════════════
---   COMMAND HANDLER HOOK
---  ═══════════════════════════════════════════════════════════════════════════

---   Handle job-specific self commands
---   Processes commands in order: Common >> UI >> BLM cycles >> BLM-specific
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
---   BLM cycle commands:
---   • cyclemainlight  - Cycle MainLight (Fire/Thunder/Aero)
---   • cyclemaindark   - Cycle MainDark (Stone/Blizzard/Water)
---   • cyclesublight   - Cycle SubLight
---   • cyclesubdark    - Cycle SubDark
---   • cycle Storm     - Cycle Storm spells
---   • cycle TierSpell - Cycle spell tiers
---
---   BLM-specific commands:
---   • buff           - Automated self-buffing (Stoneskin, Blink, Aquaveil, Ice Spikes)
---   • lightarts      - Smart Light Arts / Addendum: White (SCH subjob)
---   • darkarts       - Smart Dark Arts / Addendum: Black (SCH subjob)
---   • aoe sneak      - Party-wide Sneak (Light Arts + Accession + Sneak)
---   • invi           - Party-wide Invisible (Light Arts + Accession + Invisible)
---   • klima          - Dark Arts + Manifestation + Klimaform (charge-aware)
---   • dispel         - Dispel via /RDM, or via Addendum: Black on /SCH
---   • storm          - Current Storm state, with Klimaform (CastStorm)
---   • light/dark     - Main single-target nuke (element state + SpellTier)
---   • sublight/subdark   - Sub single-target nuke
---   • aoelight/aoedark   - Main AOE nuke (-ga state + AOETier)
---   • subaoelight/subaoedark - Sub AOE nuke
---
---   @param cmdParams table Command parameters array (e.g., {"buff"})
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

    -- ══════════════════════════════════════════════════════════════════════════
    -- DUAL-BOXING: Handle job request from MAIN
    -- ══════════════════════════════════════════════════════════════════════════
    if command == 'requestjob' then
        local DualBoxManager = require('shared/utils/dualbox/dualbox_manager')
        DualBoxManager.handle_job_request()
        eventArgs.handled = true
        return
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- WATCHDOG COMMANDS
    -- ══════════════════════════════════════════════════════════════════════════
    if WatchdogCommands.is_watchdog_command(command) then
        if WatchdogCommands.handle_command(cmdParams, eventArgs) then
            eventArgs.handled = true
        end
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

        if CommonCommands.handle_command(command, 'BLM', table.unpack(args)) then
            eventArgs.handled = true
        end
        return
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- UI COMMANDS (ui toggle, reload)
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
        MessageCommands.show_debugmidcast_toggled('BLM', _G.MidcastManagerDebugState)

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
    -- BLM CUSTOM CYCLE COMMANDS (cyclemainlight, cyclemaindark, etc.)
    -- ══════════════════════════════════════════════════════════════════════════
    if handle_blm_cycle_commands(command, eventArgs) then
        return
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- BLM STANDARD CYCLE COMMANDS (cycle Storm, cycle TierSpell)
    -- ══════════════════════════════════════════════════════════════════════════
    if handle_blm_standard_cycles(cmdParams, eventArgs) then
        return
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- BLM-SPECIFIC COMMANDS
    -- ══════════════════════════════════════════════════════════════════════════

    -- Buff: Automated self-buffing (Stoneskin, Blink, Aquaveil, Ice Spikes)
    -- Accepts: buff, buffs, buffself, selfbuff (case-insensitive via :lower above)
    if command == 'buff' or command == 'buffs'
       or command == 'buffself' or command == 'selfbuff' then
        -- Function loaded globally via blm_functions.lua
        if BuffSelf then
            BuffSelf()
            eventArgs.handled = true
        else
            BLMMessages.show_buffself_error()
        end
        return
    end

    -- LightArts / DarkArts: Arts, then Addendum on the next press (SCH subjob)
    if command == 'lightarts' then
        ScholarActions.light_arts()
        eventArgs.handled = true
        return
    end

    if command == 'darkarts' then
        ScholarActions.dark_arts()
        eventArgs.handled = true
        return
    end

    -- Sneak / Invi: Light Arts + Accession + the spell, party-wide.
    -- They ride under 'aoe' because the alt-command configs claim their own
    -- names, and CommonCommands answers before this block, so '//gs c sneak'
    -- would cast on the dual-box partner rather than here.
    if command == 'aoe' then
        if ScholarActions.try_aoe_subcommand(cmdParams[2], state.SneakInviAOE) then
            eventArgs.handled = true
        end
        return
    end

    -- Klima: Dark Arts + Manifestation + Klimaform, each step only when usable.
    -- Klimaform itself always fires; the two stratagem steps are opportunistic.
    if command == 'klima' or command == 'klimaform' then
        local steps = {}

        local dark_active = buffactive and (buffactive['Dark Arts'] or buffactive['Addendum: Black'])
        local dark_recast = windower.ffxi.get_ability_recasts()[DARK_ARTS_RECAST_ID] or 0

        if not dark_active and is_recast_ready(dark_recast) then
            table.insert(steps, {command = 'input /ja "Dark Arts" <me>', buff = 'Dark Arts'})
        end

        if ScholarActions.is_on(state.KlimaformAOE) then
            if StratagemCharges.has_charge() then
                table.insert(steps, {command = 'input /ja "Manifestation" <me>', buff = 'Manifestation'})
            else
                ScholarActions.warn_no_charge('Manifestation')
            end
        end

        -- Each step waits on its own buff instead of a fixed `wait 2`: an
        -- ability sent while the previous one still holds the action lock is
        -- refused, and the old chain never noticed. finish_anyway because
        -- Klimaform is worth casting even when Manifestation did not land -
        -- it is simply single-target then.
        ScholarActions.run_chain(steps, function()
            send_command('input /ma "Klimaform" <me>')
        end, true)

        eventArgs.handled = true
        return
    end

    -- Dispel: BLM only has access via /RDM, or via /SCH with Addendum: Black.
    -- /RDM      : direct cast on <stnpc>
    -- /SCH path : Addendum: Black is REQUIRED (Dark Arts alone doesn't grant Dispel)
    --   Addendum: Black active                    -> cast Dispel directly
    --   Dark Arts active, no Addendum: Black     -> Addendum: Black, then Dispel
    --   Nothing active                            -> Dark Arts, Addendum: Black, then Dispel
    -- FFXI rejects intermediate JAs if no stratagem charge is available.
    if command == 'dispel' then
        local sub = (player and player.sub_job) or 'NON'
        if sub == 'RDM' then
            send_command('input /ma "Dispel" <stnpc>')
        elseif sub == 'SCH' then
            ScholarActions.cast_under_black_addendum('Dispel', '<stnpc>')
        else
            local MessageCore = require('shared/utils/messages/message_core')
            MessageCore.warning(('Dispel unavailable on BLM/%s. Need /RDM or /SCH.'):format(sub))
        end
        eventArgs.handled = true
        return
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- BLM INTELLIGENT NUKE COMMANDS (with validation + refinement)
    -- ══════════════════════════════════════════════════════════════════════════

    -- Single-target nukes: element state + SpellTier
    if command == 'light' then
        eventArgs.handled = cast_from_states(state.MainLightSpell, state.SpellTier, build_nuke_name)
        return
    end

    if command == 'dark' then
        eventArgs.handled = cast_from_states(state.MainDarkSpell, state.SpellTier, build_nuke_name)
        return
    end

    if command == 'sublight' then
        eventArgs.handled = cast_from_states(state.SubLightSpell, state.SpellTier, build_nuke_name)
        return
    end

    if command == 'subdark' then
        eventArgs.handled = cast_from_states(state.SubDarkSpell, state.SpellTier, build_nuke_name)
        return
    end

    -- AOE nukes: -ga element state + AOETier (Aja >> III >> II >> I)
    if command == 'aoelight' then
        eventArgs.handled = cast_from_states(state.MainLightAOE, state.AOETier, build_aoe_name)
        return
    end

    if command == 'aoedark' then
        eventArgs.handled = cast_from_states(state.MainDarkAOE, state.AOETier, build_aoe_name)
        return
    end

    if command == 'subaoelight' then
        eventArgs.handled = cast_from_states(state.SubLightAOE, state.AOETier, build_aoe_name)
        return
    end

    if command == 'subaoedark' then
        eventArgs.handled = cast_from_states(state.SubDarkAOE, state.AOETier, build_aoe_name)
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

---  ═══════════════════════════════════════════════════════════════════════════
---   STATE CHANGE HOOK
---  ═══════════════════════════════════════════════════════════════════════════

---   Update UI when state changes (MainWeapon, HybridMode, etc.) and apply
---   or release the CombatMode weapon lock.
---   Called by Mote-Include after any state change.
---
---   @param stateField string State that changed (e.g., "MainWeapon")
---   @param newValue   string New value
---   @param oldValue   string Previous value
---   @return void
function job_state_change(stateField, newValue, oldValue)
    -- DEBUG: Track which state triggered this
    if _G.AUTOMOVE_DEBUG then
        ensure_commands_loaded()
        MessageFormatter.show_debug('BLM', string.format('[job_state_change] state=%s, old=%s, new=%s',
            tostring(stateField), tostring(oldValue), tostring(newValue)))
    end

    -- Skip UI update for Moving state (handled by AutoMove with flag)
    if stateField == 'Moving' then
        if _G.AUTOMOVE_DEBUG then
            MessageFormatter.show_debug('BLM', '[job_state_change] SKIPPED (Moving state)')
        end
        return
    end

    -- Combat Mode weapon lock (immediate: fires on the cycle itself, unlike
    -- job_update which lags behind the UI-visible cycle path). Equip the magic
    -- weapon set BEFORE disabling so the lock holds Bunzi/Ammurapi/Sroda -
    -- equip() only diverts an item to not_sent_out_equip when the slot is
    -- ALREADY disabled (GearSwap helper_functions.lua:321), so equip-then-disable
    -- in the same frame works. Accept both stateField spellings: 'CombatMode'
    -- (CycleHandler key) and 'Combat Mode' (Mote-SelfCommands description).
    if stateField == 'CombatMode' or stateField == 'Combat Mode' then
        if newValue == 'On' then
            equip({ main = "Bunzi's Rod", sub = "Ammurapi Shield", ammo = "Sroda Tathlum" })
            disable('main', 'sub', 'range', 'ammo')
        else
            -- Don't steal the disable from an active craft/fish session.
            local craft_active = _G.CraftManager and _G.CraftManager.is_active()
            if not craft_active then
                enable('main', 'sub', 'range', 'ammo')
            end
        end
    end

    update_ui()
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export globally for GearSwap
_G.job_self_command = job_self_command
_G.job_state_change = job_state_change


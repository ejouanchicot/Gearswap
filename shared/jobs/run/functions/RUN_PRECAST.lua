---============================================================================
--- RUN Precast Module - Precast Action Handling & Cooldown Monitoring
---============================================================================
--- Handles all precast actions for Rune Fencer job:
---   • Debuff blocking (Amnesia, Silence, Stun)
---   • Universal cooldown checking (abilities/spells)
---   • Weaponskill validation and range checking
---   • TP bonus optimization for weaponskills
---   • Fast Cast gear with fallback system (spell-specific > skill-specific > base)
---
--- Fast Cast Fallback (Spells only):
---   1. sets.precast.FC['Blink'] (spell-specific)
---   2. sets.precast.FC['Enhancing Magic'] (skill-specific)
---   3. sets.precast.FC (base)
---
--- Uses centralized systems for validation and messaging consistency.
---
--- @file    RUN_PRECAST.lua
--- @author  Tetsouo
--- @version 1.2.0 - Added Fast Cast fallback system
--- @date    Created: 2025-10-03 | Updated: 2025-11-11
--- @requires Tetsouo architecture, MessageFormatter, CooldownChecker
---============================================================================

---============================================================================
--- DEPENDENCIES - LAZY LOADING (Performance Optimization)
---============================================================================

local MessagePrecast = nil
local CooldownChecker = nil
local AbilityHelper = nil
local PrecastGuard = nil
local WSPrecastHandler = nil
local RUNTPConfig = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    local _, mp = pcall(require, 'shared/utils/messages/formatters/magic/message_precast')
    MessagePrecast = mp

    local _, cc = pcall(require, 'shared/utils/precast/cooldown_checker')
    CooldownChecker = cc

    local _, ah = pcall(require, 'shared/utils/precast/ability_helper')
    AbilityHelper = ah

    local _, pg = pcall(require, 'shared/utils/debuff/precast_guard')
    PrecastGuard = pg

    local _, wph = pcall(require, 'shared/utils/precast/ws_precast_handler')
    WSPrecastHandler = wph

    RUNTPConfig = _G.RUNTPConfig or {}

    modules_loaded = true
end

---============================================================================
--- COOLDOWN EXCLUSIONS
---============================================================================
--- Abilities that should NEVER be checked for cooldown
--- Player manages these charges/cooldowns manually
---
--- Scholar Stratagems (RUN/SCH):
---   • Charge-based system (0-5 charges max)
---   • Complex recharge timing (varies by job level)
---   • Player manages strategically - no automation needed
---============================================================================

local cooldown_exclusions = {
    -- Scholar Stratagems (charge-based abilities)
    ['Light Arts'] = true,
    ['Dark Arts'] = true,
    ['Addendum: White'] = true,
    ['Addendum: Black'] = true,
    ['Stratagem'] = true,
    ['Tabula Rasa'] = true,
    -- Individual stratagems
    ['Ebullience'] = true,
    ['Rapture'] = true,
    ['Altruism'] = true,
    ['Tranquility'] = true,
    ['Perpetuance'] = true,
    ['Immanence'] = true,
    ['Accession'] = true,
    ['Manifestation'] = true,
    ['Parsimony'] = true,
    ['Penury'] = true,
    ['Celerity'] = true,
    ['Alacrity'] = true,
    ['Focalization'] = true,
    ['Equanimity'] = true,
    ['Enlightenment'] = true,
    ['Klimaform'] = true
}

---============================================================================
--- AUTO-ABILITY SYSTEM
---============================================================================
--- Automatically triggers beneficial abilities before specific spells.
--- Uses AbilityHelper for smart cooldown checking and timing.
---
--- RUN does not have PLD-specific abilities (Divine Emblem, Majesty).
--- Auto-abilities disabled for RUN job.
---============================================================================

local auto_abilities = {
    -- No auto-abilities for RUN
}

---============================================================================
--- PRECAST HOOK
---============================================================================

--- Called before any action (WS, JA, spell, etc.)
--- Processing order (CRITICAL - do not reorder):
---   1. Debuff guard (PrecastGuard) - blocks if silenced/amnesia/stunned
---   2. Cooldown check (CooldownChecker) - validates ability/spell ready
---   3. Auto-abilities (AbilityHelper) - none for RUN
---   4. WS validation + TP bonus (WSPrecastHandler) - unified handling
---   5. RUN-specific gear (Fast Cast for cures/Flash)
---
--- @param spell     table  Spell/ability data
--- @param action    string Action type (not used)
--- @param spellMap  string Spell mapping (not used)
--- @param eventArgs table  Event arguments (cancel flag, etc.)
--- @return void
function job_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    -- ==========================================================================
    -- STEP 1: DEBUFF BLOCKING
    -- ==========================================================================
    -- Check for blocking debuffs (Amnesia, Silence, Stun, etc.)
    -- Prevents unnecessary equipment swaps when actions are blocked
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return -- Action blocked by debuff, exit immediately
    end

    -- ==========================================================================
    -- STEP 2: COOLDOWN VALIDATION
    -- ==========================================================================
    -- Universal cooldown check - works for ALL abilities and spells
    -- EXCLUDES abilities in cooldown_exclusions table (Scholar Stratagems, etc.)
    local is_excluded = cooldown_exclusions[spell.name]

    if not is_excluded then
        if spell.action_type == 'Ability' then
            CooldownChecker.check_ability_cooldown(spell, eventArgs)
        elseif spell.action_type == 'Magic' then
            CooldownChecker.check_spell_cooldown(spell, eventArgs)
        end

        -- Exit if action cancelled due to cooldown
        if eventArgs.cancel then
            return
        end
    end

    -- ==========================================================================
    -- DISABLED: RUN Job Abilities Messages
    -- Messages now handled by universal ability_message_handler (init_ability_messages.lua)
    -- This prevents duplicate messages from job-specific + universal system
    --
    -- LEGACY CODE (commented out to prevent duplicates):
    -- if spell.type == 'JobAbility' and JA_DB[spell.english] then
    --     MessageFormatter.show_ja_activated(spell.english, JA_DB[spell.english].description)
    -- end

    -- ==========================================================================
    -- STEP 3: AUTO-ABILITIES
    -- ==========================================================================
    -- No auto-abilities for RUN (table is empty)
    if spell.action_type == 'Magic' and auto_abilities[spell.name] then
        auto_abilities[spell.name](spell, eventArgs)
    end

    -- ==========================================================================
    -- WEAPONSKILL HANDLING (Unified via WSPrecastHandler)
    -- ==========================================================================
    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, RUNTPConfig) then
        return
    end

    -- ==========================================================================
    -- RUN-SPECIFIC PRECAST GEAR
    -- ==========================================================================
    -- Fast Cast is handled automatically by Mote-Include (sets.precast.FC)
    -- No job-specific logic needed here
end

---============================================================================
--- POST-PRECAST HOOK
---============================================================================

--- Apply TP bonus gear and display final TP (Universal via TPBonusHandler)
--- Called after precast set selection, before gear is equipped
---
--- @param spell     table  Spell/ability data
--- @param action    string Action type (not used)
--- @param spellMap  string Spell mapping (not used)
--- @param eventArgs table  Event arguments (not used)
--- @return void
function job_post_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()
    if WSPrecastHandler then
        WSPrecastHandler.apply_tp_gear(spell)
    end

    -- ==========================================================================
    -- DEBUG: PRECAST SET DISPLAY (Universal System)
    -- ==========================================================================
    -- Mote-Include already handles FC fallback: spell.name > spell.skill > base
    -- We just add debug display to show which set was selected
    if _G.PrecastDebugState and spell.action_type == 'Magic' then
        local selected_set = nil
        local set_name = 'sets.precast.FC'

        -- Detect which set Mote-Include selected
        if sets.precast.FC[spell.name] then
            selected_set = sets.precast.FC[spell.name]
            set_name = 'sets.precast.FC.' .. spell.name
        elseif spell.skill and sets.precast.FC[spell.skill] then
            selected_set = sets.precast.FC[spell.skill]
            set_name = 'sets.precast.FC[\'' .. spell.skill .. '\']'
        else
            selected_set = sets.precast.FC
            set_name = 'sets.precast.FC'
        end

        -- Show debug info
        MessagePrecast.show_debug_header(spell.name, spell.skill or 'Unknown')
        MessagePrecast.show_equipped_set(set_name)

        if selected_set then
            MessagePrecast.show_equipment(selected_set)
        end

        MessagePrecast.show_completion()
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

-- Export as module (for future require() usage)
return {
    job_precast = job_precast,
    job_post_precast = job_post_precast
}

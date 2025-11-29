---============================================================================
--- PLD Precast Module - Precast Action Handling & Cooldown Monitoring
---============================================================================
--- Handles all precast actions for Paladin job:
---   • Debuff blocking (Amnesia, Silence, Stun)
---   • Universal cooldown checking (abilities/spells)
---   • Auto-ability triggering (Majesty, Divine Emblem)
---   • Weaponskill validation and range checking
---   • TP bonus optimization for weaponskills
---   • Fast Cast gear for spells
---
--- Uses centralized systems for validation and messaging consistency.
---
--- @file    PLD_PRECAST.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-10-03
--- @requires Tetsouo architecture, MessageFormatter, CooldownChecker
---============================================================================

---============================================================================
--- DEPENDENCIES - LAZY LOADING (Performance Optimization)
---============================================================================

local CooldownChecker = nil
local AbilityHelper = nil
local PrecastGuard = nil
local WSPrecastHandler = nil
local PLDTPConfig = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    local _, cc = pcall(require, 'shared/utils/precast/cooldown_checker')
    CooldownChecker = cc

    local _, ah = pcall(require, 'shared/utils/precast/ability_helper')
    AbilityHelper = ah

    local _, pg = pcall(require, 'shared/utils/debuff/precast_guard')
    PrecastGuard = pg

    local _, wph = pcall(require, 'shared/utils/precast/ws_precast_handler')
    WSPrecastHandler = wph

    PLDTPConfig = _G.PLDTPConfig or {}

    modules_loaded = true
end

---============================================================================
--- COOLDOWN EXCLUSIONS
---============================================================================
--- Abilities that should NEVER be checked for cooldown
--- Player manages these charges/cooldowns manually
---
--- Scholar Stratagems (PLD/SCH):
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
--- Triggered abilities:
---   • Divine Emblem - Before Flash (enmity boost)
---   • Majesty - Before Protect III/IV/V, Cure III/IV (potency boost)
---============================================================================

local auto_abilities = {
    ['Flash'] = function(spell, eventArgs)
        AbilityHelper.try_ability(spell, eventArgs, 'Divine Emblem', 2)
    end,
    ['Protect III'] = function(spell, eventArgs)
        AbilityHelper.try_ability_smart(spell, eventArgs, 'Majesty', 2)
    end,
    ['Protect IV'] = function(spell, eventArgs)
        AbilityHelper.try_ability_smart(spell, eventArgs, 'Majesty', 2)
    end,
    ['Protect V'] = function(spell, eventArgs)
        AbilityHelper.try_ability_smart(spell, eventArgs, 'Majesty', 2)
    end,
    ['Cure III'] = function(spell, eventArgs)
        AbilityHelper.try_ability_smart(spell, eventArgs, 'Majesty', 2)
    end,
    ['Cure IV'] = function(spell, eventArgs)
        AbilityHelper.try_ability_smart(spell, eventArgs, 'Majesty', 2)
    end
}

---============================================================================
--- PRECAST HOOK
---============================================================================

--- Called before any action (WS, JA, spell, etc.)
--- Processing order (CRITICAL - do not reorder):
---   1. Debuff guard (PrecastGuard) - blocks if silenced/amnesia/stunned
---   2. Cooldown check (CooldownChecker) - validates ability/spell ready
---   3. Auto-abilities (AbilityHelper) - triggers Majesty/Divine Emblem
---   4. WS validation (WeaponSkillManager) - range check + validation
---   5. TP bonus calculation (TPBonusCalculator) - optimize WS gear
---   6. PLD-specific gear (Fast Cast for cures/Flash)
---
--- @param spell     table  Spell/ability data
--- @param action    string Action type (not used)
--- @param spellMap  string Spell mapping (not used)
--- @param eventArgs table  Event arguments (cancel flag, etc.)
--- @return void
function job_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    -- STEP 1: Debuff guard
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return
    end

    -- STEP 2: Cooldown check (with exclusions for Scholar Stratagems)
    local is_excluded = cooldown_exclusions[spell.name]
    if not is_excluded and CooldownChecker then
        if spell.action_type == 'Ability' then
            CooldownChecker.check_ability_cooldown(spell, eventArgs)
        elseif spell.action_type == 'Magic' then
            CooldownChecker.check_spell_cooldown(spell, eventArgs)
        end
        if eventArgs.cancel then
            return
        end
    end

    -- PLD-SPECIFIC: Auto-abilities (Majesty, Divine Emblem)
    if spell.action_type == 'Magic' and auto_abilities[spell.name] and AbilityHelper then
        auto_abilities[spell.name](spell, eventArgs)
    end

    -- WEAPONSKILL HANDLING (Unified via WSPrecastHandler)
    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, PLDTPConfig) then
        return
    end

    -- PLD-SPECIFIC PRECAST GEAR
    if spell.skill == 'Healing Magic' and sets.precast and sets.precast['Cure'] then
        equip(sets.precast['Cure'])
    end

    if spell.name == 'Flash' and sets.precast and sets.precast['Flash'] then
        equip(sets.precast['Flash'])
    end
end

---============================================================================
--- POST-PRECAST HOOK
---============================================================================

--- Apply TP bonus gear (unified via WSPrecastHandler)
function job_post_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()
    if WSPrecastHandler then
        WSPrecastHandler.apply_tp_gear(spell)
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

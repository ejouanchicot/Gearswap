---  ═══════════════════════════════════════════════════════════════════════════
---   PLD Precast Module - Precast Action Handling & Auto-Abilities
---  ═══════════════════════════════════════════════════════════════════════════
---   Debuff guard, cooldown check, auto-abilities (Majesty/Divine Emblem),
---   WS handling.
---
---   @file    PLD_PRECAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-05
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

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

-- Scholar Stratagems skipped from cooldown check (charge-based, player manages manually)

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

-- Auto-abilities: Divine Emblem before Flash, Majesty before Protect/Cure

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

--- Precast order: debuff guard → cooldown → auto-abilities → WS handler → job gear
---   @param spell table Spell/ability data
---   @param action string Action type
---   @param spellMap string Spell mapping
---   @param eventArgs table Event arguments
function job_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    -- Debuff guard
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return
    end

    -- Cooldown check (skip Scholar Stratagems)
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

---   Apply final gear adjustments before equipping
---   @param spell table Spell/ability data
---   @param action string Action type
---   @param spellMap string Spell mapping
---   @param eventArgs table Event arguments
function job_post_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()
    if WSPrecastHandler then
        WSPrecastHandler.apply_tp_gear(spell)
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

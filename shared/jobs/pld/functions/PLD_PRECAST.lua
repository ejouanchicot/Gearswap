---  ═══════════════════════════════════════════════════════════════════════════
---   PLD Precast Module - Precast Action Handling & Auto-Abilities
---  ═══════════════════════════════════════════════════════════════════════════
---   Debuff guard, cooldown check, auto-abilities (Majesty/Divine Emblem),
---   WS handling (with /SCH weaponskill variants), max-enmity override
---   (Sortie / Tanking).
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
local EnmityOverride = nil
local PLDTPConfig = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    local cc_ok, cc = pcall(require, 'shared/utils/precast/cooldown_checker')
    if not cc_ok then cc = nil end
    CooldownChecker = cc

    local ah_ok, ah = pcall(require, 'shared/utils/precast/ability_helper')
    if not ah_ok then ah = nil end
    AbilityHelper = ah

    local pg_ok, pg = pcall(require, 'shared/utils/debuff/precast_guard')
    if not pg_ok then pg = nil end
    PrecastGuard = pg

    local wph_ok, wph = pcall(require, 'shared/utils/precast/ws_precast_handler')
    if not wph_ok then wph = nil end
    WSPrecastHandler = wph

    local eo_ok, eo = pcall(require, 'shared/jobs/pld/functions/logic/enmity_override')
    if not eo_ok then eo = nil end
    EnmityOverride = eo

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

---   Swap in the /SCH variant of a weaponskill set, where one exists
---   PLD/SCH is the Sortie-only setup and builds its weaponskills differently
---   from the general tanking one, so sets.precast.WS.SCH holds the variants.
---   Runs in post_precast because Mote has laid down sets.precast.WS[name] by
---   then, and before apply_tp_gear so the TP bonus piece still wins.
---   @param spell table Spell/ability data
---   @return void
local function apply_sch_ws_set(spell)
    if spell.type ~= 'WeaponSkill' or not (player and player.sub_job == 'SCH') then
        return
    end

    local sch_sets = sets.precast and sets.precast.WS and sets.precast.WS.SCH
    local ws_set = sch_sets and (sch_sets[spell.english] or sch_sets[spell.name])
    if ws_set then
        equip(ws_set)
    end
end

---   Apply final gear adjustments before equipping
---   @param spell table Spell/ability data
---   @param action string Action type
---   @param spellMap string Spell mapping
---   @param eventArgs table Event arguments
function job_post_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    apply_sch_ws_set(spell)

    if WSPrecastHandler then
        WSPrecastHandler.apply_tp_gear(spell)
    end

    -- Cure III/IV Self: low-HP FC set (Enif Cosciales) to minimize overcure waste
    -- Must be in post_precast to override Mote-Include's standard FC equip
    if (spell.name == 'Cure III' or spell.name == 'Cure IV')
        and spell.target and spell.target.type == 'SELF'
        and sets.precast and sets.precast.FC and sets.precast.FC.CureSelf then
        equip(sets.precast.FC.CureSelf)
    end

    -- Hate-holding modes: job abilities also get what sets.EnmityMax adds
    if EnmityOverride then
        EnmityOverride.apply_precast(spell)
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

-- Module table for require() compatibility (parity with _G exports above)
return {
    job_precast = job_precast,
    job_post_precast = job_post_precast,
}

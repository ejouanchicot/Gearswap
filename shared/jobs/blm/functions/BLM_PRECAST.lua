---  ═══════════════════════════════════════════════════════════════════════════
---   BLM Precast Module - Precast Action Handling & Intelligent Spell Refinement
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles precast gear for Black Mage job:
---   • Fast Cast for all spells (cap 80%)
---   • Job Abilities (Manafont, Manawall, Elemental Seal)
---   • Intelligent Spell Refinement (automatic tier downgrading)
---     - Elemental Magic: Fire VI >> V >> IV >> III >> II >> I
---     - AOE Spells: Firaja >> Firaga III >> II >> I
---     - Enfeebling: Sleep III >> II >> I, Sleepga II >> I, etc.
---     - Dark Magic: Bio V >> IV >> III >> II >> I, Drain III >> II >> I, etc.
---   • Death spell handling (HP-based damage)
---   • Security layers (debuff guard, cooldown check for non-tiered spells)
---
---   @file    BLM_PRECAST.lua
---   @author  Tetsouo
---   @version 2.0 - Universal Refinement Integration
---   @date    Created: 2025-10-15 | Updated: 2025-10-15
---   @requires Tetsouo architecture, MessageFormatter, CooldownChecker, spell_refiner
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local CooldownChecker = nil
local PrecastGuard = nil
local WSPrecastHandler = nil
local BLMTPConfig = nil
local BLM_SPELL_FILTERS = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    local _, cc = pcall(require, 'shared/utils/precast/cooldown_checker')
    CooldownChecker = cc

    local _, pg = pcall(require, 'shared/utils/debuff/precast_guard')
    PrecastGuard = pg

    local _, wph = pcall(require, 'shared/utils/precast/ws_precast_handler')
    WSPrecastHandler = wph

    BLMTPConfig = _G.BLMTPConfig or {}

    -- Load BLM spell filters (cached by Lua after first require)
    local _, filters = pcall(require, 'shared/data/spells/BLM_SPELL_FILTERS')
    BLM_SPELL_FILTERS = filters

    modules_loaded = true
end

-- NOTE: BLM logic functions are loaded globally via blm_functions.lua:
--   • refine_various_spells() - Spell tier downgrading
--   • checkArts() - Scholar subjob Dark Arts automation
-- These functions are available in _G scope and called directly

---  ═══════════════════════════════════════════════════════════════════════════
---   HELPER FUNCTIONS (Lazy Loaded - Safe to Call After ensure_modules_loaded)
---  ═══════════════════════════════════════════════════════════════════════════

---   Check if an ability has multiple charges (bypass cooldown check)
---   @param spell table Spell object
---   @return boolean true if ability has charges
local function has_charges(spell)
    return BLM_SPELL_FILTERS and BLM_SPELL_FILTERS.CHARGE_ABILITIES[spell.english] or false
end

---   Check if a spell should use refinement instead of cooldown check
---   @param spell table Spell object
---   @return boolean true if spell uses refinement
local function uses_refinement(spell)
    if not BLM_SPELL_FILTERS then return false end

    -- Check by skill first (Elemental Magic), but exclude Storm/Klimaform (no tiers)
    if spell.skill == 'Elemental Magic' then
        if BLM_SPELL_FILTERS.ELEMENTAL_NO_TIERS[spell.english] then
            return false
        end
        return true
    end

    -- Check by spell name for other tiered spells
    return BLM_SPELL_FILTERS.REFINEMENT_SPELLS[spell.english] or false
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PRECAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

--- Stage 2: recast, or a tier downgrade for the spells that have one.
---
--- Three routes, and which one applies is not obvious from the call site.
--- Stratagems hold charges, so FFXI blocks them itself and a cooldown check
--- would refuse a cast the game would have allowed. Tiered spells go through
--- refinement, which checks the recast itself and steps down a tier rather
--- than cancelling. Everything else takes the plain check.
local function check_recast_or_refine(spell, eventArgs)
    if spell.action_type == 'Ability' then
        if not has_charges(spell) and CooldownChecker then
            CooldownChecker.check_ability_cooldown(spell, eventArgs)
        end

    elseif spell.action_type == 'Magic' then
        if uses_refinement(spell) then
            if refine_various_spells then
                refine_various_spells(spell, eventArgs)
            end
        elseif CooldownChecker then
            CooldownChecker.check_spell_cooldown(spell, eventArgs)
        end
    end
end

--- Impact needs Twilight Cloak on, and needs it to stay on.
---
--- The spell cannot be cast without the cloak and fails if the body slot
--- changes mid-cast, so the flags exist to stop anything else touching it -
--- the same arrangement BRD uses for Marsyas.
local function lock_body_for_impact()
    equip({body = 'Twilight Cloak'})
    _G.casting_impact = true
    _G.impact_body = 'Twilight Cloak'
end

function job_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return
    end

    check_recast_or_refine(spell, eventArgs)
    if eventArgs.cancel then
        return
    end

    -- BLM/SCH puts Dark Arts up before a nuke. checkArts is a global from
    -- blm_functions.lua and may not be loaded on every path.
    if spell.skill == 'Elemental Magic' and checkArts then
        checkArts(spell, eventArgs)
    end

    if spell.english == 'Impact' then
        lock_body_for_impact()
    end

    if spell.type == 'WeaponSkill' then
        if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, BLMTPConfig) then
            return
        end
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

-- Export global for GearSwap (Mote-Include)
_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

-- Module table for require() compatibility (parity with _G exports above)
return {
    job_precast = job_precast,
    job_post_precast = job_post_precast,
}


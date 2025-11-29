---============================================================================
--- THF Precast Module - Precast Action Handling & Cooldown Monitoring
---============================================================================
--- Handles all precast actions for Thief job with intelligent SA/TA combo
--- detection, treasure hunter tagging, and weaponskill optimization:
---   • Weaponskill precast (Fast Cast, TP bonus optimization, SA/TA variants)
---   • Job ability precast (Sneak Attack, Trick Attack, Flee, Hide, etc.)
---   • Fast cast for subjob spells (NIN/DNC/WAR/etc.)
---   • Cooldown tracking with formatted messages
---   • Debuff guard integration (blocks actions if silenced/amnesia)
---   • WS range validation (6y melee, 15y ranged)
---   • TP bonus calculation (Moonshade Earring automation)
---   • SA/TA pending flag tracking (instant detection before buff appears)
---   • Treasure Hunter tagging support (TreasureMode state)
---
--- Processing Order (CRITICAL - do not reorder):
---   1. Debuff guard (PrecastGuard) - blocks if silenced/amnesia/stunned
---   2. Cooldown check (CooldownChecker) - validates ability/spell ready
---   3. SA/TA pending flags (instant detection before buff appears)
---   4. WS validation (WeaponSkillManager) - TP check + range check
---   5. TP bonus calculation (TPBonusCalculator) - optimize WS gear
---   6. SA/TA variant selection (SATAManager) - apply set variants
---
--- @file    THF_PRECAST.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-06
--- @requires Tetsouo architecture, THF logic modules, TPBonusCalculator
---============================================================================

---============================================================================
--- DEPENDENCIES - LAZY LOADING (Performance Optimization)
---============================================================================

local CooldownChecker = nil
local PrecastGuard = nil
local WSPrecastHandler = nil
local SATAManager = nil
local THFTPConfig = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    local _, cc = pcall(require, 'shared/utils/precast/cooldown_checker')
    CooldownChecker = cc

    local _, pg = pcall(require, 'shared/utils/debuff/precast_guard')
    PrecastGuard = pg

    local _, wph = pcall(require, 'shared/utils/precast/ws_precast_handler')
    WSPrecastHandler = wph

    SATAManager = require('shared/jobs/thf/functions/logic/sa_ta_manager')
    THFTPConfig = _G.THFTPConfig or {}

    modules_loaded = true
end

---============================================================================
--- PRECAST HOOKS
---============================================================================

--- Called before any action (WS, JA, spell, etc.)
--- @param spell table Spell/ability data
--- @param action string Action type
--- @param spellMap string Spell mapping
--- @param eventArgs table Event arguments
--- @return void
function job_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    -- FIRST: Debuff guard
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return
    end

    -- SECOND: Cooldown check
    if CooldownChecker then
        if spell.action_type == 'Ability' then
            CooldownChecker.check_ability_cooldown(spell, eventArgs)
        elseif spell.action_type == 'Magic' then
            CooldownChecker.check_spell_cooldown(spell, eventArgs)
        end
    end

    if eventArgs.cancel then
        return
    end

    -- THF-SPECIFIC: Set pending flags for SA/TA (before buff appears)
    if spell.type == 'JobAbility' then
        if spell.name == 'Sneak Attack' then
            _G.thf_sa_pending = true
        elseif spell.name == 'Trick Attack' then
            _G.thf_ta_pending = true
        end
    end

    -- WEAPONSKILL HANDLING (Unified via WSPrecastHandler)
    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, THFTPConfig) then
        return
    end
end

---============================================================================
--- POST-PRECAST HOOK (Called AFTER set selection, BEFORE equipping)
---============================================================================

--- Apply THF-specific gear adjustments
function job_post_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    -- Apply TP gear via unified handler
    if WSPrecastHandler then
        WSPrecastHandler.apply_tp_gear(spell)
    end

    -- THF-SPECIFIC: Apply WS set variant based on SA/TA buffs
    if spell.type == 'WeaponSkill' and SATAManager then
        SATAManager.apply_variant(spell)
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Make job_precast available globally for GearSwap
_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

-- Also export as module for potential future use
local THF_PRECAST = {}
THF_PRECAST.job_precast = job_precast
THF_PRECAST.job_post_precast = job_post_precast

return THF_PRECAST

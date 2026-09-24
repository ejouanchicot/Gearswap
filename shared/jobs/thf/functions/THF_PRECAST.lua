---  ═══════════════════════════════════════════════════════════════════════════
---   THF Precast Module - Precast Action Handling & Cooldown Monitoring
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles all precast actions for Thief job with intelligent SA/TA combo
---   detection, treasure hunter tagging, and weaponskill optimization:
---   • Weaponskill precast (TP bonus optimization, SA/TA variants)
---   • Job ability and Fast Cast sets are left to Mote-Include
---   • Cooldown tracking with formatted messages
---   • Debuff guard integration (blocks actions if silenced/amnesia)
---   • WS range validation (6y melee, 15y ranged)
---   • TP bonus calculation (Moonshade Earring automation)
---   • SA/TA pending flag tracking (instant detection before buff appears)
---
---   Processing Order (CRITICAL - do not reorder):
---   1. Debuff guard (PrecastGuard) - blocks if silenced/amnesia/stunned
---   2. Cooldown check (CooldownChecker) - validates ability/spell ready
---   3. SA/TA pending flags (instant detection before buff appears)
---   4. WS validation (WSPrecastHandler) - TP check + range check
---   5. TP bonus calculation (TPBonusCalculator) - optimize WS gear
---   6. SA/TA variant selection (SATAManager) - apply set variants
---   7. TP bonus gear applied last (post-precast), over the variant
---
---   @file    shared/jobs/thf/functions/THF_PRECAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-06
---   @requires shared/jobs/thf/functions/logic/sa_ta_manager, WSPrecastHandler
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local CooldownChecker = nil
local PrecastGuard = nil
local WSPrecastHandler = nil
local SATAManager = nil
local THFTPConfig = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    local cc_ok, cc = pcall(require, 'shared/utils/precast/cooldown_checker')
    if not cc_ok then cc = nil end
    CooldownChecker = cc

    local pg_ok, pg = pcall(require, 'shared/utils/debuff/precast_guard')
    if not pg_ok then pg = nil end
    PrecastGuard = pg

    local wph_ok, wph = pcall(require, 'shared/utils/precast/ws_precast_handler')
    if not wph_ok then wph = nil end
    WSPrecastHandler = wph

    local sm_ok, sm = pcall(require, 'shared/jobs/thf/functions/logic/sa_ta_manager')
    if not sm_ok then sm = nil end
    SATAManager = sm
    THFTPConfig = _G.THFTPConfig or {}

    modules_loaded = true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PRECAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

---   Called before any action (WS, JA, spell, etc.)
---   @param spell table Spell/ability data
---   @param action string Action type
---   @param spellMap string Spell mapping
---   @param eventArgs table Event arguments
---   @return void
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

---  ═══════════════════════════════════════════════════════════════════════════
---   POST-PRECAST HOOK (Called AFTER set selection, BEFORE equipping)
---  ═══════════════════════════════════════════════════════════════════════════

---   Apply THF-specific gear adjustments
---   @param spell table Spell/ability data
---   @param action string Action type
---   @param spellMap string Spell mapping
---   @param eventArgs table Event arguments
function job_post_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    -- THF-SPECIFIC: Apply WS set variant based on SA/TA buffs.
    -- Before the TP gear: the variants are full WS sets and would overwrite
    -- the Moonshade Earring.
    if spell.type == 'WeaponSkill' and SATAManager then
        SATAManager.apply_variant(spell)
    end

    -- Apply TP gear via unified handler
    if WSPrecastHandler then
        WSPrecastHandler.apply_tp_gear(spell)
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

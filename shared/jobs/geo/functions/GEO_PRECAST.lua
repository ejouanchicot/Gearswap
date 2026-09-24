---  ═══════════════════════════════════════════════════════════════════════════
---   GEO Precast Module - Precast Action Handling & Cooldown Monitoring
---  ═══════════════════════════════════════════════════════════════════════════
---   Precast hook for Geomancer. Precast gear itself (Fast Cast, JA sets) is
---   chosen by Mote from sets.precast; this module adds:
---   • PrecastGuard (debuffs) then CooldownChecker (abilities and spells)
---   • Entrust pending flag (read by GEO_MIDCAST before the buff appears)
---   • WSPrecastHandler for weaponskills and TP bonus gear
---
---   @file    shared/jobs/geo/functions/GEO_PRECAST.lua
---   @author  Tetsouo
---   @version 2.0
---   @date    Created: 2025-10-09
---   @requires Tetsouo architecture, MessageFormatter, CooldownChecker
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local CooldownChecker = nil
local PrecastGuard = nil
local WSPrecastHandler = nil
local GEOTPConfig = nil

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

    GEOTPConfig = _G.GEOTPConfig or {}

    modules_loaded = true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PRECAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

---   Handle precast actions
---   @param spell table Spell/ability data
---   @param action table Action information from GearSwap
---   @param spellMap string Spell mapping
---   @param eventArgs table Event arguments
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

    -- Raised optimistically: aftercast lowers it again if Entrust is interrupted
    if spell.type == 'JobAbility' and spell.name == 'Entrust' then
        _G.geo_entrust_pending = true
    end

    -- WEAPONSKILL HANDLING (Unified via WSPrecastHandler)
    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, GEOTPConfig) then
        return
    end
end

---   Apply final gear adjustments before equipping
---   @param spell table Spell/ability data
---   @param action table Action information from GearSwap
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


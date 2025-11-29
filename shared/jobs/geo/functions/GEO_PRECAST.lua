---============================================================================
--- GEO Precast Module - Precast Action Handling & Cooldown Monitoring
---============================================================================
--- Handles precast gear for Geomancer job:
---   • Fast Cast for all spells
---   • Job Abilities (Radial Arcana, Ecliptic Attrition, Life Cycle)
---   • Geomancy spells precast (Indi/Geo)
---   • Entrust ability logic
---   • Security layers (debuff guard, cooldown check)
---
--- @file    GEO_PRECAST.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-10-09
--- @requires Tetsouo architecture, MessageFormatter, CooldownChecker
---============================================================================

---============================================================================
--- DEPENDENCIES - LAZY LOADING (Performance Optimization)
---============================================================================

local CooldownChecker = nil
local PrecastGuard = nil
local WSPrecastHandler = nil
local GEOTPConfig = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    local _, cc = pcall(require, 'shared/utils/precast/cooldown_checker')
    CooldownChecker = cc

    local _, pg = pcall(require, 'shared/utils/debuff/precast_guard')
    PrecastGuard = pg

    local _, wph = pcall(require, 'shared/utils/precast/ws_precast_handler')
    WSPrecastHandler = wph

    GEOTPConfig = _G.GEOTPConfig or {}

    modules_loaded = true
end

---============================================================================
--- PRECAST HOOKS
---============================================================================

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

    -- GEO-SPECIFIC: Entrust pending flag
    if spell.type == 'JobAbility' and spell.name == 'Entrust' then
        _G.geo_entrust_pending = true
    end

    -- WEAPONSKILL HANDLING (Unified via WSPrecastHandler)
    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, GEOTPConfig) then
        return
    end
end

function job_post_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()
    if WSPrecastHandler then
        WSPrecastHandler.apply_tp_gear(spell)
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export global for GearSwap (Mote-Include)
_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

-- Export module
local GEO_PRECAST = {}
GEO_PRECAST.job_precast = job_precast
GEO_PRECAST.job_post_precast = job_post_precast

return GEO_PRECAST

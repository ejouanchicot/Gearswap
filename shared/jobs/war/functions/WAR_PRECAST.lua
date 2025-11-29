---============================================================================
--- WAR Precast Module - Precast Action Handling & Cooldown Monitoring
---============================================================================
--- Handles all precast actions for Warrior job:
---   • Weaponskills preparation & TP gear optimization
---   • Job ability precast logic & cooldown tracking
---   • Fast cast for sub-job spells
---   • Security layers (debuff guard, range checks, validation)
---
--- **PERFORMANCE OPTIMIZATION:**
---   • Lazy-loaded: All modules loaded on first action (saves ~150ms at startup)
---
--- @file    WAR_PRECAST.lua
--- @author  Tetsouo
--- @version 2.1 - Lazy Loading for performance
--- @date    Created: 2025-09-29 | Updated: 2025-11-15
--- @requires Tetsouo architecture, MessageFormatter, CooldownChecker
---============================================================================
---============================================================================
--- DEPENDENCIES (LAZY LOADING for performance)
---============================================================================
-- Modules loaded on first action (saves ~150ms at startup)
local CooldownChecker = nil
local PrecastGuard = nil
local WSPrecastHandler = nil

-- WAR TP configuration (loaded from character main file)
local WARTPConfig = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then
        return
    end

    -- Cooldown checker (universal ability/spell recast validation)
    local _, cc = pcall(require, 'shared/utils/precast/cooldown_checker')
    CooldownChecker = cc

    -- Precast guard (debuff blocking: Amnesia, Silence, Stun, etc.)
    local _, pg = pcall(require, 'shared/utils/debuff/precast_guard')
    PrecastGuard = pg

    -- WS Precast Handler (unified WS validation + TP gear + messages)
    local _, wph = pcall(require, 'shared/utils/precast/ws_precast_handler')
    WSPrecastHandler = wph

    -- Load job TP config
    WARTPConfig = _G.WARTPConfig or {}

    modules_loaded = true
end

---============================================================================
--- PRECAST HOOK - MAIN SECURITY & VALIDATION
---============================================================================

--- Called before any action (WS, JA, spell, etc.)
--- Implements 4-layer security validation:
---   1. PrecastGuard    >> Block if Amnesia/Silence/Stun/etc.
---   2. CooldownChecker >> Block if ability/spell on cooldown
---   3. WeaponSkillManager >> Validate range & weaponskill validity
---   4. TP Bonus Calculation >> Optimize WS TP gear
---
--- @param spell     table  Spell/ability data from GearSwap
--- @param action    string Action type (not used)
--- @param spellMap  string Spell mapping (not used)
--- @param eventArgs table  Event arguments (modified if action cancelled)
--- @return void
function job_precast(spell, action, spellMap, eventArgs)
    -- Lazy load modules on first action
    ensure_modules_loaded()

    -- ==========================================================================
    -- LAYER 1: DEBUFF GUARD (Highest priority)
    -- ==========================================================================
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return -- Action blocked by debuff (Amnesia/Silence/etc.)
    end

    -- ==========================================================================
    -- LAYER 2: COOLDOWN CHECK (Universal for all abilities/spells)
    -- ==========================================================================
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

    -- ==========================================================================
    -- WEAPONSKILL HANDLING (Unified via WSPrecastHandler)
    -- ==========================================================================
    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, WARTPConfig) then
        return
    end
end

---============================================================================
--- POST-PRECAST HOOK - TP GEAR APPLICATION
---============================================================================

--- Apply TP bonus gear (unified via WSPrecastHandler)
--- @param spell     table  Spell/ability data
--- @param action    string Action type (not used)
--- @param spellMap  string Spell mapping (not used)
--- @param eventArgs table  Event arguments (not used)
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

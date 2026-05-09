---  ═══════════════════════════════════════════════════════════════════════════
---   DRK Precast Module - Precast Action Handling & Fast Cast
---  ═══════════════════════════════════════════════════════════════════════════
---   Debuff guard, cooldown check, WS handling, Fast Cast, Last Resort.
---
---   @file    DRK_PRECAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-05
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local CooldownChecker = nil
local PrecastGuard = nil
local WSPrecastHandler = nil
local DRKTPConfig = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    local _, cc = pcall(require, 'shared/utils/precast/cooldown_checker')
    CooldownChecker = cc

    local _, pg = pcall(require, 'shared/utils/debuff/precast_guard')
    PrecastGuard = pg

    local _, wph = pcall(require, 'shared/utils/precast/ws_precast_handler')
    WSPrecastHandler = wph

    DRKTPConfig = _G.DRKTPConfig or {}

    modules_loaded = true
end

local cooldown_exclusions = {
    -- Add DRK-specific exclusions here if needed
}

---   Handle precast actions
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

    -- Cooldown check (with exclusions)
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

    -- DRK-SPECIFIC: Buff pending flags (Dark Seal, Nether Void)
    if spell.type == 'JobAbility' then
        if spell.name == 'Dark Seal' then
            _G.drk_dark_seal_pending = true
        elseif spell.name == 'Nether Void' then
            _G.drk_nether_void_pending = true
        end
    end

    -- WEAPONSKILL HANDLING (Unified via WSPrecastHandler)
    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, DRKTPConfig) then
        return
    end

    -- DRK-SPECIFIC PRECAST GEAR
    if spell.type == 'JobAbility' then
        if spell.name == 'Last Resort' and sets.precast and sets.precast.JA and sets.precast.JA['Last Resort'] then
            equip(sets.precast.JA['Last Resort'])
        elseif spell.name == 'Weapon Bash' and sets.precast and sets.precast.JA and sets.precast.JA['Weapon Bash'] then
            equip(sets.precast.JA['Weapon Bash'])
        elseif spell.name == 'Souleater' and sets.precast and sets.precast.JA and sets.precast.JA['Souleater'] then
            equip(sets.precast.JA['Souleater'])
        elseif spell.name == 'Arcane Circle' and sets.precast and sets.precast.JA and sets.precast.JA['Arcane Circle'] then
            equip(sets.precast.JA['Arcane Circle'])
        end
    end

    -- Fast Cast for Magic
    if spell.action_type == 'Magic' and sets.precast and sets.precast.FC then
        equip(sets.precast.FC)
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

-- Module table for require() compatibility (parity with _G exports above)
return {
    job_precast = job_precast,
    job_post_precast = job_post_precast,
}


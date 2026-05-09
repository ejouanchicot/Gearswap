---  ═══════════════════════════════════════════════════════════════════════════
---   PUP Precast Module - Precast Action Handling & Pet Commands
---  ═══════════════════════════════════════════════════════════════════════════
---   Debuff guard, cooldown check, WS handling, Activate/Deploy/Retrieve.
---
---   @file    PUP_PRECAST.lua
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
local PUPTPConfig = nil
local ReadyMoveCategorizer = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    local _, cc = pcall(require, 'shared/utils/precast/cooldown_checker')
    CooldownChecker = cc

    local _, pg = pcall(require, 'shared/utils/debuff/precast_guard')
    PrecastGuard = pg

    local _, wph = pcall(require, 'shared/utils/precast/ws_precast_handler')
    WSPrecastHandler = wph

    PUPTPConfig = _G.PUPTPConfig or {}

    -- PUP specific
    local _, rmc = pcall(require, 'shared/jobs/pup/functions/logic/ready_move_categorizer')
    ReadyMoveCategorizer = rmc

    modules_loaded = true
end

--- Precast order: debuff guard → cooldown → WS handler → Call Beast → Ready moves
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

    -- Cooldown check (skip Ready Moves - they use charges, not recast)
    local is_ready_move = false
    local ready_move_category = nil
    if ReadyMoveCategorizer and spell.action_type == 'Ability' then
        ready_move_category = ReadyMoveCategorizer.get_category(spell.name)
        is_ready_move = (ready_move_category ~= nil and ready_move_category ~= 'Default')
    end

    if CooldownChecker and not is_ready_move then
        if spell.action_type == 'Ability' then
            CooldownChecker.check_ability_cooldown(spell, eventArgs)
        elseif spell.action_type == 'Magic' then
            CooldownChecker.check_spell_cooldown(spell, eventArgs)
        end
    end
    if eventArgs.cancel then return end

    -- WS handling
    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, PUPTPConfig) then
        return
    end

    -- Call Beast / Bestial Loyalty: equip summon set + broth
    if spell.name == 'Call Beast' or spell.name == 'Bestial Loyalty' then
        if sets.precast.JA['Call Beast'] then
            equip(sets.precast.JA['Call Beast'])
        end
        if state.ammoSet and state.ammoSet.value and sets[state.ammoSet.value] then
            local broth_set = sets[state.ammoSet.value]
            if broth_set and broth_set.ammo then
                equip({ammo = broth_set.ammo})
            end
        end
        return
    end

    -- Ready move precast: equip Sic/Ready set, store category for midcast
    if is_ready_move and ready_move_category then
        if sets.precast.JA['Ready'] then
            equip(sets.precast.JA['Ready'])
        elseif sets.precast.JA['Sic'] then
            equip(sets.precast.JA['Sic'])
        end
        spell.ready_move_category = ready_move_category
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

_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

-- Module table for require() compatibility (parity with _G exports above)
return {
    job_precast = job_precast,
    job_post_precast = job_post_precast,
}

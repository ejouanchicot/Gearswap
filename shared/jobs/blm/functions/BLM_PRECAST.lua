---============================================================================
--- BLM Precast Module - Precast Action Handling & Intelligent Spell Refinement
---============================================================================
--- Handles precast gear for Black Mage job:
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
--- @file    BLM_PRECAST.lua
--- @author  Tetsouo
--- @version 2.0 - Universal Refinement Integration
--- @date    Created: 2025-10-15 | Updated: 2025-10-15
--- @requires Tetsouo architecture, MessageFormatter, CooldownChecker, spell_refiner
---============================================================================

---============================================================================
--- DEPENDENCIES - CENTRALIZED SYSTEMS
---============================================================================

-- Message formatter (cooldown messages, WS TP display)
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Cooldown checker (universal ability/spell recast validation)
local CooldownChecker = require('shared/utils/precast/cooldown_checker')

-- Precast guard (debuff blocking: Amnesia, Silence, Stun, etc.)
local precast_guard_success, PrecastGuard = pcall(require, 'shared/utils/debuff/precast_guard')
if not precast_guard_success then
    PrecastGuard = nil
end

-- Weaponskill manager (WS validation + range checking)
include('../shared/utils/weaponskill/weaponskill_manager.lua')

-- TP bonus calculator (Moonshade Earring automation)
include('../shared/utils/weaponskill/tp_bonus_calculator.lua')

-- TP Bonus Handler (universal WS TP gear optimization)
local _, TPBonusHandler = pcall(require, 'shared/utils/precast/tp_bonus_handler')

-- WS Validator (universal WS range + validity validation)
local _, WSValidator = pcall(require, 'shared/utils/precast/ws_validator')

-- Set MessageFormatter in WeaponSkillManager
if WeaponSkillManager and MessageFormatter then
    WeaponSkillManager.MessageFormatter = MessageFormatter
end

---============================================================================
--- DEPENDENCIES - BLM SPECIFIC
---============================================================================

-- BLM configuration
local BLMTPConfig = _G.BLMTPConfig or {}  -- Loaded from character main file

-- Universal Job Ability Database (supports main job + subjob abilities)
local JA_DB = require('shared/data/job_abilities/UNIVERSAL_JA_DATABASE')

-- Universal Weapon Skills Database (weaponskill descriptions)
local WS_DB = require('shared/data/weaponskills/UNIVERSAL_WS_DATABASE')

-- NOTE: BLM logic functions are loaded globally via blm_functions.lua:
--   • refine_various_spells() - Spell tier downgrading
--   • checkArts() - Scholar subjob Dark Arts automation
-- These functions are available in _G scope and called directly

---============================================================================
--- BLM SPELL LISTS
---============================================================================

-- Spells that use refinement system (bypass CooldownChecker)
-- These spells have tier systems and should use automatic downgrading
local REFINEMENT_SPELLS = {
    -- Elemental Magic (all handled by refinement)
    ['Elemental Magic'] = true,

    -- Enfeebling Magic with tiers
    ['Sleep'] = true,
    ['Sleep II'] = true,
    ['Sleep III'] = true,
    ['Sleepga'] = true,
    ['Sleepga II'] = true,
    ['Break'] = true,
    ['Breakga'] = true,
    ['Bind'] = true,
    ['Bind II'] = true,

    -- Dark Magic with tiers
    ['Bio'] = true,
    ['Bio II'] = true,
    ['Bio III'] = true,
    ['Bio IV'] = true,
    ['Bio V'] = true,
    ['Poison'] = true,
    ['Poison II'] = true,
    ['Poison III'] = true,
    ['Poison IV'] = true,
    ['Poison V'] = true,
    ['Drain'] = true,
    ['Drain II'] = true,
    ['Drain III'] = true,
    ['Aspir'] = true,
    ['Aspir II'] = true,
    ['Aspir III'] = true,
    ['Burn'] = true,
    ['Frost'] = true,
    ['Choke'] = true,
    ['Rasp'] = true,
    ['Shock'] = true,
    ['Drown'] = true
}

--- Elemental Magic spells that do NOT have tiers (excluded from refinement)
--- Note: Spell names must match FFXI resources exactly (all lowercase after first letter)
local ELEMENTAL_NO_TIERS = {
    ['Klimaform'] = true,
    ['Firestorm'] = true,
    ['Sandstorm'] = true,
    ['Rainstorm'] = true,
    ['Windstorm'] = true,
    ['Hailstorm'] = true,
    ['Thunderstorm'] = true,
    ['Voidstorm'] = true,
    ['Aurorastorm'] = true
}

--- Abilities with multiple charges that should bypass cooldown check
--- These abilities use charge system - FFXI blocks when no charges available
local CHARGE_ABILITIES = {
    ['Addendum: White'] = true,
    ['Addendum: Black'] = true,
    ['Accession'] = true,
    ['Manifestation'] = true,
    ['Stratagem'] = true,  -- Generic stratagem abilities
    -- Other multi-charge abilities can be added here if needed
}

--- Check if an ability has multiple charges (bypass cooldown check)
--- @param spell table Spell object
--- @return boolean true if ability has charges
local function has_charges(spell)
    return CHARGE_ABILITIES[spell.english] or false
end

--- Check if a spell should use refinement instead of cooldown check
--- @param spell table Spell object
--- @return boolean true if spell uses refinement
local function uses_refinement(spell)
    -- Check by skill first (Elemental Magic), but exclude Storm/Klimaform (no tiers)
    if spell.skill == 'Elemental Magic' then
        -- Exclude spells without tiers
        if ELEMENTAL_NO_TIERS[spell.english] then
            return false
        end
        return true
    end

    -- Check by spell name for other tiered spells
    return REFINEMENT_SPELLS[spell.english] or false
end

---============================================================================
--- PRECAST HOOKS
---============================================================================

function job_precast(spell, action, spellMap, eventArgs)
    -- FIRST: Check for blocking debuffs (Amnesia, Silence, etc.)
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return
    end

    -- SECOND: Universal cooldown check OR refinement
    -- IMPORTANT: Spells with tier systems use refinement instead of cooldown check
    -- IMPORTANT: Abilities with charges (Stratagems) bypass cooldown check
    if spell.action_type == 'Ability' then
        -- Skip cooldown check for abilities with multiple charges (FFXI handles blocking)
        if not has_charges(spell) then
            CooldownChecker.check_ability_cooldown(spell, eventArgs)
        end
    elseif spell.action_type == 'Magic' then
        if uses_refinement(spell) then
            -- Use refinement system for tiered spells
            -- Refinement handles cooldown checking internally and downgrades tiers
            if refine_various_spells then
                refine_various_spells(spell, eventArgs)
            end
        else
            -- Use standard cooldown check for non-tiered spells
            CooldownChecker.check_spell_cooldown(spell, eventArgs)
        end
    end

    if eventArgs.cancel then
        return
    end

    -- ==========================================================================
    -- JOB ABILITIES MESSAGES (universal - supports main + subjob)
    -- DISABLED: BLM Job Abilities Messages
    -- Messages now handled by universal ability_message_handler (init_ability_messages.lua)
    -- This prevents duplicate messages from job-specific + universal system
    --
    -- LEGACY CODE (commented out to prevent duplicates):
    -- if spell.type == 'JobAbility' and JA_DB[spell.english] then
    --     MessageFormatter.show_ja_activated(spell.english, JA_DB[spell.english].description)
    -- end

    -- BLM-SPECIFIC PRECAST LOGIC

    -- Check Arts for Scholar subjob (Dark Arts automation for Elemental Magic)
    if spell.skill == 'Elemental Magic' then
        -- Function loaded globally via blm_functions.lua
        if checkArts then
            checkArts(spell, eventArgs)
        end
    end

    -- Handle Death spell (special gear)
    if spell.english == 'Death' then
        -- Death uses HP for damage calculation
        -- Special precast gear with high HP
    end

    -- WeaponSkill validation
    if WSValidator and not WSValidator.validate(spell, eventArgs) then
        return  -- WS validation failed, exit immediately
    end

    -- BLM-specific TP Bonus gear optimization for weaponskills
    -- MUST BE DONE BEFORE MESSAGE to calculate final TP correctly
    if TPBonusHandler then
        TPBonusHandler.calculate_tp_gear(spell, BLMTPConfig)
    end

    -- ==========================================================================
    -- WEAPONSKILL MESSAGES (with description + final TP including Moonshade)
    -- ==========================================================================
    if spell.type == 'WeaponSkill' then
        local current_tp = player and player.vitals and player.vitals.tp or 0

        if current_tp >= 1000 then
            -- Check if WS is in database
            if WS_DB and WS_DB[spell.english] then
                -- Calculate final TP (includes Moonshade bonus if equipped)
                local final_tp = current_tp

                -- Try to get final TP with Moonshade bonus
                if TPBonusCalculator and TPBonusCalculator.get_final_tp then
                    local weapon_name = player.equipment and player.equipment.main or nil
                    local sub_weapon = player.equipment and player.equipment.sub or nil
                    local tp_gear = _G.temp_tp_bonus_gear

                    local success, result = pcall(TPBonusCalculator.get_final_tp, current_tp, tp_gear, BLMTPConfig, weapon_name, buffactive, sub_weapon)
                    if success then
                        final_tp = result
                    end
                end
            end
        else
            -- Not enough TP - display error
            MessageFormatter.show_ws_validation_error(spell.english, "Not enough TP", string.format("%d/1000", current_tp))
        end
    end
end

function job_post_precast(spell, action, spellMap, eventArgs)
    -- Apply TP bonus gear (Moonshade Earring) without message (already displayed in precast)
    if spell.type == 'WeaponSkill' then
        local tp_gear = _G.temp_tp_bonus_gear
        if tp_gear then
            equip(tp_gear)
            _G.temp_tp_bonus_gear = nil
        end
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export global for GearSwap (Mote-Include)
_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

-- Export module
local BLM_PRECAST = {}
BLM_PRECAST.job_precast = job_precast
BLM_PRECAST.job_post_precast = job_post_precast

return BLM_PRECAST

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
--- DEPENDENCIES - THF SPECIFIC
---============================================================================

-- THF logic modules (business logic)
local SATAManager = require('shared/jobs/thf/functions/logic/sa_ta_manager')

-- THF configuration
local THFTPConfig = _G.THFTPConfig or {}  -- Loaded from character main file

-- Universal Job Ability Database (supports main job + subjob abilities)
local JA_DB = require('shared/data/job_abilities/UNIVERSAL_JA_DATABASE')

-- Universal Weapon Skills Database (weaponskill descriptions)
local WS_DB = require('shared/data/weaponskills/UNIVERSAL_WS_DATABASE')

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

    -- FIRST: Check for blocking debuffs (Amnesia, Silence, etc.)
    -- This prevents unnecessary equipment swaps when actions are blocked
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        -- Action was blocked by debuff, exit immediately
        return
    end

    -- SECOND: Universal cooldown check - works for ALL abilities and spells
    if spell.action_type == 'Ability' then
        CooldownChecker.check_ability_cooldown(spell, eventArgs)
    elseif spell.action_type == 'Magic' then
        CooldownChecker.check_spell_cooldown(spell, eventArgs)
    end

    -- If action was cancelled due to cooldown, exit early
    if eventArgs.cancel then
        return
    end

    -- ==========================================================================
    -- JOB ABILITIES MESSAGES (universal - supports main + subjob)
    -- DISABLED: THF Job Abilities Messages
    -- Messages now handled by universal ability_message_handler (init_ability_messages.lua)
    -- This prevents duplicate messages from job-specific + universal system
    --
    -- LEGACY CODE (commented out to prevent duplicates):
    -- if spell.type == 'JobAbility' and JA_DB[spell.english] then
    --     MessageFormatter.show_ja_activated(spell.english, JA_DB[spell.english].description)
    -- end

    -- Set pending flags when using SA/TA abilities (before buff is in buffactive)
    if spell.type == 'JobAbility' then
        if spell.name == 'Sneak Attack' then
            _G.thf_sa_pending = true
        elseif spell.name == 'Trick Attack' then
            _G.thf_ta_pending = true
        end
    end

    -- WeaponSkill validation
    if WSValidator and not WSValidator.validate(spell, eventArgs) then
        return  -- WS validation failed, exit immediately
    end

    -- THF-specific TP Bonus gear optimization for weaponskills
    -- MUST BE DONE BEFORE MESSAGE to calculate final TP correctly
    if TPBonusHandler then
        TPBonusHandler.calculate_tp_gear(spell, THFTPConfig)
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

                    local success, result = pcall(TPBonusCalculator.get_final_tp, current_tp, tp_gear, THFTPConfig, weapon_name, buffactive, sub_weapon)
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

---============================================================================
--- POST-PRECAST HOOK (Called AFTER set selection, BEFORE equipping)
---============================================================================

--- Apply THF-specific gear adjustments
--- This is called by GearSwap after job_precast but before actually equipping
function job_post_precast(spell, action, spellMap, eventArgs)
    if spell.type == 'WeaponSkill' then
        -- Apply TP bonus gear (Moonshade Earring) without message (already displayed in precast)
        local tp_gear = _G.temp_tp_bonus_gear
        if tp_gear then
            equip(tp_gear)
            _G.temp_tp_bonus_gear = nil
        end

        -- Apply WS set variant based on SA/TA buffs
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

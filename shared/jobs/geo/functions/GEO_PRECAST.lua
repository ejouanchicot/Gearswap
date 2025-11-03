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
--- DEPENDENCIES - GEO SPECIFIC
---============================================================================

-- GEO configuration
local GEOTPConfig = _G.GEOTPConfig or {}  -- Loaded from character main file

-- Universal Job Ability Database (supports main job + subjob abilities)
local JA_DB = require('shared/data/job_abilities/UNIVERSAL_JA_DATABASE')

-- Universal Weapon Skills Database (weaponskill descriptions)
local WS_DB = require('shared/data/weaponskills/UNIVERSAL_WS_DATABASE')

---============================================================================
--- PRECAST HOOKS
---============================================================================

function job_precast(spell, action, spellMap, eventArgs)
    -- FIRST: Check for blocking debuffs (Amnesia, Silence, etc.)
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return
    end

    -- SECOND: Universal cooldown check
    if spell.action_type == 'Ability' then
        CooldownChecker.check_ability_cooldown(spell, eventArgs)
    elseif spell.action_type == 'Magic' then
        CooldownChecker.check_spell_cooldown(spell, eventArgs)
    end

    if eventArgs.cancel then
        return
    end

    -- GEO-SPECIFIC PRECAST LOGIC

    -- ==========================================================================
    -- JOB ABILITIES MESSAGES (universal - supports main + subjob)
    -- DISABLED: GEO Job Abilities Messages
    -- Messages now handled by universal ability_message_handler (init_ability_messages.lua)
    -- This prevents duplicate messages from job-specific + universal system
    --
    -- LEGACY CODE (commented out to prevent duplicates):
    -- if spell.type == 'JobAbility' and JA_DB[spell.english] then
    --     MessageFormatter.show_ja_activated(spell.english, JA_DB[spell.english].description)
    -- end
    -- ==========================================================================
    -- WEAPONSKILL MESSAGES (universal - all weapon types)
    -- ==========================================================================
    if spell.type == 'WeaponSkill' and WS_DB[spell.english] then
        -- Check if enough TP before displaying WS message
        local current_tp = player and player.vitals and player.vitals.tp or 0
        if current_tp >= 1000 then
            -- Display WS message with current TP (Job doesn't use TPBonusHandler yet)
            MessageFormatter.show_ws_activated(spell.english, WS_DB[spell.english].description, current_tp)
        else
                -- Not enough TP - display error
                MessageFormatter.show_ws_validation_error(spell.english, "Not enough TP", string.format("%d/1000", current_tp))
            end
    end


    -- Handle Geomancy spells (Indi/Geo)
    if spellMap == 'Indi' or spellMap == 'Geo' then
        -- Precast gear (Fast Cast + Geomancy skill)
        -- Midcast will handle the handbell swap
    end

    -- WeaponSkill validation
    if WSValidator and not WSValidator.validate(spell, eventArgs) then
        return  -- WS validation failed, exit immediately
    end

    -- GEO-specific TP Bonus gear optimization for weaponskills
    if TPBonusHandler then
        TPBonusHandler.calculate_tp_gear(spell, GEOTPConfig)
    end
end

function job_post_precast(spell, action, spellMap, eventArgs)
    if TPBonusHandler and spell.type == 'WeaponSkill' then
        -- Apply TP bonus gear only (no display - already shown in precast message)
        TPBonusHandler.calculate_tp_gear(spell, GEOTPConfig)
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

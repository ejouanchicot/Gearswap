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

local MessageFormatter = nil
local CooldownChecker = nil
local PrecastGuard = nil
local TPBonusHandler = nil
local WSValidator = nil
local GEOTPConfig = nil
local JA_DB = nil
local WS_DB = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    MessageFormatter = require('shared/utils/messages/message_formatter')
    CooldownChecker = require('shared/utils/precast/cooldown_checker')

    local precast_guard_success
    precast_guard_success, PrecastGuard = pcall(require, 'shared/utils/debuff/precast_guard')
    if not precast_guard_success then
        PrecastGuard = nil
    end

    local _
    _, TPBonusHandler = pcall(require, 'shared/utils/precast/tp_bonus_handler')
    _, WSValidator = pcall(require, 'shared/utils/precast/ws_validator')

    include('../shared/utils/weaponskill/weaponskill_manager.lua')
    include('../shared/utils/weaponskill/tp_bonus_calculator.lua')

    if WeaponSkillManager and MessageFormatter then
        WeaponSkillManager.MessageFormatter = MessageFormatter
    end

    GEOTPConfig = _G.GEOTPConfig or {}
    JA_DB = require('shared/data/job_abilities/UNIVERSAL_JA_DATABASE')
    WS_DB = require('shared/data/weaponskills/UNIVERSAL_WS_DATABASE')

    modules_loaded = true
end

---============================================================================
--- PRECAST HOOKS
---============================================================================

function job_precast(spell, action, spellMap, eventArgs)
    -- Lazy load all dependencies on first precast
    ensure_modules_loaded()

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

    -- Set pending flag when using Entrust ability (before buff appears in buffactive)
    -- This allows immediate detection in midcast for Indi spell gear selection
    if spell.type == 'JobAbility' and spell.name == 'Entrust' then
        _G.geo_entrust_pending = true
    end

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
    -- MUST BE DONE BEFORE MESSAGE to calculate final TP correctly
    if TPBonusHandler then
        TPBonusHandler.calculate_tp_gear(spell, GEOTPConfig)
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

                    local success, result = pcall(TPBonusCalculator.get_final_tp, current_tp, tp_gear, GEOTPConfig, weapon_name, buffactive, sub_weapon)
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
local GEO_PRECAST = {}
GEO_PRECAST.job_precast = job_precast
GEO_PRECAST.job_post_precast = job_post_precast

return GEO_PRECAST

---============================================================================
--- WAR Precast Module - Precast Action Handling & Cooldown Monitoring
---============================================================================
--- Handles all precast actions for Warrior job:
---   • Weaponskills preparation & TP gear optimization
---   • Job ability precast logic & cooldown tracking
---   • Fast cast for sub-job spells
---   • Security layers (debuff guard, range checks, validation)
---
--- @file    WAR_PRECAST.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-09-29
--- @requires Tetsouo architecture, MessageFormatter, CooldownChecker
---============================================================================
---============================================================================
--- DEPENDENCIES - CENTRALIZED SYSTEMS
---============================================================================
-- Message formatter (cooldown & WS TP display)
local _, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')

-- Cooldown checker (universal ability/spell recast validation)
local _, CooldownChecker = pcall(require, 'shared/utils/precast/cooldown_checker')

-- Precast guard (debuff blocking: Amnesia, Silence, Stun, etc.)
local _, PrecastGuard = pcall(require, 'shared/utils/debuff/precast_guard')

-- TP Bonus Handler (universal WS TP gear optimization)
local _, TPBonusHandler = pcall(require, 'shared/utils/precast/tp_bonus_handler')

-- WS Validator (universal WS range + validity validation)
local _, WSValidator = pcall(require, 'shared/utils/precast/ws_validator')

-- WAR TP configuration (TP bonus gear thresholds)
local WARTPConfig = _G.WARTPConfig or {}  -- Loaded from character main file

-- Universal Job Ability Database (supports main job + subjob abilities)
local JA_DB = require('shared/data/job_abilities/UNIVERSAL_JA_DATABASE')

-- Universal Weapon Skills Database (weaponskill descriptions)
local WS_DB = require('shared/data/weaponskills/UNIVERSAL_WS_DATABASE')

-- WS Messages Configuration (display mode control)
local _, WS_MESSAGES_CONFIG = pcall(require, 'shared/config/WS_MESSAGES_CONFIG')
if not WS_MESSAGES_CONFIG then
    WS_MESSAGES_CONFIG = {display_mode = 'full', is_enabled = function() return true end, show_description = function() return true end}
end

-- Resources library (item/spell lookup)
local res = require('resources')

-- Weaponskill managers (loaded via include for _G availability)
include('../shared/utils/weaponskill/weaponskill_manager.lua')
include('../shared/utils/weaponskill/tp_bonus_calculator.lua')

-- Set MessageFormatter in WeaponSkillManager if both available
if WeaponSkillManager and MessageFormatter then
    WeaponSkillManager.MessageFormatter = MessageFormatter
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
    end -- Exit if cancelled by cooldown

    -- DISABLED: WAR Job Abilities Messages
    -- Messages now handled by universal ability_message_handler (init_ability_messages.lua)
    -- This prevents duplicate messages from job-specific + universal system
    --
    -- LEGACY CODE (commented out to prevent duplicates):
    -- if spell.type == 'JobAbility' and JA_DB[spell.english] then
    --     MessageFormatter.show_ja_activated(spell.english, JA_DB[spell.english].description)
    -- end

    -- ==========================================================================
    -- WEAPONSKILL HANDLING (validation FIRST, then messages - matches DNC pattern)
    -- ==========================================================================
    if spell.type == 'WeaponSkill' then
        -- ==========================================================================
        -- LAYER 3: WEAPONSKILL VALIDATION (Universal via WSValidator)
        -- ==========================================================================
        if WSValidator and not WSValidator.validate(spell, eventArgs) then
            return  -- WS validation failed, exit immediately (no message)
        end

        -- ==========================================================================
        -- LAYER 4: TP BONUS GEAR OPTIMIZATION (Universal via TPBonusHandler)
        -- ==========================================================================
        -- MUST BE DONE BEFORE MESSAGE to calculate final TP correctly
        if TPBonusHandler then
            TPBonusHandler.calculate_tp_gear(spell, WARTPConfig)
        end

        -- ==========================================================================
        -- WEAPONSKILL MESSAGES (with description + final TP including Moonshade)
        -- ==========================================================================
        if WS_DB[spell.english] and WS_MESSAGES_CONFIG.is_enabled() then
            local current_tp = player and player.vitals and player.vitals.tp or 0

            if current_tp >= 1000 then
                -- Calculate final TP (includes Moonshade bonus if equipped)
                local final_tp = current_tp

                -- Try to get final TP with Moonshade bonus
                if TPBonusCalculator and TPBonusCalculator.get_final_tp then
                    local weapon_name = player.equipment and player.equipment.main or nil
                    local sub_weapon = player.equipment and player.equipment.sub or nil
                    local tp_gear = _G.temp_tp_bonus_gear

                    local success, result = pcall(TPBonusCalculator.get_final_tp, current_tp, tp_gear, WARTPConfig, weapon_name, buffactive, sub_weapon)
                    if success then
                        final_tp = result
                    end
                end
            else
                -- Not enough TP - display error (always show errors)
                MessageFormatter.show_ws_validation_error(spell.english, "Not enough TP", string.format("%d/1000", current_tp))
            end
        end
    end
end

---============================================================================
--- POST-PRECAST HOOK - TP GEAR APPLICATION
---============================================================================

--- Apply TP bonus gear without message (already displayed in precast with final TP)
--- Called by GearSwap AFTER set selection, BEFORE actual equipping
---
--- @param spell     table  Spell/ability data
--- @param action    string Action type (not used)
--- @param spellMap  string Spell mapping (not used)
--- @param eventArgs table  Event arguments (not used)
--- @return void
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

-- Export globally for GearSwap
_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

-- Export as module (for future require() usage)
return {
    job_precast = job_precast,
    job_post_precast = job_post_precast
}

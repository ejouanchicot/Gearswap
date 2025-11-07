---============================================================================
--- WHM Precast Module - Precast Action Handling & Cooldown Monitoring
---============================================================================
--- Handles all precast actions for White Mage job:
---   • Fast Cast optimization (all spell types)
---   • Job Abilities (Benediction, Devotion, Divine Seal, Asylum, etc.)
---   • Cure spell precast (fast cast + special gear)
---   • Enhancing magic precast (fast cast + duration gear preparation)
---   • Divine/Enfeebling magic precast
---   • Weaponskill validation and range checking
---   • Security layers (debuff guard → cooldown check → job logic)
---
--- Follows 4-layer PRECAST security architecture:
---   1. PrecastGuard - Block casting under debuffs (Amnesia, Silence, Stun, etc.)
---   2. CooldownChecker - Universal ability/spell recast validation
---   3. WSValidator - Weaponskill range and validity checks
---   4. WHM-specific logic - Job-specific enhancements
---
--- @file    WHM_PRECAST.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-10-21
--- @requires shared/utils/messages/message_formatter, shared/utils/precast/cooldown_checker
---============================================================================

---============================================================================
--- DEPENDENCIES - CENTRALIZED SYSTEMS
---============================================================================

-- Message formatter (cooldown messages, ability feedback)
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Cooldown checker (universal ability/spell recast validation)
local CooldownChecker = require('shared/utils/precast/cooldown_checker')

-- Precast guard (debuff blocking: Amnesia, Silence, Stun, Petrify, Sleep, etc.)
local precast_guard_success, PrecastGuard = pcall(require, 'shared/utils/debuff/precast_guard')
if not precast_guard_success then
    MessageFormatter.error_whm_module_not_loaded('PrecastGuard')
    PrecastGuard = nil
end

-- TP Bonus Handler (universal WS TP gear optimization)
local _, TPBonusHandler = pcall(require, 'shared/utils/precast/tp_bonus_handler')

-- WS Validator (universal WS range + validity validation)
local _, WSValidator = pcall(require, 'shared/utils/precast/ws_validator')

-- WHM TP configuration (TP bonus gear thresholds)
local WHMTPConfig = _G.WHMTPConfig or {}  -- Loaded from character main file

-- Universal Job Ability Database (supports main job + subjob abilities)
local JA_DB = require('shared/data/job_abilities/UNIVERSAL_JA_DATABASE')

-- Universal Weapon Skills Database (weaponskill descriptions)
local WS_DB = require('shared/data/weaponskills/UNIVERSAL_WS_DATABASE')

-- Weaponskill manager (WS validation + range checking)
include('shared/utils/weaponskill/weaponskill_manager.lua')

-- Set MessageFormatter in WeaponSkillManager
if WeaponSkillManager and MessageFormatter then
    WeaponSkillManager.MessageFormatter = MessageFormatter
end

-- WHM message formatter
local MessageWHM = require('shared/utils/messages/formatters/jobs/message_whm')

-- Cure manager (auto-tier selection based on target HP)
local cure_manager_success, CureManager = pcall(require, 'shared/utils/whm/cure_manager')
if not cure_manager_success then
    MessageWHM.show_curemanager_not_loaded()
    CureManager = nil
end

---============================================================================
--- PRECAST HOOKS
---============================================================================

--- Main precast hook for all spells/abilities
--- Implements 4-layer security: PrecastGuard → CooldownChecker → WSValidator → WHM Logic
---
--- @param spell table Spell/ability data from Mote-Include
--- @param action string Action type (not used)
--- @param spellMap string Spell mapping from Mote-Include
--- @param eventArgs table Event arguments (contains .handled, .cancel flags)
--- @return void
function job_precast(spell, action, spellMap, eventArgs)
    -- ==========================================================================
    -- LAYER 1: DEBUFF GUARD (Highest Priority)
    -- ==========================================================================
    -- Block casting if player has blocking debuffs (Amnesia, Silence, Stun, etc.)
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return  -- Action blocked, exit immediately
    end

    -- ==========================================================================
    -- LAYER 2: COOLDOWN CHECK (Universal)
    -- ==========================================================================
    -- Check ability/spell recast timers (prevent premature casting)
    if spell.action_type == 'Ability' then
        CooldownChecker.check_ability_cooldown(spell, eventArgs)
    elseif spell.action_type == 'Magic' then
        CooldownChecker.check_spell_cooldown(spell, eventArgs)
    end

    -- Exit if cooldown check cancelled the action
    if eventArgs.cancel then
        return
    end

    -- ==========================================================================
    -- JOB ABILITIES MESSAGES (universal - supports main + subjob)
    -- DISABLED: WHM Job Abilities Messages
    -- Messages now handled by universal ability_message_handler (init_ability_messages.lua)
    -- This prevents duplicate messages from job-specific + universal system
    --
    -- LEGACY CODE (commented out to prevent duplicates):
    -- if spell.type == 'JobAbility' and JA_DB[spell.english] then
    --     MessageFormatter.show_ja_activated(spell.english, JA_DB[spell.english].description)
    -- end

    -- ==========================================================================
    -- LAYER 3: WEAPONSKILL VALIDATION (Universal via WSValidator)
    -- ==========================================================================
    if WSValidator and not WSValidator.validate(spell, eventArgs) then
        return  -- WS validation failed, exit immediately
    end

    -- ==========================================================================
    -- LAYER 3.5: TP BONUS GEAR OPTIMIZATION (Universal via TPBonusHandler)
    -- ==========================================================================
    -- MUST BE DONE BEFORE MESSAGE to calculate final TP correctly
    if TPBonusHandler then
        TPBonusHandler.calculate_tp_gear(spell, WHMTPConfig)
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

                    local success, result = pcall(TPBonusCalculator.get_final_tp, current_tp, tp_gear, WHMTPConfig, weapon_name, buffactive, sub_weapon)
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

    -- ==========================================================================
    -- LAYER 4: WHM-SPECIFIC LOGIC
    -- ==========================================================================

    -- Auto-tier Cure selection (downgrade Cure tier if target doesn't need full heal)
    if CureManager and spell.action_type == 'Magic' then
        if spell.name:find('Cure') or spell.name:find('Curaga') then
            local target = spell.target and windower.ffxi.get_mob_by_id(spell.target.id)
            local new_spell = CureManager.select_cure_tier(spell, target)

            if new_spell and new_spell ~= spell.name then
                -- Cancel current spell and cast optimal tier instead
                eventArgs.cancel = true
                send_command('input /ma "' .. new_spell .. '" ' .. spell.target.raw)
                return
            end
        end
    end

    -- Handle Paralyna when self is paralyzed (Timara WHM pattern)
    if spell.english == 'Paralyna' and buffactive.Paralyzed then
        -- No gear swaps to avoid blinking while paralyzed
        eventArgs.handled = true
        return
    end

    -- WHM-specific precast enhancements can go here
    -- Examples:
    --   • Auto-trigger Divine Seal before Cure spells (if configured)
    --   • Auto-trigger Afflatus Solace before party Cures
    --   • Devotion automation before long fights
end

--- Post-precast hook for additional customizations
--- Called after main precast set selection but before gear is equipped.
---
--- @param spell table Spell/ability data
--- @param action string Action type (not used)
--- @param spellMap string Spell mapping
--- @param eventArgs table Event arguments
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

    -- WHM-specific post-precast adjustments
    -- Examples:
    --   • Adjust Fast Cast gear based on spell type
    --   • Apply special weapon sets for certain abilities
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap (include() compatibility)
_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

-- Export as module (require() compatibility)
local WHM_PRECAST = {}
WHM_PRECAST.job_precast = job_precast
WHM_PRECAST.job_post_precast = job_post_precast

return WHM_PRECAST

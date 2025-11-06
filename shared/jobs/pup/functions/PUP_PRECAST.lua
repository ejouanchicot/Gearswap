---============================================================================
--- PUP Precast Module - Precast Action Handling & Cooldown Monitoring
---============================================================================
--- Handles all precast actions for Beastmaster job:
---   • Debuff blocking (Amnesia, Silence, Stun)
---   • Universal cooldown checking (abilities/spells)
---   • Weaponskill validation and range checking
---   • Ready move categorization (for midcast)
---
--- Uses centralized systems for validation and messaging consistency.
---
--- @file jobs/pup/functions/PUP_PRECAST.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-17
--- @requires Tetsouo architecture, MessageFormatter, CooldownChecker
---============================================================================

---============================================================================
--- DEPENDENCIES - CENTRALIZED SYSTEMS
---============================================================================

-- Message formatter (cooldown messages, WS TP display)
local success_mf, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
if not success_mf then MessageFormatter = nil end

-- Cooldown checker (universal ability/spell recast validation)
local success_cc, CooldownChecker = pcall(require, 'shared/utils/precast/cooldown_checker')
if not success_cc then CooldownChecker = nil end

-- Precast guard (debuff blocking: Amnesia, Silence, Stun, etc.)
local success_pg, PrecastGuard = pcall(require, 'shared/utils/debuff/precast_guard')
if not success_pg then PrecastGuard = nil end

-- WS Validator (universal WS range + validity validation)
local success_wsv, WSValidator = pcall(require, 'shared/utils/precast/ws_validator')
if not success_wsv then WSValidator = nil end

-- TP Bonus Handler (universal WS TP gear optimization)
local _, TPBonusHandler = pcall(require, 'shared/utils/precast/tp_bonus_handler')

-- Universal Weapon Skills Database (weaponskill descriptions)
local WS_DB = require('shared/data/weaponskills/UNIVERSAL_WS_DATABASE')

-- PUP TP configuration (TP bonus gear thresholds)
local PUPTPConfig = _G.PUPTPConfig or {}  -- Loaded from character main file

-- Weaponskill manager (WS validation + range checking)
include('../shared/utils/weaponskill/weaponskill_manager.lua')

-- Set MessageFormatter in WeaponSkillManager
if WeaponSkillManager and MessageFormatter then
    WeaponSkillManager.MessageFormatter = MessageFormatter
end

---============================================================================
--- DEPENDENCIES - PUP SPECIFIC
---============================================================================

-- Ready move categorizer (for midcast gear selection + precast detection)
local success_rmc, ReadyMoveCategorizer = pcall(require, 'shared/jobs/pup/functions/logic/ready_move_categorizer')
if not success_rmc then
    ReadyMoveCategorizer = nil
end

---============================================================================
--- PRECAST HOOK
---============================================================================

--- Called before any action (WS, JA, spell, etc.)
--- Processing order (CRITICAL - do not reorder):
---   1. Debuff guard (PrecastGuard) - blocks if silenced/amnesia/stunned
---   2. Cooldown check (CooldownChecker) - validates ability/spell ready
---   3. WS validation (WSValidator) - range check + validation
---   4. Ready move categorization (for Pet abilities)
---
--- @param spell table Spell/ability data
--- @param action string Action type (not used)
--- @param spellMap string Spell mapping (not used)
--- @param eventArgs table Event arguments (cancel flag, etc.)
--- @return void
function job_precast(spell, action, spellMap, eventArgs)

    -- ==========================================================================
    -- STEP 1: DEBUFF BLOCKING
    -- ==========================================================================
    -- Check for blocking debuffs (Amnesia, Silence, Stun, etc.)
    -- Prevents unnecessary equipment swaps when actions are blocked
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return -- Action blocked by debuff, exit immediately
    end

    -- ==========================================================================
    -- STEP 2: COOLDOWN VALIDATION
    -- ==========================================================================
    -- Universal cooldown check - works for ALL abilities and spells
    -- EXCEPT Ready Moves (they use Charges system, not recast)
    local is_ready_move = false
    local ready_move_category = nil
    if ReadyMoveCategorizer and spell.action_type == 'Ability' then
        ready_move_category = ReadyMoveCategorizer.get_category(spell.name)
        -- Only TRUE Ready Moves (not "Default" which includes Fight/Heel/etc)
        is_ready_move = (ready_move_category ~= nil and ready_move_category ~= 'Default')
    end

    if CooldownChecker and not is_ready_move then
        if spell.action_type == 'Ability' then
            CooldownChecker.check_ability_cooldown(spell, eventArgs)
        elseif spell.action_type == 'Magic' then
            CooldownChecker.check_spell_cooldown(spell, eventArgs)
        end
    end

    -- Exit if action cancelled due to cooldown
    if eventArgs.cancel then
        return
    end

    -- ==========================================================================
    -- DISABLED: PUP Job Abilities Messages
    -- Messages now handled by universal ability_message_handler (init_ability_messages.lua)
    -- This prevents duplicate messages from job-specific + universal system
    --
    -- LEGACY CODE (commented out to prevent duplicates):
    -- if spell.type == 'JobAbility' then
    --     if spell.english == 'Familiar' then
    --         MessageFormatter.show_ja_activated("Familiar", "Enhance pet stats +10% HP, extend charm")
    --     elseif spell.english == 'Reward' then
    --         MessageFormatter.show_ja_activated("Reward", "Restore pet HP with regen")
    --     ... (8 more abilities)
    --     end
    -- end
    --
    -- DISABLED: PUP Pet Commands Messages
    -- Pet commands (Fight, Heel, Stay, Sic, Ready, Leave, Snarl, Spur) also handled by universal system
    --
    -- LEGACY CODE (commented out to prevent duplicates):
    -- if spell.action_type == 'Ability' and spell.type ~= 'JobAbility' then
    --     if spell.english == 'Fight' then
    --         MessageFormatter.show_ja_activated("Fight", "Command pet to attack target")
    --     ... (8 more commands)
    --     end
    -- end

    -- ==========================================================================
    -- STEP 3: WEAPONSKILL VALIDATION
    -- ==========================================================================
    if WSValidator and not WSValidator.validate(spell, eventArgs) then
        return -- WS validation failed, exit immediately
    end

    -- ==========================================================================
    -- STEP 3.5: TP BONUS GEAR OPTIMIZATION (Universal via TPBonusHandler)
    -- ==========================================================================
    -- MUST BE DONE BEFORE MESSAGE to calculate final TP correctly
    if TPBonusHandler then
        TPBonusHandler.calculate_tp_gear(spell, PUPTPConfig)
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

                    local success, result = pcall(TPBonusCalculator.get_final_tp, current_tp, tp_gear, PUPTPConfig, weapon_name, buffactive, sub_weapon)
                    if success then
                        final_tp = result
                    end
                end

                -- Display WS message with description and FINAL TP (with Moonshade bonus)
                MessageFormatter.show_ws_activated(spell.english, WS_DB[spell.english].description, final_tp)
            end
        else
            -- Not enough TP - display error
            MessageFormatter.show_ws_validation_error(spell.english, "Not enough TP", string.format("%d/1000", current_tp))
        end
    end

    -- ==========================================================================
    -- STEP 4: CALL BEAST / BESTIAL LOYALTY (equip summonSet + broth)
    -- ==========================================================================
    if spell.name == 'Call Beast' or spell.name == 'Bestial Loyalty' then
        -- Equip base summon set
        if sets.precast.JA['Call Beast'] then
            equip(sets.precast.JA['Call Beast'])
        end

        -- Equip broth from state (forced separate to override any ammo in summonSet)
        if state.ammoSet and state.ammoSet.value and sets[state.ammoSet.value] then
            local broth_set = sets[state.ammoSet.value]
            if broth_set and broth_set.ammo then
                equip({ammo = broth_set.ammo})
            end
        end

        return -- Exit early (handled)
    end

    -- ==========================================================================
    -- STEP 5: READY MOVE PRECAST (equip Sic/Ready set)
    -- ==========================================================================
    -- Ready Moves detected via ReadyMoveCategorizer
    -- Equip precast set for Ready recast reduction (Charmer's Merlin, Gleti's Breeches)
    -- Then store category in spell object for midcast gear selection
    if is_ready_move and ready_move_category then
        -- ÉQUIPER PRECAST SET SIC/READY
        if sets.precast.JA['Ready'] then
            equip(sets.precast.JA['Ready'])
        elseif sets.precast.JA['Sic'] then
            equip(sets.precast.JA['Sic'])
        end

        -- Store category for midcast
        spell.ready_move_category = ready_move_category
    end
end

---============================================================================
--- POST-PRECAST HOOK
---============================================================================

--- Called after precast set selection, before gear is equipped
--- Handles:
---   • Call Beast / Bestial Loyalty - equip pet broth
---   • Weaponskill TP display
---
--- @param spell table Spell/ability data
--- @param action string Action type (not used)
--- @param spellMap string Spell mapping (not used)
--- @param eventArgs table Event arguments (not used)
--- @return void
function job_post_precast(spell, action, spellMap, eventArgs)
    -- ==========================================================================
    -- TP BONUS GEAR APPLICATION (without message, already displayed in precast)
    -- ==========================================================================
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

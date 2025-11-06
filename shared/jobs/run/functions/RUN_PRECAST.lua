---============================================================================
--- RUN Precast Module - Precast Action Handling & Cooldown Monitoring
---============================================================================
--- Handles all precast actions for Rune Fencer job:
---   • Debuff blocking (Amnesia, Silence, Stun)
---   • Universal cooldown checking (abilities/spells)
---   • Auto-ability triggering (Majesty, Divine Emblem)
---   • Weaponskill validation and range checking
---   • TP bonus optimization for weaponskills
---   • Fast Cast gear for spells
---
--- Uses centralized systems for validation and messaging consistency.
---
--- @file    RUN_PRECAST.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-10-03
--- @requires Tetsouo architecture, MessageFormatter, CooldownChecker
---============================================================================

---============================================================================
--- DEPENDENCIES - CENTRALIZED SYSTEMS
---============================================================================

-- Message formatter (cooldown messages, WS TP display)
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Cooldown checker (universal ability/spell recast validation)
local CooldownChecker = require('shared/utils/precast/cooldown_checker')

-- Ability helper (auto-trigger abilities before spells/WS)
local AbilityHelper = require('shared/utils/precast/ability_helper')

-- Precast guard (debuff blocking: Amnesia, Silence, Stun, etc.)
local precast_guard_success, PrecastGuard = pcall(require, 'shared/utils/debuff/precast_guard')
if not precast_guard_success then
    PrecastGuard = nil
end

-- TP Bonus Handler (universal WS TP gear optimization)
local _, TPBonusHandler = pcall(require, 'shared/utils/precast/tp_bonus_handler')

-- WS Validator (universal WS range + validity validation)
local _, WSValidator = pcall(require, 'shared/utils/precast/ws_validator')

-- Weaponskill manager (WS validation + range checking)
include('../shared/utils/weaponskill/weaponskill_manager.lua')

-- Set MessageFormatter in WeaponSkillManager
if WeaponSkillManager and MessageFormatter then
    WeaponSkillManager.MessageFormatter = MessageFormatter
end

---============================================================================
--- DEPENDENCIES - RUN SPECIFIC
---============================================================================

-- RUN TP configuration
local RUNTPConfig = _G.RUNTPConfig or {}  -- Loaded from character main file

-- Universal Job Ability Database (supports main job + subjob abilities)
local JA_DB = require('shared/data/job_abilities/UNIVERSAL_JA_DATABASE')

-- Universal Weapon Skills Database (weaponskill descriptions)
local WS_DB = require('shared/data/weaponskills/UNIVERSAL_WS_DATABASE')

---============================================================================
--- COOLDOWN EXCLUSIONS
---============================================================================
--- Abilities that should NEVER be checked for cooldown
--- Player manages these charges/cooldowns manually
---
--- Scholar Stratagems (RUN/SCH):
---   • Charge-based system (0-5 charges max)
---   • Complex recharge timing (varies by job level)
---   • Player manages strategically - no automation needed
---============================================================================

local cooldown_exclusions = {
    -- Scholar Stratagems (charge-based abilities)
    ['Light Arts'] = true,
    ['Dark Arts'] = true,
    ['Addendum: White'] = true,
    ['Addendum: Black'] = true,
    ['Stratagem'] = true,
    ['Tabula Rasa'] = true,
    -- Individual stratagems
    ['Ebullience'] = true,
    ['Rapture'] = true,
    ['Altruism'] = true,
    ['Tranquility'] = true,
    ['Perpetuance'] = true,
    ['Immanence'] = true,
    ['Accession'] = true,
    ['Manifestation'] = true,
    ['Parsimony'] = true,
    ['Penury'] = true,
    ['Celerity'] = true,
    ['Alacrity'] = true,
    ['Focalization'] = true,
    ['Equanimity'] = true,
    ['Enlightenment'] = true,
    ['Klimaform'] = true
}

---============================================================================
--- AUTO-ABILITY SYSTEM
---============================================================================
--- Automatically triggers beneficial abilities before specific spells.
--- Uses AbilityHelper for smart cooldown checking and timing.
---
--- Triggered abilities:
---   • Divine Emblem - Before Flash (enmity boost)
---   • Majesty - Before Protect III/IV/V, Cure III/IV (potency boost)
---============================================================================

local auto_abilities = {
    ['Flash'] = function(spell, eventArgs)
        AbilityHelper.try_ability(spell, eventArgs, 'Divine Emblem', 2)
    end,
    ['Protect III'] = function(spell, eventArgs)
        AbilityHelper.try_ability_smart(spell, eventArgs, 'Majesty', 2)
    end,
    ['Protect IV'] = function(spell, eventArgs)
        AbilityHelper.try_ability_smart(spell, eventArgs, 'Majesty', 2)
    end,
    ['Protect V'] = function(spell, eventArgs)
        AbilityHelper.try_ability_smart(spell, eventArgs, 'Majesty', 2)
    end,
    ['Cure III'] = function(spell, eventArgs)
        AbilityHelper.try_ability_smart(spell, eventArgs, 'Majesty', 2)
    end,
    ['Cure IV'] = function(spell, eventArgs)
        AbilityHelper.try_ability_smart(spell, eventArgs, 'Majesty', 2)
    end
}

---============================================================================
--- PRECAST HOOK
---============================================================================

--- Called before any action (WS, JA, spell, etc.)
--- Processing order (CRITICAL - do not reorder):
---   1. Debuff guard (PrecastGuard) - blocks if silenced/amnesia/stunned
---   2. Cooldown check (CooldownChecker) - validates ability/spell ready
---   3. Auto-abilities (AbilityHelper) - triggers Majesty/Divine Emblem
---   4. WS validation (WeaponSkillManager) - range check + validation
---   5. TP bonus calculation (TPBonusCalculator) - optimize WS gear
---   6. RUN-specific gear (Fast Cast for cures/Flash)
---
--- @param spell     table  Spell/ability data
--- @param action    string Action type (not used)
--- @param spellMap  string Spell mapping (not used)
--- @param eventArgs table  Event arguments (cancel flag, etc.)
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
    -- EXCLUDES abilities in cooldown_exclusions table (Scholar Stratagems, etc.)
    local is_excluded = cooldown_exclusions[spell.name]

    if not is_excluded then
        if spell.action_type == 'Ability' then
            CooldownChecker.check_ability_cooldown(spell, eventArgs)
        elseif spell.action_type == 'Magic' then
            CooldownChecker.check_spell_cooldown(spell, eventArgs)
        end

        -- Exit if action cancelled due to cooldown
        if eventArgs.cancel then
            return
        end
    end

    -- ==========================================================================
    -- DISABLED: RUN Job Abilities Messages
    -- Messages now handled by universal ability_message_handler (init_ability_messages.lua)
    -- This prevents duplicate messages from job-specific + universal system
    --
    -- LEGACY CODE (commented out to prevent duplicates):
    -- if spell.type == 'JobAbility' and JA_DB[spell.english] then
    --     MessageFormatter.show_ja_activated(spell.english, JA_DB[spell.english].description)
    -- end

    -- ==========================================================================
    -- STEP 3: AUTO-ABILITIES (MAJESTY, DIVINE EMBLEM)
    -- ==========================================================================
    -- Trigger beneficial abilities before specific spells
    if spell.action_type == 'Magic' and auto_abilities[spell.name] then
        auto_abilities[spell.name](spell, eventArgs)
    end

    -- ==========================================================================
    -- STEP 4: WEAPONSKILL VALIDATION
    -- ==========================================================================
    if WSValidator and not WSValidator.validate(spell, eventArgs) then
        return  -- WS validation failed, exit immediately
    end

    -- ==========================================================================
    -- STEP 5: TP BONUS OPTIMIZATION (Universal via TPBonusHandler)
    -- ==========================================================================
    -- MUST BE DONE BEFORE MESSAGE to calculate final TP correctly
    if TPBonusHandler then
        TPBonusHandler.calculate_tp_gear(spell, RUNTPConfig)
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

                    local success, result = pcall(TPBonusCalculator.get_final_tp, current_tp, tp_gear, RUNTPConfig, weapon_name, buffactive, sub_weapon)
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
    -- STEP 6: RUN-SPECIFIC PRECAST GEAR
    -- ==========================================================================

    -- Fast Cast for Healing Magic
    if spell.skill == 'Healing Magic' then
        equip(sets.precast['Cure'])
    end

    -- Fast Cast + Enmity for Flash
    if spell.name == 'Flash' then
        equip(sets.precast['Flash'])
    end
end

---============================================================================
--- POST-PRECAST HOOK
---============================================================================

--- Apply TP bonus gear and display final TP (Universal via TPBonusHandler)
--- Called after precast set selection, before gear is equipped
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

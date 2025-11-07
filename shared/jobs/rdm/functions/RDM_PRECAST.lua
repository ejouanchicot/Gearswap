---============================================================================
--- RDM Precast Module - Precast Action Handling & Fast Cast Optimization
---============================================================================
--- Handles all precast actions for Red Mage job:
---   • Fast Cast optimization (cap 80%)
---   • Weaponskills preparation & TP display
---   • Job ability precast (Convert, Chainspell, Saboteur, Composure)
---   • Enfeebling/Elemental spell precast
---   • Security layers (debuff guard, cooldown check, range validation)
---
--- @file    RDM_PRECAST.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-10-12
--- @requires Tetsouo architecture, MessageFormatter, CooldownChecker
---============================================================================

---============================================================================
--- DEPENDENCIES - CENTRALIZED SYSTEMS
---============================================================================

-- Message formatter (cooldown messages, WS TP display)
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Universal Weapon Skills Database (weaponskill descriptions)
local WS_DB = require('shared/data/weaponskills/UNIVERSAL_WS_DATABASE')

-- Cooldown checker (universal ability/spell recast validation)
local CooldownChecker = require('shared/utils/precast/cooldown_checker')

-- Ability helper (auto-trigger abilities before spells)
local AbilityHelper = require('shared/utils/precast/ability_helper')

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
--- DEPENDENCIES - RDM SPECIFIC
---============================================================================

-- RDM configuration
local RDMTPConfig = _G.RDMTPConfig or {}  -- Loaded from character main file

-- RDM Saboteur configuration (character-specific)
local RDMSaboteurConfig = _G.RDMSaboteurConfig or {
    auto_trigger_spells = {},
    wait_time = 2
}

---============================================================================
--- PRECAST HOOKS
---============================================================================

--- Called before any action (WS, JA, spell, etc.)
--- @param spell table Spell/ability data
--- @param action string Action type
--- @param spellMap string Spell mapping
--- @param eventArgs table Event arguments
function job_precast(spell, action, spellMap, eventArgs)
    -- FIRST: Check for blocking debuffs (Amnesia, Silence, etc.)
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return -- Action blocked, exit immediately
    end

    -- SECOND: Universal cooldown check
    if spell.action_type == 'Ability' then
        CooldownChecker.check_ability_cooldown(spell, eventArgs)
    elseif spell.action_type == 'Magic' then
        CooldownChecker.check_spell_cooldown(spell, eventArgs)
    end

    -- Exit if action was cancelled
    if eventArgs.cancel then
        return
    end

    -- ==========================================================================
    -- WEAPONSKILL MESSAGES (universal - all weapon types)
    -- ==========================================================================
    if spell.type == 'WeaponSkill' and WS_DB[spell.english] then
        -- Check if enough TP before displaying WS message
        local current_tp = player and player.vitals and player.vitals.tp or 0
        if current_tp >= 1000 then
            -- Display WS message with description and current TP        else
                -- Not enough TP - display error
                MessageFormatter.show_ws_validation_error(spell.english, "Not enough TP", string.format("%d/1000", current_tp))
            end
    end

    -- WeaponSkill validation
    if WSValidator and not WSValidator.validate(spell, eventArgs) then
        return  -- WS validation failed, exit immediately
    end

    -- DISABLED: RDM Job Abilities Messages
    -- Messages now handled by universal ability_message_handler (init_ability_messages.lua)
    -- This prevents duplicate messages from job-specific + universal system
    --
    -- LEGACY CODE (commented out to prevent duplicates):
    -- if spell.type == 'JobAbility' then
    --     if spell.english == 'Convert' then
    --         MessageFormatter.show_ja_activated("Convert", "Swap HP <-> MP")
    --     elseif spell.english == 'Chainspell' then
    --         MessageFormatter.show_ja_activated("Chainspell", "Rapid casting, zero recast")
    --     ... (4 more abilities)
    --     end
    -- end

    -- Auto-trigger Saboteur before configured enfeebling spells
    if spell.action_type == 'Magic' and spell.skill == 'Enfeebling Magic' then
        -- Check if SaboteurMode is On
        if state.SaboteurMode and state.SaboteurMode.current == 'On' then
            -- Check if this spell is in the auto-trigger list
            if RDMSaboteurConfig.auto_trigger_spells[spell.english] then
                AbilityHelper.try_ability_smart(spell, eventArgs, 'Saboteur', RDMSaboteurConfig.wait_time)
            end
        end
    end

    -- RDM-specific TP Bonus gear optimization for weaponskills
    if TPBonusHandler then
        TPBonusHandler.calculate_tp_gear(spell, RDMTPConfig)
    end
end

--- Apply final gear adjustments before equipping
--- NOTE: TP display now integrated in job_precast WS message
--- @param spell table Spell/ability data
--- @param action string Action type
--- @param spellMap string Spell mapping
--- @param eventArgs table Event arguments
function job_post_precast(spell, action, spellMap, eventArgs)
    -- Apply TP bonus gear (Moonshade Earring) without message (already displayed in precast)
    if spell.type == 'WeaponSkill' then
        local tp_gear = _G.temp_tp_bonus_gear
        if tp_gear then
            equip(tp_gear)
            _G.temp_tp_bonus_gear = nil
        end
    end

    -- Spell-specific Fast Cast sets (PRIORITY over generic FC)
    -- Example: sets.precast.FC["Stoneskin"] overrides sets.precast.FC
    if spell.action_type == 'Magic' and sets.precast.FC and sets.precast.FC[spell.english] then
        equip(sets.precast.FC[spell.english])
    end

    -- Chainspell active - no need for Fast Cast gear
    if buffactive['Chainspell'] then
        -- Keep precast gear as-is (instant cast)
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export to global scope for GearSwap
_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

-- Export module
local RDM_PRECAST = {}
RDM_PRECAST.job_precast = job_precast
RDM_PRECAST.job_post_precast = job_post_precast

return RDM_PRECAST

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

-- Precast debug messages (formatted system)
local MessagePrecast = require('shared/utils/messages/formatters/magic/message_precast')

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
--- DEBUG STATE (Global persist across reloads)
---============================================================================

-- Initialize global debug state if not exists
if _G.PrecastDebugState == nil then
    _G.PrecastDebugState = false
end

local function is_precast_debug_enabled()
    return _G.PrecastDebugState == true
end

---============================================================================
--- PRECAST HOOKS
---============================================================================

--- Called before any action (WS, JA, spell, etc.)
--- @param spell table Spell/ability data
--- @param action string Action type
--- @param spellMap string Spell mapping
--- @param eventArgs table Event arguments
function job_precast(spell, action, spellMap, eventArgs)
    local debug_enabled = is_precast_debug_enabled()

    -- DEBUG: Show precast entry
    if debug_enabled then
        local action_type = spell.type or 'Unknown'
        local action_name = spell.english or spell.name or 'Unknown'
        MessagePrecast.show_debug_header(action_name, action_type)
    end

    -- FIRST: Check for blocking debuffs (Amnesia, Silence, etc.)
    if debug_enabled then
        MessagePrecast.show_debug_step(1, 'PrecastGuard', 'info', 'Checking debuffs...')
    end

    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        if debug_enabled then
            MessagePrecast.show_debug_step(1, 'PrecastGuard', 'fail', 'BLOCKED by debuff!')
        end
        return -- Action blocked, exit immediately
    end

    if debug_enabled then
        MessagePrecast.show_debug_step(1, 'PrecastGuard', 'ok', 'No blocking debuffs')
    end

    -- SECOND: Universal cooldown check
    if debug_enabled then
        MessagePrecast.show_debug_step(2, 'Cooldown', 'info', 'Checking cooldown...')
    end

    if spell.action_type == 'Ability' then
        CooldownChecker.check_ability_cooldown(spell, eventArgs)
    elseif spell.action_type == 'Magic' then
        CooldownChecker.check_spell_cooldown(spell, eventArgs)
    end

    -- Exit if action was cancelled
    if eventArgs.cancel then
        if debug_enabled then
            MessagePrecast.show_debug_step(2, 'Cooldown', 'fail', 'CANCELLED (on cooldown or blocked)')
        end
        return
    end

    if debug_enabled then
        MessagePrecast.show_debug_step(2, 'Cooldown', 'ok', 'Ready to use')
    end

    -- ==========================================================================
    -- PHALANX OPTIMIZATION (Auto-swap between Phalanx/Phalanx II)
    -- ==========================================================================
    -- Logic:
    --   - Phalanx II on self → Downgrade to Phalanx (better for self)
    --   - Phalanx on others → Upgrade to Phalanx II (better for others)
    if spell.action_type == 'Magic' and spell.skill == 'Enhancing Magic' then
        local spell_name = spell.english or spell.name

        if spell_name == 'Phalanx' or spell_name == 'Phalanx II' then
            local target = spell.target
            local is_self = (target and target.name == player.name)
            local new_spell = nil

            if spell_name == 'Phalanx II' and is_self then
                -- Phalanx II on self → Cast Phalanx instead
                new_spell = 'Phalanx'
                MessageFormatter.show_phalanx_downgrade()
            elseif spell_name == 'Phalanx' and not is_self then
                -- Phalanx on others → Cast Phalanx II instead
                new_spell = 'Phalanx II'
                MessageFormatter.show_phalanx_upgrade()
            end

            if new_spell then
                -- Cancel current spell and cast optimal tier
                eventArgs.cancel = true
                send_command('input /ma "' .. new_spell .. '" ' .. spell.target.raw)
                return
            end
        end
    end

    -- ==========================================================================
    -- WEAPONSKILL MESSAGES (universal - all weapon types)
    -- ==========================================================================
    if spell.type == 'WeaponSkill' then
        local current_tp = player and player.vitals and player.vitals.tp or 0

        if debug_enabled then
            MessagePrecast.show_debug_step(3, 'WeaponSkill TP', 'info', 'Current TP: ' .. tostring(current_tp))
        end

        if WS_DB[spell.english] then
            -- Check if enough TP before displaying WS message
            if current_tp >= 1000 then
                -- Display WS message with description and current TP
                if debug_enabled then
                    MessagePrecast.show_debug_step(3, 'TP Check', 'ok', tostring(current_tp) .. ' >= 1000')
                end
            else
                -- Not enough TP - display error
                MessageFormatter.show_ws_validation_error(spell.english, "Not enough TP", string.format("%d/1000", current_tp))
                if debug_enabled then
                    MessagePrecast.show_debug_step(3, 'TP Check', 'fail', tostring(current_tp) .. ' < 1000')
                end
            end
        end

        -- WeaponSkill validation
        if debug_enabled then
            MessagePrecast.show_debug_step(4, 'WS Validator', 'info', 'Checking range/validity...')
        end

        if WSValidator and not WSValidator.validate(spell, eventArgs) then
            if debug_enabled then
                MessagePrecast.show_debug_step(4, 'WS Validator', 'fail', 'Out of range or invalid target')
            end
            return  -- WS validation failed, exit immediately
        end

        if debug_enabled then
            MessagePrecast.show_debug_step(4, 'WS Validator', 'ok', 'In range, valid target')
        end
    end

    -- DISABLED: RDM Job Abilities Messages
    -- Messages now handled by universal ability_message_handler (init_ability_messages.lua)
    -- This prevents duplicate messages from job-specific + universal system
    --
    -- LEGACY CODE (commented out to prevent duplicates):
    -- if spell.type == 'JobAbility' then
    --     if spell.english == 'Convert' then
    --         MessageFormatter.show_ja_activated("Convert", "Swap HP <>> MP")
    --     elseif spell.english == 'Chainspell' then
    --         MessageFormatter.show_ja_activated("Chainspell", "Rapid casting, zero recast")
    --     ... (4 more abilities)
    --     end
    -- end

    -- ==========================================================================
    -- MAGIC PRECAST (Fast Cast)
    -- ==========================================================================
    if spell.action_type == 'Magic' then
        if debug_enabled then
            MessagePrecast.show_debug_step(5, 'Magic (Fast Cast)', 'info', 'Skill: ' .. (spell.skill or 'Unknown'))
        end

        -- Auto-trigger Saboteur before configured enfeebling spells
        if spell.skill == 'Enfeebling Magic' then
            -- Check if SaboteurMode is On
            if state.SaboteurMode and state.SaboteurMode.current == 'On' then
                -- Check if this spell is in the auto-trigger list
                if RDMSaboteurConfig.auto_trigger_spells[spell.english] then
                    if debug_enabled then
                        MessagePrecast.show_debug_step(5, 'Saboteur Auto', 'ok', 'Will trigger before ' .. spell.english)
                    end
                    AbilityHelper.try_ability_smart(spell, eventArgs, 'Saboteur', RDMSaboteurConfig.wait_time)
                else
                    if debug_enabled then
                        MessagePrecast.show_debug_step(5, 'Saboteur Auto', 'info', 'Not in auto-trigger list')
                    end
                end
            else
                if debug_enabled then
                    MessagePrecast.show_debug_step(5, 'Saboteur Auto', 'info', 'Mode is Off')
                end
            end
        end
    end

    -- ==========================================================================
    -- TP BONUS HANDLER (Weaponskill TP gear optimization)
    -- ==========================================================================
    if spell.type == 'WeaponSkill' and TPBonusHandler then
        if debug_enabled then
            MessagePrecast.show_debug_step(6, 'TP Bonus', 'info', 'Calculating optimal TP gear...')
        end
        TPBonusHandler.calculate_tp_gear(spell, RDMTPConfig)
        if debug_enabled then
            MessagePrecast.show_debug_step(6, 'TP Bonus', 'ok', 'Gear optimization complete')
        end
    end

    -- DEBUG: Show completion
    if debug_enabled then
        MessagePrecast.show_completion()
    end
end

--- Apply final gear adjustments before equipping
--- NOTE: TP display now integrated in job_precast WS message
--- @param spell table Spell/ability data
--- @param action string Action type
--- @param spellMap string Spell mapping
--- @param eventArgs table Event arguments
function job_post_precast(spell, action, spellMap, eventArgs)
    local debug_enabled = is_precast_debug_enabled()

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

    -- DEBUG: Display equipped set and gear
    if debug_enabled then
        -- Determine which set was equipped and get the actual set table
        local set_name = "Unknown"
        local gear_set = nil

        if spell.type == 'WeaponSkill' then
            if sets.precast.WS and sets.precast.WS[spell.english] then
                set_name = "sets.precast.WS[" .. spell.english .. "]"
                gear_set = sets.precast.WS[spell.english]
            elseif sets.precast.WS then
                set_name = "sets.precast.WS (base)"
                gear_set = sets.precast.WS
            end
        elseif spell.type == 'JobAbility' then
            if sets.precast.JA and sets.precast.JA[spell.english] then
                set_name = "sets.precast.JA[" .. spell.english .. "]"
                gear_set = sets.precast.JA[spell.english]
            elseif sets.precast.JA then
                set_name = "sets.precast.JA (base)"
                gear_set = sets.precast.JA
            end
        elseif spell.action_type == 'Magic' then
            if buffactive['Chainspell'] then
                set_name = "No FC (Chainspell active)"
                gear_set = nil
            elseif sets.precast.FC and sets.precast.FC[spell.english] then
                set_name = "sets.precast.FC[" .. spell.english .. "]"
                gear_set = sets.precast.FC[spell.english]
            elseif sets.precast.FC and spell.skill and sets.precast.FC[spell.skill] then
                set_name = "sets.precast.FC[" .. spell.skill .. "]"
                gear_set = sets.precast.FC[spell.skill]
            elseif sets.precast.FC then
                set_name = "sets.precast.FC (base)"
                gear_set = sets.precast.FC
            end
        elseif spell.type == 'RangedAttack' then
            set_name = "sets.precast.RA"
            gear_set = sets.precast.RA
        end

        MessagePrecast.show_equipped_set(set_name)
        if gear_set then
            MessagePrecast.show_equipment(gear_set)
        end
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

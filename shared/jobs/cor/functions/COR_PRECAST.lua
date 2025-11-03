---============================================================================
--- COR Precast Module - Precast Action Handling & Cooldown Monitoring
---============================================================================
--- Handles all precast actions for Corsair job:
---   • Weaponskill precast (Fast Cast, TP bonus optimization)
---   • Phantom Roll precast (gear selection + roll tracking for Double-Up)
---   • Quick Draw precast (element-based shots)
---   • Ranged Attack precast (Snapshot gear)
---   • Job ability precast (Crooked Cards tracking)
---   • Fast Cast for subjob spells (NIN/DNC/RDM/etc.)
---   • Security layers (debuff guard, cooldown check, range validation)
---   • Luzaf's Ring management (16y vs 8y roll range)
---
--- Processing Order (CRITICAL):
---   1. Debuff guard (PrecastGuard) - blocks if silenced/amnesia/stunned
---   2. Cooldown check (CooldownChecker) - validates ability/spell ready
---   3. WS validation (WeaponSkillManager) - TP check + range check
---   4. COR-specific logic (Rolls, Quick Draw, Crooked Cards)
---   5. TP bonus calculation (TPBonusCalculator) - ranged WS optimization
---
--- @file    COR_PRECAST.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-10-07
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
--- DEPENDENCIES - COR SPECIFIC
---============================================================================

-- TP Bonus system (ranged weapon-based TP bonus for COR)
local CORTPConfig = _G.CORTPConfig or {}  -- Loaded from character main file

-- Universal Job Ability Database (supports main job + subjob abilities)
local JA_DB = require('shared/data/job_abilities/UNIVERSAL_JA_DATABASE')

-- Universal Weapon Skills Database (weaponskill descriptions)
local WS_DB = require('shared/data/weaponskills/UNIVERSAL_WS_DATABASE')

-- Set MessageFormatter in TPBonusCalculator
if TPBonusCalculator and MessageFormatter then
    TPBonusCalculator.MessageFormatter = MessageFormatter
end

-- Note: _G.cor_last_roll is initialized in roll_tracker.lua
-- Used for Double-Up gear matching via .name field

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

    -- WeaponSkill validation
    if WSValidator and not WSValidator.validate(spell, eventArgs) then
        return  -- WS validation failed, exit immediately
    end

    -- COR-specific precast gear logic

    -- ==========================================================================
    -- DISABLED: COR Job Abilities Messages
    -- Messages now handled by universal ability_message_handler (init_ability_messages.lua)
    -- This prevents duplicate messages from job-specific + universal system
    --
    -- LEGACY CODE (commented out to prevent duplicates):
    -- if spell.type == 'JobAbility' then
    --     if JA_DB[spell.english] then
    --         MessageFormatter.show_ja_activated(spell.english, JA_DB[spell.english].description)
    --     end
    -- end
    -- ==========================================================================

    -- SPECIAL HANDLING: Track Crooked Cards timestamp (keep this)
    if spell.type == 'JobAbility' and spell.english == 'Crooked Cards' then
        _G.cor_crooked_timestamp = os.time()
    end
    -- ==========================================================================
    -- WEAPONSKILL MESSAGES (universal - all weapon types)
    -- ==========================================================================
    if spell.type == 'WeaponSkill' and WS_DB[spell.english] then            -- Check if enough TP before displaying WS message
            local current_tp = player and player.vitals and player.vitals.tp or 0
            if current_tp >= 1000 then
                -- Display WS message with current TP
                MessageFormatter.show_ws_activated(spell.english, WS_DB[spell.english].description, nil)  -- TP displayed by TPBonusHandler after gear equip
            else
                -- Not enough TP - display error
                MessageFormatter.show_ws_validation_error(spell.english, "Not enough TP", string.format("%d/1000", current_tp))
            end
    end


    -- DISABLED: Quick Draw (CorsairShot) Messages
    -- Messages now handled by universal ability_message_handler (init_ability_messages.lua)
    --
    -- LEGACY CODE (commented out to prevent duplicates):
    -- if spell.type == 'CorsairShot' then
    --     local shot_element = spell.english:match("(%w+) Shot")
    --     if shot_element then
    --         MessageFormatter.show_ja_activated(spell.english, shot_element .. " elemental damage")
    --     end
    -- end

    -- Phantom Roll precast (tell Mote to use CorsairRoll sets)
    if spell.type == 'CorsairRoll' then
        -- Set custom class so Mote looks in sets.precast.CorsairRoll
        classes.CustomClass = 'CorsairRoll'

        -- Track roll name for Double-Up to use same gear (using table structure)
        if not _G.cor_last_roll then
            _G.cor_last_roll = {}
        end
        _G.cor_last_roll.name = spell.english
    end

    -- Double-Up (use gear from last roll used)
    if spell.english == 'Double-Up' and _G.cor_last_roll and _G.cor_last_roll.name then
        -- Check if there's a specific set for this roll
        if sets.precast.CorsairRoll[_G.cor_last_roll.name] then
            equip(sets.precast.CorsairRoll[_G.cor_last_roll.name])
        else
            -- Fallback to base CorsairRoll set
            equip(sets.precast.CorsairRoll)
        end
    end

    -- Quick Draw precast (tell Mote to use CorsairShot sets)
    if spell.type == 'CorsairShot' then
        -- Set custom class so Mote looks in sets.precast.CorsairShot
        classes.CustomClass = 'CorsairShot'
    end

    -- Ranged Attack precast
    if spell.type == 'Ranged Attack' then
        -- Set custom class so Mote looks in sets.precast.RA
        classes.CustomClass = 'RA'
    end

    -- COR-specific TP Bonus gear optimization for weaponskills
    if TPBonusHandler then
        TPBonusHandler.calculate_tp_gear(spell, CORTPConfig)
    end
end

--- Called after precast gear is equipped
--- @param spell table Spell/ability data
--- @param action string Action type
--- @param spellMap string Spell mapping
--- @param eventArgs table Event arguments
--- @return void
function job_post_precast(spell, action, spellMap, eventArgs)
    -- Phantom Roll: Adjust ring based on Luzaf Ring state
    if spell.type == 'CorsairRoll' then
        if state and state.LuzafRing then
            if state.LuzafRing.value == 'ON' then
                -- Keep Luzaf's Ring (16y range)
                equip({left_ring = "Luzaf's Ring"})
            elseif state.LuzafRing.value == 'OFF' then
                -- Use Gurebu's Ring instead (8y range)
                equip({left_ring = "Gurebu's Ring"})
            end
        end
    end

    -- Display final TP for weaponskills
    if TPBonusHandler then
        TPBonusHandler.apply_and_display(spell, CORTPConfig)
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export global for GearSwap (Mote-Include)
_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

-- Export module for future use
local COR_PRECAST = {}
COR_PRECAST.job_precast = job_precast
COR_PRECAST.job_post_precast = job_post_precast

return COR_PRECAST

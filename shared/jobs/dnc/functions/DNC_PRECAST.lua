---============================================================================
--- DNC Precast Module - Precast Action Handling & Cooldown Monitoring
---============================================================================
--- Handles all precast actions for Dancer job with auto-buff systems:
---   • Weaponskill precast (Fast Cast, TP bonus optimization)
---   • Auto-Jump integration (DRG subjob - ultra-fast 0.5s timing)
---   • Auto-Climactic Flourish (optimized 1s timing before configured WS)
---   • Job ability precast (Steps, Sambas, Jigs, Waltzes, Flourishes)
---   • Fast cast for subjob spells (NIN/SAM/WAR/etc.)
---   • Cooldown tracking with formatted messages
---   • Debuff guard integration (blocks actions if silenced/amnesia)
---   • WS range validation (6y melee, 15y ranged)
---   • TP bonus calculation (Moonshade Earring automation)
---   • Mote refine_waltz override (allows waltzes on full HP targets)
---
--- Processing order (CRITICAL - do not reorder):
---   1. Debuff guard (PrecastGuard) - blocks if silenced/amnesia/stunned
---   2. Cooldown check (CooldownChecker) - validates ability/spell ready
---   3. Climactic timestamp tracking (instant detection before buff appears)
---   4. Auto-Jump trigger (JumpManager) - if DNC/DRG and TP < 1000
---   5. Auto-Climactic trigger (ClimaticManager) - if configured WS
---   6. WS validation (WeaponSkillManager) - range check + validation
---   7. TP bonus calculation (TPBonusCalculator) - optimize WS gear
---
--- @file    DNC_PRECAST.lua
--- @author  Tetsouo
--- @version 3.2 - Ultra-Fast Jump (0.5s) + Optimized Climactic (1s)
--- @date    Created: 2025-10-04 | Updated: 2025-10-10
--- @requires Tetsouo architecture, DNC logic modules, TPBonusCalculator
---============================================================================

---============================================================================
--- DEPENDENCIES - CENTRALIZED SYSTEMS
---============================================================================

-- Message formatter (cooldown messages, WS TP display)
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Universal Weapon Skills Database (weaponskill descriptions)
local WS_DB = require('shared/data/weaponskills/UNIVERSAL_WS_DATABASE')

-- Universal Job Abilities Database (job ability descriptions)
local JA_DB = require('shared/data/job_abilities/UNIVERSAL_JA_DATABASE')

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
--- DEPENDENCIES - DNC SPECIFIC
---============================================================================

-- DNC logic modules (business logic)
local ClimaticManager = require('shared/jobs/dnc/functions/logic/climactic_manager')
local WSVariantSelector = require('shared/jobs/dnc/functions/logic/ws_variant_selector')
local JumpManager = require('shared/jobs/dnc/functions/logic/jump_manager')

-- DNC configuration (character-specific, not in shared/)
-- Note: This will be loaded from Tetsouo/config or Kaories/config via main file
local DNCTPConfig = _G.DNCTPConfig or {}

---============================================================================
--- MOTE OVERRIDES
---============================================================================

--- Override Mote's refine_waltz to allow waltzes even when target is full HP
--- This is needed for wake-up utility (removing sleep from party members)
--- Mote calls this function during precast for all waltz abilities
function refine_waltz(spell, action, spellMap, eventArgs)
    -- Do nothing - let our WaltzManager handle everything via //gs c waltz commands
    -- This disables Mote's automatic waltz blocking/refinement when target is full HP
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
    -- FIRST: Check for blocking debuffs (Amnesia, Silence, etc.)
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return -- Action blocked, exit immediately
    end

    -- SECOND: Universal cooldown check
    if spell.action_type == 'Ability' then
        CooldownChecker.check_ability_cooldown(spell, eventArgs)
    elseif spell.action_type == 'Magic' and not (spell.english == 'Utsusemi: Ni' or spell.english == 'Utsusemi: Ichi') then
        CooldownChecker.check_spell_cooldown(spell, eventArgs)
    end

    -- Exit if action was cancelled
    if eventArgs.cancel then
        return
    end

    -- THIRD: Samba TP requirement check (350 TP needed)
    if spell.type == 'Samba' then
        local current_tp = player and player.tp or 0
        local required_tp = 350

        if current_tp < required_tp then
            -- Not enough TP - show error message and cancel
            MessageFormatter.show_ability_tp_error(spell.name, current_tp, required_tp)
            eventArgs.cancel = true
            return
        end
    end

    -- DISABLED: DNC Job Abilities Messages
    -- Messages now handled by universal ability_message_handler (init_ability_messages.lua)
    -- This prevents duplicate messages from job-specific + universal system
    --
    -- LEGACY CODE (commented out to prevent duplicates):
    -- if spell.type == 'JobAbility' and spell.english ~= 'Jump' and spell.english ~= 'High Jump' then
    --     if JA_DB[spell.english] then
    --         MessageFormatter.show_ja_activated(spell.english, JA_DB[spell.english].description)
    --     end
    -- end
    -- ... (Steps, Sambas, Waltzes, Jigs, Flourishes I/II/III all disabled)

    -- SPECIAL HANDLING: Climactic Flourish timestamp (keep this)
    if spell.type == 'Flourish3' and spell.english == 'Climactic Flourish' then
        _G.dnc_climactic_timestamp = os.time()
    end

    -- Jump/High Jump (DRG subjob)
    -- DISABLED: Messages now handled by universal ability_message_handler
    -- (prevents duplicates)
    --
    -- LEGACY CODE (commented out):
    -- if spell.type == 'JobAbility' and (spell.english == 'Jump' or spell.english == 'High Jump') then
    --     if JA_DB[spell.english] then
    --         MessageFormatter.show_ja_activated(spell.english, JA_DB[spell.english].description)
    --     end
    -- end

    -- WeaponSkill validation
    if spell.type == 'WeaponSkill' and WeaponSkillManager then
        -- ==========================================================================
        -- CRITICAL: Check auto-triggers FIRST (before any messages)
        -- ==========================================================================

        -- Auto-trigger Jump before WS if DNC/DRG and TP < 1000 (via JumpManager)
        JumpManager.auto_trigger_jump(spell, eventArgs)
        if eventArgs.cancel then
            return  -- Jump combo triggered, exit (no WS message)
        end

        -- Auto-trigger Climactic Flourish before configured WS
        ClimaticManager.auto_trigger(spell, eventArgs)
        if eventArgs.cancel then
            return  -- Climactic triggered, exit (no WS message)
        end

        -- WS validation (range + validity)
        if WSValidator and not WSValidator.validate(spell, eventArgs) then
            return  -- WS validation failed, exit (no WS message)
        end

        -- DNC-specific TP Bonus gear optimization for weaponskills
        -- MUST BE DONE BEFORE MESSAGE to calculate final TP correctly
        if TPBonusHandler then
            TPBonusHandler.calculate_tp_gear(spell, DNCTPConfig)
        end

        -- ==========================================================================
        -- WEAPONSKILL MESSAGES (with description + final TP including Moonshade)
        -- Display ONLY when WS will ACTUALLY execute (all checks passed)
        -- ==========================================================================
        local current_tp = player and player.vitals and player.vitals.tp or 0

        if current_tp >= 1000 then
            -- Check if WS is in database
            if WS_DB and WS_DB[spell.english] then
                -- Reset auto-recast flag (cleanup)
                _G.DNC_AUTO_WS_RECAST = false

                -- Calculate final TP (includes Moonshade bonus if equipped)
                local final_tp = current_tp

                -- Try to get final TP with Moonshade bonus
                if TPBonusCalculator and TPBonusCalculator.get_final_tp then
                    local weapon_name = player.equipment and player.equipment.main or nil
                    local sub_weapon = player.equipment and player.equipment.sub or nil
                    local tp_gear = _G.temp_tp_bonus_gear

                    local success, result = pcall(TPBonusCalculator.get_final_tp, current_tp, tp_gear, DNCTPConfig, weapon_name, buffactive, sub_weapon)
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

--- Apply any final gear adjustments before equipping
--- @param spell table Spell/ability data
--- @param action string Action type
--- @param spellMap string Spell mapping
--- @param eventArgs table Event arguments
function job_post_precast(spell, action, spellMap, eventArgs)
    if spell.type == 'WeaponSkill' then
        -- FIRST: Apply WS set variant based on buffs (Fan Dance/Climactic)
        -- This must happen BEFORE TP bonus gear to avoid overwriting Moonshade
        WSVariantSelector.apply_variant(spell)

        -- SECOND: Apply TP bonus gear (Moonshade Earring) without message (already displayed in precast)
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

-- Make job_precast available globally for GearSwap
_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

-- Also export as module for potential future use
local DNC_PRECAST = {}
DNC_PRECAST.job_precast = job_precast
DNC_PRECAST.job_post_precast = job_post_precast

return DNC_PRECAST

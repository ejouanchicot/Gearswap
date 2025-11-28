---============================================================================
--- WAR Precast Module - Precast Action Handling & Cooldown Monitoring
---============================================================================
--- Handles all precast actions for Warrior job:
---   • Weaponskills preparation & TP gear optimization
---   • Job ability precast logic & cooldown tracking
---   • Fast cast for sub-job spells
---   • Security layers (debuff guard, range checks, validation)
---
--- **PERFORMANCE OPTIMIZATION:**
---   • Lazy-loaded: All modules loaded on first action (saves ~150ms at startup)
---
--- @file    WAR_PRECAST.lua
--- @author  Tetsouo
--- @version 2.1 - Lazy Loading for performance
--- @date    Created: 2025-09-29 | Updated: 2025-11-15
--- @requires Tetsouo architecture, MessageFormatter, CooldownChecker
---============================================================================
---============================================================================
--- DEPENDENCIES (LAZY LOADING for performance)
---============================================================================
-- Modules loaded on first action (saves ~150ms at startup)
local MessageFormatter = nil
local CooldownChecker = nil
local PrecastGuard = nil
local TPBonusHandler = nil
local WSValidator = nil
local JA_DB = nil
local WS_DB = nil
local WS_MESSAGES_CONFIG = nil
local res = nil
local WeaponSkillManager = nil
local TPBonusCalculator = nil

-- WAR TP configuration (loaded from character main file)
local WARTPConfig = _G.WARTPConfig or {}

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then
        return
    end

    -- Message formatter (cooldown & WS TP display)
    local _, mf = pcall(require, 'shared/utils/messages/message_formatter')
    MessageFormatter = mf

    -- Cooldown checker (universal ability/spell recast validation)
    local _, cc = pcall(require, 'shared/utils/precast/cooldown_checker')
    CooldownChecker = cc

    -- Precast guard (debuff blocking: Amnesia, Silence, Stun, etc.)
    local _, pg = pcall(require, 'shared/utils/debuff/precast_guard')
    PrecastGuard = pg

    -- TP Bonus Handler (universal WS TP gear optimization)
    local _, tph = pcall(require, 'shared/utils/precast/tp_bonus_handler')
    TPBonusHandler = tph

    -- WS Validator (universal WS range + validity validation)
    local _, wsv = pcall(require, 'shared/utils/precast/ws_validator')
    WSValidator = wsv

    -- Universal Job Ability Database (supports main job + subjob abilities)
    JA_DB = require('shared/data/job_abilities/UNIVERSAL_JA_DATABASE')

    -- Universal Weapon Skills Database (weaponskill descriptions)
    WS_DB = require('shared/data/weaponskills/UNIVERSAL_WS_DATABASE')

    -- WS Messages Configuration (display mode control)
    local _, wsmc = pcall(require, 'shared/config/WS_MESSAGES_CONFIG')
    if not wsmc then
        wsmc = {display_mode = 'full', is_enabled = function() return true end, show_description = function() return true end}
    end
    WS_MESSAGES_CONFIG = wsmc

    -- Resources library (item/spell lookup)
    res = require('resources')

    -- Weaponskill managers
    local _, wsm = pcall(require, 'shared/utils/weaponskill/weaponskill_manager')
    WeaponSkillManager = wsm or _G.WeaponSkillManager

    local _, tpc = pcall(require, 'shared/utils/weaponskill/tp_bonus_calculator')
    TPBonusCalculator = tpc or _G.TPBonusCalculator

    -- Set MessageFormatter in WeaponSkillManager if both available
    if WeaponSkillManager and MessageFormatter then
        WeaponSkillManager.MessageFormatter = MessageFormatter
    end

    modules_loaded = true
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
    -- Lazy load modules on first action
    ensure_modules_loaded()

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
                eventArgs.cancel = true  -- Cancel the WS action
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
    -- Lazy load modules if needed (in case post_precast called before precast)
    ensure_modules_loaded()

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

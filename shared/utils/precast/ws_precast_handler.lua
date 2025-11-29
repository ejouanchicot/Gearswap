---============================================================================
--- WS Precast Handler - Unified WeaponSkill Processing
---============================================================================
--- Centralizes ALL weaponskill precast logic into a single handler.
--- Eliminates ~450 lines of duplicated code across 15 PRECAST modules.
---
--- Combines:
---   • WSValidator        - Range + validity checks
---   • TPBonusHandler     - TP gear calculation
---   • TP requirement     - 1000 TP minimum check
---   • Final TP display   - With Moonshade/Fencer bonuses
---
--- Usage (in job_precast):
---   if not WSPrecastHandler.handle(spell, eventArgs, JOBTPConfig) then
---       return
---   end
---
--- Usage (in job_post_precast):
---   WSPrecastHandler.apply_tp_gear(spell)
---
--- @file    utils/precast/ws_precast_handler.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-11-29
---============================================================================

local WSPrecastHandler = {}

---============================================================================
--- LAZY LOADING - Dependencies loaded on first use
---============================================================================

local MessageFormatter = nil
local WSValidator = nil
local TPBonusHandler = nil
local TPBonusCalculator = nil
local WS_DB = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    -- Message formatter
    local _, mf = pcall(require, 'shared/utils/messages/message_formatter')
    MessageFormatter = mf

    -- WS Validator (range + validity)
    local _, wsv = pcall(require, 'shared/utils/precast/ws_validator')
    WSValidator = wsv

    -- TP Bonus Handler (gear calculation)
    local _, tph = pcall(require, 'shared/utils/precast/tp_bonus_handler')
    TPBonusHandler = tph

    -- TP Bonus Calculator (final TP with bonuses)
    local _, tpc = pcall(require, 'shared/utils/weaponskill/tp_bonus_calculator')
    TPBonusCalculator = tpc or _G.TPBonusCalculator

    -- WS Database (descriptions)
    local _, wsdb = pcall(require, 'shared/data/weaponskills/UNIVERSAL_WS_DATABASE')
    WS_DB = wsdb

    modules_loaded = true
end

---============================================================================
--- MAIN HANDLER - PRECAST PHASE
---============================================================================

--- Handle all weaponskill precast logic in one call
--- Processing order:
---   1. WSValidator.validate() - Range + validity
---   2. TPBonusHandler.calculate_tp_gear() - TP gear optimization
---   3. TP requirement check (>= 1000)
---   4. Final TP calculation (with Moonshade bonus)
---
--- @param spell table Spell/ability data from GearSwap
--- @param eventArgs table Event arguments (modified if WS cancelled)
--- @param tp_config table Job-specific TP configuration (e.g., WARTPConfig)
--- @return boolean true if WS should proceed, false if cancelled
function WSPrecastHandler.handle(spell, eventArgs, tp_config)
    -- Early exit if not weaponskill
    if spell.type ~= 'WeaponSkill' then
        return true
    end

    -- Lazy load modules
    ensure_modules_loaded()

    -- ==========================================================================
    -- STEP 1: VALIDATION (Range + Validity)
    -- ==========================================================================
    if WSValidator and not WSValidator.validate(spell, eventArgs) then
        return false  -- WS validation failed
    end

    -- ==========================================================================
    -- STEP 2: TP BONUS GEAR CALCULATION
    -- ==========================================================================
    if TPBonusHandler and tp_config then
        TPBonusHandler.calculate_tp_gear(spell, tp_config)
    end

    -- ==========================================================================
    -- STEP 3: TP REQUIREMENT CHECK (>= 1000)
    -- ==========================================================================
    local current_tp = player and player.vitals and player.vitals.tp or 0

    if current_tp < 1000 then
        eventArgs.cancel = true
        if MessageFormatter then
            MessageFormatter.show_ws_validation_error(
                spell.english,
                "Not enough TP",
                string.format("%d/1000", current_tp)
            )
        end
        return false
    end

    -- ==========================================================================
    -- STEP 4: FINAL TP CALCULATION (with Moonshade bonus)
    -- ==========================================================================
    -- Final TP is calculated but message display is disabled
    -- (messages handled by universal ability_message_handler)
    if TPBonusCalculator and TPBonusCalculator.get_final_tp and tp_config then
        local weapon_name = player.equipment and player.equipment.main or nil
        local sub_weapon = player.equipment and player.equipment.sub or nil
        local tp_gear = _G.temp_tp_bonus_gear

        local success, final_tp = pcall(
            TPBonusCalculator.get_final_tp,
            current_tp,
            tp_gear,
            tp_config,
            weapon_name,
            buffactive,
            sub_weapon
        )

        if success then
            -- Store final TP for potential use by other systems
            _G.temp_final_tp = final_tp
        end
    end

    return true  -- WS should proceed
end

---============================================================================
--- POST-PRECAST PHASE - TP GEAR APPLICATION
---============================================================================

--- Apply TP bonus gear calculated in precast phase
--- Called in job_post_precast() after set selection
---
--- @param spell table Spell/ability data from GearSwap
--- @return void
function WSPrecastHandler.apply_tp_gear(spell)
    -- Early exit if not weaponskill
    if spell.type ~= 'WeaponSkill' then
        return
    end

    -- Apply stored TP gear
    local tp_gear = _G.temp_tp_bonus_gear
    if tp_gear then
        equip(tp_gear)
        _G.temp_tp_bonus_gear = nil
    end

    -- Cleanup final TP temp
    _G.temp_final_tp = nil
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return WSPrecastHandler

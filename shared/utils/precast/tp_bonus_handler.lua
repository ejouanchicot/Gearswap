---============================================================================
--- TP Bonus Handler - Universal WeaponSkill TP Gear Optimization
---============================================================================
--- Centralizes TP bonus gear calculation and application across all jobs.
--- Eliminates ~378 lines of duplicated code across 9 PRECAST modules.
---
--- Features:
---   • Automatic TP bonus gear calculation (precast phase)
---   • TP gear application with safe equip() (post-precast phase)
---   • Final TP calculation with Fencer/Store TP bonuses
---   • Formatted TP display via MessageFormatter
---   • Safe error handling with validation
---
--- Usage (in job_precast):
---   TPBonusHandler.calculate_tp_gear(spell, JOBTPConfig)
---
--- Usage (in job_post_precast):
---   TPBonusHandler.apply_and_display(spell, JOBTPConfig)
---
--- @file    utils/precast/tp_bonus_handler.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-17
---============================================================================

local TPBonusHandler = {}

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Load message formatter for TP display
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Load TP bonus calculator (legacy include-based module)
include('../shared/utils/weaponskill/tp_bonus_calculator.lua')

---============================================================================
--- PRECAST PHASE - TP GEAR CALCULATION
---============================================================================

--- Calculate optimal TP bonus gear for weaponskill
--- Called in job_precast() to determine best TP gear before set selection
--- Stores result in _G.temp_tp_bonus_gear for post_precast phase
---
--- @param spell table Spell/ability data from GearSwap
--- @param tp_config table Job-specific TP configuration (e.g., WARTPConfig)
--- @return void (stores result in _G.temp_tp_bonus_gear)
function TPBonusHandler.calculate_tp_gear(spell, tp_config)
    -- Early exit if not weaponskill
    if spell.type ~= 'WeaponSkill' then
        return
    end

    -- Validate dependencies
    if not TPBonusCalculator then
        return
    end
    if not tp_config then
        return
    end
    if not player or not player.vitals then
        return
    end

    -- Extract player state
    local current_tp = player.vitals.tp or 0
    local weapon_name = player.equipment and player.equipment.main or nil
    local sub_weapon = player.equipment and player.equipment.sub or nil

    -- Calculate optimal TP bonus gear
    local tp_gear = TPBonusCalculator.calculate(current_tp, tp_config, weapon_name, buffactive, sub_weapon)

    -- Store for application in post_precast
    _G.temp_tp_bonus_gear = tp_gear
end

---============================================================================
--- POST-PRECAST PHASE - TP GEAR APPLICATION & DISPLAY
---============================================================================

--- Apply TP bonus gear and display final TP
--- Called in job_post_precast() after set selection, before equipping
--- Applies stored TP gear, calculates final TP (with bonuses), displays formatted message
---
--- @param spell table Spell/ability data from GearSwap
--- @param tp_config table Job-specific TP configuration (e.g., WARTPConfig)
--- @return void
function TPBonusHandler.apply_and_display(spell, tp_config)
    -- Early exit if not weaponskill
    if spell.type ~= 'WeaponSkill' then
        return
    end

    -- Validate dependencies
    if not TPBonusCalculator then
        return
    end
    if not tp_config then
        return
    end
    if not player or not player.vitals then
        return
    end

    -- Extract player state
    local current_tp = player.vitals.tp or 0
    local weapon_name = player.equipment and player.equipment.main or nil
    local sub_weapon = player.equipment and player.equipment.sub or nil

    -- Retrieve stored TP gear from precast phase
    local tp_gear = _G.temp_tp_bonus_gear

    -- Apply TP bonus gear if calculated
    if tp_gear then
        equip(tp_gear)
    end

    -- Calculate final TP (includes TP bonus gear + Fencer/Store TP if applicable)
    local total_tp = TPBonusCalculator.get_final_tp(current_tp, tp_gear, tp_config, weapon_name, buffactive,
        sub_weapon)

    -- Display formatted TP message
    if MessageFormatter then
        MessageFormatter.show_ws_tp(spell.name, total_tp)
    end

    -- Cleanup temporary global
    _G.temp_tp_bonus_gear = nil
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return TPBonusHandler

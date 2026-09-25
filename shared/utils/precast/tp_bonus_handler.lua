---  ═══════════════════════════════════════════════════════════════════════════
---   TPBonusHandler - INTERNAL helper for WSPrecastHandler
---  ═══════════════════════════════════════════════════════════════════════════
---   Not a public-facing system. Single caller: ws_precast_handler.lua.
---   Computes TP-bonus gear delta when a weaponskill is launched, defers the
---   actual lookup to TPBonusCalculator (which IS the public engine).
---
---   If you need TP-bonus computations from a job module, use
---   `TPBonusCalculator` (shared/utils/weaponskill/tp_bonus_calculator.lua).
---   Don't require this file directly.
---
---   @file    shared/utils/precast/tp_bonus_handler.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-17
---  ═══════════════════════════════════════════════════════════════════════════

local TPBonusHandler = {}

local TPBonusCalculatorLoaded = false

--- Load TPBonusCalculator once and publish it as _G.TPBonusCalculator.
--- @return table|nil The calculator, or nil if it failed to load
local function ensure_calculator_loaded()
    if not TPBonusCalculatorLoaded then
        local success, calc = pcall(require, 'shared/utils/weaponskill/tp_bonus_calculator')
        if success then
            _G.TPBonusCalculator = calc
        end
        TPBonusCalculatorLoaded = true
    end
    return _G.TPBonusCalculator
end

--- TP read straight from the game's memory.
--- player.vitals.tp is GearSwap's copy, re-read from the game only when the
--- last read is over 0.5 s old (refresh.lua refresh_player), so it can trail
--- the real value; get_player() reads the game directly.
--- Falls back to the copy if the direct read fails.
--- @return number
function TPBonusHandler.live_tp()
    local ok, me = pcall(windower.ffxi.get_player)
    if ok and me and me.vitals and me.vitals.tp then
        return me.vitals.tp
    end
    return player and player.vitals and player.vitals.tp or 0
end

--- Compute the TP bonus gear for a weaponskill and store it in
--- _G.temp_tp_bonus_gear, where WSPrecastHandler.apply_tp_gear picks it up.
--- @param spell table Spell object from GearSwap
--- @param tp_config table Job TP config (e.g. WARTPConfig)
function TPBonusHandler.calculate_tp_gear(spell, tp_config)
    if spell.type ~= 'WeaponSkill' then
        return
    end

    if not tp_config then
        return
    end
    if not player or not player.vitals then
        return
    end

    local calculator = ensure_calculator_loaded()
    if not calculator then
        return
    end

    local current_tp = TPBonusHandler.live_tp()
    local weapon_name = player.equipment and player.equipment.main or nil
    local sub_weapon = player.equipment and player.equipment.sub or nil

    local tp_gear = calculator.calculate(current_tp, tp_config, weapon_name, buffactive, sub_weapon)
    local ok_t, Trace = pcall(require, 'shared/utils/debug/trace_log')
    if ok_t and Trace then
        Trace.log('TP', '%s tp %s main %s sub %s range %s -> gear %s', spell.english, current_tp,
            weapon_name, sub_weapon, player.equipment and player.equipment.range, tp_gear)
    end

    -- Applied in job_post_precast by WSPrecastHandler.apply_tp_gear
    _G.temp_tp_bonus_gear = tp_gear
end

return TPBonusHandler

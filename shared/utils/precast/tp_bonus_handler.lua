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
---   @file shared/utils/precast/tp_bonus_handler.lua
---  ═══════════════════════════════════════════════════════════════════════════

local TPBonusHandler = {}

local MessageFormatter = nil
local TPBonusCalculatorLoaded = false

local function get_formatter()
    if not MessageFormatter then
        MessageFormatter = require('shared/utils/messages/message_formatter')
    end
    return MessageFormatter
end

local function ensure_calculator_loaded()
    if not TPBonusCalculatorLoaded then
        -- Use require instead of include for caching
        local success, calc = pcall(require, 'shared/utils/weaponskill/tp_bonus_calculator')
        if success then
            _G.TPBonusCalculator = calc
        end
        TPBonusCalculatorLoaded = true
    end
    return _G.TPBonusCalculator
end

function TPBonusHandler.calculate_tp_gear(spell, tp_config)
    -- Early exit if not weaponskill
    if spell.type ~= 'WeaponSkill' then
        return
    end

    -- Validate config
    if not tp_config then
        return
    end
    if not player or not player.vitals then
        return
    end

    -- Lazy-load calculator only when needed
    local calculator = ensure_calculator_loaded()
    if not calculator then
        return
    end

    -- Extract player state
    local current_tp = player.vitals.tp or 0
    local weapon_name = player.equipment and player.equipment.main or nil
    local sub_weapon = player.equipment and player.equipment.sub or nil

    -- Calculate optimal TP bonus gear
    local tp_gear = calculator.calculate(current_tp, tp_config, weapon_name, buffactive, sub_weapon)

    -- Store for application in post_precast
    _G.temp_tp_bonus_gear = tp_gear
end

return TPBonusHandler

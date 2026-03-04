-- WS Precast Handler: range check → TP gear → TP requirement → apply gear.
-- Centralizes ~450 lines of WS logic duplicated across 15 PRECAST modules.

local WSPrecastHandler = {}

-- Dependencies (lazy-loaded on first WS)

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

function WSPrecastHandler.handle(spell, eventArgs, tp_config)
    if spell.type ~= 'WeaponSkill' then
        return true
    end

    ensure_modules_loaded()

    -- Range + validity check
    if WSValidator and not WSValidator.validate(spell, eventArgs) then
        return false
    end

    -- TP gear calculation
    if TPBonusHandler and tp_config then
        TPBonusHandler.calculate_tp_gear(spell, tp_config)
    end

    -- TP requirement check (>= 1000)
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

    -- Final TP calculation with Moonshade bonus (stored for other systems, not displayed)
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

return WSPrecastHandler

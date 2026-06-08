-- WS Precast Handler: range check → TP gear → TP requirement → apply gear.
-- Centralizes ~450 lines of WS logic duplicated across 15 PRECAST modules.

local WSPrecastHandler = {}

-- Dependencies (lazy-loaded on first WS)

local MessageFormatter = nil
local WSValidator = nil
local TPBonusHandler = nil
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

end

return WSPrecastHandler

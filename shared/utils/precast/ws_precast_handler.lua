---============================================================================
--- WS Precast Handler - Unified WeaponSkill Processing
---============================================================================
--- Single weaponskill entry point for every [JOB]_PRECAST.lua:
---   handle()        - range/validity check (WSValidator), TP bonus gear
---                     calculation (TPBonusHandler), 1000 TP minimum check
---   apply_tp_gear() - equips the stored TP bonus gear in job_post_precast
---
--- @file    shared/utils/precast/ws_precast_handler.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-11-29
---============================================================================

local WSPrecastHandler = {}

-- Dependencies are lazy-loaded on the first weaponskill
local MessageFormatter = nil
local WSValidator = nil
local TPBonusHandler = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    local mf_ok, mf = pcall(require, 'shared/utils/messages/message_formatter')
    if not mf_ok then mf = nil end
    MessageFormatter = mf

    local wsv_ok, wsv = pcall(require, 'shared/utils/precast/ws_validator')
    if not wsv_ok then wsv = nil end
    WSValidator = wsv

    local tph_ok, tph = pcall(require, 'shared/utils/precast/tp_bonus_handler')
    if not tph_ok then tph = nil end
    TPBonusHandler = tph

    modules_loaded = true
end

--- Run the weaponskill precast checks.
--- @param spell table Spell object from GearSwap
--- @param eventArgs table Event args (cancel is set when the WS is refused)
--- @param tp_config table|nil Job TP config; nil skips the TP gear calculation
--- @return boolean True if the WS should proceed (always true for non-WS)
function WSPrecastHandler.handle(spell, eventArgs, tp_config)
    if spell.type ~= 'WeaponSkill' then
        return true
    end

    ensure_modules_loaded()

    if WSValidator and not WSValidator.validate(spell, eventArgs) then
        return false
    end

    if TPBonusHandler and tp_config then
        TPBonusHandler.calculate_tp_gear(spell, tp_config)
    end

    -- TP requirement check (>= 1000), on the TP read from the game itself:
    -- GearSwap's own copy (player.vitals.tp) is re-read from the game only
    -- when its last read is over 0.5 s old (refresh.lua refresh_player), so
    -- it can trail the real value. The trace logs both to see how often.
    local copy_tp = player and player.vitals and player.vitals.tp or 0
    local current_tp = TPBonusHandler and TPBonusHandler.live_tp() or copy_tp
    local ok_t, Trace = pcall(require, 'shared/utils/debug/trace_log')
    if ok_t and Trace then
        Trace.log('WSTP', '%s live tp %s, GearSwap copy %s%s', spell.english, current_tp, copy_tp,
            current_tp ~= copy_tp and ' (DIFFERENT)' or '')
    end
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

    return true
end

--- Equip the TP bonus gear computed by handle(), then clear it.
--- Called from job_post_precast.
--- @param spell table Spell object from GearSwap
function WSPrecastHandler.apply_tp_gear(spell)
    if spell.type ~= 'WeaponSkill' then
        return
    end

    local tp_gear = _G.temp_tp_bonus_gear
    if tp_gear then
        equip(tp_gear)
        _G.temp_tp_bonus_gear = nil
    end
end

return WSPrecastHandler

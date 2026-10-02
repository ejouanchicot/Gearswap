---============================================================================
--- WS Precast Handler - Unified WeaponSkill Processing
---============================================================================
--- Single weaponskill entry point for every [JOB]_PRECAST.lua:
---   validate()      - range/validity check only (WSValidator), no TP check:
---                     for an automation that builds TP before the WS (Jump)
---   handle()        - range/validity check (WSValidator), auto-Jump on
---                     /DRG (AutoJump, state.JumpAuto), TP bonus gear
---                     calculation (TPBonusHandler), 1000 TP minimum check
---   apply_tp_gear() - equips the stored TP bonus gear in job_post_precast
---
--- An automation that spends an ability before the weaponskill (Third Eye,
--- Climactic Flourish, Jump) must run after these checks, or a weaponskill
--- out of range spends the ability and is then refused.
---
--- @file    shared/utils/precast/ws_precast_handler.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2025-11-29
---============================================================================

local WSPrecastHandler = {}

-- Dependencies are lazy-loaded on the first weaponskill
local MessageFormatter = nil
local WSValidator = nil
local TPBonusHandler = nil
local AutoJump = nil

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

    local aj_ok, aj = pcall(require, 'shared/utils/drg/auto_jump')
    AutoJump = aj_ok and aj or nil

    modules_loaded = true
end

--- Range and validity only (no TP check, no TP gear).
--- @param spell table Spell object from GearSwap
--- @param eventArgs table Event args (cancel is set when the WS is refused)
--- @return boolean True if the WS may proceed (always true for non-WS)
function WSPrecastHandler.validate(spell, eventArgs)
    if spell.type ~= 'WeaponSkill' then
        return true
    end
    ensure_modules_loaded()
    return not (WSValidator and not WSValidator.validate(spell, eventArgs))
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

    -- After the range check (a WS out of range must not spend a Jump), before
    -- the TP check (Jump builds the TP the WS lacks). A WS taken over this way
    -- is replayed once the jumps land, and is not TP-checked now.
    if AutoJump then
        AutoJump.auto_trigger_jump(spell, eventArgs)
        if eventArgs.cancel then return false end
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
    -- the set is on now: what it wears (GearSwap's equip list) counts its own TP pieces
    -- (Boii Cuisses in the base set), so no piece is added for a gap it already closes
    -- gearswap is reached through the user environment's lookup, not as a field of _G
    local ok_g, list = pcall(function() return gearswap.equip_list end)
    local args = _G.temp_tp_bonus_args
    if not ok_g then list = nil end
    if args and type(list) == 'table' and _G.TPBonusCalculator then
        local ok, again = pcall(_G.TPBonusCalculator.calculate, args.tp, args.config, args.main, buffactive, args.sub, list)
        if ok then tp_gear = again end
        local ok_t, Trace = pcall(require, 'shared/utils/debug/trace_log')
        if ok_t and Trace then Trace.log('TP', 'with the set on -> gear %s', tp_gear) end
    end
    _G.temp_tp_bonus_args = nil
    if tp_gear then
        equip(tp_gear)
    end
    _G.temp_tp_bonus_gear = nil
end

return WSPrecastHandler

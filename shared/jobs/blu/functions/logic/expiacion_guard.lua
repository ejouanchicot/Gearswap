---  ═══════════════════════════════════════════════════════════════════════════
---   BLU Expiacion Guard - hold Expiacion back for the Aftermath: Lv.3 window
---  ═══════════════════════════════════════════════════════════════════════════
---   Option blu_expiacion_window (config/AUTO_ABILITIES.lua, off by default).
---   Tizona's Aftermath: Lv.3 needs Expiacion at 3000 TP. With Tizona in the
---   main hand, no Aftermath: Lv.3 up and less than 3000 TP, the first press
---   is cancelled and opens a 3 s window: a second press within it goes.
---
---   TP is read from the game (TPBonusHandler.live_tp): GearSwap's own copy
---   can trail by up to 0.5 s. Under 1000 TP nothing is done here, the
---   weaponskill check refuses the WS with its own message.
---
---   @file    shared/jobs/blu/functions/logic/expiacion_guard.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-09-26
---  ═══════════════════════════════════════════════════════════════════════════

local BLUExpiacionGuard = {}

local AutoOptions = require('shared/utils/core/auto_options')

local WINDOW_SECONDS = 3
local FULL_TP = 3000
local MIN_TP = 1000

-- Closing time of the open window (os.clock), nil when closed
local window_until = nil

--- TP read from the game, GearSwap's copy as a fallback.
--- @return number
local function live_tp()
    local ok, TPBonusHandler = pcall(require, 'shared/utils/precast/tp_bonus_handler')
    if ok and TPBonusHandler and TPBonusHandler.live_tp then
        return TPBonusHandler.live_tp()
    end
    return player and player.vitals and player.vitals.tp or 0
end

--- Whether the window from an earlier press is still open.
--- @return boolean
local function window_open()
    return window_until ~= nil and os.clock() < window_until
end

--- The conditions under which Expiacion is held back.
--- @param tp number Live TP
--- @return boolean
local function should_hold(tp)
    if not (player and player.equipment and player.equipment.main == 'Tizona') then return false end
    if buffactive and buffactive['Aftermath: Lv.3'] then return false end
    return tp >= MIN_TP and tp < FULL_TP
end

--- Cancel the first Expiacion press under the conditions above.
--- @param spell table Weaponskill object from GearSwap
--- @param eventArgs table Event args (cancel is set when held back)
--- @return boolean True when the weaponskill was cancelled
function BLUExpiacionGuard.check(spell, eventArgs)
    if spell.english ~= 'Expiacion' or not AutoOptions.on('blu_expiacion_window') then return false end
    local tp = live_tp()
    local MessageFormatter = require('shared/utils/messages/message_formatter')
    local Trace = require('shared/utils/debug/trace_log')
    -- Gab's file said so at 3000 TP too (Tizona, no Aftermath: Lv.3): it goes
    if tp >= FULL_TP and player and player.equipment and player.equipment.main == 'Tizona'
        and not (buffactive and buffactive['Aftermath: Lv.3']) then
        Trace.log('EXPIACION', 'tp %s, no AM3 -> goes (full TP)', tp)
        MessageFormatter.show_info(('Expiacion at %d TP (no Aftermath: Lv.3)'):format(tp))
        return false
    end
    if not should_hold(tp) then return false end

    if window_open() then
        Trace.log('EXPIACION', 'tp %s, window open -> goes', tp)
        MessageFormatter.show_info(('Expiacion at %d TP (no Aftermath: Lv.3)'):format(tp))
        return false
    end

    eventArgs.cancel = true
    window_until = os.clock() + WINDOW_SECONDS
    Trace.log('EXPIACION', 'tp %s, no AM3 -> cancelled, window %ss', tp, WINDOW_SECONDS)
    MessageFormatter.show_warning(('Expiacion cancelled (%d TP, no Aftermath: Lv.3): press again within %d s to use it anyway')
        :format(tp, WINDOW_SECONDS))
    return true
end

return BLUExpiacionGuard

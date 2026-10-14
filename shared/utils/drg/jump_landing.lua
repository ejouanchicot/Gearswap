---============================================================================
--- Jump Landing - wait for a Jump to land before reading the TP it gave
---============================================================================
--- A Jump sent with send_command lands some time later (its animation, the
--- server's lag): reading the TP after a fixed wait can see the TP from before
--- it. Here the Jump's own action packet (0x028, our actor, the ability's id)
--- tells it went off, then the TP the game shows is read once it moved (it
--- comes in its own packet just after). A Jump that never goes off (out of
--- range, refused) ends the wait at TIMEOUT.
---
---   JumpLanding.after('Jump', function(tp) ... end)
---   JumpLanding.after('High Jump', function(tp) ... end, function() <send it again> end)
---
--- Used by shared/utils/drg/auto_jump.lua (Jump before a weaponskill) and
--- shared/utils/drg/DRG_JUMP_MANAGER.lua (//gs c jump).
---
--- @file    shared/utils/drg/jump_landing.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-03
---============================================================================

local ActionListener = require('shared/utils/core/action_listener')
local live_tp = require('shared/utils/core/live_tp')

local JumpLanding = {}

--- Ability ids (res/job_abilities.lua)
local JUMP_IDS = {['Jump'] = 66, ['High Jump'] = 67}
--- Action categories a job ability comes in (6, and 14 for the unblinkable ones)
local JA_CATEGORIES = {[6] = true, [14] = true}

local POLL = 0.1
--- No shortest wait: the Jump's packet and the TP that follows it end the wait. Until 2026-10-13 a floor of
--- 1.0 s stood here: measured in game that night, a Jump, a High Jump and the weaponskill took 2 to 3 s with
--- no auto-attack in between. NOT measured: whether the game accepts an ability that soon after another (a
--- refused one is sent again, RESEND_AT).
--- A Jump sent through `resend` that has not gone off by then is sent once more
local RESEND_AT = 1.2
--- Longest wait for the TP once the Jump went off
local TP_WAIT = 0.6
--- Longest wait in all
local TIMEOUT = 3.0

--- A listener key of its own for each wait: two waits at once (//gs c jump during an automatic Jump) shared one,
--- the second replaced the first's listener and the first, ending at TIMEOUT, took the second's off. The count lives
--- on windower (kept across loads): a wait of the load before, still running, never meets a new one's key.
local function new_key()
    windower._jump_landing_n = (windower._jump_landing_n or 0) + 1
    return 'jump_landing#' .. windower._jump_landing_n
end

local function my_id()
    local ok, me = pcall(windower.ffxi.get_player)
    return ok and me and me.id or nil
end

--- Call done(tp) once the Jump sent went off and its TP came (TP_WAIT at most after it), or after TIMEOUT.
--- @param name string 'Jump' or 'High Jump'
--- @param done function Called with the TP the game shows then
--- @param resend function|nil Called once when the Jump has not gone off after RESEND_AT (sent too soon
---   after another ability, the game refuses it): it sends the Jump again
function JumpLanding.after(name, done, resend)
    local id, me = JUMP_IDS[name], my_id()
    -- the TP when the Jump went off: an auto-attack's TP that came before it is not the Jump's
    local landed_at, tp_then, waited, finished = nil, nil, 0, false
    local key = new_key()
    ActionListener.on(key, function(act)
        if not landed_at and act.actor_id == me and JA_CATEGORIES[act.category] and act.param == id then
            landed_at, tp_then = waited, live_tp()
        end
    end)
    local function poll()
        if finished then return end
        waited = math.floor((waited + POLL) * 10 + 0.5) / 10  -- tenths, no float drift
        local tp = live_tp()
        if resend and not landed_at and waited >= RESEND_AT then
            resend()
            resend = nil
        end
        local tp_in = landed_at and (tp ~= tp_then or waited - landed_at >= TP_WAIT)
        if waited >= TIMEOUT or tp_in then
            finished = true
            ActionListener.off(key)
            return done(tp)
        end
        coroutine.schedule(poll, POLL)
    end
    coroutine.schedule(poll, POLL)
end

return JumpLanding

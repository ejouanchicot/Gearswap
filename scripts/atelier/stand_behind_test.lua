---============================================================================
--- Test of shared/jobs/geo/functions/logic/stand_behind.lua (the decision, not the game)
--- Run from data/: lua5.1 scripts/atelier/stand_behind_test.lua
--- @file scripts/atelier/stand_behind_test.lua
--- @author ejouanchicot
--- @date Created: 2026-11-13
---============================================================================
-- The spot matches Silmaril's (Calc.Range_Calc "Melee", Position.Check_Movement with Auto_Distance,
-- Calculate_Offset "Back", copied below as written in C#); the first placement goes at once; a monster that
-- turns is followed only after `settle` seconds off the spot; nothing moves during a cast; a run stops on arrival,
-- after 4 s, or with the monster gone; a spot farther than 20 yalms is not run to.
package.path = './?.lua;' .. package.path
windower = {}
-- the real trace_log loads the project's require cache, which then bypasses the stubs below
local trace_lines = {}
package.loaded['shared/utils/debug/trace_log'] = {log = function(tag, fmt, ...) trace_lines[#trace_lines + 1] = fmt end}
-- and the real job_config loads it too: its stub goes first, its values set by each part below
local config_values = {}
package.loaded['shared/utils/core/job_config'] = {get = function(_, key, default)
    local v = config_values[key]
    if v == nil then return default end
    return v
end}
local SB = dofile('shared/jobs/geo/functions/logic/stand_behind.lua')

local fails = 0
local function check(name, ok, detail)
    if not ok then fails = fails + 1 end
    print((ok and 'ok   ' or 'FAIL ') .. name .. (detail and (': ' .. detail) or ''))
end
local function near(a, b) return math.abs(a - b) < 1e-9 end

-- Silmaril, as written: melee range, the Auto_Distance offset, then Calculate_Offset "Back"
local function silmaril_spot(mob, me)
    local range = math.floor((2.0 + mob.model_size + me.model_size - 0.5) * 100 + 0.5) / 100
    local num, num2 = range - 0.2, 0.25
    local offset = (num + num2) / 2.0
    local h = mob.heading
    h = (not (h < 0.0)) and (math.pi * 2.0 - h) or math.abs(h)
    h = h + math.pi
    return mob.x + math.cos(h) * offset, mob.y + math.sin(h) * offset
end
local me0 = {x = 0, y = 0, model_size = 0.6}
for _, case in ipairs({{h = 0, s = 1.2}, {h = 1.1, s = 3.4}, {h = -2.0, s = 0.8}, {h = math.pi, s = 6}}) do
    local mob = {x = 10, y = -4, heading = case.h, model_size = case.s}
    local x, y = SB.spot(mob, me0)
    local sx, sy = silmaril_spot(mob, me0)
    check(('spot same as Silmaril (heading %.1f, size %.1f)'):format(case.h, case.s), near(x, sx) and near(y, sy),
        ('%.3f,%.3f vs %.3f,%.3f'):format(x, y, sx, sy))
end

-- a set distance: that many yalms from the mob's center, still behind it
do
    local mob = {x = 10, y = -4, heading = 1.1, model_size = 3.4}
    local x, y, d = SB.spot(mob, me0, 4)
    local ax, ay = SB.spot(mob, me0)
    local ux, uy = (ax - mob.x), (ay - mob.y)
    local ul = math.sqrt(ux * ux + uy * uy)
    check('set distance: 4 yalms from the center', near(math.sqrt((x - mob.x) ^ 2 + (y - mob.y) ^ 2), 4) and d == 4)
    check('set distance: same side as Silmaril\'s spot', near((x - mob.x) / 4, ux / ul) and near((y - mob.y) / 4, uy / ul))
end

local MOB = {spawn_type = 16, hpp = 100, x = 10, y = 0, heading = 0, model_size = 1}
local sx, sy = SB.spot(MOB, me0)
local function at(x, y) return {x = x, y = y, model_size = 0.6} end
local far = at(sx + 5, sy)          -- 5 yalms off the spot
local there = at(sx + 0.2, sy)      -- arrived
local S = 7

-- first placement: at once
local st = {first = true}
local act = SB.step(st, 0, far, MOB, false, S)
check('first placement goes at once', act and act.run ~= nil)
check('run points to the spot', act and near(act.run, SB.angle(far.x, far.y, sx, sy)))
act = SB.step(st, 0.5, there, MOB, false, S)
check('arrived: stop and face the mob', act and act.stop and act.face ~= nil and near(act.face, SB.angle(there.x, there.y, MOB.x, MOB.y)))
check('arrived: no longer running', st.running_since == nil)

-- the monster turns: wait settle seconds off the spot, then walk back
st = {}
check('off the spot at 0 s: waits', SB.step(st, 10, far, MOB, false, S) == nil)
check('off the spot at 6 s: still waits', SB.step(st, 16, far, MOB, false, S) == nil)
act = SB.step(st, 17.1, far, MOB, false, S)
check('off the spot past 7 s: walks back', act and act.run ~= nil)

-- back on the spot before settle: the wait starts again
st = {}
SB.step(st, 0, far, MOB, false, S)
check('back on the spot: wait cleared', SB.step(st, 3, there, MOB, false, S) == nil and st.away_since == nil)
check('off again: waits from zero', SB.step(st, 8, far, MOB, false, S) == nil)

-- casting: never moves; a run under way stops and resumes after the cast
st = {first = true}
check('casting: no first run', SB.step(st, 0, far, MOB, true, S) == nil)
SB.step(st, 1, far, MOB, false, S)
act = SB.step(st, 1.5, far, MOB, true, S)
check('cast during a run: stop', act and act.stop)
act = SB.step(st, 4, far, MOB, false, S)
check('after the cast: runs again at once', act and act.run ~= nil)

-- a run lasts 4 s at most
st = {first = true}
SB.step(st, 0, far, MOB, false, S)
act = SB.step(st, 4.5, far, MOB, false, S)
check('run longer than 4 s: stop', act and act.stop)

-- a moving monster is never run after: the wait starts again once it stands still
st = {}
SB.note_movement(st, {id = 9, x = 0, y = 0}, 0)
check('first sight: taken as standing', st.mob_moving == false)
SB.note_movement(st, {id = 9, x = 0.1, y = 0}, 0.5)
check('a small shift: still standing', st.mob_moving == false)
SB.note_movement(st, {id = 9, x = 2, y = 0}, 1.0)
check('moved: moving', st.mob_moving == true)
SB.note_movement(st, {id = 9, x = 2, y = 0}, 2.0)
check('1 s without moving: still counted as moving', st.mob_moving == true)
SB.note_movement(st, {id = 9, x = 2, y = 0}, 2.6)
check('1.6 s without moving: standing', st.mob_moving == false)

st = {}
SB.step(st, 0, far, MOB, false, S)               -- off the spot, wait starts
st.mob_moving = true
check('monster moving: no run', SB.step(st, 8, far, MOB, false, S) == nil)
check('monster moving: wait restarted', st.away_since == nil)
st.mob_moving = false
check('standing again: waits from zero', SB.step(st, 9, far, MOB, false, S) == nil)
act = SB.step(st, 16.1, far, MOB, false, S)
check('standing 7 s off the spot: walks back', act and act.run ~= nil)
st.mob_moving = true
act = SB.step(st, 16.6, far, MOB, false, S)
check('monster moves during a run: stop', act and act.stop and st.running_since == nil)

-- facing the monster while standing (the turn sent with the stop of a run was lost: back to the mob)
do
    local mob = {x = 10, y = 0}
    local me = {x = 6, y = 0}
    local want = SB.angle(me.x, me.y, mob.x, mob.y)
    me.heading = want
    check('facing it: no turn', SB.face_turn(me, mob) == nil)
    me.heading = want + math.pi
    check('back to it: turned towards it', SB.face_turn(me, mob) ~= nil and near(SB.face_turn(me, mob), want))
    me.heading = want + math.rad(20)
    check('20 degrees off: let be', SB.face_turn(me, mob) == nil)
    local behind_y = {x = 10, y = 0.001}
    me = {x = 6, y = 0}
    local w2 = SB.angle(me.x, me.y, behind_y.x, behind_y.y)
    me.heading = w2 + 2 * math.pi - 0.1
    check('across the -pi/+pi wrap: no turn', SB.face_turn(me, behind_y) == nil)
end

-- far spot, no monster, dead monster
st = {first = true}
check('spot 25 yalms away: no run', SB.step(st, 0, at(sx + 25, sy), MOB, false, S) == nil)
check('no monster: nothing', SB.step({first = true}, 0, far, nil, false, S) == nil)
check('dead monster: nothing', SB.step({first = true}, 0, far, {spawn_type = 16, hpp = 0, x = 0, y = 0, heading = 0}, false, S) == nil)
check('a player, not a monster: nothing', SB.step({first = true}, 0, far, {spawn_type = 13, hpp = 100, x = 0, y = 0, heading = 0}, false, S) == nil)
st = {first = true}
SB.step(st, 0, far, MOB, false, S)
act = SB.step(st, 0.5, far, nil, false, S)
check('monster gone during a run: stop', act and act.stop and st.running_since == nil)

-- the loop: one per start, and a run under way always stopped (stop, unload, resume after a load)
local runs, scheduled = {}, {}
windower = {_load_gen = 1, ffxi = {
    run = function(v) runs[#runs + 1] = v end, turn = function() end,
    get_info = function() return {zone = 262} end,
    get_player = function() return nil end,          -- no player: look() does nothing
}}
coroutine.schedule = function(fn) scheduled[#scheduled + 1] = fn end
local function tick_all()
    local now = scheduled
    scheduled = {}
    for _, fn in ipairs(now) do fn() end
end
SB.start()
tick_all()
check('one loop after a start', #scheduled == 1)
SB.start()
tick_all()
check('a second start: still one loop', #scheduled == 1, tostring(#scheduled))
windower._stand_behind.running_since = 1
runs = {}
SB.unload()
check('unload stops a run', runs[1] == false and windower._stand_behind.running_since == nil)
check('unload keeps it on (the next GEO load goes on)', windower._stand_behind.on == true)
windower._stand_behind.running_since = 1
windower._load_gen = 2
runs = {}
SB.resume()
check('resume after a load stops a run left on', runs[1] == false)
tick_all()
check('resume: one loop, on the new load', #scheduled == 1)
windower._stand_behind.running_since = 1
runs = {}
SB.stop('test')
check('stop stops a run and turns off', runs[1] == false and windower._stand_behind.on == false)
tick_all()
check('stopped: no loop left', #scheduled == 0)

-- `first`: the named monster (nearest in combat first), the leader told once on arrival or after the wait
local mobs = {
    [1] = {id = 1, name = 'Vampire Leech', spawn_type = 16, hpp = 100, status = 0, distance = 4},
    [2] = {id = 2, name = 'Vampire Leech', spawn_type = 16, hpp = 100, status = 1, claim_id = 1, distance = 50},
    [3] = {id = 3, name = 'Vampire Leech', spawn_type = 16, hpp = 100, status = 1, claim_id = 1, distance = 20},
    [4] = {id = 4, name = 'Vampire Leech', spawn_type = 16, hpp = 0, status = 1, distance = 1},
    [5] = {id = 5, name = 'Tetsouo', spawn_type = 13, hpp = 100, status = 1, distance = 1},
}
check('named: the nearest one in combat', (SB.find_named('vampire leech', mobs) or {}).id == 3)
check('named: none of that name', SB.find_named('Aminon', mobs) == nil)
-- 2026-11-14: only a monster someone fights; one that died is forgotten even when it pops again with its id
mobs[3].claim_id = 0
check('named: an unclaimed one left out', (SB.find_named('vampire leech', mobs) or {}).id == 2)
mobs[3].claim_id = 1
check('fought: claimed and alive', SB.fought({hpp = 50, claim_id = 9}) and not SB.fought({hpp = 50, claim_id = 0})
    and not SB.fought({hpp = 0, claim_id = 9}) and not SB.fought(nil))

local leech = {id = 3, name = 'Vampire Leech', spawn_type = 16, hpp = 100, status = 1, claim_id = 1, x = 10, y = 0, heading = 0,
    model_size = 1, distance = 20}
local spotx, spoty = SB.spot(leech, {model_size = 0.6}, 4)
local me_mob = {x = spotx, y = spoty, model_size = 0.6}
local sent_cmds = {}
send_command = function(c) sent_cmds[#sent_cmds + 1] = c end
midaction = function() return false end
windower = {_load_gen = 5, ffxi = {
    run = function() end, turn = function() end,
    get_info = function() return {zone = 262} end,
    get_player = function() return {main_job = 'GEO', target_locked = false} end,
    get_mob_by_target = function(t) if t == 'me' then return me_mob end end,
    get_mob_by_id = function(id) return id == 3 and leech or nil end,
    get_mob_array = function() return {[3] = leech} end,
}}
config_values.stand_behind_distance = 4
package.loaded['shared/utils/messages/message_formatter'] = {show_info = function() end}
scheduled = {}
SB.command({'first', 'Tetsouo', 'leechtest', 'Vampire', 'Leech'})
check('first: going behind the named mob', windower._stand_behind.mob_name == 'Vampire Leech')
tick_all()     -- the first look: already on the spot
check('first: leader told on arrival', sent_cmds[1] == 'send Tetsouo gs c sortie leechtest placed', tostring(sent_cmds[1]))
tick_all(); tick_all()
check('first: told only once', #sent_cmds == 1, tostring(#sent_cmds))

sent_cmds = {}
me_mob = {x = spotx + 6, y = spoty, model_size = 0.6}
midaction = function() return true end      -- casting: never moves, never arrives
scheduled = {}
SB.command({'first', 'Tetsouo', 'leechtest', 'Vampire', 'Leech'})
local wait_fn = table.remove(scheduled, 1)   -- scheduled first: the 12 s wait, kept out of the ticks
tick_all()
check('not there yet: nothing told', #sent_cmds == 0)
wait_fn()
check('after the wait: leader told anyway', sent_cmds[1] == 'send Tetsouo gs c sortie leechtest placed')
SB.stop('test')

-- 2026-11-13: `behind off` (another target loaded) before the wait is over: the leader is not told
sent_cmds = {}
scheduled = {}
SB.command({'first', 'Tetsouo', 'aminon', 'Aminon'})
wait_fn = table.remove(scheduled, 1)
SB.command({'off'})
wait_fn()
check('stopped before the wait: nothing told', #sent_cmds == 0, tostring(sent_cmds[1]))

-- looks every 0.1 s while running (0.5 s is 2-3 yalms: the spot was overshot), 0.5 s otherwise
do
    local delays = {}
    local saved = coroutine.schedule
    coroutine.schedule = function(fn, delay) delays[#delays + 1] = delay; scheduled[#scheduled + 1] = fn end
    midaction = function() return false end
    me_mob = {x = spotx + 8, y = spoty, model_size = 0.6}
    windower.ffxi.get_player = function() return {main_job = 'GEO', target_locked = true} end
    windower.ffxi.get_mob_by_target = function(t) if t == 'me' then return me_mob elseif t == 't' then return leech end end
    scheduled = {}
    SB.command({})
    check('running: next look in 0.1 s', delays[#delays] == 0.1, tostring(delays[#delays]))
    me_mob = {x = spotx, y = spoty, model_size = 0.6}
    tick_all()
    check('arrived: next look in 0.5 s', delays[#delays] == 0.5, tostring(delays[#delays]))
    SB.stop('test')
    coroutine.schedule = saved
end

-- one /lockon per run, however many looks the run takes (lifted at every look, the GEO spun)
sent_cmds = {}
midaction = function() return false end
me_mob = {x = spotx + 8, y = spoty, model_size = 0.6}
windower.ffxi.get_player = function() return {main_job = 'GEO', target_locked = true} end
windower.ffxi.get_mob_by_target = function(t) if t == 'me' then return me_mob elseif t == 't' then return leech end end
scheduled = {}
SB.command({})
for _ = 1, 6 do tick_all() end
local lockons = 0
for _, c in ipairs(sent_cmds) do if c == 'input /lockon' then lockons = lockons + 1 end end
check('one /lockon for the whole run', lockons == 1, tostring(lockons))
SB.stop('test')

-- stand_behind_lock: on the spot 10 s with the monster standing, the GEO stays put for good behind it
do
    local M = {id = 77, spawn_type = 16, hpp = 100, x = 10, y = 0, heading = 0, model_size = 1}
    local st = {lock = 10, back = 2, mob_moving = false}
    SB.step(st, -0.5, there, M, false, S)            -- first look at this monster: the count starts at the next
    check('lock: on the spot at 0 s, not yet', SB.step(st, 0, there, M, false, S) == nil and not st.locked)
    check('lock: on the spot at 9 s, not yet', SB.step(st, 9, there, M, false, S) == nil and not st.locked)
    local a = SB.step(st, 10, there, M, false, S)
    check('lock: 10 s on the spot, in place for good', a and a.locked and st.locked == 77)
    check('lock: its place kept', st.lock_x == there.x and st.lock_y == there.y and st.lock_mx == M.x)
    local turned = {id = 77, spawn_type = 16, hpp = 100, x = 10, y = 0, heading = math.pi / 2, model_size = 1}
    check('lock: the monster turns, no run however long', SB.step(st, 30, there, turned, false, S) == nil
        and SB.step(st, 60, there, turned, false, S) == nil)

    -- knocked back (white hits): back to the locked place after 2 s, never during a cast
    check('knockback: 1 s off its place, waits', SB.step(st, 61, far, turned, false, S) == nil)
    check('knockback: casting, waits', SB.step(st, 63, far, turned, true, S) == nil)
    local back = SB.step(st, 63.1, far, turned, false, S)
    check('knockback: 2 s off, walks back', back and back.run ~= nil)
    check('knockback: towards its locked place', back and near(back.run, SB.angle(far.x, far.y, there.x, there.y)))
    local stop = SB.step(st, 63.5, at(there.x + 0.1, there.y), turned, false, S)
    check('knockback: back there, stops', stop and stop.stop and st.locked == 77)

    -- a place it cannot reach (pushed against a wall): after 3 runs back that never arrive, where it stands is its place
    local wall = at(there.x + 3, there.y)
    local t0 = 64
    for i = 1, 3 do
        SB.step(st, t0, wall, turned, false, S)                  -- off its place: the wait starts
        local r = SB.step(st, t0 + 2.1, wall, turned, false, S)  -- walks back
        local e = SB.step(st, t0 + 6.3, wall, turned, false, S)  -- 4 s later, still not there
        check('cannot reach: run ' .. i .. ' goes and ends', r and r.run ~= nil and e and e.stop)
        if i < 3 then check('cannot reach: keeps its place after miss ' .. i, st.lock_x == there.x and not e.adopted)
        else check('cannot reach: 3rd miss, stands here now', e.adopted and st.lock_x == wall.x) end
        t0 = t0 + 7
    end
    check('cannot reach: no more running', SB.step(st, t0 + 10, wall, turned, false, S) == nil)
    st.lock_x, st.lock_y = there.x, there.y

    -- the monster itself moves off: the lock is over, placed behind it again
    local moved = {id = 77, spawn_type = 16, hpp = 100, x = 14, y = 0, heading = 0, model_size = 1}
    local u = SB.step(st, 200, there, moved, false, S)
    check('monster moved 4 yalms: lock over', u and u.unlocked and st.locked == nil)

    -- locked behind one monster, another one is placed for as usual
    st.locked, st.lock_x, st.lock_y, st.lock_mx, st.lock_my = 77, there.x, there.y, M.x, M.y
    local other = {id = 78, spawn_type = 16, hpp = 100, x = 10, y = 0, heading = 0, model_size = 1}
    SB.step(st, 210, far, other, false, S)
    local b = SB.step(st, 217.1, far, other, false, S)
    check('lock: another monster is placed for again', b and b.run ~= nil)

    st = {lock = 10, mob_moving = false, in_place_mob = 77}
    SB.step(st, 0, there, M, false, S)
    SB.step(st, 6, far, M, false, S)                  -- turned before 10 s: the count restarts
    SB.step(st, 7, there, M, false, S)
    check('lock: count restarts after leaving the spot', SB.step(st, 16, there, M, false, S) == nil and not st.locked)
    check('lock: 10 s from the return', SB.step(st, 17, there, M, false, S) ~= nil and st.locked == 77)

    st = {lock = 10, mob_moving = true}
    SB.step(st, 0, there, M, false, S)
    check('lock: monster moving, never locks', SB.step(st, 20, there, M, false, S) == nil and not st.locked)

    st = {lock = 0, mob_moving = false}
    SB.step(st, 0, there, M, false, S)
    check('lock 0: never locks', SB.step(st, 100, there, M, false, S) == nil and not st.locked)
end

-- the count belongs to one monster: on the spot of a new one at first sight, it starts from zero
do
    local A = {id = 1, spawn_type = 16, hpp = 100, x = 10, y = 0, heading = 0, model_size = 1}
    local B = {id = 2, spawn_type = 16, hpp = 100, x = 10, y = 0, heading = 0, model_size = 1}
    local st = {lock = 10, mob_moving = false}
    SB.step(st, 0, there, A, false, S)
    SB.step(st, 1, there, A, false, S)
    check('count per monster: a new one starts from zero', SB.step(st, 11, there, B, false, S) == nil and not st.locked)
    SB.step(st, 12, there, B, false, S)                -- the count starts here
    check('count per monster: 9 s behind the new one, not yet', SB.step(st, 21, there, B, false, S) == nil)
    check('count per monster: 10 s behind the new one', SB.step(st, 22, there, B, false, S) ~= nil and st.locked == 2)
end

-- a plain //gs c behind while already on keeps the placement and the lock (the fight sends `first`, then `behind`)
do
    windower._stand_behind = nil
    scheduled = {}
    SB.command({'first', 'Tetsouo', 'leechtest', 'Vampire', 'Leech'})
    local first_state = windower._stand_behind
    first_state.locked = 99
    SB.command({})
    check('plain behind while on: same state, lock kept', windower._stand_behind == first_state and first_state.locked == 99)
    SB.stop('test')
    SB.command({})
    check('plain behind after off: a fresh start', windower._stand_behind ~= first_state and windower._stand_behind.locked == nil)
    SB.stop('test')
end

-- `first ... id=<n>`: that very monster, before the lock or the nearest of the name
do
    windower._stand_behind = nil
    scheduled = {}
    SB.command({'first', 'Tetsouo', 'leechtest', 'id=4242', 'Vampire', 'Leech'})
    local st = windower._stand_behind
    check('first with id: id kept', st.want_id == 4242)
    check('first with id: name without the id', st.mob_name == 'Vampire Leech')
    SB.stop('test')
    SB.command({'first', 'Tetsouo', 'leechtest', 'Vampire', 'Leech'})
    check('first without id: name only', windower._stand_behind.want_id == nil and windower._stand_behind.mob_name == 'Vampire Leech')
    SB.stop('test')
end

print(fails == 0 and 'ALL OK' or (fails .. ' FAILED'))
os.exit(fails == 0 and 0 or 1)

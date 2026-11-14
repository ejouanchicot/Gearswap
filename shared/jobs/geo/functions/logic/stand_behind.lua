---============================================================================
--- GEO Stand Behind - stand behind the locked monster, nobody engaged
---============================================================================
--- //gs c behind       start: the GEO walks behind the monster it is locked on
---                     (`stand_behind_distance` yalms from its center, 0 = half the melee range),
---                     and back there whenever it stayed off that spot for
---                     `stand_behind_settle` seconds (geo/combat/GEO_CONFIG.lua,
---                     7 by default): a monster that turns for a moment as the
---                     hate moves does not drag the GEO around. Once on the
---                     spot `stand_behind_lock` seconds (10 by default) with the
---                     monster standing still, it is in place for good: it no
---                     longer moves until the next //gs c behind (wanted by the
---                     player for Aminon, 2026-11-13: placed by the tank, it only
---                     turns, and running after it as it turns serves nothing).
---                     Knocked back from there (Aminon's white hits), it walks
---                     back to that very place after `stand_behind_back`
---                     seconds (2 by default); the monster itself moving more
---                     than a yalm ends the lock, and it is placed behind again.
--- //gs c behind off   stop (also sent by //gs c sortie for every profile that
---                     does not ask for it, and by //gs c escort).
---
--- Why: Silmaril places a character behind the mob only while the player it
--- assists is ENGAGED (Combat_Actions.Combat, decompiled), and on Aminon HQ
--- nobody engages: the GEO locks on without engaging (Fighting, Attack Off).
--- The spot is Silmaril's own (Position.Check_Movement with Auto_Distance):
--- half the melee range behind the mob as it faces, melee range = 2 + mob size
--- + own size - 0.5 (Calc.Range_Calc). Running is Silmaril's addon's own way
--- (addons/Silmaril/lib/Moving.lua): windower.ffxi.run(-atan2(dy, dx)), the
--- lock-on lifted first (a locked character does not run straight).
---
--- Fast (asked 2026-11-14: 27 s to be placed on a Leech): a moving monster is
--- run after, the run aimed again at every look (0.1 s) at the spot behind where
--- it is now. 3 runs in a row that end short of the spot (a kited monster, a
--- wall, a monster turning to face the GEO) and it stands 10 s before trying
--- again: the bot casts meanwhile. While a run is under way, the bot's spells
--- are held back at the precast (hold_check; never Stun nor a Cure): one
--- started mid-run stopped it 5 times in that placement.
---
--- Safety: never moves while a spell or ability is under way (moving cancels
--- it); one run lasts 4 s at most; a spot farther than 20 yalms is not run to;
--- only acts while locked on a monster (in a follow or an escort it never is);
--- stops on a zone change, a job other than GEO, a newer GearSwap load (which
--- starts it again on GEO when it was on). Every step is written to the trace
--- (//gs c trace, tag BEHIND).
---
--- @file    shared/jobs/geo/functions/logic/stand_behind.lua
--- @author  ejouanchicot
--- @version 1.1 - runs after a moving monster, the bot's spells held during a run
--- @date    Created: 2026-11-13 | Updated: 2026-11-14
---============================================================================

local StandBehind = {}

local TICK = 0.5          -- seconds between two looks
local TICK_RUN = 0.1      -- seconds between two looks while running: 0.5 s is 2-3 yalms of running, the spot
                          -- was overshot again and again until the 4 s limit (2026-11-13)
local TOLERANCE = 1.0     -- yalms off the spot before it counts as moved away
local ARRIVED = 0.25      -- yalms from the spot: there (0.4 left the GEO at 4.3 for 4: with a look every 0.1 s,
                          -- about 0.5 yalm of running, a window of 0.5 is still not run past)
local MOVE_LIMIT = 4      -- seconds one run may last
local MAX_RUN = 20        -- yalms: a spot farther than this is not run to
local SETTLE = 7          -- default of stand_behind_settle
local LOCK = 10           -- default of stand_behind_lock
local BACK = 2            -- default of stand_behind_back: seconds pushed off the locked place before walking back
local MAX_MISSES = 3      -- runs back that end without arriving before the GEO takes where it stands as its place
                          -- (pushed against a wall, hits faster than it walks back: no endless running, review)
local ARRIVAL_WAIT = 20   -- seconds `first` waits for the placement before telling the leader anyway (12 told it
                          -- before the GEO was there: the fight profile's spells then cut its runs, 2026-11-14)
local RELIFT_EVERY = 1    -- seconds between two lifts of a lock-on the bot put back during a run
local RELIFT_MAX = 3      -- lifts again in one run (4 s)
local CHASE_MAX = 3       -- runs in a row ending short of the spot before a pause (kited, a wall, facing the GEO)
local CHASE_PAUSE = 10    -- seconds it then stands, the bot casting (no pause: it ran without end, review 2026-11-14);
                          -- doubled at each pause in a row (60 at most), back to 10 once it reaches its spot
local STILL = 1.5         -- seconds without moving before the monster counts as standing (the stay-put lock)
local STILL_MOVE = 0.3    -- yalms the monster may shift between two looks and still count as standing
local NEAR = 5            -- yalms off the spot under which a WALKING monster is waited for, not run after: close to
                          -- it, the spot moves as fast as she runs and she stuck to its back for 4 s (2026-11-14
                          -- 20:56, 21:05, 21:12, each time a Leech walking to its tank)
local NEAR_STILL = 0.5    -- seconds without moving before that monster counts as stopped
local NO_PROGRESS = 1     -- seconds of a run without getting 0.3 yalm closer: the run ends (stuck)
local FACE_OFF = math.rad(35) -- facing further off the monster than this: turned towards it
local FACE_EVERY = 1      -- seconds between two turns
local MONSTER = 16        -- spawn_type of a monster

local function trace(fmt, ...)
    local args = {...}
    pcall(function() require('shared/utils/debug/trace_log').log('BEHIND', fmt, unpack(args)) end)
end

--- Seconds off the spot before walking back (GEO_CONFIG stand_behind_settle).
--- @return number
function StandBehind.settle()
    local ok, s = pcall(function() return require('shared/utils/core/job_config').get('GEO', 'stand_behind_settle', SETTLE) end)
    return ok and type(s) == 'number' and s >= 0 and s or SETTLE
end

--- Seconds on the spot, the monster standing, after which the GEO stays put for good
--- (GEO_CONFIG stand_behind_lock; 0 = never, it keeps following the monster's turns).
--- @return number
function StandBehind.lock_after()
    local ok, s = pcall(function() return require('shared/utils/core/job_config').get('GEO', 'stand_behind_lock', LOCK) end)
    return ok and type(s) == 'number' and s >= 0 and s or LOCK
end

--- Seconds knocked off the locked place before walking back (GEO_CONFIG stand_behind_back).
--- @return number
function StandBehind.back_after()
    local ok, s = pcall(function() return require('shared/utils/core/job_config').get('GEO', 'stand_behind_back', BACK) end)
    return ok and type(s) == 'number' and s >= 0 and s or BACK
end

--- Yalms from the mob's center (GEO_CONFIG stand_behind_distance), nil: Silmaril's own distance.
--- @return number|nil
function StandBehind.distance()
    local ok, d = pcall(function() return require('shared/utils/core/job_config').get('GEO', 'stand_behind_distance', 0) end)
    return ok and type(d) == 'number' and d > 0 and d or nil
end

--- The spot behind a mob, as Silmaril computes it (half the melee range), or `dist` yalms behind it.
--- @param mob table x, y, heading, model_size
--- @param me table model_size
--- @param dist number|nil Yalms from the mob's center, nil: Silmaril's
--- @return number, number, number x, y, distance from the mob
function StandBehind.spot(mob, me, dist)
    local range = 2 + (mob.model_size or 0) + (me.model_size or 0) - 0.5
    local d = dist or (range - 0.2 + 0.25) / 2
    local a = mob.heading < 0 and math.abs(mob.heading) or (math.pi * 2 - mob.heading)
    a = a + math.pi
    return mob.x + math.cos(a) * d, mob.y + math.sin(a) * d, d
end

--- The run/turn angle from a point towards another (Silmaril's addon convention).
--- @return number radians
function StandBehind.angle(from_x, from_y, to_x, to_y)
    return -math.atan2(to_y - from_y, to_x - from_x)
end

local function distance(ax, ay, bx, by)
    return math.sqrt((ax - bx) ^ 2 + (ay - by) ^ 2)
end

--- On the spot: counts the time there with the monster standing; past st.lock seconds, in place for good
--- behind that monster (st.locked = its id: another one, as on a run of Leeches, is placed for again).
--- @return table|nil {locked = true} the moment it locks
local function hold_spot(st, now, mob, me)
    if not (st.lock and st.lock > 0) or st.mob_moving or st.in_place_mob ~= mob.id then
        st.in_place_since, st.in_place_mob = nil, mob.id
        return nil
    end
    st.in_place_since = st.in_place_since or now
    if now - st.in_place_since < st.lock then return nil end
    st.locked, st.in_place_since = mob.id or true, nil
    st.lock_x, st.lock_y, st.lock_mx, st.lock_my = me.x, me.y, mob.x, mob.y
    return {locked = true}
end

--- Where to stand and how long to wait off it: behind the monster, or, locked behind it, the place it locked on.
--- @return number|nil, number, number, boolean x, y, wait, locked here (x nil: the monster moved off, lock over)
local function goal(st, me, mob, settle)
    if not (st.locked and (st.locked == true or st.locked == mob.id)) then
        local x, y = StandBehind.spot(mob, me, st.dist)
        return x, y, settle, false
    end
    if not st.lock_mx then return me.x, me.y, settle, true end
    if distance(mob.x, mob.y, st.lock_mx, st.lock_my) > TOLERANCE then
        st.locked = nil
        return nil
    end
    return st.lock_x, st.lock_y, st.back or BACK, true
end

--- The end of a run that did not arrive back on the locked place: after MAX_MISSES of them, the place it stands
--- on becomes its place (a place it cannot reach would have it run all fight long instead of casting).
local function missed_back(st, me)
    st.misses = (st.misses or 0) + 1
    if st.misses < MAX_MISSES then return false end
    st.misses, st.lock_x, st.lock_y = 0, me.x, me.y
    return true
end

local function stop_action(st, mob, me, now, off)
    local secs = st.running_since and now and (now - st.running_since) or nil
    st.running_since = nil
    return {stop = true, face = mob and StandBehind.angle(me.x, me.y, mob.x, mob.y) or nil, secs = secs, off = off}
end

--- A run over (arrived, 4 s, or too far): stop facing the mob; a run back to the locked place counts its misses.
--- Not there yet behind a monster: the next run goes at once; the CHASE_MAX-th short run in a row pauses CHASE_PAUSE s.
local function end_run(st, mob, me, off, locked, now)
    st.away_since, st.resume = nil, false
    local adopted, gave_up = false, nil
    if locked then
        if off <= ARRIVED then st.misses = 0 else adopted = missed_back(st, me) end
    elseif off <= ARRIVED then
        st.chase_misses, st.pauses = 0, 0
    elseif off <= MAX_RUN then
        st.chase_misses = (st.chase_misses or 0) + 1
        if st.chase_misses >= CHASE_MAX then
            st.pauses = (st.pauses or 0) + 1
            local pause = math.min(60, CHASE_PAUSE * 2 ^ (st.pauses - 1))
            st.chase_misses, st.pause_until, gave_up = 0, (now or 0) + pause, pause
        else
            st.resume = true
        end
    end
    local act = stop_action(st, mob, me, now, off)
    act.adopted = adopted or nil
    act.gave_up = gave_up
    return act
end

--- One look: what to do now. Pure: the loop applies the answer.
--- @param st table Run state (running_since, away_since, first, resume; dist: yalms behind, nil = Silmaril's;
---   lock: seconds on the spot before staying put for good, locked: in place for good behind that mob id (lock_x,
---   lock_y: that place, walked back to when knocked off it after `back` seconds; lock_mx, lock_my: the monster then);
---   mob_moving: the monster moved within the last STILL seconds - run after all the same, aimed again at each look;
---   chase_misses: runs in a row that ended short of the spot, CHASE_MAX of them and it stands until pause_until)
--- @param now number Seconds
--- @param me table This character's mob
--- @param mob table|nil The monster (nil: none)
--- @param casting boolean A spell or ability under way
--- @param settle number Seconds off the spot before walking back
--- @return table|nil {run = angle} | {stop = true, face = angle|nil} | {locked = true} | {unlocked = true} | nil
function StandBehind.step(st, now, me, mob, casting, settle)
    if not mob or mob.spawn_type ~= MONSTER or (mob.hpp or 0) == 0 or type(mob.heading) ~= 'number' then
        if st.running_since then return stop_action(st, nil, me) end
        return nil
    end
    local x, y, wait, locked = goal(st, me, mob, settle)
    if not x then return {unlocked = true} end
    local off = distance(me.x, me.y, x, y)
    if st.running_since then
        if casting then st.resume = true return stop_action(st, nil, me, now, off) end
        if off < (st.run_best or math.huge) - 0.3 then st.run_best, st.run_best_at = off, now end
        if off <= ARRIVED or now - st.running_since > MOVE_LIMIT or off > MAX_RUN
                or now - (st.run_best_at or now) > NO_PROGRESS then
            return end_run(st, mob, me, off, locked, now)
        end
        return {run = StandBehind.angle(me.x, me.y, x, y)}
    end
    if casting then return nil end
    if off <= TOLERANCE then
        st.away_since, st.resume, st.chase_misses, st.pauses = nil, false, 0, 0
        if locked then return nil end
        return hold_spot(st, now, mob, me)
    end
    st.in_place_since = nil
    -- after CHASE_MAX short runs: stands until pause_until (the bot casts), then tries again
    if st.pause_until and now < st.pause_until then st.away_since = nil return nil end
    -- close to a monster still walking: wait until it stops (far off, it is run after: the first approach)
    if off <= NEAR and st.mob_last and now - st.mob_last.since < NEAR_STILL then return nil end
    if off > MAX_RUN then return nil end
    st.away_since = st.away_since or now
    if st.first or st.resume or now - st.away_since >= wait then
        st.first, st.resume, st.running_since, st.run_back = false, false, now, locked
        st.run_best, st.run_best_at = off, now
        return {run = StandBehind.angle(me.x, me.y, x, y), off = off}
    end
    return nil
end

--- The nearest living monster of that name, one in combat first (several Vampire Leech around).
--- @param name string
--- @param mobs table|nil Test seam: the mob array
--- @return table|nil
--- A living monster someone fights (claimed). Silmaril's Fighting locks any monster of the profile's name, a
--- fresh one nobody pulled too: after the first Leech died, Kaories walked behind the next unclaimed one and kept
--- chasing it as it roamed (2026-11-14).
--- @param mob table|nil
--- @return boolean
function StandBehind.fought(mob)
    return mob ~= nil and (mob.hpp or 0) > 0 and (mob.claim_id or 0) ~= 0
end

function StandBehind.find_named(name, mobs)
    local best, best_rank
    name = name:lower()
    for _, mob in pairs(mobs or windower.ffxi.get_mob_array() or {}) do
        if type(mob) == 'table' and mob.spawn_type == MONSTER and StandBehind.fought(mob) and mob.valid_target ~= false
                and type(mob.name) == 'string' and mob.name:lower() == name then
            local rank = (mob.status == 1 and 0 or 1e9) + (mob.distance or 0)
            if not best_rank or rank < best_rank then best, best_rank = mob, rank end
        end
    end
    return best
end

--- The monster to stand behind: the locked target, else the last one (the lock is lifted to run, and Silmaril's
--- Fighting locks it again later), else the one named by `first` (the bot off, nothing locked yet).
local function current_mob(st, p)
    -- the very monster the leader saw claimed (`first ... id=`), as long as it lives
    -- once dead it is forgotten: a monster that pops again keeps its id (the Leech, 2026-11-14)
    local wanted = st.want_id and windower.ffxi.get_mob_by_id(st.want_id)
    if StandBehind.fought(wanted) then st.target_id = wanted.id return wanted end
    if wanted then st.want_id = nil end   -- seen dead (or no longer fought); out of sight it is kept
    if p.target_locked then
        local mob = windower.ffxi.get_mob_by_target('t')
        if StandBehind.fought(mob) then st.target_id = mob.id return mob end
    end
    local mob = st.target_id and windower.ffxi.get_mob_by_id(st.target_id) or nil
    if StandBehind.fought(mob) then return mob end
    st.target_id = nil
    if st.mob_name then
        mob = StandBehind.find_named(st.mob_name)
        st.target_id = mob and mob.id or nil
        return mob
    end
    return nil
end

--- Whether the monster moved lately (st.mob_moving): its place at each look, moved more than STILL_MOVE
--- yalms resets the time it has been standing.
--- @param st table Run state
--- @param mob table|nil
--- @param now number Seconds
function StandBehind.note_movement(st, mob, now)
    if not mob then st.mob_last, st.mob_moving = nil, false return end
    local last = st.mob_last
    if not last or last.id ~= mob.id then
        -- first sight: taken as standing, so the first placement is not held back
        st.mob_last, st.mob_moving = {id = mob.id, x = mob.x, y = mob.y, since = now - STILL}, false
        return
    end
    if distance(last.x, last.y, mob.x, mob.y) > STILL_MOVE then
        last.x, last.y, last.since = mob.x, mob.y, now
    end
    st.mob_moving = now - last.since < STILL
end

--- The turn that puts this character facing the monster, nil when it already does (within FACE_OFF).
--- Same convention as Silmaril's addon: windower heading and turn() share it (Moving.lua face_target).
--- @param me table x, y, heading
--- @param mob table x, y
--- @return number|nil
function StandBehind.face_turn(me, mob)
    if type(me.heading) ~= 'number' then return nil end
    local want = StandBehind.angle(me.x, me.y, mob.x, mob.y)
    local diff = math.abs((want - me.heading + math.pi) % (2 * math.pi) - math.pi)
    return diff > FACE_OFF and want or nil
end

--- Facing the monster while standing: a turn sent with the stop of a run was lost (the run's direction won and
--- the GEO stood with its back to the mob, 2026-11-13), and a monster that shifts a little turns too.
local function keep_facing(st, me, mob, casting)
    if st.running_since or casting or not mob or os.clock() - (st.turned_at or 0) < FACE_EVERY then return end
    local turn = StandBehind.face_turn(me, mob)
    if turn then
        windower.ffxi.turn(turn)
        st.turned_at = os.clock()
    end
end

--- `first`: tell the leader once, on arrival or after ARRIVAL_WAIT (the rest of the fight waits on it).
local function tell_placed(st, why)
    if not (st and st.notify) then return end
    local command = st.notify
    st.notify = nil
    trace('placed (%s): %s', why, command)
    send_command(command)
end

--- Stop a run under way (a run left on would go on forever: nothing else stops it).
local function halt(st)
    if st and st.running_since then
        pcall(windower.ffxi.run, false)
        st.running_since = nil
        trace('run stopped (%s)', 'halt')
    end
end

local function apply(st, act, p)
    if act.run then
        if not st.running_logged then
            trace('%s (target %s, %.1f yalms off, monster %s)',
                st.run_back and 'run back to its locked place (knocked off it)' or 'run to the spot behind',
                tostring(st.target_id), act.off or -1, st.mob_moving and 'moving' or 'standing')
            -- once per run: a locked character does not run straight, and Silmaril's Fighting locks on again at
            -- once; lifted at every look, the lock went on and off and the GEO spun (2026-11-13)
            if p.target_locked then send_command('input /lockon') end
            st.lifts, st.lifted_at = 0, os.clock()
        elseif p.target_locked and os.clock() - (st.lifted_at or 0) >= RELIFT_EVERY and (st.lifts or 0) < RELIFT_MAX then
            -- the bot locked it again mid-run: locked, she ran into the monster and stuck there 4 s, 3.2 yalms off
            -- the spot (2026-11-14 20:56, 21:05: every run once the fight profile was on). Lifted again, at most
            -- once a second (every look spun her, 2026-11-13)
            send_command('input /lockon')
            st.lifts, st.lifted_at = (st.lifts or 0) + 1, os.clock()
            trace('lock-on lifted again: the bot locked it during the run')
        end
        st.running_logged = true
        windower.ffxi.run(act.run)
    elseif act.locked then
        trace('in place for good: %ss on the spot, the monster standing; only a knockback moves it now', tostring(st.lock))
    elseif act.unlocked then
        trace('the monster moved off: lock over, placed behind it again')
    elseif act.stop then
        windower.ffxi.run(false)
        if act.face then windower.ffxi.turn(act.face) end
        trace('stopped%s after %s s, %s yalms off, %s%s%s', act.face and ', facing the mob' or ' (cast or mob gone)',
            act.secs and ('%.1f'):format(act.secs) or '?', act.off and ('%.1f'):format(act.off) or '?',
            p.target_locked and 'locked on' or 'not locked',
            act.adopted and ('; ' .. MAX_MISSES .. ' runs back never arrived: this is its place now') or '',
            act.gave_up and ('; ' .. CHASE_MAX .. ' runs short of the spot: stands ' .. act.gave_up .. ' s') or '')
        st.running_logged = false
    end
end

local function look(st)
    local p, me = windower.ffxi.get_player(), windower.ffxi.get_mob_by_target('me')
    if not (p and me) then return end
    local info = windower.ffxi.get_info()
    if p.main_job ~= 'GEO' or (info and info.zone ~= st.zone) then
        StandBehind.stop(p.main_job ~= 'GEO' and 'job changed' or 'zone changed')
        return
    end
    local casting = type(rawget(_G, 'midaction')) == 'function' and midaction() or false
    local mob = current_mob(st, p)
    StandBehind.note_movement(st, mob, os.clock())
    local act = StandBehind.step(st, os.clock(), me, mob, casting == true, st.settle)
    if act then apply(st, act, p) end
    keep_facing(st, me, mob, casting == true)
    if st.notify and mob and not st.running_since then
        local x, y = StandBehind.spot(mob, me, st.dist)
        if distance(me.x, me.y, x, y) <= TOLERANCE then tell_placed(st, 'on the spot') end
    end
end

--- One look every TICK while on. One loop only: each start or resume gets a token, and a loop whose token or
--- load is no longer the current one ends (a newer load starts its own: resume()).
local function loop(load_gen, token)
    local st = windower._stand_behind
    if not (st and st.on) or st.token ~= token or st.load_gen ~= load_gen or windower._load_gen ~= load_gen then return end
    local ok, err = pcall(look, st)
    if not ok then
        trace('error: %s', tostring(err))
        halt(st)
    end
    coroutine.schedule(function() loop(load_gen, token) end, st.running_since and TICK_RUN or TICK)
end

local function new_token()
    windower._stand_behind_token = (windower._stand_behind_token or 0) + 1
    return windower._stand_behind_token
end

--- Start (or start again): the first placement goes at once. A loop already running ends.
--- A plain start while already on in this zone and load keeps what is under way: //gs c sortie <target> fight
--- sends `behind first` then, with the fight profile, a plain `behind`; starting over there threw away the
--- placement and the stay-put lock (review 2026-11-13).
--- @param opts table|nil mob_name: the monster to go behind while nothing is locked; mob_id: that very monster
---   (before the lock and the name); notify: a command sent once
---   placed (or after ARRIVAL_WAIT seconds)
function StandBehind.start(opts)
    opts = opts or {}
    local info = windower.ffxi.get_info()
    local cur = windower._stand_behind
    if not (opts.mob_name or opts.notify) and cur and cur.on and cur.load_gen == windower._load_gen
            and cur.zone == (info and info.zone) then
        trace('already on: placement and lock kept')
        return
    end
    halt(cur)
    local st = {on = true, first = true, load_gen = windower._load_gen, token = new_token(),
        zone = info and info.zone, settle = StandBehind.settle(), dist = StandBehind.distance(),
        lock = StandBehind.lock_after(), back = StandBehind.back_after(),
        mob_name = opts.mob_name, notify = opts.notify, want_id = opts.mob_id}
    windower._stand_behind = st
    trace('on (settle %ss, lock %ss, %s%s%s)', st.settle, st.lock, st.dist and (st.dist .. ' yalms') or 'melee distance',
        st.mob_name and (', ' .. st.mob_name) or '', st.want_id and (' id ' .. st.want_id) or '')
    if st.notify then
        coroutine.schedule(function()
            -- st.on: a `behind off` in between (another target loaded) must not answer for this fight (2026-11-13)
            if windower._stand_behind == st and st.on then tell_placed(st, 'waited ' .. ARRIVAL_WAIT .. ' s') end
        end, ARRIVAL_WAIT)
    end
    loop(windower._load_gen, st.token)
end

--- Stop, and stop running if a run was under way.
--- @param why string|nil For the trace
function StandBehind.stop(why)
    local st = windower._stand_behind
    if not (st and st.on) then return end
    st.on = false
    st.notify = nil   -- the leader's `placed` is not owed any more
    halt(st)
    trace('off (%s)', why or 'asked')
end

--- The job file going away (file_unload: a job or subjob change, //gs reload, //lua unload): a run under way
--- stops; staying on, the next GEO load goes on (resume).
function StandBehind.unload()
    halt(windower._stand_behind)
end

--- At a GearSwap load on GEO: on before the load, on again (the old load's loop has stopped).
function StandBehind.resume()
    local st = windower._stand_behind
    if st and st.on and st.load_gen ~= windower._load_gen then
        halt(st)
        st.load_gen, st.token = windower._load_gen, new_token()
        trace('on again after a load')
        loop(windower._load_gen, st.token)
    end
end

--- Precast: while a run is under way, the bot's spells are cancelled (it sends them again once she stands): a spell
--- started mid-run stopped it, 5 times in one placement (2026-11-14). Never Stun nor a Cure (Cure, Cura, Curaga: a
--- Cure the JA queue sends again carries allow_next, held here it was lost); a run left on past its 4 s (a loop
--- gone) holds nothing.
--- @param spell table GearSwap spell
--- @param eventArgs table
--- @return boolean True when cancelled
function StandBehind.hold_check(spell, eventArgs)
    local st = windower._stand_behind
    if not (st and st.on and st.running_since) or spell.action_type ~= 'Magic' or spell.english == 'Stun'
            or tostring(spell.english):find('^Cur') then
        return false
    end
    if os.clock() - st.running_since > MOVE_LIMIT + 1 then return false end
    eventArgs.cancel = true
    if st.held_logged ~= st.running_since then
        st.held_logged = st.running_since
        trace('%s held back: running to the spot', tostring(spell.english))
    end
    return true
end

--- //gs c behind                                behind the locked monster
--- //gs c behind off                            stop
--- //gs c behind first <leader> <target> [id=<n>] <mob>  behind that monster (that id when given) first, then
---     `send <leader> gs c sortie <target> placed` (//gs c sortie <target> fight waits on it)
--- @param args table The words after 'behind'
function StandBehind.command(args)
    args = args or {}
    local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
    local word = args[1] and args[1]:lower()
    if word == 'off' then
        StandBehind.stop('asked')
        if ok then MessageFormatter.show_info('Behind: off') end
    elseif word == 'first' and args[2] and args[3] and args[4] then
        local id = tonumber((args[4]:match('^id=(%d+)$')))
        local name = table.concat({select(id and 5 or 4, unpack(args))}, ' ')
        StandBehind.start({mob_name = name, mob_id = id, notify = ('send %s gs c sortie %s placed'):format(args[2], args[3])})
        if ok then MessageFormatter.show_info('Behind: going behind ' .. name .. ' first') end
    else
        StandBehind.start()
        if ok then MessageFormatter.show_info('Behind: on - behind the locked monster') end
    end
end

_G.StandBehind = StandBehind

return StandBehind

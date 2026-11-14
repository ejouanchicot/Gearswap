---============================================================================
--- Test of the ability queue (shared/utils/precast/ability_queue.lua)
---============================================================================
--- One job ability at a time, by rank, never twice; sent in the bot's gap (3.5 s
--- after a spell, 1.5 s after an ability, no spell under way); sent again when
--- refused; dropped when no longer wanted, on recast, or after 20 s. For 1.5 s
--- after one of ours, the bot's spells are held back at the precast (never Stun,
--- never a spell let through by allow_next).
---
--- Run from data/: lua5.1 scripts/atelier/ability_queue_test.lua
---
--- @file scripts/atelier/ability_queue_test.lua
--- @author ejouanchicot
--- @date Created: 2026-11-14
---============================================================================
package.path = './?.lua;' .. package.path

local fails = 0
local function check(name, got, want)
    local ok = got == want
    if not ok then fails = fails + 1 end
    print((ok and 'ok   ' or 'FAIL ') .. name .. (ok and '' or (': got ' .. tostring(got) .. ', wanted ' .. tostring(want))))
end

-- a virtual clock: scheduled work runs at its time, in order
local now, sent, jobs, traces = 0, {}, {}, {}
os.clock = function() return now end
coroutine.schedule = function(fn, d) jobs[#jobs + 1] = {at = now + (d or 0), fn = fn} end
local function run(limit)
    while #jobs > 0 do
        table.sort(jobs, function(a, b) return a.at < b.at end)
        if limit and jobs[1].at > limit then now = limit return end
        local job = table.remove(jobs, 1)
        now = job.at
        job.fn()
    end
    if limit then now = limit end
end

-- the game: a /ja goes through unless refused; then its recast starts and its aftercast comes
local ready, refuse, casting = {}, {}, false
local Q
send_command = function(c)
    sent[#sent + 1] = {at = now, cmd = c}
    local ja = c:match('/ja "([^"]+)"')
    if not ja then return end
    if (refuse[ja] or 0) > 0 then refuse[ja] = refuse[ja] - 1 return end
    ready[ja] = false
    Q.note_end({action_type = 'Ability'})
end
_G.midaction = function() return casting end
windower = {_load_gen = 1}
package.loaded['shared/utils/precast/ability_helper'] = {
    is_ability_ready = function(a) return ready[a] ~= false end,
}
package.loaded['shared/utils/debug/trace_log'] = {log = function(_, fmt, ...) traces[#traces + 1] = fmt:format(...) end}
Q = dofile('shared/utils/precast/ability_queue.lua')

local function fresh()
    now, sent, jobs, traces, ready, refuse, casting = 0, {}, {}, {}, {}, {}, false
    windower = {_load_gen = 1}
    Q = dofile('shared/utils/precast/ability_queue.lua')   -- a new load: the clock starts again at 0
end
local function at(cmd, n)
    n = n or 1
    for _, x in ipairs(sent) do
        if x.cmd == cmd then n = n - 1 if n == 0 then return x.at end end
    end
end
local function count(cmd)
    local n = 0 for _, x in ipairs(sent) do if x.cmd == cmd then n = n + 1 end end return n
end
local FC, BOL, BOG, EA = 'input /ja "Full Circle" <me>', 'input /ja "Bolster" <me>',
    'input /ja "Blaze of Glory" <me>', 'input /ja "Ecliptic Attrition" <me>'

-- 1. rank order whatever the order queued, one at a time, 1.5 s apart (the ability gap)
fresh()
Q.queue('Ecliptic Attrition'); Q.queue('Blaze of Glory'); Q.queue('Full Circle'); Q.queue('Bolster')
run()
check('order: Full Circle first, at once', at(FC), 0)
check('order: Bolster 1.5 s later', at(BOL), 1.5)
check('order: Blaze of Glory then', at(BOG), 3)
check('order: Ecliptic Attrition last', at(EA), 4.5)

-- 2. never twice: three Blaze of Glory asked, one sent
fresh()
check('first BoG queued', Q.queue('Blaze of Glory'), true)
check('second BoG refused', Q.queue('Blaze of Glory'), false)
check('third BoG refused', Q.queue('Blaze of Glory'), false)
run()
check('one BoG sent', count(BOG), 1)
-- already done: not queued, on_end told
fresh()
local why
check('already done: not queued', Q.queue('Bolster', {done = function() return true end,
    on_end = function(w) why = w end}), false)
check('  on_end told', why, 'already done')

-- 3. the gap: 3.5 s after a spell, 1.5 s after an ability, nothing while casting
fresh()
now = 10
Q.note_end({action_type = 'Magic'})
Q.queue('Ecliptic Attrition'); run(20)
check('after a spell: at 13.5, not before', at(EA), 13.5)
fresh()
now = 10
Q.note_end({action_type = 'Ability'})     -- the bot's Last Resort
Q.queue('Ecliptic Attrition'); run(20)
check('after an ability: at 11.5', at(EA), 11.5)
fresh()
casting = true
Q.queue('Ecliptic Attrition'); run(4)
check('while casting: not sent', at(EA), nil)
casting = false
run(10)
check('cast over: sent at the next look', at(EA), 4.5)
-- a spell cancelled in its precast (held back) leaves no gap
fresh()
now = 5
Q.note_end({action_type = 'Magic', interrupted = true})
Q.queue('Bolster'); run(10)
check('interrupted spell: no gap after it', at(BOL), 5)

-- 4. refused: sent again after a new gap, at most 3 times
fresh()
refuse['Blaze of Glory'] = 1
local ended
Q.queue('Blaze of Glory', {on_end = function(w) ended = w end}); run()
check('refused once: sent twice', count(BOG), 2)
check('  second try 1 s later', at(BOG, 2), 1)
check('  went through', ended, 'went through')
fresh()
refuse['Blaze of Glory'] = 9
Q.queue('Blaze of Glory', {on_end = function(w) ended = w end}); run()
check('always refused: 3 tries', count(BOG), 3)
check('  then dropped', ended, 'refused 3 times')

-- 5. dropped: on recast, no longer wanted, no gap within 20 s
fresh()
ready['Bolster'] = false
Q.queue('Bolster', {done = function() return false end, on_end = function(w) ended = w end}); run()
check('on recast: not sent', count(BOL), 0)
check('  dropped', ended, 'dropped: on recast')
fresh()
local want = true
Q.queue('Full Circle', {wanted = function() return want end, on_end = function(w) ended = w end})
casting = true
run(2); want = false; run(3)
check('no longer wanted: not sent', count(FC), 0)
check('  dropped', ended, 'dropped: no longer wanted')
fresh()
casting = true
Q.queue('Full Circle', {on_end = function(w) ended = w end}); run(25)
check('no gap in 20 s: not sent', count(FC), 0)
check('  dropped', ended, 'dropped: no gap within 20 s')
casting = false

-- 6. the hold: 1.5 s after ours, the bot's spells are cancelled; never Stun; allow_next goes once
fresh()
Q.queue('Bolster'); run(0.5)
local function try(name)
    local args = {}
    return Q.hold_check({action_type = 'Magic', english = name}, args), args.cancel
end
local held, cancel = try('Absorb-TP')
check('hold: Absorb-TP held', held, true) check('  cancelled', cancel, true)
check('hold: Stun never', (try('Stun')), false)
check('hold: a job ability is not a spell', Q.hold_check({action_type = 'Ability', english = 'Last Resort'}, {}), false)
Q.allow_next('Geo-Frailty')
check('hold: allow_next goes', (try('Geo-Frailty')), false)
check('hold: allow_next only once', (try('Geo-Frailty')), true)
now = 1.6
check('hold over at 1.5 s', (try('Absorb-TP')), false)
-- sent outside the queue (a precast chain) holds the same way
fresh()
Q.sent_outside('Widened Compass')
check('sent outside: held too', (try('Dia II')), true)

-- 7. two asks at once (the opening and the reaction to Bolster): one Blaze of Glory
fresh()
Q.queue('Full Circle'); Q.queue('Bolster'); Q.queue('Blaze of Glory')
run(2)
Q.queue('Blaze of Glory')      -- Bolster gained: its reaction asks for it too
run()
check('opening + Bolster reaction: one BoG', count(BOG), 1)

-- 8. cancel_all and a newer load drop everything
fresh()
casting = true
Q.queue('Full Circle', {on_end = function(w) ended = w end})
Q.cancel_all('fight over')
check('cancel_all: dropped', ended, 'dropped: fight over')
check('cancel_all: nothing queued', Q.queued('Full Circle'), false)
fresh()
casting = true
Q.queue('Full Circle'); run(1)
windower._load_gen = 2
casting = false
run(5)
check('newer load: nothing sent', count(FC), 0)

-- 9. a chain that died (its coroutine lost): the next queue() starts it again
fresh()
casting = true
Q.queue('Full Circle'); run(1)
jobs = {}                      -- the chain is gone
casting = false
now = 5
Q.queue('Bolster'); run()
check('dead chain restarted: Full Circle', at(FC), 5)
check('  then Bolster', at(BOL), 6.5)

-- 10. a look that fails (a game read during a zone change) does not kill the chain
fresh()
local broken = true
package.loaded['shared/utils/precast/ability_helper'].is_ability_ready = function(a)
    if broken then error('no recast table') end
    return ready[a] ~= false
end
Q.queue('Full Circle'); run(2)
check('read failing: nothing sent', count(FC), 0)
check('read failing: the failure traced', traces[#traces]:find('look failed') ~= nil, true)
broken = false
run(5)
check('read back: sent by the same chain', at(FC) ~= nil, true)
package.loaded['shared/utils/precast/ability_helper'].is_ability_ready = function(a) return ready[a] ~= false end
-- past its 20 s an ability no longer counts as queued (a Full Circle waiting there cancels the bot's Geo-)
fresh()
casting = true
Q.queue('Full Circle'); jobs = {}       -- its chain lost
now = 21
check('past 20 s: no longer queued', Q.queued('Full Circle'), false)
casting = false
-- the bot sending a held spell again and again: one trace line per hold
fresh()
Q.queue('Bolster'); run(0.2)
local before = #traces
for _ = 1, 50 do Q.hold_check({action_type = 'Magic', english = 'Absorb-TP'}, {}) end
check('held 50 times: one trace line', #traces - before, 1)

-- 11. the effect comes later than the check (Blaze of Glory's buff 1.15 s after, in game): the recast started,
-- so it went through, never sent again
fresh()
local buff_up = false
Q.queue('Blaze of Glory', {done = function() return buff_up end, on_end = function(w) ended = w end})
run(1.05)
coroutine.schedule(function() buff_up = true end, 0.1)
run()
check('late effect: sent once', count(BOG), 1)
check('  counted as gone through', ended == 'went through' or ended == 'went through (on recast)', true)

print(fails == 0 and 'ALL OK' or (fails .. ' FAILED'))
os.exit(fails == 0 and 0 or 1)

---============================================================================
--- Test of the fight opening (shared/jobs/geo/functions/logic/fight_opening.lua)
--- and of the boss check (shared/utils/sortie/sortie_boss.lua)
---============================================================================
--- The opening chosen from the GEO's recasts and buffs, run through the real
--- ability queue (shared/utils/precast/ability_queue.lua); Ecliptic Attrition
--- after the bot's bubble; the recasts a COR gives back during the fight
--- (Bolster: the opening again; Blaze of Glory: a new bubble with it); nothing
--- more once the fight is over.
--- Run from data/: lua5.1 scripts/atelier/fight_opening_test.lua
--- @file scripts/atelier/fight_opening_test.lua
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

-- a virtual clock
local now, sent, jobs = 0, {}, {}
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

-- the game: recasts (0 = ready), buffs, the luopan; a /ja goes through unless refused
local RECAST = {['Full Circle'] = 60, ['Bolster'] = 3600, ['Blaze of Glory'] = 500, ['Ecliptic Attrition'] = 300}
local recast, buffs, pet, refuse = {}, {}, nil, {}
local Queue
send_command = function(c)
    sent[#sent + 1] = {at = now, cmd = c}
    local ja = c:match('/ja "([^"]+)"')
    if not ja then return end
    if (refuse[ja] or 0) > 0 then refuse[ja] = refuse[ja] - 1 return end
    recast[ja] = RECAST[ja]
    if ja == 'Full Circle' then pet = nil end
    if ja == 'Bolster' or ja == 'Blaze of Glory' then buffs[ja] = true end
    Queue.note_end({action_type = 'Ability'})
end
_G.midaction = function() return false end
local mobs = {}
windower = {ffxi = {get_mob_by_target = function() return pet end, get_mob_array = function() return mobs end,
    get_ability_recasts = function() return recast end}}
buffactive = setmetatable({}, {__index = function(_, k) return buffs[k] end})
package.loaded['resources'] = {job_abilities = {with = function(_, _, name) return {recast_id = name} end}}
package.loaded['shared/utils/precast/ability_helper'] = {
    is_buff_active = function(b) return buffs[b] == true end,
    is_ability_ready = function(a) return (recast[a] or 0) == 0 end,
    queue = function() return Queue end,
}
package.loaded['shared/utils/core/job_config'] = {get = function(_, _, d) return d end}
package.loaded['shared/utils/debug/trace_log'] = {log = function() end}
local BF = dofile('shared/jobs/geo/functions/logic/bolster_follow.lua')
package.loaded['shared/jobs/geo/functions/logic/bolster_follow'] = BF
local FO = dofile('shared/jobs/geo/functions/logic/fight_opening.lua')

local LUOPAN = {name = 'Luopan', hpp = 100}
local function fresh()
    now, sent, jobs, recast, buffs, pet, refuse = 0, {}, {}, {}, {}, nil, {}
    windower._geo_fight, windower._geo_ea_after, windower._geo_luopan_bog, windower._geo_luopan_bolster = nil, nil, nil, nil
    -- the queue's times on windower belong to the last case's clock
    windower._jaq_spell_end, windower._jaq_ability_end, windower._jaq_hold_until, windower._jaq_allow = nil, nil, nil, nil
    Queue =dofile('shared/utils/precast/ability_queue.lua')
end
local function at(cmd, n)
    n = n or 1
    for _, x in ipairs(sent) do if x.cmd == cmd then n = n - 1 if n == 0 then return x.at end end end
end
local function count(cmd) local n = 0 for _, x in ipairs(sent) do if x.cmd == cmd then n = n + 1 end end return n end
local FC, BOL, BOG, EA = 'input /ja "Full Circle" <me>', 'input /ja "Bolster" <me>',
    'input /ja "Blaze of Glory" <me>', 'input /ja "Ecliptic Attrition" <me>'
local OPENED = 'send Tetsouo gs c sortie aminon opened'
--- the bot places a bubble (precast notes how, aftercast tells the opening)
local function bubble()
    BF.note_cast({skill = 'Geomancy', english = 'Geo-Frailty'})
    pet = LUOPAN
    buffs['Blaze of Glory'] = nil
    Queue.note_end({action_type = 'Magic'})
    FO.on_bubble_placed()
end

local ALL = {bolster = true, bog = true, ea = true}
local function plan(allow, s) local steps, ea = FO.plan(allow, s) return table.concat(steps, ', '), ea end

-- the plan
local p, ea = plan(ALL, {bolster_ready = true, bog_ready = true, ea_ready = true})
check('Bolster ready, no luopan: Bolster, BoG', p, 'Bolster, Blaze of Glory') check('  no EA after', ea, false)
p = plan(ALL, {bolster_ready = true, bog_ready = true, ea_ready = true, luopan = true})
check('Bolster ready, luopan out: Full Circle first', p, 'Full Circle, Bolster, Blaze of Glory')
p, ea = plan(ALL, {bog_ready = true, ea_ready = true, luopan = true})
check('Bolster down, BoG ready, luopan out: Full Circle, BoG', p, 'Full Circle, Blaze of Glory') check('  EA after the bubble', ea, true)
p, ea = plan(ALL, {bog_ready = true, ea_ready = false})
check('Bolster down, BoG ready, EA on recast: BoG', p, 'Blaze of Glory') check('  no EA after', ea, false)
p, ea = plan(ALL, {bolster_up = true, bog_ready = true, ea_ready = true, luopan = true, bubble_bolster = true})
check('under Bolster, its own luopan: nothing', p, '') check('  no EA after', ea, false)
p, ea = plan(ALL, {bolster_up = true, bog_ready = true, ea_ready = true, luopan = true, bubble_bolster = false})
check('under Bolster, luopan from before it: Full Circle, BoG', p, 'Full Circle, Blaze of Glory') check('  no EA (Bolster up)', ea, false)
p = plan(ALL, {bolster_up = true, bog_ready = false, luopan = true})
check('under Bolster, luopan from before, BoG on recast: Full Circle', p, 'Full Circle')
p = plan(ALL, {bolster_up = true, bog_ready = true, ea_ready = true})
check('under Bolster, no luopan: BoG', p, 'Blaze of Glory')
p, ea = plan(ALL, {ea_ready = true, luopan = true})
check('nothing but EA, luopan out: EA now', p, 'Ecliptic Attrition')
p, ea = plan(ALL, {ea_ready = true})
check('nothing but EA, no luopan: none now', p, '') check('  EA after the bubble', ea, true)
p = plan({bog = true, ea = true}, {bolster_ready = true, bog_ready = true, ea_ready = true})
check('Bolster not listed (Leech): no Bolster', p, 'Blaze of Glory')

-- the run: one ability at a time in the queue, then `opened`
fresh()
pet = LUOPAN
FO.open_fight('Tetsouo', 'aminon', 'bolster,bog,ea'); run(20)
check('run: Full Circle at 0', at(FC), 0)
check('run: Bolster 1.5 s later', at(BOL), 1.5)
check('run: BoG at 3', at(BOG), 3)
check('run: opened once BoG is through', at(OPENED), 4)
check('run: one of each', count(FC) + count(BOL) + count(BOG), 3)
FO.fight_end(); run()

-- Blaze of Glory refused once: sent again, `opened` after it went
fresh()
recast['Bolster'] = 100
refuse['Blaze of Glory'] = 1
FO.open_fight('Tetsouo', 'aminon', 'bog'); run(20)
check('BoG refused: sent twice', count(BOG), 2)
check('BoG refused: opened after the second', at(OPENED), 2)
FO.fight_end(); run()

-- nothing to open with: `opened` at once
fresh()
recast['Bolster'], recast['Blaze of Glory'], recast['Ecliptic Attrition'] = 100, 100, 100
FO.open_fight('Tetsouo', 'aminon', 'bolster,bog,ea'); run(1)
check('nothing ready: opened at once', at(OPENED), 0)
FO.fight_end(); run()

-- the fight over midway: nothing more, no `opened`
fresh()
pet = LUOPAN
FO.open_fight('Tetsouo', 'aminon', 'bolster,bog,ea'); run(0.5)
FO.fight_end(); run()
check('over: Full Circle had gone', at(FC), 0)
check('over: no Bolster', at(BOL), nil)
check('over: no opened', at(OPENED), nil)

-- Bolster on recast: BoG, then EA once the bot's bubble is placed, 3.5 s after that spell
fresh()
recast['Bolster'] = 100
FO.open_fight('Tetsouo', 'aminon', 'bolster,bog,ea'); run(9)
check('no Bolster: BoG at once', at(BOG), 0)
check('no Bolster: no EA yet', at(EA), nil)
now = 10
bubble(); run(20)
check('bubble placed: EA 3.5 s after the spell', at(EA), 13.5)
sent = {}
bubble(); run(30)
check('next bubble: no second EA', at(EA), nil)
FO.fight_end(); run()

-- as in game (2026-11-14): the luopan shows 0.6 s after the Geo-'s aftercast, Blaze of Glory's buff 1.15 s after
-- its /ja. EA must wait for the luopan, not be dropped at once; BoG must count as gone through.
fresh()
recast['Bolster'] = 100
local late_buff = true
local plain = send_command
send_command = function(c)
    plain(c)
    if late_buff and c == BOG then
        buffs['Blaze of Glory'] = nil
        coroutine.schedule(function() buffs['Blaze of Glory'] = true end, 1.15)
    end
end
FO.open_fight('Tetsouo', 'aminon', 'bolster,bog,ea'); run(9)
check('late buff: BoG sent once', count(BOG), 1)
now = 10
BF.note_cast({skill = 'Geomancy', english = 'Geo-Frailty'})
buffs['Blaze of Glory'] = nil
Queue.note_end({action_type = 'Magic'})
FO.on_bubble_placed()                       -- aftercast: no luopan yet
coroutine.schedule(function() pet = LUOPAN end, 0.6)
run(20)
check('luopan late: EA still goes, 3.5 s after the spell', at(EA), 13.5)
send_command, late_buff = plain, false
FO.fight_end(); run()
-- no luopan ever after the bubble (the Geo- failed): EA dropped, never sent
fresh()
recast['Bolster'] = 100
FO.open_fight('Tetsouo', 'aminon', 'bolster,bog,ea'); run(9)
now = 10
Queue.note_end({action_type = 'Magic'})
FO.on_bubble_placed()
run(30)
check('no luopan within 5 s: no EA', at(EA), nil)
FO.fight_end(); run()

-- placed too late (after 45 s): no EA
fresh()
recast['Bolster'] = 100
FO.open_fight('Tetsouo', 'aminon', 'bolster,bog,ea'); run(59)
now = 60
bubble(); run(70)
check('bubble after 45 s: no EA', at(EA), nil)
FO.fight_end(); run()

-- given back during the fight
local function fight_under_way()
    fresh()
    FO.open_fight('Tetsouo', 'aminon', 'bolster,bog,ea'); run(9)   -- Bolster, BoG
    now = 10
    bubble(); run(30)                                               -- placed under both
    buffs['Bolster'], buffs['Blaze of Glory'] = nil, nil            -- Bolster over (3 min later, say)
    windower._geo_luopan_bolster = false
    sent = {}
end
-- Wild Card: Bolster back -> the opening again, Full Circle first (the luopan out is not boosted)
fight_under_way()
recast['Bolster'], recast['Blaze of Glory'] = 0, 0
run(40)
check('Wild Card: Full Circle', at(FC) ~= nil, true)
check('  then Bolster', at(BOL) ~= nil and at(BOL) > at(FC), true)
check('  then BoG', at(BOG) ~= nil and at(BOG) > at(BOL), true)
FO.fight_end(); run()
-- Random Deal: BoG back, luopan placed without it, no Bolster -> Full Circle, BoG, bubble, EA
fight_under_way()
windower._geo_luopan_bog = false
recast['Blaze of Glory'], recast['Ecliptic Attrition'] = 0, 0
run(40)
check('Random Deal: Full Circle', at(FC) ~= nil, true)
check('  then BoG', at(BOG) ~= nil and at(BOG) > at(FC), true)
check('  no Bolster', at(BOL), nil)
now = 50
bubble(); run(60)
check('  EA after the new bubble', at(EA), 53.5)
FO.fight_end(); run()
-- Random Deal with the luopan already under BoG: kept for later
fight_under_way()
windower._geo_luopan_bog = true
recast['Blaze of Glory'] = 0
run(40)
check('BoG back, luopan has it: nothing', #sent, 0)
FO.fight_end(); run()
-- Random Deal under Bolster: nothing
fight_under_way()
buffs['Bolster'] = true
windower._geo_luopan_bog = false
recast['Blaze of Glory'] = 0
run(40)
check('BoG back under Bolster: nothing', #sent, 0)
FO.fight_end(); run()
-- EA alone back: nothing
fight_under_way()
recast['Ecliptic Attrition'] = 0
run(40)
check('EA alone back: nothing', #sent, 0)
FO.fight_end(); run()
-- a recast running out by itself: not given back
fight_under_way()
windower._geo_luopan_bog = false
recast['Blaze of Glory'] = 3
run(32)
recast['Blaze of Glory'] = 0
run(40)
check('BoG run out by itself: nothing', #sent, 0)
FO.fight_end(); run()
-- the recast table empty for a moment (zone change): not taken for a recast given back
fight_under_way()
windower._geo_luopan_bog = false
local real = windower.ffxi.get_ability_recasts
windower.ffxi.get_ability_recasts = function() return {} end
run(36)
windower.ffxi.get_ability_recasts = real
run(40)
check('empty recast table: nothing', #sent, 0)
FO.fight_end(); run()
-- the game frozen 10 s between two looks, a recast of 8 s left run out in between: not given back
fight_under_way()
windower._geo_luopan_bog = false
recast['Blaze of Glory'] = 8
run(32)
local saved = jobs
jobs = {}
now = 42
recast['Blaze of Glory'] = 0
jobs = saved
for _, j in ipairs(jobs) do if j.at < now then j.at = now end end
run(50)
check('frozen 10 s, recast run out meanwhile: nothing', #sent, 0)
FO.fight_end(); run()
-- the fight over: nothing watched any more
fight_under_way()
FO.fight_end()
recast['Bolster'], recast['Blaze of Glory'] = 0, 0
run(60)
check('fight over: given back ignored', #sent, 0)

-- the boss check
local SB = dofile('shared/utils/sortie/sortie_boss.lua')
local cfg = {bosses = {triboulex = 'Triboulex', aminon = 'Aminon', degei = 'Degei'}}
local function mob(name, claim, dist) return {name = name, spawn_type = 16, hpp = 50, claim_id = claim and 1 or 0, distance = (dist or 10) ^ 2, valid_target = true} end
mobs = {mob('Triboulex', true)}
check('Triboulex fought: aminon fight refused', SB.refusal(cfg, 'aminon', 'aminon', {mob = 'Aminon'}, 'fight') ~= nil, true)
check('Triboulex fought: aminon prep refused', SB.refusal(cfg, 'aminon', 'aminon', {}, nil) ~= nil, true)
check('Triboulex fought: triboulex goes', SB.refusal(cfg, 'triboulex', 'triboulex', {}, nil), nil)
check('alias degei on Triboulex: refused', SB.refusal(cfg, 'degei', 'melee', {}, nil) ~= nil, true)
check('melee typed (no boss): goes', SB.refusal(cfg, 'melee', 'melee', {}, nil), nil)
mobs = {mob('Aminon', false)}
check('Aminon there, not claimed: fight goes', SB.refusal(cfg, 'aminon', 'aminon', {mob = 'Aminon'}, 'fight'), nil)
mobs = {mob('Aminon', true, 80)}
check('Aminon 80 yalms off: fight refused', SB.refusal(cfg, 'aminon', 'aminon', {mob = 'Aminon'}, 'fight') ~= nil, true)
mobs = {}
check('nobody fought: prep goes', SB.refusal(cfg, 'aminon', 'aminon', {}, nil), nil)
windower.ffxi.get_mob_array = function() error('no') end
check('game unreadable: goes', SB.refusal(cfg, 'aminon', 'aminon', {mob = 'Aminon'}, 'fight'), nil)

print(fails == 0 and 'ALL OK' or (fails .. ' FAILED'))
os.exit(fails == 0 and 0 or 1)

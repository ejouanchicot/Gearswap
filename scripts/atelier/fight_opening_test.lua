---============================================================================
--- Test of the fight opening (shared/jobs/geo/functions/logic/bolster_follow.lua)
--- and of the boss check (shared/utils/sortie/sortie_boss.lua)
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

-- game state
local buffs, ready, pet = {}, {}, nil
local now, sent, queue = 0, {}, {}
os.clock = function() return now end
local bog_refused = false
send_command = function(c)
    sent[#sent + 1] = {at = now, cmd = c}
    if c == 'input /ja "Blaze of Glory" <me>' and not bog_refused then buffs['Blaze of Glory'] = true end
end
coroutine.schedule = function(fn, d) queue[#queue + 1] = {at = now + (d or 0), fn = fn} end
local function run(limit)
    while #queue > 0 do
        table.sort(queue, function(a, b) return a.at < b.at end)
        if limit and queue[1].at > limit then now = limit return end
        local job = table.remove(queue, 1)
        now = job.at
        job.fn()
    end
end
local mobs = {}
windower = {ffxi = {get_mob_by_target = function() return pet end, get_mob_array = function() return mobs end}}
package.loaded['shared/utils/precast/ability_helper'] = {
    is_buff_active = function(b) return buffs[b] == true end,
    is_ability_ready = function(a) return ready[a] == true end,
}
package.loaded['shared/utils/core/job_config'] = {get = function(_, _, d) return d end}
package.loaded['shared/utils/debug/trace_log'] = {log = function() end}
local BF = dofile('shared/jobs/geo/functions/logic/bolster_follow.lua')

local ALL = {bolster = true, bog = true, ea = true}
local function plan(allow, s) local steps, ea = BF.plan(allow, s) return table.concat(steps, ', '), ea end

-- the plan
local p, ea = plan(ALL, {bolster_ready = true, bog_ready = true, ea_ready = true})
check('Bolster ready, no luopan: Bolster, BoG', p, 'Bolster, Blaze of Glory') check('  no EA after', ea, false)
p = plan(ALL, {bolster_ready = true, bog_ready = true, ea_ready = true, luopan = true})
check('Bolster ready, luopan out: Full Circle first', p, 'Full Circle, Bolster, Blaze of Glory')
p, ea = plan(ALL, {bog_ready = true, ea_ready = true, luopan = true})
check('Bolster down, BoG ready, luopan out: Full Circle, BoG', p, 'Full Circle, Blaze of Glory') check('  EA after the bubble', ea, true)
p, ea = plan(ALL, {bog_ready = true, ea_ready = false})
check('Bolster down, BoG ready, EA on recast: BoG', p, 'Blaze of Glory') check('  no EA after', ea, false)
p, ea = plan(ALL, {bolster_up = true, bog_ready = true, ea_ready = true, luopan = true})
check('under Bolster, luopan out: nothing (no Full Circle, no EA)', p, '') check('  no EA after', ea, false)
p = plan(ALL, {bolster_up = true, bog_ready = true, ea_ready = true})
check('under Bolster, no luopan: BoG', p, 'Blaze of Glory')
p, ea = plan(ALL, {ea_ready = true, luopan = true})
check('nothing but EA, luopan out: EA now', p, 'Ecliptic Attrition')
p, ea = plan(ALL, {ea_ready = true})
check('nothing but EA, no luopan: none now', p, '') check('  EA after the bubble', ea, true)
p = plan({bog = true, ea = true}, {bolster_ready = true, bog_ready = true, ea_ready = true})
check('Bolster not listed (Leech): no Bolster', p, 'Blaze of Glory')

-- the run: abilities 1.5 s apart, then `opened`
ready = {['Bolster'] = true, ['Blaze of Glory'] = true, ['Ecliptic Attrition'] = true}
pet = {name = 'Luopan', hpp = 100}
BF.open_fight('Tetsouo', 'aminon', 'bolster,bog,ea'); run()
local function at(cmd) for _, x in ipairs(sent) do if x.cmd == cmd then return x.at end end end
check('run: Full Circle at 0', at('input /ja "Full Circle" <me>'), 0)
check('run: Bolster at 1.5', at('input /ja "Bolster" <me>'), 1.5)
check('run: BoG at 3', at('input /ja "Blaze of Glory" <me>'), 3)
check('run: opened at 4.5', at('send Tetsouo gs c sortie aminon opened'), 4.5)

-- Blaze of Glory refused: sent again once, `opened` after its buff (or after the last look)
sent, queue, now, buffs = {}, {}, 0, {}
bog_refused = true
ready['Bolster'], pet = false, nil   -- no luopan out: no Full Circle first
BF.open_fight('Tetsouo', 'aminon', 'bog'); run()
local n = 0 for _, x in ipairs(sent) do if x.cmd == 'input /ja "Blaze of Glory" <me>' then n = n + 1 end end
check('BoG refused: sent twice', n, 2)
check('BoG refused: opened after the looks', at('send Tetsouo gs c sortie aminon opened'), 6)
bog_refused, buffs = false, {}
sent, queue, now = {}, {}, 0
BF.open_fight('Tetsouo', 'aminon', 'bog'); run()
check('BoG up: opened 1.5 s after it', at('send Tetsouo gs c sortie aminon opened'), 1.5)
ready['Bolster'], buffs, pet = true, {}, {name = 'Luopan', hpp = 100}

-- cancelled midway: nothing more, no `opened`
sent, queue, now = {}, {}, 0
BF.open_fight('Tetsouo', 'aminon', 'bolster,bog,ea'); run(0.5)
BF.cancel_open(); run()
check('cancel: Full Circle had gone', at('input /ja "Full Circle" <me>'), 0)
check('cancel: no Bolster', at('input /ja "Bolster" <me>'), nil)
check('cancel: no opened', at('send Tetsouo gs c sortie aminon opened'), nil)

-- Bolster on recast: BoG, then EA once the bot's bubble is placed (not under Bolster)
sent, queue, now = {}, {}, 0
ready['Bolster'], pet = false, nil
BF.open_fight('Tetsouo', 'aminon', 'bolster,bog,ea'); run()
check('no Bolster: BoG at once', at('input /ja "Blaze of Glory" <me>'), 0)
check('no Bolster: no EA yet', at('input /ja "Ecliptic Attrition" <me>'), nil)
now = 10
pet = {name = 'Luopan', hpp = 100}
BF.on_bubble_placed(); run(11.6)
check('bubble placed: EA 1.5 s later', at('input /ja "Ecliptic Attrition" <me>'), 11.5)
ready['Ecliptic Attrition'] = false   -- it went: on recast
run()
sent = {}
BF.on_bubble_placed(); run()
check('next bubble: no second EA', at('input /ja "Ecliptic Attrition" <me>'), nil)
-- the bot just cast a spell: EA waits for 3.5 s after it, then goes
sent, queue, now = {}, {}, 100
ready['Ecliptic Attrition'] = true
windower._geo_ea_after = 130
windower._geo_cast_end = 100.5
BF.on_bubble_placed(); run(110)
check('EA after a spell: not inside 3.5 s of it', at('input /ja "Ecliptic Attrition" <me>'), 104)
ready['Ecliptic Attrition'] = false run()
windower._geo_cast_end = nil

-- placed too late (after 45 s): no EA
sent, queue, now = {}, {}, 0
pet = nil
BF.open_fight('Tetsouo', 'aminon', 'bolster,bog,ea'); run()
now = 60
pet = {name = 'Luopan', hpp = 100}
BF.on_bubble_placed(); run()
check('bubble after 45 s: no EA', at('input /ja "Ecliptic Attrition" <me>'), nil)

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

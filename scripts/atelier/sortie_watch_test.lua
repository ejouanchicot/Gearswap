---============================================================================
--- Test of the Sortie watch (shared/utils/sortie/sortie_watch.lua, wired in sortie_commands.lua)
---============================================================================
--- A target with `auto_fight` and `mob`: its prep watches for that monster and
--- runs the fight once the party claims it; any other sortie order ends the watch.
---
--- Run from data/: lua5.1 scripts/atelier/sortie_watch_test.lua
---
--- @file scripts/atelier/sortie_watch_test.lua
--- @author ejouanchicot
--- @date Created: 2026-11-13
---============================================================================

package.path = './?.lua;' .. package.path

local done, failed = 0, 0
local function check(what, ok)
    done = done + 1
    if not ok then failed = failed + 1 print('FAILED ' .. what) end
end

-- fakes: game, clock, scheduler, commands (set before the modules load)
local clock, queue, sent = 0, {}, {}
os.clock = function() return clock end
coroutine.schedule = function(fn, delay) queue[#queue + 1] = {at = clock + (delay or 0), fn = fn} end
send_command = function(cmd) sent[#sent + 1] = cmd end
local mobs, zone = {}, 100
local party = {p0 = {name = 'Tetsouo', mob = {id = 1001}}, p1 = {name = 'Kaories', mob = {id = 1002}},
    a10 = {name = 'Hysoka', mob = {id = 1003}}}
windower = {_load_gen = 1, ffxi = {
    get_info = function() return {zone = zone} end,
    get_mob_array = function() return mobs end,
    get_party = function() return party end,
    get_player = function() return {name = 'Tetsouo'} end,
}}
player = {name = 'Tetsouo', main_job = 'PLD', sub_job = 'RUN'}
package.loaded['shared/utils/debug/trace_log'] = {log = function() end}
local CFG = {alt = 'Kaories', profile_root = 'Kaories/Sortie/GEO/', targets = {
    leechtest = {profile = 'LeechAuto', indi = 'Indi-Fury', fight_ja = {'Blaze of Glory'}, behind = true,
        mob = 'Vampire Leech', auto_fight = true,
        prep = {profile = 'LeechPrep', indi = 'Indi-Refresh', follow = 'Tetsouo'}},
    manual = {profile = 'LeechAuto', indi = 'Indi-Fury', mob = 'Vampire Leech',
        prep = {profile = 'LeechPrep', indi = 'Indi-Refresh', follow = 'Tetsouo'}},
}}
package.loaded['shared/utils/core/char_paths'] = {optional = function() return CFG end}
package.loaded['shared/utils/dualbox/alt_group'] = {note = function() end}
package.loaded['shared/utils/messages/formatters/system/message_sortie'] =
    setmetatable({}, {__index = function() return function() end end})

local W = require('shared/utils/sortie/sortie_watch')
local Sortie = require('shared/utils/sortie/sortie_commands')

local function advance(seconds)
    local stop = clock + seconds
    while true do
        table.sort(queue, function(a, b) return a.at < b.at end)
        if not queue[1] or queue[1].at > stop then break end
        local job = table.remove(queue, 1)
        clock = job.at
        job.fn()
    end
    clock = stop
end
local function has(cmd) for _, c in ipairs(sent) do if c == cmd then return true end end return false end
local function leech(id, claim, hpp) return {id = id, name = 'Vampire Leech', spawn_type = 16, hpp = hpp or 100,
    status = claim and 1 or 0, claim_id = claim or 0} end
local function reset() queue, sent, mobs, clock, zone = {}, {}, {}, 0, 100 windower._sortie_watch = nil
    windower._sortie_fight = nil windower._load_gen = 1 end

-- pure parts
local ids = W.alliance_ids(party)
check('alliance ids: party and alliance', ids[1001] and ids[1002] and ids[1003])
local function first(...) return W.claimed(...)[1] end
check('claimed by the party: found', first('vampire leech', {leech(5, 1001)}, ids) ~= nil)
check('claimed by an alliance member: found', first('Vampire Leech', {leech(5, 1003)}, ids) ~= nil)
check('unclaimed: not found', first('Vampire Leech', {leech(5, nil)}, ids) == nil)
check('claimed by another group: not found', first('Vampire Leech', {leech(5, 9999)}, ids) == nil)
check('dead: not found', first('Vampire Leech', {leech(5, 1001, 0)}, ids) == nil)
check('another name: not found', first('Aminon', {leech(5, 1001)}, ids) == nil)
check('left out: not found', first('Vampire Leech', {leech(5, 1001)}, ids, {[5] = true}) == nil)

-- the prep watches, the claim starts the fight once
reset()
Sortie.handle({'leechtest'})
check('prep: watching', W.watching() == 'leechtest')
check('prep: prep profile loaded', has('send Kaories sm load Kaories/Sortie/GEO/LeechPrep'))
mobs = {leech(5, nil), leech(6, 9999)}
advance(5)
check('no party claim: no fight', not has('send Kaories sm off') and W.watching() == 'leechtest')
mobs = {leech(5, 1001), leech(6, 9999)}
advance(0.6)
check('claimed by Tetsouo: fight started (bot off)', has('send Kaories sm off'))
check('claimed: alt goes behind that very Leech first', has('send Kaories gs c behind first Tetsouo leechtest id=5 Vampire Leech'))
check('claimed: watch over', W.watching() == nil)
sent = {}
advance(5)
check('fires once only', not has('send Kaories gs c behind first Tetsouo leechtest id=5 Vampire Leech'))

-- a Leech already claimed when the prep is typed: left out, only a new claim starts the fight
reset()
mobs = {leech(7, 1001)}
Sortie.handle({'leechtest'})
advance(2)
check('already claimed at the prep: no fight', not has('send Kaories sm off') and W.watching() == 'leechtest')
mobs = {leech(7, 1001), leech(8, 1001)}
advance(0.6)
check('a new claim: fight behind the new one', has('send Kaories gs c behind first Tetsouo leechtest id=8 Vampire Leech'))

-- a target without auto_fight never watches
reset()
Sortie.handle({'manual'})
check('no auto_fight: no watch', W.watching() == nil)

-- fight typed by hand ends the watch (no second fight later)
reset()
Sortie.handle({'leechtest'})
mobs = {leech(4)}
mobs[1].distance = 25      -- a Leech around (squared yalms): `fight` needs its monster there (sortie_boss.lua)
Sortie.handle({'leechtest', 'fight'})
check('fight by hand: watch over', W.watching() == nil)
sent = {}
mobs = {leech(5, 1001)}
advance(30)
check('fight by hand: the claim does not start it again', not has('send Kaories gs c behind first Tetsouo leechtest id=5 Vampire Leech'))

-- the alt's `placed` answer keeps the watch; other orders end it
reset()
Sortie.handle({'leechtest'})
Sortie.handle({'leechtest', 'placed'})
check('placed: watch kept', W.watching() == 'leechtest')
Sortie.handle({'list'})
check('list: watch kept', W.watching() == 'leechtest')
Sortie.handle({'escort'})
check('escort: watch over', W.watching() == nil)

-- zone change, newer load, time limit
reset()
Sortie.handle({'leechtest'})
zone = 200
advance(1)
check('zone change: watch over', W.watching() == nil)
reset()
Sortie.handle({'leechtest'})
windower._load_gen = 2
advance(1)
check('newer GearSwap load: watch over', W.watching() == nil)
reset()
Sortie.handle({'leechtest'})
advance(1801)
check('30 min without a claim: watch over', W.watching() == nil)

-- a new prep replaces the watch: only one loop runs
reset()
Sortie.handle({'leechtest'})
Sortie.handle({'leechtest'})
advance(1)                                      -- the replaced loop sees it is no longer current and ends
local loops = 0
for _, job in ipairs(queue) do loops = loops + 1 end
check('prep twice: one loop', loops == 1)

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

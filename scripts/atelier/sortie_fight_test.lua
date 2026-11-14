---============================================================================
--- Test of a Sortie target's prep follow and fight abilities (shared/utils/sortie/sortie_commands.lua)
---============================================================================
--- `prep.follow`: the prep profile makes the alt follow that player instead of
--- follow off. `fight_ja`: //gs c sortie <target> fight asks the alt for its
--- opening (//gs c fightopen) and loads the fight profile on its `opened`; any
--- other sortie order drops a fight under way (2026-11-13).
---
--- Run from data/: lua5.1 scripts/atelier/sortie_fight_test.lua
---
--- @file scripts/atelier/sortie_fight_test.lua
--- @author ejouanchicot
--- @date Created: 2026-11-13
---============================================================================

package.path = './?.lua;' .. package.path

local done, failed = 0, 0
local function check(what, got, want)
    done = done + 1
    if got ~= want then
        failed = failed + 1
        print(('FAILED %s: got %s, wanted %s'):format(what, tostring(got), tostring(want)))
    end
end

local CFG = {alt = 'Kaories', profile_root = 'Kaories/Sortie/GEO/',
    orders = {off = {command = 'sm off'}, judgment = {command = 'gs c judgment'}},
    targets = {
        leechtest = {profile = 'LeechAuto', indi = 'Indi-Fury', fight_ja = {'Bolster', 'Blaze of Glory'}, behind = true,
            prep = {profile = 'LeechPrep', indi = 'Indi-Refresh', follow = 'Tetsouo'}},
        melee = {profile = 'Melee', indi = 'Indi-Fury'},
        leechmob = {profile = 'LeechAuto', indi = 'Indi-Fury', fight_ja = {'Blaze of Glory'}, behind = true,
            mob = 'Vampire Leech', prep = {profile = 'LeechPrep', indi = 'Indi-Refresh', follow = 'Tetsouo'}},
    }}
-- every command with the time it goes out: scheduled work runs at its delay, in time order
local now, sent, queue = 0, {}, {}
send_command = function(cmd) sent[#sent + 1] = {at = now, cmd = cmd} end
coroutine.schedule = function(fn, delay) queue[#queue + 1] = {at = now + (delay or 0), fn = fn} end
local function run_queue(limit)
    while #queue > 0 do
        table.sort(queue, function(a, b) return a.at < b.at end)
        if limit and queue[1].at > limit then now = limit return end
        local job = table.remove(queue, 1)
        now = job.at
        job.fn()
    end
end
windower = {ffxi = {get_player = function() return {name = 'Tetsouo'} end}}
player = {name = 'Tetsouo', main_job = 'PLD', sub_job = 'RUN'}
package.loaded['shared/utils/core/char_paths'] = {optional = function() return CFG end}
local noted = {}
package.loaded['shared/utils/dualbox/alt_group'] = {note = function(c) noted[#noted + 1] = c end}
local warnings = {}
package.loaded['shared/utils/messages/message_formatter'] = {show_warning = function(m) warnings[#warnings + 1] = m end}
package.loaded['shared/utils/messages/formatters/system/message_sortie'] =
    setmetatable({}, {__index = function() return function() end end})
local Sortie = require('shared/utils/sortie/sortie_commands')

local function lines()
    local out = {}
    for _, s in ipairs(sent) do out[#out + 1] = ('%.1f %s'):format(s.at, s.cmd) end
    return table.concat(out, ' | ')
end
local function has(cmd) for _, s in ipairs(sent) do if s.cmd == cmd then return s.at end end return nil end

-- 1. the prep: its profile, follow Tetsouo
Sortie.handle({'leechtest'}); run_queue()
check('prep profile loaded', has('send Kaories sm load Kaories/Sortie/GEO/LeechPrep') ~= nil, true)
check('prep follows Tetsouo', has('send Kaories sm follow Tetsouo') ~= nil, true)
check('prep: no follow off', has('send Kaories sm follow off'), nil)
check('alt window told the follow', noted[#noted].follow, 'Tetsouo')
check('prep: not behind', has('send Kaories gs c behind off') ~= nil and has('send Kaories gs c behind') == nil, true)

-- 2. the fight with `fight_ja`: bot off, the alt picks its opening (//gs c fightopen), the profile on `opened`
sent, noted, now, queue = {}, {}, 0, {}
Sortie.handle({'leechtest', 'fight'}); run_queue(1)
check('fight: bot off first', has('send Kaories sm off'), 0)
check('fight: opening asked of the alt', has('send Kaories gs c fightopen Tetsouo leechtest bolster,bog'), 0)
check('fight: no Full Circle from the leader', has('send Kaories /ja "Full Circle" <me>'), nil)
check('fight: no profile before `opened`', has('send Kaories sm load Kaories/Sortie/GEO/LeechAuto'), nil)
now = 3
Sortie.handle({'leechtest', 'opened'}); run_queue(4)
local load = has('send Kaories sm load Kaories/Sortie/GEO/LeechAuto')
check('opened: profile at once', load, 3)
check('fight: follow off with the fight profile', has('send Kaories sm follow off') ~= nil and has('send Kaories sm follow off') >= load, true)
check('fight: bot back on last', has('send Kaories sm on') >= load, true)
check('fight: behind with the fight profile', has('send Kaories gs c behind') ~= nil and has('send Kaories gs c behind') >= load, true)
run_queue()
local loads = 0
for _, x in ipairs(sent) do if x.cmd == 'send Kaories sm load Kaories/Sortie/GEO/LeechAuto' then loads = loads + 1 end end
check('opened, then the 15 s wait: the profile once', loads, 1)

-- 2a. no `opened`: the profile after 15 s (OPENED_WAIT)
sent, now, queue = {}, 0, {}
Sortie.handle({'leechtest', 'fight'}); run_queue()
check('no opened: profile at 15 s', has('send Kaories sm load Kaories/Sortie/GEO/LeechAuto'), 15)

-- 2b. with `mob`: placement first; nothing else until the alt answers `placed`
sent, now, queue = {}, 0, {}
Sortie.handle({'leechmob', 'fight'}); run_queue(2.9)
check('placing: bot off', has('send Kaories sm off'), 0)
check('placing: follow off', has('send Kaories sm follow off'), 0)
check('placing: behind first, named mob', has('send Kaories gs c behind first Tetsouo leechmob Vampire Leech'), 0)
check('placing: no opening yet', has('send Kaories gs c fightopen Tetsouo leechmob bog'), nil)
now = 3
Sortie.handle({'leechmob', 'placed'}); run_queue(3.5)
check('placed: opening then', has('send Kaories gs c fightopen Tetsouo leechmob bog'), 3)
Sortie.handle({'leechmob', 'placed'}); now = 4
Sortie.handle({'leechmob', 'opened'}); run_queue()
local opens, loads2 = 0, 0
for _, x in ipairs(sent) do
    if x.cmd == 'send Kaories gs c fightopen Tetsouo leechmob bog' then opens = opens + 1 end
    if x.cmd == 'send Kaories sm load Kaories/Sortie/GEO/LeechAuto' then loads2 = loads2 + 1 end
end
check('placed twice, the 14 s wait: one opening', opens, 1)
check('opened then the waits: one profile', loads2, 1)

-- 2c. no answer at all: opening at 14 s, profile at 29 s
sent, now, queue = {}, 0, {}
Sortie.handle({'leechmob', 'fight'}); run_queue()
check('no answer: opening at 14 s', has('send Kaories gs c fightopen Tetsouo leechmob bog'), 14)
check('no answer: profile at 29 s', has('send Kaories sm load Kaories/Sortie/GEO/LeechAuto'), 29)

-- 2d. 2026-11-13: a wrong `fight`, then another target: the fight is dropped, its late answers ignored
sent, now, queue = {}, 0, {}
Sortie.handle({'leechmob', 'fight'}); run_queue(5)
now = 5
Sortie.handle({'melee'}); run_queue(5)
check('another target: the alt stops its opening', has('send Kaories gs c fightopen off'), 5)
now = 12
Sortie.handle({'leechmob', 'placed'}); run_queue()
check('dropped fight: no opening (answer nor 14 s wait)', has('send Kaories gs c fightopen Tetsouo leechmob bog'), nil)
check('dropped fight: its profile never loads', has('send Kaories sm load Kaories/Sortie/GEO/LeechAuto'), nil)
-- dropped during the opening: no profile from `opened` nor from the 8 s wait
sent, now, queue = {}, 0, {}
Sortie.handle({'leechtest', 'fight'}); run_queue(1)
now = 1
Sortie.handle({'escort'}); run_queue(1)
Sortie.handle({'leechtest', 'opened'}); run_queue()
check('dropped while opening: no fight profile', has('send Kaories sm load Kaories/Sortie/GEO/LeechAuto'), nil)
check('dropped: the player told', warnings[#warnings], 'sortie: leechtest fight dropped')
-- an order (judgment) during the fight: it goes on
sent, now, queue = {}, 0, {}
Sortie.handle({'leechtest', 'fight'}); run_queue(1)
now = 1
Sortie.handle({'judgment'})
Sortie.handle({'leechtest', 'opened'}); run_queue()
check('order during the fight: profile still loads', has('send Kaories sm load Kaories/Sortie/GEO/LeechAuto'), 1)
-- `off` drops it
sent, now, queue = {}, 0, {}
Sortie.handle({'leechtest', 'fight'}); run_queue(1)
now = 1
Sortie.handle({'off'}); Sortie.handle({'leechtest', 'opened'}); run_queue()
check('off: fight dropped', has('send Kaories sm load Kaories/Sortie/GEO/LeechAuto'), nil)
-- a command refused by the boss check does not drop the fight under way; `force` goes past the check
CFG.bosses = {aminon = 'Aminon'}
CFG.targets.aminon = {profile = 'AminonFight', indi = 'Indi-Fury', fight_ja = {'Bolster'}, behind = true, mob = 'Aminon',
    prep = {profile = 'AminonPrep', indi = 'Indi-Refresh'}}
windower.ffxi.get_mob_array = function() return {} end
sent, now, queue = {}, 0, {}
Sortie.handle({'leechtest', 'fight'}); run_queue(1)
now = 1
Sortie.handle({'aminon', 'fight'})
check('refused: Aminon fight not started', has('send Kaories gs c behind first Tetsouo aminon Aminon'), nil)
Sortie.handle({'leechtest', 'opened'}); run_queue()
check('refused: the fight under way goes on', has('send Kaories sm load Kaories/Sortie/GEO/LeechAuto'), 1)
sent, now, queue = {}, 0, {}
Sortie.handle({'aminon', 'fight', 'force'}); run_queue(1)
check('force: past the check', has('send Kaories gs c behind first Tetsouo aminon Aminon'), 0)
Sortie.handle({'off'})
-- Leshonn's `fight` (no walk behind) is never checked
CFG.bosses.prepfc = 'Leshonn'
windower.ffxi.get_mob_array = nil
-- no fight under way: no `fightopen off` sent
sent, now, queue = {}, 0, {}
Sortie.handle({'melee'}); run_queue()
check('nothing under way: nothing to stop', has('send Kaories gs c fightopen off'), nil)

-- 2e. a fight loaded with an opening: the next order tells the alt it is over (//gs c fightend: it stops
-- watching its recasts, shared/jobs/geo/functions/logic/fight_opening.lua), once
sent, now, queue = {}, 0, {}
Sortie.handle({'leechtest', 'fight'}); run_queue(1)
now = 1
Sortie.handle({'leechtest', 'opened'}); run_queue()
check('loaded: no fightend yet', has('send Kaories gs c fightend'), nil)
now = 100
Sortie.handle({'melee'}); run_queue()
check('another target after the load: fightend', has('send Kaories gs c fightend'), 100)
check('  and no fightopen off (nothing pending)', has('send Kaories gs c fightopen off'), nil)
sent = {}
Sortie.handle({'melee'}); run_queue()
check('fightend told once', has('send Kaories gs c fightend'), nil)
for _, order in ipairs({'escort', 'off'}) do
    sent, now, queue = {}, 0, {}
    Sortie.handle({'leechtest', 'fight'}); run_queue(1)
    now = 1
    Sortie.handle({'leechtest', 'opened'}); run_queue()
    Sortie.handle({order}); run_queue()
    check(order .. ' after the load: fightend', has('send Kaories gs c fightend') ~= nil, true)
end
-- a fight dropped before its load: fightopen off, no fightend
sent, now, queue = {}, 0, {}
Sortie.handle({'leechtest', 'fight'}); run_queue(1)
Sortie.handle({'melee'}); run_queue()
check('dropped before the load: fightopen off', has('send Kaories gs c fightopen off') ~= nil, true)
check('  no fightend', has('send Kaories gs c fightend'), nil)

-- 3. a target with no fight_ja and no follow behaves as before
sent, now = {}, 0
Sortie.handle({'melee'}); run_queue()
check('plain target: follow off', has('send Kaories sm follow off') ~= nil, true)

if failed > 0 then print(lines()) end
-- no fight_ja (Leshonn, Gartell): Full Circle, then the profile 1.5 s later; full_circle = false: at once
CFG.targets.prepfc = {profile = 'Leshonn', indi = 'Indi-Frailty', prep = {profile = 'LeshonnPrep', indi = 'Indi-Focus'}}
sent, noted, now, queue = {}, {}, 0, {}
Sortie.handle({'prepfc', 'fight'}); run_queue()
check('no fight_ja: Full Circle at once', has('send Kaories /ja "Full Circle" <me>'), 0)
check('no fight_ja: profile 1.5 s later', has('send Kaories sm load Kaories/Sortie/GEO/Leshonn'), 1.5)
CFG.targets.nofc = {profile = 'LeechAuto', indi = 'Indi-Fury', full_circle = false,
    prep = {profile = 'LeechPrep', indi = 'Indi-Refresh', follow = 'Tetsouo'}}
sent, noted, now, queue = {}, {}, 0, {}
Sortie.handle({'nofc', 'fight'}); run_queue()
check('no full circle: none sent', has('send Kaories /ja "Full Circle" <me>'), nil)
check('no full circle: profile at once', has('send Kaories sm load Kaories/Sortie/GEO/LeechAuto'), 0)

-- full_circle_first: bot off and Full Circle first, the profile 1.5 s later
CFG.targets.fcfirst = {profile = 'LeechPull', indi = 'Indi-Fury', full_circle_first = true}
sent, noted, now, queue = {}, {}, 0, {}
Sortie.handle({'fcfirst'}); run_queue()
check('fc first: bot off at once', has('send Kaories sm off'), 0)
check('fc first: Full Circle at once', has('send Kaories /ja "Full Circle" <me>'), 0)
check('fc first: profile 1.5 s later', has('send Kaories sm load Kaories/Sortie/GEO/LeechPull'), 1.5)
sent, noted, now, queue = {}, {}, 0, {}
Sortie.handle({'melee'}); run_queue()
check('no fc first: no Full Circle', has('send Kaories /ja "Full Circle" <me>'), nil)
check('no fc first: profile at once', has('send Kaories sm load Kaories/Sortie/GEO/Melee'), 0)

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

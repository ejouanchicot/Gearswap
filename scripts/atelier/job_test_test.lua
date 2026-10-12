---============================================================================
--- Test of //gs c jobtest (shared/utils/debug/job_test.lua)
---============================================================================
--- The run against a game made of tables: a job change packet changes the
--- game's job and, a moment later, loads GearSwap (one more load, on_load).
--- Checked: the steps played and their order, what each one records, a job
--- the server refuses, a stop, the way back home, and that nothing starts
--- outside the Mog House.
---
--- Run from data/: lua5.1 scripts/atelier/job_test_test.lua
---
--- @file scripts/atelier/job_test_test.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-12
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

-- a clock of our own: scheduled calls run in the order of their time
local now, tasks = 0, {}
coroutine.schedule = function(fn, delay) tasks[#tasks + 1] = {at = now + (delay or 0), fn = fn, n = #tasks} end
local function run_all(limit)
    local n = 0
    while #tasks > 0 and n < (limit or 100000) do
        table.sort(tasks, function(a, b) if a.at ~= b.at then return a.at < b.at end return a.n < b.n end)
        local task = table.remove(tasks, 1)
        now = task.at
        task.fn()
        n = n + 1
    end
end
os.clock = function() return now end
os.time = function() return math.floor(now) end

local JOBS = {[1] = 'WAR', [4] = 'BLM', [7] = 'PLD', [16] = 'BLU', [22] = 'RUN'}
local game, JobTest
local function new_game()
    game = {main = 'PLD', sub = 'RUN', mog_house = true, refused = {}, injected = {}, simulated = {}, broken = {}}
    now, tasks = 0, {}
    windower._job_test, windower._job_test_last, windower._load_gen, windower._lockstyle_recorded = nil, nil, 5, nil
end
player = {name = 'Test'}
windower = {addon_path = 'X:/', file_exists = function() return true end, get_dir = function() return {} end,
    ffxi = {
        get_info = function() return {mog_house = game.mog_house} end,
        get_player = function()
            return {main_job = game.main, sub_job = game.sub, jobs = {WAR = 99, BLM = 99, PLD = 99, BLU = 99, RUN = 99}}
        end,
    }}
package.loaded['resources'] = {jobs = (function() local t = {} for id, s in pairs(JOBS) do t[id] = {ens = s} end return t end)()}
package.loaded['packets'] = {
    new = function(_, _, fields) return fields end,
    inject = function(fields)
        local field, id = next(fields)
        local short = JOBS[id]
        game.injected[#game.injected + 1] = field .. ' ' .. short
        if game.refused[short] then return end
        if field == 'Main Job' then game.main = short else game.sub = short end
        -- GearSwap loads the job a moment later: one more load, handed to the test
        coroutine.schedule(function()
            windower._load_gen = windower._load_gen + 1
            player.main_job, player.sub_job = game.main, game.sub
            JobTest.on_load()
        end, 1.5)
    end}
package.loaded['shared/utils/messages/message_formatter'] = {show_info = function() end}
package.loaded['shared/utils/core/char_paths'] = {atelier_dir = function() return nil end, writable = function() return nil end,
    load = function() return true, {default = 3, by_subjob = {BLM = 9}} end}
package.loaded['shared/utils/core/command_queue'] = {pending = function() return 0 end}
package.loaded['shared/utils/atelier/atelier_export'] = {json = function() return '{}' end}
package.loaded['shared/utils/debug/full_test'] = {run = function()
    return {score = 96, sections = {{title = 'A', results = {{status = 'OK', name = 'fine'}, {status = 'WARN', name = 'UI', detail = 'late'}}}}}
end}
package.loaded['shared/utils/atelier/atelier_sim'] = {
    actions = function() return {ja = {'Sentinel'}, ws = {'Savage Blade'}, ma = {'Cure', 'Flash'}} end,
    run = function(req)
        game.simulated[#game.simulated + 1] = req.kind .. ' ' .. req.name
        if game.broken[req.name] then error('attempt to index a nil value') end
        return {ok = true}
    end}
sets = {idle = {}}

JobTest = require('shared/utils/debug/job_test')
local function labels(results)
    local out = {}
    for _, r in ipairs(results) do out[#out + 1] = r.kind .. ':' .. r.main .. '/' .. r.sub end
    return table.concat(out, ' ')
end

-- 1. outside the Mog House nothing starts
new_game()
game.mog_house = false
check('outside the Mog House: refused', JobTest.handle({}).ok, false)
check('no packet sent', #game.injected, 0)

-- 2. two jobs named: each one with the home subjob, the home job, three subjobs, the home subjob, a double change
new_game()
windower._lockstyle_recorded = nil
local r = JobTest.handle({'WAR', 'BLM'})
check('started', r.ok, true)
check('eight steps', r.steps, 8)
run_all()
local last = windower._job_test_last
check('the run ended', JobTest.active(), false)
check('the steps in order', labels(last.results),
    'main:WAR/RUN main:BLM/RUN main:PLD/RUN sub:PLD/BLM sub:PLD/BLU sub:PLD/WAR sub:PLD/RUN rapid:BLU/RUN')
check('back on the home job', game.main .. '/' .. game.sub, 'PLD/RUN')
local war = last.results[1]
check('a step knows where it came from', war.from, 'PLD/RUN')
check('the load is timed', war.load_s > 0, true)
check('one packet, one load', war.packets .. '/' .. war.loads, '1/1')
check('GearSwap and the game agree', war.gearswap, war.game)
check('the health score is kept', war.score, 96)
check('four actions simulated', war.sim.count, 4)
check('no error', war.sim.errors, 0)
local notes = table.concat(war.notes or {}, ' | ')
check('the line that is not OK is noted', notes:find('WARN A: UI (late)', 1, true) ~= nil, true)
check('the lockstyle not seen is noted', notes:find('lockstyle 3 asked, none seen', 1, true) ~= nil, true)
local rapid = last.results[8]
check('the double change sends two main jobs', rapid.packets, 2)
check('and ends on the second', rapid.game, 'BLU/RUN')
check('two loads for it', rapid.loads, 2)

-- 3. an action that breaks the job's code is named, the others still run
new_game()
game.broken = {Flash = true}
JobTest.handle({'WAR'})
run_all()
war = windower._job_test_last.results[1]
check('one error counted', war.sim.errors, 1)
check('and named', table.concat(war.notes, ' | '):find('FAIL ma Flash: ', 1, true) ~= nil, true)
check('every action was tried', war.sim.count, 4)

-- 4. nosim: no action is simulated
new_game()
JobTest.handle({'WAR', 'nosim'})
run_all()
check('nosim: nothing simulated', #game.simulated, 0)
check('nosim: the step is still measured', windower._job_test_last.results[1].score, 96)

-- 5. a job the server refuses: said, and the run goes on
new_game()
game.refused = {WAR = true}
JobTest.handle({'WAR', 'BLM'})
run_all()
last = windower._job_test_last
check('refused: the step says it', table.concat(last.results[1].notes, ' | '):find('FAIL not on WAR/RUN', 1, true) ~= nil, true)
check('refused: the next job is still played', last.results[2].game, 'BLM/RUN')
check('refused: back home at the end', game.main .. '/' .. game.sub, 'PLD/RUN')

-- 6. stopped by the player: the step in hand is finished, then home
new_game()
JobTest.handle({'WAR', 'BLM'})
JobTest.handle({'stop'})
run_all()
last = windower._job_test_last
check('stopped: only the first step was played', #last.results, 1)
check('stopped: back home', game.main .. '/' .. game.sub, 'PLD/RUN')

-- 7. leaving the Mog House ends the run without another packet
new_game()
JobTest.handle({'WAR', 'BLM'})
run_all(6)
game.mog_house = false
local sent = #game.injected
run_all()
check('left the Mog House: no packet after that', #game.injected, sent)
check('left the Mog House: the run ended', JobTest.active(), false)

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

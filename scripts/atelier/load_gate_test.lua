---============================================================================
--- Test of the load gate (shared/utils/core/load_gate.lua)
---============================================================================
--- Deferred load work against a game made of tables: run when the load is
--- still the live one, dropped after a newer load or a subjob change, and
--- kept waiting while the game has not yet answered the job change the load
--- was made for.
---
--- Run from data/: lua5.1 scripts/atelier/load_gate_test.lua
---
--- @file scripts/atelier/load_gate_test.lua
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
local function run_until(limit)
    while true do
        table.sort(tasks, function(a, b) if a.at ~= b.at then return a.at < b.at end return a.n < b.n end)
        if not tasks[1] or tasks[1].at > limit then break end
        local task = table.remove(tasks, 1)
        now = task.at
        task.fn()
    end
    now = limit
end

local game = {}
windower = {_load_gen = 0, ffxi = {get_player = function() return {main_job = game.main, sub_job = game.sub} end}}
package.loaded['shared/utils/debug/trace_log'] = {log = function() end}
local LoadGate = require('shared/utils/core/load_gate')

--- A load of GearSwap for main/sub while the game reports game_main/game_sub; one task deferred half a second.
local ran
local function load_for(main, sub, game_main, game_sub)
    now, tasks, ran = 0, {}, 0
    game.main, game.sub = game_main, game_sub
    player = {main_job = main, sub_job = sub}
    LoadGate.begin()
    LoadGate.defer(0.5, function() ran = ran + 1 end, 'test')
end

-- 1. the usual load: the task runs once, at its time
load_for('PLD', 'RUN', 'PLD', 'RUN')
run_until(0.4)
check('not before its time', ran, 0)
run_until(1)
check('run at its time', ran, 1)
run_until(30)
check('once only', ran, 1)

-- 2. a newer load before the task is due: dropped
load_for('PLD', 'RUN', 'PLD', 'RUN')
LoadGate.begin()
run_until(30)
check('a newer load drops it', ran, 0)

-- 3. the subjob changed since the load: dropped (a reload follows such a change)
load_for('PLD', 'RUN', 'PLD', 'RUN')
game.sub = 'BLU'
run_until(30)
check('a subjob change drops it', ran, 0)

-- 4. the file was loaded on the job change request, the game still reports the job of before: the task waits
load_for('DRK', 'SAM', 'DRG', 'SAM')
run_until(1)
check('the game is not on the job yet: not run, not dropped', ran, 0)
game.main = 'DRK'
run_until(2)
check('run once the game is on the job', ran, 1)
run_until(30)
check('once only', ran, 1)

-- 5. the same, and a newer load comes while it waits: dropped
load_for('DRK', 'SAM', 'DRG', 'SAM')
run_until(1)
LoadGate.begin()
game.main = 'DRK'
run_until(30)
check('a newer load while it waits drops it', ran, 0)

-- 6. the game never gets to that job (the server refused the change): given up after ten seconds
load_for('DRK', 'SAM', 'DRG', 'SAM')
run_until(9)
check('still waiting at nine seconds', #tasks, 1)
run_until(30)
check('never run', ran, 0)
check('and no longer waiting', #tasks, 0)

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

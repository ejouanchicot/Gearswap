---============================================================================
--- Test of Bags Quiet (shared/utils/equipment/bags_quiet.lua)
---============================================================================
--- An action that reads the bags (the lockstyle) waits for them to stop
--- moving: run 2 s after the last change, at once outside the game, left out
--- after 120 s of movement; LockstyleManager.apply_style goes through it.
---
--- Run from data/: lua5.1 scripts/atelier/bags_quiet_test.lua
---
--- @file scripts/atelier/bags_quiet_test.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-16
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
local function run_until(limit, each)
    while true do
        table.sort(tasks, function(a, b) if a.at ~= b.at then return a.at < b.at end return a.n < b.n end)
        if not tasks[1] or tasks[1].at > limit then break end
        local task = table.remove(tasks, 1)
        now = task.at
        if each then each(now) end
        task.fn()
    end
    now = limit
end

-- the bags: inventory count changes while `moving_until` is ahead of the clock
local inventory, moving_until, in_game = 40, 0, true
windower = {addon_path = './', ffxi = {get_bag_info = function(id)
    if not in_game then return nil end
    if id == 0 and now < moving_until then inventory = inventory + 1 end
    return {count = id == 0 and inventory or 10}
end}}
local traced = {}
package.loaded['shared/utils/debug/trace_log'] = {log = function(_, fmt, ...) traced[#traced + 1] = fmt:format(...) end}
local BagsQuiet = require('shared/utils/equipment/bags_quiet')

local function start(moving)
    now, tasks, traced, moving_until = 0, {}, {}, moving
    local ran
    BagsQuiet.run(function() ran = now end, 'lockstyle 7')
    return function() return ran end
end

-- 1. nothing moves: the action goes once the bags were seen the same twice, 2 s later
local ran = start(0)
run_until(1.5)
check('still bags: not before 2 s', ran(), nil)
run_until(10)
check('still bags: at 2 s', ran(), 2)

-- 2. items move for 5 s (the last change read at 4 s): the action waits for two calm reads after it
ran = start(5)
run_until(30)
check('moving 5 s: 2 s after the last move seen', ran(), 6)

-- 3. items keep moving: left out after 120 s, said in the trace
ran = start(1000)
run_until(300)
check('moving all along: never run', ran(), nil)
check('moving all along: traced', traced[1] and traced[1]:find('lockstyle 7 left out', 1, true) ~= nil, true)

-- 4. outside the game (no bag info): at once
in_game = false
ran = start(0)
check('outside the game: at once', ran(), 0)
in_game = true

-- 5. LockstyleManager.apply_style: /lockstyleset only once the bags are calm
local sent = {}
send_command = function(cmd) sent[#sent + 1] = {at = now, cmd = cmd} end
package.loaded['shared/utils/messages/message_formatter'] = setmetatable({}, {__index = function() return function() end end})
package.loaded['shared/utils/lockstyle/lockstyle_pieces'] = {expect = function() end}
_G.DRESSUP_MANAGEMENT_ENABLED = false
local LockstyleManager = require('shared/utils/lockstyle/lockstyle_manager')
now, tasks, moving_until = 0, {}, 4
LockstyleManager.apply_style(12)
run_until(3)
check('apply_style: nothing while the bags move', #sent, 0)
run_until(20)
check('apply_style: sent once', #sent, 1)
check('apply_style: the style', sent[1] and sent[1].cmd, 'input /lockstyleset 12')
check('apply_style: 2 s after the last move seen', sent[1] and sent[1].at, 5)

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

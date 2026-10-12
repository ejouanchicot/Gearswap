---============================================================================
--- Test of the ghost watch (shared/utils/debug/ghost_watch.lua)
---============================================================================
--- Four loads, each in a sandbox of its own as in game (the module is loaded
--- again in each one, and a function of a load sees that load's `coroutine`).
--- Each load schedules a loop that never notices it was replaced, a loop that
--- stops when it is, and a single call. Only the first must be reported as
--- running long after its load.
---
--- Run from data/: lua5.1 scripts/atelier/ghost_watch_test.lua
---
--- @file scripts/atelier/ghost_watch_test.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-12
---============================================================================

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
local shared = setmetatable({schedule = function(fn, delay) tasks[#tasks + 1] = {at = now + (delay or 0), fn = fn, n = #tasks} end},
    {__index = coroutine})
local real_time = os.time
os.time = function() return math.floor(now) end
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

windower = {_load_gen = 0}
local module = assert(loadfile('shared/utils/debug/ghost_watch.lua'))
local ran = {immortal = 0, polite = 0, once = 0}

--- One load: a new sandbox with the shared libraries, the module loaded in it, then what the load schedules.
local function load(watching)
    windower._load_gen = windower._load_gen + 1
    local env = setmetatable({coroutine = shared}, {__index = _G})
    env._G = env
    local Ghosts = setfenv(module, env)()
    if watching == 'start' then Ghosts.start() end
    Ghosts.install()
    local body = setfenv(function()
        local mine = windower._load_gen
        local function immortal() ran.immortal = ran.immortal + 1 coroutine.schedule(immortal, 5) end
        local function polite()
            if windower._load_gen ~= mine then return end
            ran.polite = ran.polite + 1
            coroutine.schedule(polite, 5)
        end
        coroutine.schedule(immortal, 5)
        coroutine.schedule(polite, 5)
        coroutine.schedule(function() ran.once = ran.once + 1 end, 3)
    end, env)
    body()
    return Ghosts
end

-- 1. not asked for: the sandbox keeps the shared `coroutine`, nothing is counted
local Ghosts = load()
run_until(now + 60)
check('off: nothing counted', #Ghosts.report(), 0)

-- 2. on, four loads a minute apart
Ghosts = load('start')
for _ = 1, 3 do run_until(now + 60) Ghosts = load() end
run_until(now + 60)
local report = Ghosts.report()
check('the work still runs as it would have', ran.once, 5)
check('one line is reported running after its load', #report, 2)
local worst = report[1]
check('the loop that never stops is the latest', worst.where:match('^ghost_watch_test%.lua:%d+$') ~= nil, true)
check('for the three loads that were replaced', worst.loads, 3)
check('long after its load was replaced', worst.latest >= 170, true)
check('many calls', worst.calls > 60, true)
check('the polite loop stopped at its first look', report[2].calls, 3)
check('within seconds of the replacement', report[2].latest <= 5, true)

-- 3. stopped: the next load is not watched
Ghosts.stop()
local before = Ghosts.report()[1].loads
load()
run_until(now + 60)
check('stopped: the watched loads still count theirs', Ghosts.report()[1].loads >= before, true)

os.time = real_time
print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

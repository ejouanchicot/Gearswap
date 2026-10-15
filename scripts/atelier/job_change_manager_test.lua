---============================================================================
--- Test of the job change manager (shared/utils/core/job_change_manager.lua)
---============================================================================
--- The debounced `gs reload` against a clock of our own: one reload for a
--- burst of changes, 2 s for a subjob change and 3 s for a main job change,
--- nothing once cancel_all() has run (file_unload), and the job state seeded
--- once per environment (Mote calls user_setup before job_sub_job_change).
---
--- Run from data/: lua5.1 scripts/atelier/job_change_manager_test.lua
---
--- @file scripts/atelier/job_change_manager_test.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-15
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
coroutine.schedule = function(fn, delay) tasks[#tasks + 1] = {at = now + (delay or 0), fn = fn, n = #tasks} return #tasks end
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

local reloads
windower = {send_command = function(cmd) if cmd == 'gs reload' then reloads[#reloads + 1] = now end end}
local quiet = {log = function() end, log_if = function() end, logf_if = function() end}
package.loaded['shared/utils/debug/trace_log'] = quiet
package.loaded['shared/utils/debug/debug_logger'] = quiet
package.loaded['shared/utils/ui/UI_MANAGER'] = {destroy = function() end}
local JCM = require('shared/utils/core/job_change_manager')
local STATE = _G.JobChangeManagerSTATE

--- A fresh environment loaded for main/sub (the state lives on that environment's _G).
local function load_for(main, sub)
    now, tasks, reloads = 0, {}, {}
    STATE.current_main_job, STATE.current_sub_job = nil, nil
    STATE.debounce_counter, STATE.lockstyle_cancel_registry = 0, {}
    player = {main_job = main, sub_job = sub}
    JCM.initialize()
end

-- 1. a subjob change: one reload, 2 s later
load_for('PLD', 'RUN')
JCM.on_job_change('PLD', 'BLU')
run_until(1.9)
check('subjob change: not before 2 s', #reloads, 0)
run_until(30)
check('subjob change: one reload', #reloads, 1)
check('subjob change: at 2 s', reloads[1], 2.0)

-- 2. a main job change: 3 s
load_for('PLD', 'RUN')
JCM.on_job_change('WAR', 'SAM')
run_until(30)
check('main job change: one reload', #reloads, 1)
check('main job change: at 3 s', reloads[1], 3.0)

-- 3. a burst: three changes a second apart, one reload, 2 s after the last
load_for('PLD', 'RUN')
JCM.on_job_change('PLD', 'BLU')
run_until(1)
JCM.on_job_change('PLD', 'WAR')
run_until(2)
JCM.on_job_change('PLD', 'RUN')
run_until(30)
check('burst: one reload only', #reloads, 1)
check('burst: 2 s after the last change', reloads[1], 4.0)

-- 4. the file unloads before the reload is due (file_unload -> cancel_all): no reload, the lockstyles cancelled
load_for('PLD', 'RUN')
local cancelled = 0
JCM.register_lockstyle_cancel('PLD', function() cancelled = cancelled + 1 end)
JCM.on_job_change('PLD', 'BLU')
run_until(1)
JCM.cancel_all()
run_until(30)
check('cancel_all: no reload', #reloads, 0)
check('cancel_all: the lockstyle cancelled', cancelled, 1)

-- 5. Mote runs user_setup (initialize) with the new subjob before job_sub_job_change: the seed keeps the
--    job of the load, so a subjob change still gets 2 s and not the main job's 3 s
load_for('PLD', 'RUN')
player = {main_job = 'PLD', sub_job = 'BLU'}
JCM.initialize()
check('seed kept: subjob of the load', STATE.current_sub_job, 'RUN')
JCM.on_job_change('PLD', 'BLU')
run_until(30)
check('seed kept: 2 s', reloads[1], 2.0)

-- 6. //gs c reload while a change is pending: reloads at once, and the pending one is dropped
load_for('PLD', 'RUN')
JCM.on_job_change('PLD', 'BLU')
run_until(1)
JCM.force_reload()
run_until(30)
check('force_reload: one reload only', #reloads, 1)
check('force_reload: at once', reloads[1], 1)

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

---============================================================================
--- Job Test - job changes played and measured in game, one after the other
---============================================================================
--- //gs c jobtest [JOB ...] [nosim]   in the Mog House: change to each job (all the jobs you have, or the ones
---                                    named), then change subjob three times on your own job, then change main
---                                    job twice in a row, and come back to the job and subjob you had.
---                                    `nosim` leaves the actions out; `bare` measures nothing but how many
---                                    older loads stay in memory (the loads as they are with no test in them);
---                                    `ghosts` counts the scheduled work that still runs after its load was
---                                    replaced (ghost_watch.lua); `short`: the jobs named and the way back
---                                    only; `skip=a,b`: deferred load tasks left out (load_gate.lua);
---                                    `gaps=2,4,6`: the main job changed to the job named and back, that many
---                                    seconds apart, to see at what age a load starts being kept in memory.
--- //gs c jobtest stored              anywhere, no job change: after a full collection, the older loads still in
---                                    memory (every load is noted, config_loader.lua), the memory held, and the
---                                    functions kept on `windower` (env_watch.lua). POST /jobtest with `stored`.
--- //gs c jobtest stop                stop after the step being measured and come back.
--- //gs c jobtest                     while one runs: where it is.
---
--- Every load is a normal one (lockstyle, macro book, dual-box, Atelier export): this is the game as it is
--- played. For each step, once the game is on the job asked:
---   * the time from the job change to the load, how many loads it took, and how long the keys took to land
---     (the paced command queue, command_queue.lua, back to empty);
---   * the job GearSwap believes it is on against the job the game is on;
---   * the health check of //gs c fulltest (systems, modules, hooks, sets), every line that is not OK;
---   * the lockstyle set the game applied against the one the job's file asks for;
---   * the addon's Lua memory, as it stands and after a full collection (what the loads keep), and how
---     many older loads are still in memory then (env_watch.lua);
---   * every ability, weapon skill and spell the job has, run through its precast, midcast and aftercast
---     without being done (atelier_sim.lua, what the Atelier's Simulate tab uses): an error in the job's code
---     for any of them, and how long each takes. A few at a time, so the game does not freeze.
---
--- The report is written to <Character>/atelier/job_test.json and job_test.log, and read through the live
--- link (GET /jobtest). The job changes are the tour's (atelier_tour.lua: outgoing 0x100, which the server
--- accepts in the Mog House only). The run's state lives on windower (windower._job_test): every load
--- replaces the sandbox, and AtelierExport.after_load hands each load to on_load.
---
--- A diagnostic tool.
---
--- @file    shared/utils/debug/job_test.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-12
---============================================================================

local JobTest = {}

local SETTLE = 12           -- seconds a load is given before it is looked at (the lockstyle comes 2 s after a load)
local JOB_WAIT = 25         -- seconds a load waits for the game to be on the job asked
local STEP_TIMEOUT = 70     -- a step whose load never came is given up after this
local QUEUE_WAIT = 40       -- seconds the keys are given to land
local NEXT_GAP = 3          -- seconds between a step and the next change
local RAPID_GAP = 0.7       -- seconds between the two changes of the "twice in a row" step
local SIM_BATCH, SIM_TICK = 5, 0.1   -- actions simulated at a time, seconds between two batches
local SLOW_MS = 30          -- an action whose three phases take longer is named
local MAX_NOTES = 40

local function changes() return require('shared/utils/atelier/atelier_tour').changes end

local function say(text)
    local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
    if ok and MessageFormatter.show_info then MessageFormatter.show_info('Job test: ' .. text) end
end

--- True while a test runs (one that stopped answering ends by itself).
--- @return boolean
function JobTest.active()
    local run = windower._job_test
    return type(run) == 'table' and os.time() < (run.deadline or 0)
end

local function note(step, text)
    step.notes = step.notes or {}
    if #step.notes < MAX_NOTES then step.notes[#step.notes + 1] = text end
end

---============================================================================
--- WHAT IS MEASURED
---============================================================================

--- //gs c fulltest's own checks: the score, and every line that is not OK.
local function health(step)
    local ok, report = pcall(function() return require('shared/utils/debug/full_test').run() end)
    if not ok then return note(step, 'health check failed: ' .. tostring(report)) end
    step.score = report.score
    for _, section in ipairs(report.sections or {}) do
        for _, r in ipairs(section.results or {}) do
            if r.status ~= 'OK' then
                note(step, ('%s %s: %s%s'):format(r.status, section.title, tostring(r.name),
                    (r.detail and r.detail ~= '') and (' (' .. tostring(r.detail) .. ')') or ''))
            end
        end
    end
end

--- The lockstyle set the job's file asks for on this subjob, or nil.
local function lockstyle_wanted(main, sub)
    local ok, loaded, cfg = pcall(require('shared/utils/core/char_paths').load, 'job', main .. '_LOCKSTYLE', main)
    if not (ok and loaded and type(cfg) == 'table') then return nil end
    return tostring((type(cfg.by_subjob) == 'table' and cfg.by_subjob[sub]) or cfg.default or '')
end

--- The job GearSwap is on, the lockstyle the game applied since the change, the Lua memory.
local function facts(step)
    local me = windower.ffxi.get_player() or {}
    step.game = ('%s/%s'):format(tostring(me.main_job), tostring(me.sub_job))
    step.gearswap = ('%s/%s'):format(tostring(player and player.main_job), tostring(player and player.sub_job))
    if step.gearswap ~= step.game then note(step, 'FAIL GearSwap is on ' .. step.gearswap .. ', the game on ' .. step.game) end
    if type(rawget(_G, 'sets')) ~= 'table' or next(sets) == nil then note(step, 'FAIL no sets') end
    local seen, wanted = windower._lockstyle_recorded, lockstyle_wanted(step.main, step.sub)
    step.lockstyle = (type(seen) == 'table' and (seen.at or 0) >= step.t0) and tostring(seen.set) or nil
    step.lockstyle_wanted = wanted
    if wanted and wanted ~= '' and step.lockstyle ~= wanted then
        note(step, ('WARN lockstyle %s asked, %s seen'):format(wanted, tostring(step.lockstyle or 'none')))
    end
    -- as it stands, then after a full collection: what is still held is what the loads keep
    local G = rawget(_G, 'gearswap')
    local count = type(G) == 'table' and rawget(G, 'collectgarbage')
    local ok, kb = pcall(function() return count('count') end)
    step.memory_kb = ok and math.floor(kb) or nil
    local ok_c, held = pcall(function() count('collect') return count('count') end)
    step.memory_held_kb = ok_c and math.floor(held) or nil
    -- the older loads still in memory (env_watch.lua): each one is a whole sandbox kept
    local ok_e, alive = pcall(function() return require('shared/utils/debug/env_watch').survivors() end)
    step.old_loads = ok_e and type(alive) == 'table' and #alive or nil
end

--- One action through the job's precast, midcast and aftercast, timed.
local function simulate(step, Sim, kind, name)
    local at = os.clock()
    local ok, r = pcall(Sim.run, {kind = kind, name = name, target = 'auto', ignore_recasts = true})
    local ms = (os.clock() - at) * 1000
    local sim = step.sim
    sim.count, sim.ms = sim.count + 1, sim.ms + ms
    if ms > sim.max_ms then sim.max_ms, sim.max_name = ms, kind .. ' ' .. name end
    if ms > SLOW_MS then sim.slow = sim.slow + 1 end
    local err = (not ok and tostring(r)) or (type(r) == 'table' and r.ok == false and tostring(r.error)) or nil
    if err then
        sim.errors = sim.errors + 1
        note(step, ('FAIL %s %s: %s'):format(kind, name, err:sub(1, 220)))
    end
end

--- Every ability, weapon skill and spell the job has, as {kind, name}.
local function action_list()
    local Sim = require('shared/utils/atelier/atelier_sim')
    local ok, actions = pcall(Sim.actions)
    local list = {}
    for _, kind in ipairs({'ja', 'ws', 'ma'}) do
        for _, name in ipairs(ok and type(actions) == 'table' and actions[kind] or {}) do list[#list + 1] = {kind, name} end
    end
    return list, Sim
end

---============================================================================
--- THE RUN
---============================================================================

local advance

--- True while the wait started by the load `gen` for the step `token` is still the one to follow.
local function still_mine(token, gen)
    local run = windower._job_test
    return type(run) == 'table' and run.token == token and windower._load_gen == gen
end

local function close_step(token)
    local run = windower._job_test
    local step = run.step
    step.seconds = math.floor((os.clock() - step.t0) * 10 + 0.5) / 10
    if step.sim then
        step.sim.ms, step.sim.max_ms = math.floor(step.sim.ms + 0.5), math.floor(step.sim.max_ms + 0.5)
    end
    step.t0 = nil
    run.results[#run.results + 1] = step
    run.step = nil
    run.token = token + 1            -- this step's watchdog no longer has a say
    coroutine.schedule(advance, NEXT_GAP)
end

local function simulate_all(token, gen, list, Sim, index)
    if not still_mine(token, gen) then return end
    local step = windower._job_test.step
    for _ = 1, SIM_BATCH do
        local action = list[index]
        if not action then return close_step(token) end
        simulate(step, Sim, action[1], action[2])
        index = index + 1
    end
    coroutine.schedule(function() simulate_all(token, gen, list, Sim, index) end, SIM_TICK)
end

--- The keys have landed (or never will): the step is looked at.
local function inspect(token, gen)
    if not still_mine(token, gen) then return end
    local run = windower._job_test
    local step = run.step
    if run.bare then
        -- nothing of the test but the count of older loads: what a load keeps by itself
        local ok_e, alive = pcall(function() return require('shared/utils/debug/env_watch').survivors() end)
        step.old_loads = ok_e and type(alive) == 'table' and #alive or nil
        return close_step(token)
    end
    health(step)
    facts(step)
    if run.nosim then return close_step(token) end
    local list, Sim = action_list()
    step.sim = {count = 0, errors = 0, ms = 0, max_ms = 0, slow = 0}
    simulate_all(token, gen, list, Sim, 1)
end

local function wait_for_keys(token, gen, left)
    if not still_mine(token, gen) then return end
    local step = windower._job_test.step
    local ok, pending = pcall(function() return require('shared/utils/core/command_queue').pending() end)
    if ok and pending > 0 and left > 0 then
        return coroutine.schedule(function() wait_for_keys(token, gen, left - 1) end, 1)
    end
    step.keys_s = math.floor((os.clock() - step.t0) * 10 + 0.5) / 10
    if ok and pending > 0 then note(step, ('WARN %d key command(s) still waiting after %d s'):format(pending, QUEUE_WAIT)) end
    inspect(token, gen)
end

--- Wait until the game itself is on the job asked, then let the load settle.
local function wait_for_job(token, gen, left)
    if not still_mine(token, gen) then return end
    local step, me = windower._job_test.step, windower.ffxi.get_player() or {}
    if me.main_job == step.main and me.sub_job == step.sub then
        return coroutine.schedule(function() wait_for_keys(token, gen, QUEUE_WAIT) end, SETTLE)
    end
    if left > 0 then coroutine.schedule(function() wait_for_job(token, gen, left - 1) end, 1) end
end

--- Called at each load (AtelierExport.after_load): the load is counted and timed for the step being played.
--- @return boolean True when a test runs
function JobTest.on_load()
    if not JobTest.active() then return false end
    local run = windower._job_test
    local step = run.step
    pcall(function() require('shared/utils/debug/env_watch').mark() end)
    if run.gaps then
        -- a run of timed changes: each load is only noted, with when it came
        local entry = {load = windower._load_gen, at = os.clock()}
        run.load_log[#run.load_log + 1] = entry
        if run.parts then
            -- the n-th load builds the Atelier export up to its n-th stage (AtelierExport.build(upto)): the first
            -- load kept in memory names the stage that keeps it
            entry.stage = #run.load_log
            coroutine.schedule(function()
                pcall(function() require('shared/utils/atelier/atelier_export').build(entry.stage) end)
            end, 1)
        end
        return true
    end
    if not step then return true end
    step.loads = (step.loads or 0) + 1
    step.load_s = math.floor((os.clock() - step.t0) * 10 + 0.5) / 10
    wait_for_job(run.token, windower._load_gen, JOB_WAIT)
    return true
end

---============================================================================
--- THE STEPS
---============================================================================

local function write_report(run)
    local Paths = require('shared/utils/core/char_paths')
    local data = {at = os.date('%Y-%m-%d %H:%M:%S'), home = run.home_main .. '/' .. run.home_sub, results = run.results,
        stopped = run.stopped}
    if run.ghosts then
        -- scheduled work that ran after its load was replaced (ghost_watch.lua)
        local Ghosts = require('shared/utils/debug/ghost_watch')
        data.ghosts = Ghosts.report()
        Ghosts.stop()
    end
    local ok, text = pcall(function() return require('shared/utils/atelier/atelier_export').json(data) end)
    local path = Paths.writable('atelier', 'job_test.json')
    local file = ok and path and io.open(path, 'w')
    if file then file:write(text) file:close() end
    windower._job_test_last = data
end

local function finish(run, why)
    run.stopped = why
    windower._load_skip = nil
    write_report(run)
    windower._job_test = nil
    local bad = 0
    for _, step in ipairs(run.results) do if step.notes then bad = bad + 1 end end
    say(('done: %d step(s), %d with something to look at%s. Report: atelier/job_test.json'):format(
        #run.results, bad, why and (' (' .. why .. ')') or ''))
end

--- Back to the job and subjob of before the test. The test ends here: that last load is not measured.
local function go_home(run, why)
    local C, me = changes(), windower.ffxi.get_player() or {}
    local steps = C.in_mog_house() and C.steps_to(me.main_job, me.sub_job, run.home_main, run.home_sub, run.all) or {}
    finish(run, why)
    if #steps > 0 then C.send_steps(steps) end
end

--- A change that no load answered, or a load that never reached the job asked.
local function watch(token)
    coroutine.schedule(function()
        local run = windower._job_test
        if type(run) ~= 'table' or run.token ~= token or not run.step then return end
        local me = windower.ffxi.get_player() or {}
        note(run.step, ('FAIL not on %s/%s after %d s (the game is on %s/%s, %d load(s))'):format(run.step.main, run.step.sub,
            STEP_TIMEOUT, tostring(me.main_job), tostring(me.sub_job), run.step.loads or 0))
        close_step(token)
    end, STEP_TIMEOUT)
end

--- Send the packets of a step. "rapid": the main job changes to another job first, and to the job asked
--- RAPID_GAP later, before GearSwap has loaded the first.
local function send(run, step, me)
    local C = changes()
    if step.kind ~= 'rapid' then
        local steps = C.steps_to(me.main_job, me.sub_job, step.main, step.sub, run.all)
        step.packets = #steps
        return C.send_steps(steps), #steps
    end
    step.packets = 2
    C.inject('Main Job', step.via)
    coroutine.schedule(function() if C.in_mog_house() then C.inject('Main Job', step.main) end end, RAPID_GAP)
    return nil, 2
end

advance = function()
    local run = windower._job_test
    if type(run) ~= 'table' then return end
    if not changes().in_mog_house() then return finish(run, 'you left the Mog House') end
    local step = table.remove(run.queue, 1)
    if not step then return go_home(run) end
    local me = windower.ffxi.get_player() or {}
    step.from, step.t0 = ('%s/%s'):format(tostring(me.main_job), tostring(me.sub_job)), os.clock()
    run.step = step
    run.token = (run.token or 0) + 1
    run.deadline = os.time() + STEP_TIMEOUT + QUEUE_WAIT + 120
    say(('%s  %s -> %s/%s  (%d left)'):format(step.kind, step.from, step.main, step.sub, #run.queue))
    local _, sent = send(run, step, me)
    if sent == 0 then
        -- already on that job: looked at as it is, no load to wait for
        step.loads, step.load_s = 0, 0
        return wait_for_keys(run.token, windower._load_gen, QUEUE_WAIT)
    end
    watch(run.token)
end

--- A run of timed changes (gaps=2,4,6...): the main job goes to `alt`, then back, then to `alt` again, each
--- change that many seconds after the one before. Nothing is measured but which of those loads are still in
--- memory at the end, against how long each one lived: at what age a load starts being kept.
local function gap_run(run)
    local C, i = changes(), 0
    local function conclude()
        local ok, alive = pcall(function() return require('shared/utils/debug/env_watch').survivors() end)
        local kept = {}
        for _, gen in ipairs(ok and type(alive) == 'table' and alive or {}) do kept[gen] = true end
        for n, entry in ipairs(run.load_log) do
            local after = run.load_log[n + 1]
            entry.lived = after and math.floor((after.at - entry.at) * 10 + 0.5) / 10 or nil
            entry.kept, entry.at = kept[entry.load] == true, nil
        end
        run.results = {{kind = 'gaps', main = run.home_main, sub = run.home_sub, loads = run.load_log}}
        finish(run)
    end
    local function change()
        if not C.in_mog_house() then return finish(run, 'you left the Mog House') end
        i = i + 1
        if i > #run.gaps + 1 then return coroutine.schedule(conclude, 15) end
        run.deadline = os.time() + 120
        C.inject('Main Job', (i % 2 == 1) and run.alt or run.home_main)
        coroutine.schedule(change, run.gaps[i] or 15)
    end
    change()
end

--- The steps of a run: every job with its usual subjob, three subjobs on the home job, one double change.
local function plan(jobs, all, home_main, home_sub)
    local C, queue, me = changes(), {}, windower.ffxi.get_player() or {}
    local function has(short) return (tonumber((me.jobs or {})[short] or (me.jobs or {})[short:lower()]) or 0) > 0 end
    for _, short in ipairs(jobs) do
        local sub = C.export_sub(short) or home_sub
        if sub == short or not has(sub) then sub = short ~= home_main and home_main or home_sub end
        queue[#queue + 1] = {kind = 'main', main = short, sub = sub}
    end
    local others = {}
    for _, short in ipairs(all) do
        if short ~= home_main and short ~= home_sub then others[#others + 1] = short end
    end
    queue[#queue + 1] = {kind = 'main', main = home_main, sub = home_sub}
    for i = 1, math.min(3, #others) do queue[#queue + 1] = {kind = 'sub', main = home_main, sub = others[i]} end
    queue[#queue + 1] = {kind = 'sub', main = home_main, sub = home_sub}
    if #others >= 2 then queue[#queue + 1] = {kind = 'rapid', via = others[1], main = others[2], sub = home_sub} end
    return queue
end

--- Where a run is, or what the last one found: for //gs c jobtest and the live link.
--- @return table {running, left, step, results, at, stopped}
function JobTest.status()
    local run = JobTest.active() and windower._job_test or nil
    if run then
        return {running = true, left = #run.queue, step = run.step and (run.step.kind .. ' ' .. run.step.main .. '/' .. run.step.sub),
            results = run.results}
    end
    local last = windower._job_test_last or {}
    return {running = false, at = last.at, stopped = last.stopped, results = last.results}
end

--- //gs c jobtest [stop | JOB ... | nosim]
--- @param args table The command's words after 'jobtest'
--- @return table {ok, error, steps}
function JobTest.handle(args)
    args = args or {}
    local word = args[1] and tostring(args[1]):lower()
    if word == 'stored' then
        -- the functions kept on `windower`, which outlives the loads (env_watch.lua: a shallow look, not a walk)
        local Watch = require('shared/utils/debug/env_watch')
        local old = Watch.survivors()
        local G = rawget(_G, 'gearswap')
        local count = type(G) == 'table' and rawget(G, 'collectgarbage')
        return {ok = true, old_loads = old, load = windower._load_gen, stored = Watch.stored_functions(),
            memory_held_kb = type(count) == 'function' and math.floor(count('count')) or nil}
    end
    if word == 'stop' then
        if not JobTest.active() then say('no test is running') return {ok = false, error = 'not running'} end
        windower._job_test.queue = {}
        say('stopping after this step, then back to ' .. windower._job_test.home_main)
        return {ok = true}
    end
    if JobTest.active() then
        local s = JobTest.status()
        say(('running: %s, %d step(s) left (//gs c jobtest stop)'):format(tostring(s.step), s.left))
        return {ok = false, error = 'running'}
    end
    local C, named, nosim, bare, ghosts, short, skip, gaps, parts = changes(), {'tour'}, false, false, false, false, nil, nil, false
    for _, a in ipairs(args) do
        local w = tostring(a):lower()
        if w == 'nosim' then nosim = true elseif w == 'bare' then bare = true elseif w == 'ghosts' then ghosts = true
        elseif w == 'short' then short = true
        elseif w == 'parts' then parts = true
        elseif w:match('^gaps=') then
            gaps = {}
            for n in w:sub(6):gmatch('[%d.]+') do gaps[#gaps + 1] = tonumber(n) end
        elseif w:match('^skip=') then
            -- deferred load tasks left out for this run, by their label (load_gate.lua; _ for a space, * for all)
            skip = {}
            for label in w:sub(6):gmatch('[^,]+') do skip[(label:gsub('_', ' '))] = true end
        else named[#named + 1] = tostring(a) end
    end
    local why = (not C.in_mog_house() and 'only in the Mog House: the game changes job nowhere else')
        or (not pcall(require, 'packets') and 'Windower\'s packets library is missing')
        or (require('shared/utils/atelier/atelier_tour').active() and 'an Atelier tour is running')
    local me = windower.ffxi.get_player() or {}
    local jobs, all = C.jobs_wanted(named), C.jobs_wanted({'tour'})
    why = why or ((#jobs == 0 or not (me.main_job and me.sub_job)) and 'no job to visit')
        or (#all < 3 and 'needs a third job to move the subjob through')
    if why then say(why) return {ok = false, error = why} end
    local queue = plan(jobs, all, me.main_job, me.sub_job)
    if short then
        -- the jobs named and the way back only
        queue = {}
        for _, short_job in ipairs(jobs) do queue[#queue + 1] = {kind = 'main', main = short_job, sub = me.sub_job ~= short_job and me.sub_job or me.main_job} end
        queue[#queue + 1] = {kind = 'main', main = me.main_job, sub = me.sub_job}
    end
    windower._load_skip = skip
    if gaps then
        -- an odd number of gaps: the last change is the way back
        if #gaps % 2 == 0 then gaps[#gaps + 1] = 15 end
        windower._job_test = {gaps = gaps, alt = jobs[1], home_main = me.main_job, home_sub = me.sub_job, all = all,
            results = {}, load_log = {}, queue = {}, token = 0, parts = parts, deadline = os.time() + 120}
        say(('%d timed change(s) between %s and %s. Stay in the Mog House.'):format(#gaps + 1, jobs[1], me.main_job))
        gap_run(windower._job_test)
        return {ok = true, steps = #gaps + 1}
    end
    windower._job_test = {queue = queue, home_main = me.main_job, home_sub = me.sub_job, all = all, results = {},
        token = 0, nosim = nosim, bare = bare, ghosts = ghosts, deadline = os.time() + STEP_TIMEOUT + QUEUE_WAIT + 120}
    if ghosts then require('shared/utils/debug/ghost_watch').start() end
    local count = #queue
    say(('%d step(s), about %d min. Stay in the Mog House; //gs c jobtest stop to stop.'):format(count, math.ceil(count * 30 / 60)))
    advance()
    return {ok = true, steps = count}
end

return JobTest

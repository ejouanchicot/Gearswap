---============================================================================
--- Atelier Tour - every job exported in game, one job change after another
---============================================================================
--- //gs c atelier tour [JOB ...]   in the Mog House: change to each job (all
---                                 the jobs you have, or the ones named), let
---                                 GearSwap load it, write its Atelier export
---                                 (bags and measured stats included), then
---                                 come back to the job and subjob you had.
--- //gs c atelier tour stop        stop after the job being exported and come back.
---
--- A job change is the packet the game sends when you change job at the
--- Moogle (outgoing 0x100, one field at a time: main job, or subjob). The
--- server only accepts it in the Mog House, so the tour refuses to start,
--- and stops, anywhere else. Each job is exported with the subjob of its
--- main export file when it has one, else with the subjob you started on.
---
--- Every load of the tour replaces the sandbox: the tour's state lives on
--- `windower` (windower._atelier_tour), and each load picks it up again from
--- AtelierExport.after_load (on_load). While it runs, the lockstyle, the macro
--- book and the dual-box job exchange of each load are skipped (active():
--- lockstyle_manager.lua, macrobook_manager.lua, dualbox_manager.lua); the
--- last load, back on your own job, is a normal one.
---
--- @file    shared/utils/atelier/atelier_tour.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-11
---============================================================================

local AtelierTour = {}

local STEP_GAP = 2.5        -- seconds between two packets of one change (subjob, then main job)
local SETTLE = 6            -- seconds a load is given before its export is tried
local EXPORT_TRIES = 12     -- then every 2 s until the bags are read
local JOB_WAIT = 20         -- seconds a load waits for the game to be on the job asked
local STEP_TIMEOUT = 45     -- a job whose load never came is skipped after this
local NEXT_GAP = 2          -- seconds between an export and the next change

local function say(text)
    local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
    if ok and MessageFormatter.show_info then MessageFormatter.show_info('Atelier tour: ' .. text) end
end

local function in_mog_house()
    local info = windower.ffxi.get_info and windower.ffxi.get_info()
    return type(info) == 'table' and info.mog_house == true
end

local function job_id(short)
    local ok, res = pcall(require, 'resources')
    if not (ok and res and res.jobs) then return nil end
    for id, job in pairs(res.jobs) do
        if job.ens == short then return id end
    end
    return nil
end

--- True while a tour runs (a tour that stopped answering ends by itself).
--- @return boolean
function AtelierTour.active()
    local tour = windower._atelier_tour
    return type(tour) == 'table' and os.time() < (tour.deadline or 0)
end

---============================================================================
--- JOB CHANGES
---============================================================================

local function inject(field, short)
    local ok, packets = pcall(require, 'packets')
    local id = job_id(short)
    if not (ok and packets and id) then return false end
    packets.inject(packets.new('outgoing', 0x100, {[field] = id}))
    return true
end

--- The packets that take (main, sub) to (want_main, want_sub). The game never
--- lets the main job and the subjob be the same job, so a subjob in the way
--- moves first (when the two jobs simply swap: to a job of `all` that is
--- neither of them).
--- @return table List of {field, job}
local function steps_to(main, sub, want_main, want_sub, all)
    local steps = {}
    if sub == want_main then
        local park = want_sub
        if want_sub == main then
            for _, short in ipairs(all) do
                if short ~= main and short ~= sub then park = short break end
            end
        end
        steps[#steps + 1] = {'Sub Job', park}
        sub = park
    end
    if main ~= want_main then steps[#steps + 1] = {'Main Job', want_main} end
    if sub ~= want_sub then steps[#steps + 1] = {'Sub Job', want_sub} end
    return steps
end

local function send_steps(steps)
    for i, step in ipairs(steps) do
        coroutine.schedule(function()
            if in_mog_house() then inject(step[1], step[2]) end
        end, (i - 1) * STEP_GAP)
    end
end

---============================================================================
--- WHICH JOBS, WHICH SUBJOB
---============================================================================

local function char_dir()
    return windower.addon_path .. 'data/' .. player.name .. '/'
end

local function has_job(levels, short)
    if type(levels) ~= 'table' then return true end
    return (tonumber(levels[short] or levels[short:lower()]) or 0) > 0
end

--- The jobs to visit: the ones asked for, else every job the character has
--- a level in, and a GearSwap file for either way.
local function jobs_wanted(args)
    local me, list, asked = windower.ffxi.get_player() or {}, {}, {}
    for i = 2, #args do asked[#asked + 1] = args[i]:upper() end
    local ok, res = pcall(require, 'resources')
    if #asked == 0 and ok and res and res.jobs then
        for _, job in pairs(res.jobs) do asked[#asked + 1] = job.ens end
        table.sort(asked)
    end
    for _, short in ipairs(asked) do
        local file = char_dir() .. player.name .. '_' .. short .. '.lua'
        if job_id(short) and has_job(me.jobs, short) and windower.file_exists(file) then list[#list + 1] = short end
    end
    return list
end

--- The subjob a job's export is made with: the one of its main export file
--- (<Char>/atelier/exports/<JOB>_<SUB>.js, `main_sub`), else nil.
local function export_sub(short)
    local dir = require('shared/utils/core/char_paths').atelier_dir('exports')
    local found = nil
    for _, name in ipairs(dir and windower.get_dir(dir) or {}) do
        local sub = name:match('^' .. short .. '_(%u%u%u)%.js$')
        if sub then
            local file = io.open(dir .. '/' .. name, 'rb')
            local text = file and file:read('*a') or ''
            if file then file:close() end
            if not found or text:find('"main_sub":true', 1, true) then found = sub end
        end
    end
    return found
end

---============================================================================
--- THE TOUR
---============================================================================

local advance

local function finish(tour)
    windower._atelier_tour = nil
    say(('done: %d job(s) exported%s. Reload data/atelier.html.'):format(#tour.done,
        #tour.failed > 0 and (', not done: ' .. table.concat(tour.failed, ' ')) or ''))
end

--- Back to the job and subjob of before the tour. The tour ends here, before
--- the change: that last load is a normal one (lockstyle, macro book, dual-box).
local function go_home(tour)
    local me = windower.ffxi.get_player() or {}
    local steps = in_mog_house() and steps_to(me.main_job, me.sub_job, tour.home_main, tour.home_sub, tour.all) or {}
    finish(tour)
    if #steps > 0 then send_steps(steps) else windower.send_command('gs reload') end
end

--- A change that no load answered (a job the server refused): the job is skipped.
local function watch(token, short)
    coroutine.schedule(function()
        local tour = windower._atelier_tour
        if type(tour) ~= 'table' or tour.token ~= token then return end
        tour.failed[#tour.failed + 1] = short
        advance()
    end, STEP_TIMEOUT)
end

advance = function()
    local tour = windower._atelier_tour
    if type(tour) ~= 'table' then return end
    if not in_mog_house() then
        windower._atelier_tour = nil
        return say('stopped: you left the Mog House (' .. #tour.done .. ' job(s) exported)')
    end
    local short = table.remove(tour.queue, 1)
    if not short then return go_home(tour) end
    local me = windower.ffxi.get_player() or {}
    local sub = export_sub(short) or tour.home_sub
    if sub == short or not has_job(me.jobs, sub) then sub = short ~= tour.home_main and tour.home_main or tour.home_sub end
    tour.expect, tour.expect_sub = short, sub
    tour.token = (tour.token or 0) + 1
    tour.deadline = os.time() + STEP_TIMEOUT + 60
    say(('%s/%s (%d left)'):format(short, sub, #tour.queue))
    local steps = steps_to(me.main_job, me.sub_job, short, sub, tour.all)
    if #steps == 0 then return AtelierTour.on_load() end
    send_steps(steps)
    watch(tour.token, short)
end

--- True while the wait started by the load `gen` for the step `token` is still
--- the one to follow (no newer load took over, the tour did not move on).
local function still_mine(token, gen)
    local tour = windower._atelier_tour
    return type(tour) == 'table' and tour.token == token and windower._load_gen == gen
end

local function export_now(token, gen, left)
    if not still_mine(token, gen) then return end
    local tour = windower._atelier_tour
    local me, Slips = windower.ffxi.get_player(), require('shared/utils/atelier/slip_items')
    local ready = me and (me.main_job_level or 0) > 0 and Slips.bags_ready()
    if not ready and left > 0 then
        return coroutine.schedule(function() export_now(token, gen, left - 1) end, 2)
    end
    local ok, rel = pcall(require('shared/utils/atelier/atelier_export').export)
    local list = ok and rel and tour.done or tour.failed
    list[#list + 1] = tour.expect
    tour.token = tour.token + 1     -- this job's watchdog no longer has a say
    coroutine.schedule(advance, NEXT_GAP)
end

--- Wait until the game itself is on the job the tour asked for, then export.
--- GearSwap loads the job's file on the request, sometimes before the game
--- has changed job (2026-10-11: DRK and NIN skipped, their only load came too
--- early to be told from the previous job's): the load is not asked "is this
--- the job", the game is, once a second.
local function wait_for_job(token, gen, left)
    if not still_mine(token, gen) then return end
    local tour, me = windower._atelier_tour, windower.ffxi.get_player() or {}
    if me.main_job == tour.expect and me.sub_job == tour.expect_sub then
        return coroutine.schedule(function() export_now(token, gen, EXPORT_TRIES) end, SETTLE)
    end
    if left > 0 then coroutine.schedule(function() wait_for_job(token, gen, left - 1) end, 1) end
end

--- Called at each load (AtelierExport.after_load): while a tour runs, the
--- load's export is the tour's. A newer load takes the wait over.
--- @return boolean True when a tour runs (the usual export of the load is left out)
function AtelierTour.on_load()
    if not AtelierTour.active() then return false end
    wait_for_job(windower._atelier_tour.token, windower._load_gen, JOB_WAIT)
    return true
end

--- //gs c atelier tour ...
--- @param args table The command's words, from 'tour'
function AtelierTour.handle(args)
    local word = args[2] and args[2]:lower()
    if word == 'stop' then
        if not AtelierTour.active() then return say('no tour is running') end
        windower._atelier_tour.queue = {}
        return say('stopping after this job, then back to ' .. windower._atelier_tour.home_main)
    end
    if AtelierTour.active() then return say('already running (//gs c atelier tour stop)') end
    if not in_mog_house() then return say('only in the Mog House: the game changes job nowhere else') end
    if not pcall(require, 'packets') then return say('Windower\'s packets library is missing') end
    local jobs, me = jobs_wanted(args), windower.ffxi.get_player() or {}
    if #jobs == 0 or not (me.main_job and me.sub_job) then return say('no job to visit (a job needs a level and its GearSwap file, and you a subjob)') end
    -- every job you have: one of them parks the subjob when two jobs swap
    local all = jobs_wanted({'tour'})
    if #all < 3 then return say('needs a third job to move the subjob through') end
    windower._atelier_tour = {queue = jobs, home_main = me.main_job, home_sub = me.sub_job, all = all,
        done = {}, failed = {}, token = 0, deadline = os.time() + STEP_TIMEOUT + 60}
    say(('%d job(s), about %d min. Stay in the Mog House; //gs c atelier tour stop to stop.'):format(#jobs, math.ceil(#jobs * 20 / 60)))
    advance()
end

return AtelierTour

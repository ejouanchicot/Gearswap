---============================================================================
--- Load Gate - deferred load work that a newer load or a job change cancels
---============================================================================
--- A load schedules work for later (watchdog, warp, macro book, lockstyle,
--- dual-box, Atelier export...). GearSwap never cancels a scheduled
--- coroutine, and a counter kept on the sandbox _G is replaced by the next
--- load, so a quick job change used to let the OLD load's work run after the
--- NEW load: a second watchdog, the old job's macro book, an event handler
--- registered too late for GearSwap to drop it at the next reload.
---
--- begin() numbers each load (config_loader, first shared file of every
--- load). defer(delay, fn) runs fn only if, at that moment:
---   - no newer load has started (the number is kept on `windower`, which
---     outlives the sandbox);
---   - the game still reports the main job and subjob this load was for.
--- A skipped task writes a LOAD line to //gs c trace.
---
--- A main job the game does not report YET is another matter. GearSwap loads
--- the job file on the job change request (outgoing 0x100), before the server
--- has answered: for a moment the game still reports the job of before. A task
--- due in that moment (AutoMove, 0.5 s after the load) was dropped as "job
--- changed" and never run, since a main job change alone brings no second
--- load. Seen in game on 2026-10-12 (//gs c jobtest: DRG/SAM to DRK/SAM, one
--- load, AutoMove not started 12 s later). Such a task now waits for the game
--- to be on the load's job, WAIT_STEP at a time, for WAIT_MAX at most.
---
--- @file    shared/utils/core/load_gate.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-30
---============================================================================

local LoadGate = {}

-- Seconds between two looks at the game's job, and how long a task waits for it
local WAIT_STEP, WAIT_MAX = 0.5, 10

--- Start of a load: a new number, and the jobs it is for.
function LoadGate.begin()
    windower._load_gen = (windower._load_gen or 0) + 1
end

local function trace(fmt, ...)
    pcall(function(...) require('shared/utils/debug/trace_log').log('LOAD', fmt, ...) end, ...)
end

--- True while the load numbered `gen`, for main/sub, is still the live one.
--- @param gen number
--- @param main string|nil
--- @param sub string|nil
--- @return boolean, string|nil reason when not
function LoadGate.still_current(gen, main, sub)
    if gen ~= windower._load_gen then return false, 'newer load' end
    local p = windower.ffxi.get_player()
    if not p then return true end
    if main and p.main_job and p.main_job ~= main then return false, 'job changed' end
    -- No subjob reads differently in GearSwap and in the game: compare only
    -- when both name one
    if sub and p.sub_job and p.sub_job ~= sub then return false, 'subjob changed' end
    return true
end

--- Run fn after `delay` seconds, unless a newer load or a job change came
--- in between.
--- @param delay number Seconds
--- @param fn function
--- @param label string Name for the trace
--- @param gen number|nil Load the work belongs to (default: the current
---   one). A module made at load time passes its own, so a call it gets
---   after a newer load has started is dropped as well.
function LoadGate.defer(delay, fn, label, gen)
    gen = gen or windower._load_gen or 0
    -- a diagnostic switch (//gs c jobtest ... skip=<labels>, job_test.lua): the tasks named are left out, to find
    -- by elimination which one keeps something
    local skip = windower._load_skip
    if type(skip) == 'table' and (skip['*'] or skip[tostring(label)]) then
        return trace('%s left out (jobtest skip)', tostring(label))
    end
    local main, sub = player and player.main_job, player and player.sub_job
    local attempt
    attempt = function(waited)
        local ok, why = LoadGate.still_current(gen, main, sub)
        if ok then return fn() end
        -- the game is not on this load's main job yet: wait for it, as long as no newer load starts
        if why == 'job changed' and waited < WAIT_MAX then
            if waited == 0 then trace('%s waits for the game to be on %s', tostring(label), tostring(main)) end
            return coroutine.schedule(function() attempt(waited + WAIT_STEP) end, WAIT_STEP)
        end
        trace('%s skipped (%s)', tostring(label), why)
    end
    coroutine.schedule(function() attempt(0) end, delay)
end

_G.LoadGate = LoadGate

return LoadGate

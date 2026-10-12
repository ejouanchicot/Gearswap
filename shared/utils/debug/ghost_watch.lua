---============================================================================
--- Ghost Watch - scheduled work of an old load that still runs
---============================================================================
--- GearSwap never cancels a scheduled coroutine: work a load scheduled goes on
--- running after a newer load has replaced it, against the old sandbox. A
--- loop that reschedules itself and never notices it was replaced runs for
--- the rest of the session: it keeps its whole load in memory (a few
--- megabytes a job change) and costs its time again at every tick.
---
--- While it is on (//gs c jobtest ... ghosts), install() gives the load being
--- made a `coroutine` of its own whose schedule() notes, when the scheduled
--- function runs, whether the load that scheduled it is still the live one.
--- A call that runs after its load was replaced is counted under the file and
--- line its function was written at, with how long after the replacement it
--- ran. Work ending a few seconds after a job change is normal; a line that
--- still runs minutes later, for load after load, is a ghost.
---
--- It only counts: the function runs as it would have. Nothing of the memory
--- is walked (env_watch.lua says why).
---
--- A diagnostic tool, off unless asked for.
---
--- @file    shared/utils/debug/ghost_watch.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-12
---============================================================================

local GhostWatch = {}

--- Start counting, from the next load on.
function GhostWatch.start()
    windower._ghost_watch = {on = true, began = {}, late = {}}
end

--- Stop counting (the loads already made keep their own `coroutine` until they are replaced).
function GhostWatch.stop()
    if type(windower._ghost_watch) == 'table' then windower._ghost_watch.on = false end
end

--- Where a function was written: "file.lua:line".
local function origin(fn)
    local getinfo = type(debug) == 'table' and debug.getinfo
    if not getinfo or type(fn) ~= 'function' then return '?' end
    local ok, info = pcall(getinfo, fn, 'S')
    if not (ok and type(info) == 'table') then return '?' end
    return (tostring(info.short_src):match('[^/\\]+$') or '?') .. ':' .. tostring(info.linedefined)
end

--- At the start of a load (config_loader, before anything schedules): while the watch is on, this load's
--- sandbox gets a `coroutine` whose schedule() counts the calls that run after the load was replaced.
function GhostWatch.install()
    local watch = windower._ghost_watch
    if type(watch) ~= 'table' or not watch.on then return end
    local gen, real = windower._load_gen or 0, coroutine
    watch.began[gen] = os.time()
    local own = setmetatable({}, {__index = real})
    own.schedule = function(fn, delay)
        local key = origin(fn)
        return real.schedule(function(...)
            if (windower._load_gen or 0) ~= gen then
                local replaced = watch.began[gen + 1]
                local late = replaced and (os.time() - replaced) or 0
                local entry = watch.late[key] or {calls = 0, latest = 0, loads = {}}
                watch.late[key] = entry
                entry.calls = entry.calls + 1
                if late > entry.latest then entry.latest = late end
                entry.loads[gen] = true
            end
            return fn(...)
        end, delay)
    end
    rawset(_G, 'coroutine', own)
end

--- What ran after its load was replaced, the latest first.
--- @return table list of {where, calls, loads (how many loads it ran for), latest (seconds after the replacement)}
function GhostWatch.report()
    local list = {}
    local watch = windower._ghost_watch
    for key, entry in pairs(type(watch) == 'table' and watch.late or {}) do
        local loads = 0
        for _ in pairs(entry.loads) do loads = loads + 1 end
        list[#list + 1] = {where = key, calls = entry.calls, loads = loads, latest = entry.latest}
    end
    table.sort(list, function(a, b) if a.latest ~= b.latest then return a.latest > b.latest end return a.calls > b.calls end)
    return list
end

return GhostWatch

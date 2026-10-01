---============================================================================
--- Trace Log - record what the game really returns, to a file
---============================================================================
--- Offline tests prove the code does what it says; they cannot prove the
--- game gives the values the code assumes. This writes those values, as they
--- happen in play, to <Character>/trace.log, so they can be read afterwards.
---
---   //gs c trace on      start recording (survives reloads, even //lua r gearswap)
---   //gs c trace off     stop
---   //gs c trace clear   empty the file
---   //gs c trace dead ...  watch the functions the dead-code scan found
---                          unused (shared/utils/debug/tombstones.lua)
---   //gs c trace         status
---
--- Callers: TraceLog.log('TAG', 'format %s', ...) - a no-op while off, so the
--- calls can stay in the code.
---
--- While on, every load also writes its steps (tag LOAD: entry file, systems,
--- keys, HUD, alt window, lockstyle, unload) and an ALIVE line every
--- HEARTBEAT seconds (Lua memory, zone, status, counts of frequent events).
--- trace_hooks.lua adds every module read, include, command sent and
--- GearSwap event. After a client crash, the last line tells what was running.
---
--- The file is moved to trace.old.log once it passes MAX_BYTES (checked at
--- each load), so a long session keeps the latest hours plus one old file.
---
--- A diagnostic tool: it prints with add_to_chat directly (CODE_QUALITY §6),
--- so it keeps working when the message system is what is being traced.
---
--- @file    shared/utils/debug/trace_log.lua
--- @author  ejouanchicot
--- @version 1.2
--- @date    Created: 2026-09-25 | Updated: 2026-09-29 (load steps, heartbeat, hooks)
---============================================================================

local TraceLog = {}

local CHAT = 207
local HEARTBEAT = 1    -- seconds between two ALIVE lines
local MAX_BYTES = 10 * 1024 * 1024

local function file_path(name)
    if not (player and player.name and windower and windower.addon_path) then return nil end
    return require('shared/utils/core/char_paths').writable('saved', name or 'trace.log')
end

--- On/off lives on `windower` (outlives gs reload and job changes) and in a
--- marker file next to the log, read once per load: //lua r gearswap resets
--- the whole addon, `windower` table included, and used to switch the trace
--- off without a word right when a reload was the thing being tested.
local function is_on()
    if windower and windower._trace_log_on == nil then
        local marker = file_path('trace.on')
        local f = marker and io.open(marker, 'r')
        windower._trace_log_on = f ~= nil
        if f then f:close() end
    end
    return windower and windower._trace_log_on == true
end

--- Create or delete the marker file.
--- @param on boolean
local function set_marker(on)
    local marker = file_path('trace.on')
    if not marker then return end
    if on then
        local f = io.open(marker, 'w')
        if f then f:write('on') f:close() end
    else
        os.remove(marker)
    end
end

--- Readable form of any value, tables one level deep.
--- @param v any
--- @return string
local function show(v)
    if type(v) ~= 'table' then return tostring(v) end
    local parts = {}
    for k, x in pairs(v) do
        parts[#parts + 1] = tostring(k) .. '=' .. (type(x) == 'table' and '{...}' or tostring(x))
    end
    table.sort(parts)
    return '{' .. table.concat(parts, ', ') .. '}'
end

--- Append one formatted line to a file, opened and closed at once so the line
--- is on disk even if the process dies right after. Uses nothing from the
--- sandbox: trace_hooks' wrappers call it after later loads.
--- @param path string Log file
--- @param job string|nil Main job for the [JOB] column
--- @param tag string Short subject
--- @param text string Line body
function TraceLog.write_line(path, job, tag, text)
    local file = io.open(path, 'a')
    if not file then return end
    file:write(('%s %.2f [%s] %s %s\n'):format(os.date('%H:%M:%S'), os.clock(), tostring(job), tag, text))
    file:close()
end

--- Append one line when tracing is on.
--- @param tag string Short subject ('HUD', 'TP', 'WARP'...)
--- @param fmt string string.format pattern
--- @param ... any Values; tables are expanded one level
function TraceLog.log(tag, fmt, ...)
    if not is_on() then return end
    local path = file_path()
    if not path then return end
    local args = {...}
    for i = 1, select('#', ...) do
        if type(args[i]) == 'table' or args[i] == nil or type(args[i]) == 'boolean' then
            args[i] = show(args[i])
        end
    end
    local ok, text = pcall(string.format, fmt, unpack(args, 1, select('#', ...)))
    if not ok then text = fmt .. ' <format error: ' .. tostring(text) .. '>' end
    TraceLog.write_line(path, player and player.main_job, tag, text)
end

--- The log file path for this character, nil before the player is known.
--- @return string|nil
function TraceLog.path()
    return file_path()
end

--- Move the log to trace.old.log once it passes MAX_BYTES (one old file kept).
function TraceLog.rotate()
    local path = file_path()
    local file = path and io.open(path, 'r')
    if not file then return end
    local size = file:seek('end') or 0
    file:close()
    if size < MAX_BYTES then return end
    local old = file_path('trace.old.log')
    os.remove(old)
    os.rename(path, old)
end

--- Lua memory of the GearSwap addon in KB. The sandbox has no collectgarbage,
--- GearSwap's own globals do.
--- @return string e.g. "mem 48213KB", '' when unavailable
local function memory()
    local G = rawget(_G, 'gearswap')
    local count = type(G) == 'table' and rawget(G, 'collectgarbage')
    if type(count) ~= 'function' then return '' end
    local ok, kb = pcall(count, 'count')
    return ok and (' mem %dKB'):format(kb) or ''
end

--- ALIVE body: sub, memory, zone, status and the frequent events counted by
--- trace_hooks since the previous beat.
--- @return string
local function alive_text()
    local info = windower.ffxi.get_info()
    local hooks = rawget(_G, 'TraceHooks')
    local counts = hooks and hooks.take_counts() or ''
    return ('sub %s%s zone %s %s%s'):format(tostring(player and player.sub_job), memory(),
        tostring(info and info.zone), tostring(player and player.status), counts ~= '' and ' | ' .. counts or '')
end

--- ALIVE every HEARTBEAT seconds while tracing, from the latest load only:
--- the generation counter lives on `windower` because the coroutine of an
--- older load keeps running after a reload.
function TraceLog.start_heartbeat()
    windower._trace_heartbeat_gen = (windower._trace_heartbeat_gen or 0) + 1
    local gen = windower._trace_heartbeat_gen
    local function beat()
        if gen ~= windower._trace_heartbeat_gen or not is_on() then return end
        TraceLog.log('ALIVE', '%s', alive_text())
        coroutine.schedule(beat, HEARTBEAT)
    end
    coroutine.schedule(beat, HEARTBEAT)
end

--- True while recording (for callers that would compute something costly).
--- @return boolean
function TraceLog.enabled()
    return is_on()
end

--- Handle //gs c trace [on|off|clear]
--- @param args table Words after "trace"
--- @return boolean handled
function TraceLog.handle(args)
    local sub = args and args[1] and args[1]:lower() or ''
    if sub == 'dead' then
        -- //gs c trace dead ...: watch the "dead" functions in play (tombstones.lua)
        return require('shared/utils/debug/tombstones').handle({select(2, unpack(args))})
    end
    local path = file_path() or '?'
    if sub == 'on' then
        windower._trace_log_on = true
        set_marker(true)
        pcall(function() require('shared/utils/debug/trace_hooks').install() end)
        TraceLog.log('TRACE', 'started')
        TraceLog.start_heartbeat()
    elseif sub == 'off' then
        TraceLog.log('TRACE', 'stopped')
        windower._trace_log_on = false
        set_marker(false)
    elseif sub == 'clear' then
        local file = io.open(path, 'w')
        if file then file:close() end
    end
    add_to_chat(CHAT, ('[TRACE] %s -> %s'):format(is_on() and 'ON' or 'OFF', path))
    return true
end

_G.TraceLog = TraceLog

return TraceLog

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
---   //gs c trace         status
---
--- Callers: TraceLog.log('TAG', 'format %s', ...) - a no-op while off, so the
--- calls can stay in the code.
---
--- A diagnostic tool: it prints with add_to_chat directly (CODE_QUALITY §6),
--- so it keeps working when the message system is what is being traced.
---
--- @file    shared/utils/debug/trace_log.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-25
---============================================================================

local TraceLog = {}

local CHAT = 207

local function file_path(name)
    if not (player and player.name and windower and windower.addon_path) then return nil end
    return ('%sdata/%s/%s'):format(windower.addon_path, player.name, name or 'trace.log')
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
    local file = io.open(path, 'a')
    if not file then return end
    file:write(('%s %.2f [%s] %s %s\n'):format(os.date('%H:%M:%S'), os.clock(), tostring(player and player.main_job),
        tag, text))
    file:close()
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
    local path = file_path() or '?'
    if sub == 'on' then
        windower._trace_log_on = true
        set_marker(true)
        TraceLog.log('TRACE', 'started')
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

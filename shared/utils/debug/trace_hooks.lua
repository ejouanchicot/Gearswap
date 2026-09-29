---============================================================================
--- Trace Hooks - fine-grained //gs c trace, to find where a client crash hits
---============================================================================
--- A client crash kills the process: the last line of trace.log is the last
--- thing written. The base trace (trace_log.lua) marks load steps and a
--- heartbeat; this adds what happened between them, so the last line names
--- the file, the command or the event running when the game died:
---
---   REQ path     a module read from disk (cache misses only)
---   INC path     an include() (Mote, set files, hooks)
---   CMD text     every command GearSwap sends to Windower (binds, lockstyle...)
---   EV > name    a GearSwap event starts: precast, buff_change, self_command,
---   EV < name    and ends (a > without its < is where it stopped). Callbacks
---                registered by the project go through the same door and are
---                named after their event ('zone change', 'action'...).
---
--- Very frequent events (prerender, chunks, mouse...) are only counted; the
--- heartbeat writes the counts once per second.
---
--- Installed only when the trace is on at load. The sandbox part (REQ, INC)
--- is redone on every load; the engine part (EV, CMD) wraps GearSwap's own
--- functions once and stays until //lua r gearswap, doing nothing while the
--- trace is off. Every wrapper passes arguments and results through untouched.
---
--- @file    shared/utils/debug/trace_hooks.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

local TraceLog = require('shared/utils/debug/trace_log')

local TraceHooks = {}

-- Counted, never written one by one: several per frame or per packet.
local FREQUENT = {
    ['prerender'] = true, ['postrender'] = true, ['mouse'] = true, ['keyboard'] = true,
    ['incoming chunk'] = true, ['outgoing chunk'] = true,
    ['incoming text'] = true, ['outgoing text'] = true, ['time change'] = true,
}

--- {n = count, ...}: results kept even when some are nil.
local function pack(...)
    return {n = select('#', ...), ...}
end

--- What an event is about: spell name, buff name, command text.
--- @param v any First value GearSwap passes to the event
--- @return string
local function detail(v)
    if type(v) == 'string' then return ' ' .. v:sub(1, 80) end
    if type(v) == 'table' and v.english then return ' ' .. tostring(v.english) end
    return ''
end

--- Writer for the engine wrappers. They outlive the load that made them, so
--- they read the path and the job from what persists, not from this sandbox.
--- @param G table GearSwap's own globals
--- @param W table The sandbox windower table (persists across loads)
--- @return function write(tag, text)
local function make_writer(G, W)
    local write_line = TraceLog.write_line
    return function(tag, text)
        if not W._trace_log_on or not W._trace_path then return end
        local p = G.player
        write_line(W._trace_path, p and p.main_job, tag, text)
    end
end

--- EV lines around every GearSwap event, counts for the frequent ones.
local function wrap_events(G, W, write)
    local names = setmetatable({}, {__mode = 'k'})
    W._trace_event_names = names
    W._trace_counts = W._trace_counts or {}

    local register = W.register_event
    W.register_event = function(event, func, ...)
        if type(func) == 'function' then names[func] = tostring(event) end
        return register(event, func, ...)
    end

    local equip_sets = G.equip_sets
    G.equip_sets = function(swap_type, ts, ...)
        if not W._trace_log_on then return equip_sets(swap_type, ts, ...) end
        local name = type(swap_type) == 'string' and swap_type or names[swap_type] or '?'
        if FREQUENT[name] or name == '?' then
            W._trace_counts[name] = (W._trace_counts[name] or 0) + 1
            return equip_sets(swap_type, ts, ...)
        end
        write('EV', '> ' .. name .. detail((...)))
        local results = pack(equip_sets(swap_type, ts, ...))
        write('EV', '< ' .. name)
        return unpack(results, 1, results.n)
    end
end

--- CMD line for every command sent through Windower.
local function wrap_commands(G, W, write)
    local real = G.windower
    local send = real.send_command
    real.send_command = function(command, ...)
        if W._trace_log_on then write('CMD', tostring(command):sub(1, 200)) end
        return send(command, ...)
    end
end

--- REQ and INC lines for this load's sandbox.
local function hook_loads()
    _G.__require_miss_hook = function(path)
        TraceLog.log('REQ', '%s', path)
    end
    local include = rawget(_G, 'include')
    if type(include) == 'function' and not rawget(_G, '__include_traced') then
        _G.__include_traced = true
        _G.include = function(path, ...)
            TraceLog.log('INC', '%s', tostring(path))
            return include(path, ...)
        end
    end
end

--- Install the hooks when the trace is on (called at the top of each load).
--- @return boolean True when installed or already in place
function TraceHooks.install()
    if not TraceLog.enabled() then return false end
    local G = rawget(_G, 'gearswap')
    if type(G) ~= 'table' then return false end
    TraceLog.rotate()
    windower._trace_path = TraceLog.path()
    hook_loads()
    if not G._trace_engine_hooked then
        G._trace_engine_hooked = true
        local write = make_writer(G, windower)
        wrap_events(G, windower, write)
        wrap_commands(G, windower, write)
    end
    return true
end

--- Counts of the frequent events since the last call, then reset.
--- @return string e.g. "prerender=60 incoming chunk=112", '' when none
function TraceHooks.take_counts()
    local counts = windower._trace_counts
    if not counts then return '' end
    local parts = {}
    for name, n in pairs(counts) do parts[#parts + 1] = name .. '=' .. n end
    table.sort(parts)
    windower._trace_counts = {}
    return table.concat(parts, ' ')
end

_G.TraceHooks = TraceHooks

return TraceHooks

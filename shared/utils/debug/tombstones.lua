---============================================================================
--- Tombstones - is "dead" code really dead? Watch it in play before deleting
---============================================================================
--- The dead-code scan (notes/docs-perso/code-mort-2026-10-01.md) lists the
--- functions nothing seems to call. A text search cannot see everything, so
--- before deleting them each one is wrapped while playing: the wrapper writes
--- the first call of each function to <Character>/saved/tombstones.log (and
--- one chat line), then calls the real function. Nothing else changes.
---
---   //gs c trace dead on      watch from now on (kept across reloads)
---   //gs c trace dead off     stop at the next load
---   //gs c trace dead status  functions watched in this load, calls seen
---   //gs c trace dead clear   empty the log
---
--- Targets: tombstone_targets.lua, {module, table, function, file, line}.
--- A module is wrapped when it loads (module_cache.lua calls
--- _G.__require_load_hook after each load), and the ones already loaded
--- when the watch starts are wrapped at once. A function only exists in the
--- jobs that load its module: one session per job played covers them.
---
--- A diagnostic tool: it prints with add_to_chat directly (CODE_QUALITY §6),
--- since the functions it watches are mostly message functions.
---
--- @file    shared/utils/debug/tombstones.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-01 (delete with the dead code)
---============================================================================

local Tombstones = {}

local CHAT = 207
local TARGETS = 'shared/utils/debug/tombstone_targets'

local function saved_path(name)
    if not (player and player.name) then return nil end
    local ok, path = pcall(function()
        return require('shared/utils/core/char_paths').writable('saved', name)
    end)
    return ok and path or nil
end

--- On/off on windower (outlives a gs reload) and in a marker file (outlives
--- //lua reload gearswap), read once per load.
local function is_on()
    if windower._tombstones_on == nil then
        local marker = saved_path('tombstones.on')
        -- character not known yet: ask again later rather than remember "off"
        if not marker then return false end
        local f = io.open(marker, 'r')
        windower._tombstones_on = f ~= nil
        if f then f:close() end
    end
    return windower._tombstones_on == true
end

local function set_marker(on)
    local marker = saved_path('tombstones.on')
    if not marker then return end
    if on then
        local f = io.open(marker, 'w')
        if f then f:write('on') f:close() end
    else
        os.remove(marker)
    end
end

--- Per load: targets by module (lower-case path), what is wrapped, calls seen.
local function state()
    local s = rawget(_G, '_tombstones')
    if s then return s end
    s = {by_module = {}, total = 0, wrapped = {}, wrapped_count = 0, seen = {}}
    -- stored before the targets load: their own load goes through the hook
    _G._tombstones = s
    local ok, targets = pcall(require, TARGETS)
    for _, t in ipairs(ok and type(targets) == 'table' and targets or {}) do
        local key = t[1]:lower()
        s.by_module[key] = s.by_module[key] or {}
        table.insert(s.by_module[key], t)
        s.total = s.total + 1
    end
    return s
end

local function caller()
    local dbg = rawget(_G, 'debug')
    if not (dbg and dbg.traceback) then return 'no traceback in the sandbox' end
    local ok, tb = pcall(dbg.traceback, '', 3)
    if not ok or type(tb) ~= 'string' then return '?' end
    local lines = {}
    for line in tb:gmatch('[^\n]+') do
        if not line:find('traceback') and not line:find('tombstones.lua', 1, true) and #lines < 4 then
            lines[#lines + 1] = (line:gsub('^%s+', ''))
        end
    end
    return table.concat(lines, ' <- ')
end

--- A watched function was called: once per function and per load.
local function hit(t)
    local s = state()
    local key = t[2] .. '.' .. t[3]
    if s.seen[key] then return end
    s.seen[key] = true
    local path = saved_path('tombstones.log')
    local file = path and io.open(path, 'a')
    if file then
        file:write(('%s [%s] CALLED %s (%s:%d) from %s\n'):format(os.date('%Y-%m-%d %H:%M:%S'),
            tostring(player and player.main_job), key, t[4], t[5], caller()))
        file:close()
    end
    add_to_chat(CHAT, ('[TOMBSTONE] %s was called (%s:%d): NOT dead'):format(key, t[4], t[5]))
end

local function wrap_in(tbl, t)
    if type(tbl) ~= 'table' then return false end
    local fn = rawget(tbl, t[3])
    if type(fn) ~= 'function' then return false end
    local s = state()
    if s.wrapped[fn] then return true end
    local wrapper = function(...)
        hit(t)
        return fn(...)
    end
    s.wrapped[wrapper] = true
    tbl[t[3]] = wrapper
    return true
end

--- Wrap the targets of one module (its returned table, and the global table
--- of that name when it is another one).
local function wrap_module(path, result)
    if tostring(path):lower() == TARGETS then return end
    local s = state()
    for _, t in ipairs(s.by_module[tostring(path):lower()] or {}) do
        local done = wrap_in(result, t)
        local global = t[2] ~= '_G' and rawget(_G, t[2]) or (t[2] == '_G' and _G) or nil
        if global and global ~= result then done = wrap_in(global, t) or done end
        if done and not t.counted then
            t.counted = true
            s.wrapped_count = s.wrapped_count + 1
        end
    end
end

--- Start watching in this load when it is on (config_loader.lua, first
--- shared file of every load).
function Tombstones.install()
    if not is_on() or rawget(_G, '_tombstones_installed') then return end
    _G._tombstones_installed = true
    _G.__require_load_hook = function(path, result) pcall(wrap_module, path, result) end
    local cache = rawget(_G, '__require_cache') or {}
    for key, result in pairs(cache) do pcall(wrap_module, key, result) end
end

--- //gs c trace dead [on|off|status|clear]
--- @param args table Words after "dead"
--- @return boolean handled
function Tombstones.handle(args)
    local sub = args and args[1] and args[1]:lower() or 'status'
    if sub == 'on' then
        windower._tombstones_on = true
        set_marker(true)
        Tombstones.install()
    elseif sub == 'off' then
        windower._tombstones_on = false
        set_marker(false)
    elseif sub == 'clear' then
        local path = saved_path('tombstones.log')
        local f = path and io.open(path, 'w')
        if f then f:close() end
    end
    local s = state()
    local calls = 0
    local path = saved_path('tombstones.log')
    local f = path and io.open(path, 'r')
    if f then
        for line in f:lines() do if line:find(' CALLED ') then calls = calls + 1 end end
        f:close()
    end
    add_to_chat(CHAT, ('[TOMBSTONE] %s | watched in this load: %d / %d | calls logged: %d -> %s'):format(
        is_on() and 'ON' or 'OFF', s.wrapped_count, s.total, calls, tostring(path)))
    return true
end

return Tombstones

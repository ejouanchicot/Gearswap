---============================================================================
--- Env Watch - which old loads are still in memory, and what holds them
---============================================================================
--- Every load of a job file gets a new sandbox (_G, modules, sets, states);
--- the one before should be freed. When something that outlives a load keeps a
--- function or a table of it, the whole old sandbox stays in memory: a few
--- megabytes more at every job change, for the rest of the session.
---
--- mark() notes the sandbox of the load being made in a table that does not
--- keep it alive (weak keys, on windower, which outlives the loads).
--- survivors() collects the garbage and says which older loads are still
--- there.
---
--- It does not look for what holds them. A walk of the memory from inside the
--- game (tables, upvalues, environments, from `windower` and the addon's
--- globals) was tried three times on 2026-10-12 and crashed the client twice:
--- it is not done from here any more. scripts/audit/leakprobe.lua replays
--- loads outside the game and walks there, where it can only cost a script.
--- stored_functions() is not such a walk: it opens the fields written on
--- `windower` a few levels deep and names the functions kept there.
---
--- A diagnostic tool, used by //gs c jobtest (job_test.lua). It reads only.
---
--- @file    shared/utils/debug/env_watch.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-12
---============================================================================

local EnvWatch = {}

--- A function of the addon's own globals (the sandbox has no collectgarbage, debug or getfenv of its own).
local function engine(name, field)
    local own = rawget(_G, name)
    if own ~= nil then return field and own[field] or own end
    local G = rawget(_G, 'gearswap')
    local lib = type(G) == 'table' and rawget(G, name) or nil
    return field and type(lib) == 'table' and lib[field] or (not field and lib) or nil
end

local function watched()
    if type(rawget(windower, '_env_watch')) ~= 'table' then
        windower._env_watch = setmetatable({}, {__mode = 'k'})
    end
    return windower._env_watch
end

--- Note the sandbox of the load being made.
function EnvWatch.mark()
    watched()[_G] = windower._load_gen or 0
end

--- The older loads still in memory once the garbage is collected.
--- @return table sorted list of load numbers, nil when the garbage cannot be collected from here
function EnvWatch.survivors()
    local collect = engine('collectgarbage')
    if type(collect) ~= 'function' then return nil end
    collect('collect')
    collect('collect')
    local list = {}
    for env, gen in pairs(watched()) do
        if env ~= _G then list[#list + 1] = gen end
    end
    table.sort(list)
    return list
end

-- The shallow look below: how deep it goes, how many tables it opens, and the size past which a table is left
-- closed. Small on purpose (see the header): it reads a few hundred values, never the memory at large.
local DEPTH, MAX_TABLES, MAX_FIELDS = 4, 3000, 1500

--- The functions the job code has stored on `windower`, which outlives the loads: each one keeps the sandbox of
--- the load that made it. Looked for a few levels deep in the fields written on `windower`, in tables only (no
--- upvalue is read, no function is entered).
--- @return table list of {path, where = 'file.lua:line', load = the load that made it or nil, old = true when
---   that load is no longer the live one}
function EnvWatch.stored_functions()
    local getinfo, getfenv_ = engine('debug', 'getinfo'), engine('getfenv')
    local watch, found, opened, seen = watched(), {}, 0, {}
    seen[watch] = true
    local path = {}
    local function look(value, depth)
        local kind = type(value)
        if kind == 'function' then
            local ok, info = pcall(getinfo, value, 'S')
            if not (ok and type(info) == 'table') or info.what == 'C' then return end
            local ok_e, env = pcall(getfenv_, value)
            local gen = ok_e and type(env) == 'table' and watch[env] or nil
            found[#found + 1] = {path = table.concat(path, '.'), load = gen, old = (ok_e and env ~= _G) or nil,
                where = (tostring(info.short_src):match('[^/\]+$') or '?') .. ':' .. tostring(info.linedefined)}
        elseif kind == 'table' and depth < DEPTH and not seen[value] and opened < MAX_TABLES then
            seen[value] = true
            opened = opened + 1
            local fields = 0
            for k, v in next, value do
                fields = fields + 1
                if fields > MAX_FIELDS then break end
                if type(v) == 'function' or type(v) == 'table' then
                    path[#path + 1] = tostring(k)
                    look(v, depth + 1)
                    path[#path] = nil
                end
            end
        end
    end
    if type(getinfo) ~= 'function' or type(getfenv_) ~= 'function' then return found end
    for k, v in next, windower do
        path[1] = 'windower.' .. tostring(k)
        look(v, 1)
        path[1] = nil
    end
    return found
end

return EnvWatch

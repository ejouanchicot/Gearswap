---============================================================================
--- Atelier Live - the Atelier page talks to GearSwap while the game runs
---============================================================================
--- A small HTTP door on 127.0.0.1 (this PC only), opened by GearSwap itself
--- with the LuaSocket it loads (gearswap.lua: socket = require 'socket';
--- job files reach it as gearswap.socket). data/atelier.html, opened from
--- the disk, asks it:
---
---   GET  /ping                 player, job, subjob, version (+1 at each load)
---   GET  /export               the loaded job's data (AtelierExport.build)
---   POST /save?file=<name>     writes <Char>/saved/<name>: keybind_overrides.lua
---                              or set_overrides.lua only
---   GET  /actions              the job's spells, abilities and weapon skills
---   POST /simulate?kind=&name=  what the job wears for an action (atelier_sim.lua),
---        &target=&status=&s.<Mode>=  without doing it
---   POST /reload[?full=1]      //gs reload (so a saved change is worn now), or the
---                              whole addon: //lua r gearswap
---
--- Every request but the browser's preflight carries the token written in
--- data/atelier/live_<Character>.js, a file only a page on this disk can read:
--- a web site cannot use the door. The door stays open across job loads
--- (windower._atelier_live) and closes with the addon.
---
--- Started by AtelierExport.after_load when //gs c atelier on is set, or by
--- //gs c atelier live.
---
--- @file shared/utils/atelier/atelier_live.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-01
---============================================================================

local AtelierLive = {}

local FIRST_PORT, PORT_TRIES = 52740, 8
local SAVED_FILES = {['keybind_overrides.lua'] = true, ['set_overrides.lua'] = true}
local MAX_BODY = 2 * 1024 * 1024
local POLL_EVERY = 6   -- frames between two looks at the door

local function socket_lib()
    local ok, gs = pcall(function() return gearswap end)
    return ok and type(gs) == 'table' and rawget(gs, 'socket') or nil
end

local function token()
    math.randomseed(os.time() + math.floor(os.clock() * 1000))
    local out = {}
    for i = 1, 32 do out[i] = ('%x'):format(math.random(0, 15)) end
    return table.concat(out)
end

local function live_file(name)
    return windower.addon_path .. 'data/atelier/live_' .. name .. '.js'
end

local function write(path, text)
    local f = io.open(path, 'wb')
    if not f then return false end
    f:write(text)
    f:close()
    return true
end

---============================================================================
--- HTTP
---============================================================================

local function respond(client, status, body)
    local head = {'HTTP/1.1 ' .. status, 'Access-Control-Allow-Origin: *',
        'Access-Control-Allow-Headers: X-Atelier-Token, Content-Type',
        'Access-Control-Allow-Methods: GET, POST, OPTIONS',
        -- a page from the disk asking 127.0.0.1: Chrome's private network preflight
        'Access-Control-Allow-Private-Network: true',
        'Content-Type: application/json; charset=utf-8', 'Content-Length: ' .. #body, 'Connection: close', '', ''}
    client:settimeout(2)
    client:send(table.concat(head, '\r\n') .. body)
end

local function read_request(client)
    client:settimeout(0.3)
    local line = client:receive('*l')
    if not line then return nil end
    local method, target = line:match('^(%u+)%s+(%S+)')
    if not method then return nil end
    local headers = {}
    while true do
        local h = client:receive('*l')
        if not h or h == '' then break end
        local k, v = h:match('^([^:]+):%s*(.-)%s*$')
        if k then headers[k:lower()] = v end
    end
    local n = math.min(tonumber(headers['content-length'] or 0) or 0, MAX_BODY)
    local body = n > 0 and client:receive(n) or ''
    return {method = method, path = target:match('^[^?]*'), query = target:match('%?(.*)$') or '', headers = headers, body = body or ''}
end

-- ?a=1&b=two%20words -> {a = '1', b = 'two words'}
local function query_table(query)
    local out = {}
    for k, v in query:gmatch('([^&=]+)=([^&]*)') do
        local function decode(x) return (x:gsub('+', ' '):gsub('%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)) end
        out[decode(k)] = decode(v)
    end
    return out
end

local function route(req, live)
    if req.method == 'OPTIONS' then return '204 No Content', '' end
    if req.headers['x-atelier-token'] ~= live.token then return '403 Forbidden', '{"error":"token"}' end
    local Export = require('shared/utils/atelier/atelier_export')
    if req.path == '/ping' then
        return '200 OK', Export.json({player = player and player.name, job = player and player.main_job,
            sub = player and player.sub_job, version = live.version})
    end
    if req.path == '/export' then
        local data = Export.build()
        if not data then return '503 Service Unavailable', '{"error":"no job"}' end
        data.live = true
        return '200 OK', Export.json(data)
    end
    if req.path == '/save' and req.method == 'POST' then
        local file = req.query:match('file=([%w_%.]+)')
        if not SAVED_FILES[file] then return '400 Bad Request', '{"error":"file"}' end
        local path = require('shared/utils/core/char_paths').writable('saved', file)
        if not (path and write(path, req.body)) then return '500 Internal Server Error', '{"error":"write"}' end
        return '200 OK', Export.json({ok = true, file = file})
    end
    if req.path == '/actions' then
        return '200 OK', Export.json(require('shared/utils/atelier/atelier_sim').actions())
    end
    if req.path == '/simulate' and req.method == 'POST' then
        local q = query_table(req.query)
        local states = {}
        for k, v in pairs(q) do local name = k:match('^s%.(.+)$'); if name then states[name] = v end end
        local result = require('shared/utils/atelier/atelier_sim').run({kind = q.kind, name = q.name, target = q.target,
            status = q.status, states = states, ignore_recasts = q.recasts ~= '1', tp = q.tp})
        return '200 OK', Export.json(result)
    end
    if req.path == '/reload' and req.method == 'POST' then
        -- ?full=1: the whole addon (lua r gearswap); the door closes with it and the new
        -- GearSwap opens another one (AtelierExport.after_load), the page reads its new file
        local full = req.query:match('full=1') ~= nil
        coroutine.schedule(function() windower.send_command(full and 'lua r gearswap' or 'gs reload') end, 0.3)
        return '200 OK', '{"ok":true}'
    end
    return '404 Not Found', '{"error":"path"}'
end

local function serve(client, live)
    local ok, err = pcall(function()
        local req = read_request(client)
        if req then respond(client, route(req, live)) end
    end)
    client:close()
    if not ok then
        local ok_t, Trace = pcall(require, 'shared/utils/debug/trace_log')
        if ok_t and Trace and Trace.log then pcall(Trace.log, 'ATELIER', 'live: ' .. tostring(err)) end
    end
end

---============================================================================
--- DOOR
---============================================================================

--- Open the door (once per addon load) and look at it every few frames during
--- this file load; a new load counts as a new version for the page.
--- @return number|nil port, string|nil error
function AtelierLive.start()
    if not (player and player.name) then return nil, 'no player' end
    local live = windower._atelier_live
    if not (live and live.server) then
        local socket = socket_lib()
        if not socket then return nil, 'LuaSocket not reachable' end
        local server, port
        for p = FIRST_PORT, FIRST_PORT + PORT_TRIES - 1 do
            server = socket.bind('127.0.0.1', p)
            if server then port = p break end
        end
        if not server then return nil, 'no free port' end
        server:settimeout(0)
        live = {server = server, port = port, token = token(), version = 0}
        windower._atelier_live = live
    end
    live.version = live.version + 1
    -- the page finds the door through this file (one per character: two boxes, two doors)
    write(live_file(player.name), ('window.ATELIER_LIVE = window.ATELIER_LIVE || {};\nATELIER_LIVE[%q] = {port: %d, token: %q};\n')
        :format(player.name, live.port, live.token))
    -- the index lists the live files, so the page asks for those only
    pcall(function() require('shared/utils/atelier/atelier_export').write_index() end)
    -- raw: no refresh of GearSwap's globals at every frame; GearSwap drops it at the
    -- next file load (refresh.lua unregisters the user's events)
    local frame = 0
    windower.raw_register_event('prerender', function()
        frame = frame + 1
        if frame % POLL_EVERY ~= 0 then return end
        local client = live.server:accept()
        while client do
            serve(client, live)
            client = live.server:accept()
        end
    end)
    return live.port
end

return AtelierLive

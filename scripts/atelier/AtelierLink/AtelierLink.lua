---============================================================================
--- AtelierLink - the Atelier page's hand on GearSwap (load, unload, reload)
---============================================================================
--- A Windower addon of its own, so it keeps running while GearSwap is
--- unloaded: data/atelier.html (GearSwap's data folder) asks it, on
--- 127.0.0.1 (this PC only), to load, unload or reload GearSwap. GearSwap's
--- own door (shared/utils/atelier/atelier_live.lua) answers the page's data
--- questions while GearSwap runs; this one only holds the switch.
---
---   GET  /ping                  player, job, subjob
---   POST /gearswap?do=load      //lua load gearswap   (also unload, reload)
---
--- Every request but the browser's preflight carries the token written in
--- GearSwap/data/atelier/link_<Character>.js, a file only a page on this disk
--- can read.
---
--- Installed and loaded by //gs c atelier link (GearSwap copies this file
--- from data/scripts/atelier/AtelierLink/ into addons/AtelierLink/). To load
--- it with the game: add "lua load atelierlink" to Windower's scripts/init.txt.
---
--- @file scripts/atelier/AtelierLink/AtelierLink.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-01
---============================================================================

_addon.name = 'AtelierLink'
_addon.author = 'ejouanchicot'
_addon.version = '1.0'
_addon.commands = {'atelierlink'}

local socket = require('socket')

local FIRST_PORT, PORT_TRIES = 52760, 8
local POLL_EVERY = 6
local DATA = windower.windower_path .. 'addons/GearSwap/data/'
local ACTIONS = {load = 'lua load gearswap', unload = 'lua unload gearswap', reload = 'lua reload gearswap'}

local server, port, token, written_for
local frame = 0

local function write(path, text)
    local f = io.open(path, 'wb')
    if not f then return false end
    f:write(text)
    f:close()
    return true
end

local function json(t)
    local parts = {}
    for k, v in pairs(t) do
        local value = type(v) == 'string' and ('"' .. v:gsub('[%c"\\]', '') .. '"') or tostring(v)
        parts[#parts + 1] = ('"%s":%s'):format(k, value)
    end
    return '{' .. table.concat(parts, ',') .. '}'
end

local function new_token()
    math.randomseed(os.time() + math.floor(os.clock() * 1000))
    local out = {}
    for i = 1, 32 do out[i] = ('%x'):format(math.random(0, 15)) end
    return table.concat(out)
end

-- The file the page reads to find the door, once the character is known
local function write_link_file()
    local p = windower.ffxi.get_player()
    if not (p and p.name and server) or written_for == p.name then return end
    if write(DATA .. 'atelier/link_' .. p.name .. '.js', ('window.ATELIER_LINK = window.ATELIER_LINK || {};\nATELIER_LINK[%q] = {port: %d, token: %q};\n')
        :format(p.name, port, token)) then written_for = p.name end
end

-- A listening socket on that port, or nil when another program holds it. Not socket.bind():
-- it sets SO_REUSEADDR, and on Windows that lets the second box bind the port of the first,
-- whose door then answers both
local function listen_on(p)
    local tcp = socket.tcp()
    if not tcp then return nil end
    if tcp:bind('127.0.0.1', p) and tcp:listen(32) then return tcp end
    tcp:close()
    return nil
end

local function open_door()
    for p = FIRST_PORT, FIRST_PORT + PORT_TRIES - 1 do
        server = listen_on(p)
        if server then port = p break end
    end
    if not server then
        windower.add_to_chat(167, 'AtelierLink: no free port, the page cannot reach the game.')
        return
    end
    server:settimeout(0)
    token = new_token()
    write_link_file()
end

---============================================================================
--- HTTP
---============================================================================

local function respond(client, status, body)
    local head = {'HTTP/1.1 ' .. status, 'Access-Control-Allow-Origin: *',
        'Access-Control-Allow-Headers: X-Atelier-Token, Content-Type',
        'Access-Control-Allow-Methods: GET, POST, OPTIONS',
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
    local n = math.min(tonumber(headers['content-length'] or 0) or 0, 4096)
    if n > 0 then client:receive(n) end
    return {method = method, path = target:match('^[^?]*'), query = target:match('%?(.*)$') or '', headers = headers}
end

local function route(req)
    if req.method == 'OPTIONS' then return '204 No Content', '' end
    if req.headers['x-atelier-token'] ~= token then return '403 Forbidden', '{"error":"token"}' end
    if req.path == '/ping' then
        local p = windower.ffxi.get_player() or {}
        return '200 OK', json({player = p.name or '', job = p.main_job or '', sub = p.sub_job or ''})
    end
    if req.path == '/gearswap' and req.method == 'POST' then
        local command = ACTIONS[req.query:match('do=(%a+)') or '']
        if not command then return '400 Bad Request', '{"error":"do"}' end
        -- after the answer: an unload or reload of GearSwap must not cut this request short
        coroutine.schedule(function() windower.send_command(command) end, 0.2)
        return '200 OK', '{"ok":true}'
    end
    return '404 Not Found', '{"error":"path"}'
end

local function serve(client)
    pcall(function()
        local req = read_request(client)
        if req then respond(client, route(req)) end
    end)
    client:close()
end

---============================================================================
--- EVENTS
---============================================================================

windower.register_event('load', open_door)
windower.register_event('login', function() written_for = nil; coroutine.schedule(write_link_file, 5) end)
windower.register_event('prerender', function()
    if not server then return end
    frame = frame + 1
    if frame % POLL_EVERY ~= 0 then return end
    if not written_for then write_link_file() end
    local client = server:accept()
    while client do
        serve(client)
        client = server:accept()
    end
end)
windower.register_event('unload', function() if server then server:close() end end)
windower.register_event('addon command', function()
    windower.add_to_chat(207, ('AtelierLink: listening on 127.0.0.1:%s for data/atelier.html'):format(tostring(port)))
end)

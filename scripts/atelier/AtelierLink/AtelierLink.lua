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
--- The page's update screen (data/atelier/app/js/update.js) downloads a release
--- itself and hands the files here: a file the browser writes carries the Mark
--- of the Web, and Windows Defender took our own update.js for a trojan that way
--- (2026-10-21). Written by Lua, a file is as a package or git leaves it.
---   GET  /info                  player, the data folder's version, whether it is under git
---   POST /read                  body: paths (one per line) -> per path "<size>\n<bytes>", "-1\n" when missing
---   POST /file?path=<rel>       body: the file's bytes, written under data/
---   POST /remove?path=<rel>     the file removed
---   POST /relink                this addon copied from data/scripts/atelier/AtelierLink/ and
---                               reloaded, then GearSwap reloaded
--- Paths are relative to GearSwap's data folder, never outside it; a data folder
--- under git (the author's) is never written. //atelierlink testroot <folder>
--- serves another data folder (a test install) until the addon reloads.
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
-- an update sends hundreds of requests in a row: while they come, every frame is polled
local BUSY_FRAMES = 120
local MAX_BODY = 8 * 1024 * 1024
local DATA = windower.windower_path .. 'addons/GearSwap/data/'
local ACTIONS = {load = 'lua load gearswap', unload = 'lua unload gearswap', reload = 'lua reload gearswap'}

local server, port, token, written_for
local frame, busy_until = 0, 0
local data = DATA

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

--- A number from a text, below 2^31 - 1 (each step stays under 2^53: exact in Lua's numbers).
local function digest(text, mul)
    local h = 0
    for i = 1, #text do h = (h * mul + text:byte(i)) % 2147483647 end
    return h
end

--- The door's token, 32 hex digits: not from the time alone, the clock to the millisecond, the socket clock and
--- the addresses Lua gave fresh objects mixed four ways, each seeding 8 digits (as GearSwap's atelier_live.lua).
local function new_token()
    local seed = table.concat({tostring(os.time()), tostring(os.clock()), tostring({}), tostring(function() end),
        tostring(socket.gettime and socket.gettime() or ''), tostring({})}, '|')
    local out = {}
    for lane, mul in ipairs({31, 131, 1313, 13131}) do
        math.randomseed(digest(seed .. lane, mul))
        for _ = 1, 8 do out[#out + 1] = ('%x'):format(math.random(0, 15)) end
    end
    return table.concat(out)
end

-- The file the page reads to find the door, once the character is known
-- link_last.js names the character too: a page with no character yet (a fresh package) finds the door by it
local function write_link_file()
    local p = windower.ffxi.get_player()
    if not (p and p.name and server) or written_for == p.name then return end
    local text = ('window.ATELIER_LINK = window.ATELIER_LINK || {};\nATELIER_LINK[%q] = {port: %d, token: %q};\n')
        :format(p.name, port, token)
    if write(data .. 'atelier/link_' .. p.name .. '.js', text) then
        write(data .. 'atelier/link_last.js', text .. ('window.ATELIER_LINK_LAST = %q;\n'):format(p.name))
        written_for = p.name
    end
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

local function response(status, body, content_type)
    -- "null": the origin of a page opened from the disk, the only one the door answers
    local head = {'HTTP/1.1 ' .. status, 'Access-Control-Allow-Origin: null',
        'Access-Control-Allow-Headers: X-Atelier-Token, Content-Type',
        'Access-Control-Allow-Methods: GET, POST, OPTIONS',
        'Access-Control-Allow-Private-Network: true',
        'Content-Type: ' .. (content_type or 'application/json; charset=utf-8'), 'Content-Length: ' .. #body,
        'Connection: close', '', ''}
    return table.concat(head, '\r\n') .. body
end

---============================================================================
--- FILES OF THE DATA FOLDER (the page's update)
---============================================================================

-- A path under data/ as the page sends it (URL-encoded), or nil: no "..", no drive, no backslash, no leading slash
local function safe_rel(rel)
    if type(rel) ~= 'string' then return nil end
    rel = rel:gsub('%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    if rel == '' or #rel > 300 or rel:find('..', 1, true) or rel:sub(1, 1) == '/' or not rel:match('^[%w%._%-/ ]+$') then
        return nil
    end
    return rel
end

local function under_git()
    return windower.dir_exists(data .. '.git')
end

local function read_file(rel)
    local f = io.open(data .. rel, 'rb')
    if not f then return nil end
    local text = f:read('*a')
    f:close()
    return text
end

-- its folders made first, one level at a time
local function write_file(rel, bytes)
    local at = data
    for part in rel:gmatch('([^/]+)/') do
        at = at .. part .. '/'
        if not windower.dir_exists(at) then windower.create_dir(at) end
    end
    return write(data .. rel, bytes)
end

local function info()
    local p = windower.ffxi.get_player() or {}
    local v = read_file('VERSION')
    return json({player = p.name or '', version = v and v:match('^%s*(.-)%s*$') or '', git = under_git()})
end

-- per path asked: "<size>\n<bytes>", or "-1\n" for a path missing or refused
local function read_many(body)
    local out = {}
    for line in (body or ''):gmatch('[^\r\n]+') do
        local rel = safe_rel(line)
        local bytes = rel and read_file(rel)
        out[#out + 1] = bytes and (#bytes .. '\n' .. bytes) or '-1\n'
    end
    return table.concat(out)
end

-- This addon, as the update just left it in data/scripts/, put in addons/AtelierLink/ and loaded again (which
-- ends this copy), then GearSwap reloaded on the new code
local function relink()
    local text = read_file('scripts/atelier/AtelierLink/AtelierLink.lua')
    if not text then return false end
    local dir = windower.windower_path .. 'addons/AtelierLink/'
    if not write(dir .. 'AtelierLink.lua', text) then return false end
    coroutine.schedule(function() windower.send_command('lua reload gearswap; lua reload atelierlink') end, 0.2)
    return true
end

local function file_route(req)
    if req.path == '/info' then return '200 OK', info() end
    if req.method ~= 'POST' then return nil end
    if req.path == '/read' then return '200 OK', read_many(req.body), 'application/octet-stream' end
    if under_git() then return '409 Conflict', '{"error":"git"}' end
    if req.path == '/relink' then
        if relink() then return '200 OK', '{"ok":true}' end
        return '500 Internal Server Error', '{"error":"relink"}'
    end
    local rel = safe_rel(req.query:match('path=([^&]*)'))
    if (req.path == '/file' or req.path == '/remove') and not rel then return '400 Bad Request', '{"error":"path"}' end
    if req.path == '/file' then
        if write_file(rel, req.body or '') then return '200 OK', '{"ok":true}' end
        return '500 Internal Server Error', '{"error":"write"}'
    end
    if req.path == '/remove' then
        os.remove(data .. rel)
        return '200 OK', '{"ok":true}'
    end
    return nil
end

-- The request in a client's bytes so far: the request, nil while it is still arriving, false when it is not one
local function parse_request(buf)
    local head_end = buf:find('\r\n\r\n', 1, true)
    if not head_end then
        if #buf > 16384 then return false end
        return nil
    end
    local head = buf:sub(1, head_end - 1)
    local method, target = head:match('^(%u+)%s+(%S+)')
    if not method then return false end
    local headers = {}
    for line in head:gmatch('\r\n([^\r\n]*)') do
        local k, v = line:match('^([^:]+):%s*(.-)%s*$')
        if k then headers[k:lower()] = v end
    end
    local n = tonumber(headers['content-length'] or 0) or 0
    if n > MAX_BODY then return false end
    if #buf < head_end + 3 + n then return nil end
    return {method = method, path = target:match('^[^?]*'), query = target:match('%?(.*)$') or '', headers = headers,
        body = n > 0 and buf:sub(head_end + 4, head_end + 3 + n) or nil}
end

local function route(req)
    -- a browser always says where a request comes from; a web site's is refused (a page from the disk sends "null")
    local origin = req.headers['origin']
    if origin and origin ~= 'null' then return '403 Forbidden', '{"error":"origin"}' end
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
    local status, body, content_type = file_route(req)
    if status then return status, body, content_type end
    return '404 Not Found', '{"error":"path"}'
end

-- An error is written to data/atelier/link_errors.txt (and said once): the door stays silent otherwise
local said_error = false
local function note_error(where, err)
    local f = io.open(DATA .. 'atelier/link_errors.txt', 'a')
    if f then f:write(os.date('%Y-%m-%d %H:%M:%S ') .. where .. ': ' .. tostring(err) .. '\n'); f:close() end
    if not said_error then
        said_error = true
        windower.add_to_chat(167, 'AtelierLink error (' .. where .. '): ' .. tostring(err))
    end
end

-- Every socket is non-blocking: this runs in the game's frame, and a read or a send that waited (a page that stopped
-- midway, a request of 300 files) froze the whole game (2026-10-21). Each frame takes what has arrived and sends
-- what the socket takes, in bounded pieces; a client still unfinished after CLIENT_SECONDS is dropped.
local CLIENT_SECONDS, ACCEPTS_PER_FRAME = 20, 16
local READ_PIECE, SEND_PIECE = 65536, 262144
local clients = {}

-- One frame of one client; true once it is done (answered, gone, or not a request)
local function step(c)
    if not c.out then
        local got, err, partial = c.sock:receive(READ_PIECE)
        got = got or partial
        if got and #got > 0 then c.buf = c.buf .. got end
        local req = parse_request(c.buf)
        if req == false then return true end
        if req == nil then return err == 'closed' end
        c.out, c.sent = response(route(req)), 0
    end
    local i, err, last = c.sock:send(c.out, c.sent + 1, math.min(c.sent + SEND_PIECE, #c.out))
    c.sent = i or last or c.sent
    return c.sent >= #c.out or err == 'closed'
end

local function poll()
    if not written_for then write_link_file() end
    for _ = 1, ACCEPTS_PER_FRAME do
        local sock = server:accept()
        if not sock then break end
        sock:settimeout(0)
        clients[#clients + 1] = {sock = sock, buf = '', drop_at = socket.gettime() + CLIENT_SECONDS}
        busy_until = frame + BUSY_FRAMES
    end
    for i = #clients, 1, -1 do
        local c = clients[i]
        local ok, done = pcall(step, c)
        if not ok then note_error('request', done) end
        if not ok or done or socket.gettime() > c.drop_at then
            c.sock:close()
            table.remove(clients, i)
        end
    end
    if #clients > 0 then busy_until = frame + BUSY_FRAMES end
end

---============================================================================
--- EVENTS
---============================================================================

windower.register_event('load', open_door)
windower.register_event('login', function() written_for = nil; coroutine.schedule(write_link_file, 5) end)
windower.register_event('prerender', function()
    if not server then return end
    frame = frame + 1
    if frame % POLL_EVERY ~= 0 and frame > busy_until then return end
    local ok, err = pcall(poll)
    if not ok then note_error('poll', err) end
end)
windower.register_event('unload', function() if server then server:close() end end)
windower.register_event('addon command', function(cmd, ...)
    -- a test install's data folder (its page then finds this door in its own atelier/ folder)
    if cmd == 'testroot' then
        local path = table.concat({...}, ' ')
        data = (path == '' or path == 'off') and DATA or (path:gsub('\\', '/'):gsub('/?$', '/'))
        written_for = nil
        write_link_file()
        windower.add_to_chat(207, 'AtelierLink: serving ' .. data)
        return
    end
    windower.add_to_chat(207, ('AtelierLink: listening on 127.0.0.1:%s for %satelier.html'):format(tostring(port), data))
end)

-- for scripts/atelier/atelier_link_test.lua (a Windower addon's return value is not used)
return {route = route, safe_rel = safe_rel}

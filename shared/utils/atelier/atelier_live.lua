---============================================================================
--- Atelier Live - the Atelier page talks to GearSwap while the game runs
---============================================================================
--- A small HTTP door on 127.0.0.1 (this PC only), opened by GearSwap itself
--- with the LuaSocket it loads (gearswap.lua: socket = require 'socket';
--- job files reach it as gearswap.socket). data/atelier.html, opened from
--- the disk, asks it:
---
---   GET  /ping                 player, job, subjob, version (+1 at each load), boot (when
---                              this door was opened: another one after //lua r gearswap)
---   GET  /export               the loaded job's data (AtelierExport.build)
---   GET  /measure              the character's stats, gear and buffs at the last status packet
---                              (AtelierExport.measure): fetched when /ping's `stat` count moves
---   POST /save?file=<name>     writes <Char>/atelier/overrides/<name>: keybind_overrides.lua,
---                              set_overrides.lua, bag_plan.js (the role of each bag and the category of each item,
---                              for the page's bags plan) or list_layout.js (how the page's list of sets is
---                              arranged) only
---   GET  /actions              the job's spells, abilities and weapon skills
---   GET  /sim_buffs            the buffs the job's code reads (Simulate's buff choices)
---   POST /bag_plan              the page's tidy-up plan (id, from bag, to bag, name a line), kept for
---                              //gs c bags (shared/utils/wardrobe/bag_mover.lua)
---   POST /icons?ids=1,2,3      writes the icons of those items the page lacks (pieces you
---                              do not hold: item_icons.lua), at most 300 a call
---   GET  /tpbonus?tp=&main=&sub=&range=&weapons=&buffs=  the TP bonus pieces the job's rules add
---                              to a weaponskill at that TP, and its TP steps (AtelierSim.tp_bonus)
---   POST /simulate?kind=&name=  what the job wears for an action (atelier_sim.lua),
---        &target=&status=&s.<Mode>=  without doing it
---   POST /push?mode=preview|write[&hash=]  a set written into the set file, previewed
---                              first (shared/utils/atelier/set_push.lua)
---   GET  /push_history, POST /push_undo?id=  the pushes, and putting a file back
---   POST /delete?mode=preview|write[&hash=]  a set and its versions taken out of
---                              the set file (set_push.lua)
---   POST /equip?job=           the pieces the page shows for a set, worn now: one line a piece,
---                              slot <tab> name <tab> augments joined by | (equip_pieces)
---   POST /reload[?full=1]      //gs reload (so a saved change is worn now), or the
---                              whole addon: //lua r gearswap
---
--- Every request but the browser's preflight carries the token written in
--- data/atelier/live_<Character>.js, a file only a page on this disk can read:
--- a web site cannot use the door. A request a browser sends from a web site
--- (an Origin other than "null", which is what a page opened from the disk sends)
--- is refused before its token is looked at, and the door closes until the next
--- load after BAD_TOKENS refused tokens in BAD_WINDOW seconds (someone guessing).
--- What it writes is read back as data, never run (shared/utils/core/lua_data.lua):
--- set_overrides.lua and keybind_overrides.lua must be data to be written, and
--- a settings file may only have its values changed (atelier_configs.lua). The door stays open across job loads
--- (windower._atelier_live) and closes with the addon.
---
--- Opened at every GearSwap load (AtelierExport.after_load), for every
--- character: //gs c atelier live off closes it for this character (marker
--- <Char>/atelier/live.off), //gs c atelier live opens it again.
---
--- @file shared/utils/atelier/atelier_live.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-01
---============================================================================

local AtelierLive = {}

local FIRST_PORT, PORT_TRIES = 52740, 8
local SAVED_FILES = {['keybind_overrides.lua'] = true, ['set_overrides.lua'] = true, ['list_layout.js'] = true, ['bag_plan.js'] = true}
local MAX_BODY = 2 * 1024 * 1024
local POLL_EVERY = 6   -- frames between two looks at the door
local BAD_TOKENS, BAD_WINDOW = 30, 60   -- refused tokens that close the door, within that many seconds

local function socket_lib()
    local ok, gs = pcall(function() return gearswap end)
    return ok and type(gs) == 'table' and rawget(gs, 'socket') or nil
end

--- A number from a text, below 2^31 - 1 (each step stays under 2^53: exact in Lua's numbers).
local function digest(text, mul)
    local h = 0
    for i = 1, #text do h = (h * mul + text:byte(i)) % 2147483647 end
    return h
end

--- The door's token: 32 hex digits. Not from the time alone (a page could try the few seeds a known start time
--- leaves): the clock to the millisecond, the socket clock, and the addresses Lua gave fresh objects (the heap
--- is not at the same place from one start to the next), mixed four ways, each seeding 8 digits.
local function token()
    local socket = socket_lib()
    local seed = table.concat({tostring(os.time()), tostring(os.clock()), tostring({}), tostring(function() end),
        tostring(socket and socket.gettime and socket.gettime() or ''), tostring({})}, '|')
    local out = {}
    for lane, mul in ipairs({31, 131, 1313, 13131}) do
        math.randomseed(digest(seed .. lane, mul))
        for _ = 1, 8 do out[#out + 1] = ('%x'):format(math.random(0, 15)) end
    end
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
    -- "null": the origin of a page opened from the disk, the only one the door answers
    local head = {'HTTP/1.1 ' .. status, 'Access-Control-Allow-Origin: null',
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

--- The job a push or a delete is for: the page's ?job= (a job of this character, three letters), else the
--- one loaded in game
local function asked_job(q)
    local job = q.job and q.job:upper()
    if job and job:match('^%u%u%u$') then return job end
    return player and player.main_job
end

-- The slots a piece can be asked for, as the page names them (GearSwap reads ring1 / ear1 as left_ring / left_ear)
local EQUIP_SLOTS = {main = true, sub = true, range = true, ammo = true, head = true, body = true, hands = true, legs = true,
    feet = true, neck = true, waist = true, ear1 = true, ear2 = true, ring1 = true, ring2 = true, back = true}

--- Wears the pieces the page sends, through GearSwap's own //gs equip (it keeps the locked slots locked):
--- they go into a set of their own, taken out again once worn. They stay on until the job's code changes
--- the gear (an action, a status change).
--- @param body string One line a piece: slot, name, augments joined by |, tab separated; the name
---   "empty" takes the slot off
--- @return number How many pieces were asked
local function equip_pieces(body)
    local set, n = {}, 0
    for line in (body or ''):gmatch('[^\r\n]+') do
        local slot, name, augs = line:match('^(%w+)\t([^\t]+)\t?(.*)$')
        if slot and EQUIP_SLOTS[slot] and n < 16 then
            n = n + 1
            if name == 'empty' then set[slot] = empty
            elseif augs ~= '' then
                local list = {}
                for aug in augs:gmatch('[^|]+') do list[#list + 1] = aug end
                set[slot] = {name = name, augments = list}
            else set[slot] = name end
        end
    end
    if n == 0 then return 0 end
    sets.atelier_equip = set
    windower.send_command('gs equip sets.atelier_equip')
    coroutine.schedule(function() if type(sets) == 'table' then sets.atelier_equip = nil end end, 5)
    return n
end

--- A refused token, counted: too many in a short time closes the door until the next load (it opens again then,
--- with a new token).
local function refused_token(live)
    local now = os.time()
    if not live.bad_since or now - live.bad_since > BAD_WINDOW then live.bad_since, live.bad = now, 0 end
    live.bad = live.bad + 1
    if live.bad >= BAD_TOKENS then
        coroutine.schedule(function()
            AtelierLive.stop()
            local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
            if ok and MessageFormatter then
                MessageFormatter.show_warning(('Atelier: %d wrong tokens in %d s, the door is closed until the next load'):format(BAD_TOKENS, BAD_WINDOW))
            end
        end, 0)
    end
    return '403 Forbidden', '{"error":"token"}'
end

local function route(req, live)
    -- a browser always says where a request comes from; a web site's is refused (a page from the disk sends "null")
    local origin = req.headers['origin']
    if origin and origin ~= 'null' then return '403 Forbidden', '{"error":"origin"}' end
    if req.method == 'OPTIONS' then return '204 No Content', '' end
    if req.headers['x-atelier-token'] ~= live.token then return refused_token(live) end
    local Export = require('shared/utils/atelier/atelier_export')
    if req.path == '/ping' then
        -- the alt's job as last exchanged (dualbox_manager.lua AltJobState): the macro book GearSwap
        -- picks at the load depends on it. Not is_alt_online(): the state is only refreshed at a job
        -- exchange, so 30 s after a load it reads offline although the alt is still there
        local alt_state = rawget(_G, 'AltJobState')
        local alt = type(alt_state) == 'table' and alt_state.online ~= nil and alt_state.job or nil
        return '200 OK', Export.json({player = player and player.name, job = player and player.main_job,
            sub = player and player.sub_job, version = live.version, boot = live.boot, alt = alt,
            stat = windower._atelier_stat_seq or 0, rebuild = windower._atelier_rebuild,
            -- when a command last moved things between the bags (//gs c bags go, //gs c wo:
            -- ExportBags.changed): the page reads the bags again
            tidy = windower._bags_changed,
            -- how full each bag is: the page reads the bags again when it changed and has settled
            bags = (function()
                local ok, counts = pcall(function() return require('shared/utils/atelier/atelier_place').bag_counts() end)
                return ok and counts or nil
            end)(),
            -- where the character stands: zone, Mog House, moogles around, bags open there (atelier_place.lua)
            place = (function()
                local ok, place = pcall(function() return require('shared/utils/atelier/atelier_place').read() end)
                return ok and place or nil
            end)()})
    end
    if req.path == '/export' then
        local data = Export.build()
        if not data then return '503 Service Unavailable', '{"error":"no job"}' end
        data.live = true
        return '200 OK', Export.json(data)
    end
    if req.path == '/measure' then
        local char = Export.measure()
        if not char then return '503 Service Unavailable', '{"error":"no measure"}' end
        return '200 OK', Export.json(char)
    end
    if req.path == '/save' and req.method == 'POST' then
        local file = req.query:match('file=([%w_%.]+)')
        if not SAVED_FILES[file] then return '400 Bad Request', '{"error":"file"}' end
        -- the .lua ones are read by GearSwap at each load: data only (set_overrides.lua, key_overrides.lua)
        if file:match('%.lua$') and require('shared/utils/core/lua_data').parse(req.body) == nil then
            return '400 Bad Request', '{"error":"not data"}'
        end
        local CharPaths = require('shared/utils/core/char_paths')
        local path = CharPaths.writable('atelier', file)
        if not (path and write(path, req.body)) then return '500 Internal Server Error', '{"error":"write"}' end
        CharPaths.retire(file)
        return '200 OK', Export.json({ok = true, file = file})
    end
    if req.path == '/actions' then
        return '200 OK', Export.json(require('shared/utils/atelier/atelier_sim').actions())
    end
    if req.path == '/icons' and req.method == 'POST' then
        local ids = {}
        for id in tostring(query_table(req.query).ids or ''):gmatch('%d+') do
            if #ids < 300 then ids[#ids + 1] = tonumber(id) end
        end
        local folder = windower.addon_path .. 'data/atelier/icons/'
        local ok, n = pcall(require('shared/utils/atelier/item_icons').write_missing, ids, folder)
        return '200 OK', Export.json({ok = ok, written = ok and n or 0})
    end
    if req.path == '/sim_buffs' then
        return '200 OK', Export.json(require('shared/utils/atelier/atelier_sim').sim_buffs())
    end
    if req.path == '/tpbonus' then
        local q = query_table(req.query)
        return '200 OK', Export.json(require('shared/utils/atelier/atelier_sim').tp_bonus({tp = q.tp, main = q.main, sub = q.sub, range = q.range, weapons = q.weapons, buffs = q.buffs, worn = q.worn}))
    end
    if req.path == '/simulate' and req.method == 'POST' then
        local q = query_table(req.query)
        local states = {}
        for k, v in pairs(q) do local name = k:match('^s%.(.+)$'); if name then states[name] = v end end
        local result = require('shared/utils/atelier/atelier_sim').run({kind = q.kind, name = q.name, target = q.target,
            status = q.status, states = states, ignore_recasts = q.recasts ~= '1', tp = q.tp, buffs = q.buffs, file = q.file == '1'})
        return '200 OK', Export.json(result)
    end
    if req.path == '/push' and req.method == 'POST' then
        local q, SetPush = query_table(req.query), require('shared/utils/atelier/set_push')
        local job = asked_job(q)
        if not job then return '503 Service Unavailable', '{"error":"no job"}' end
        local result = q.mode == 'write' and SetPush.write(job, req.body, q.hash) or SetPush.preview(job, req.body)
        return '200 OK', Export.json(result)
    end
    if req.path == '/equip' and req.method == 'POST' then
        local q = query_table(req.query)
        -- a job's pieces worn on another job: the game would refuse most of them
        if q.job and player and q.job:upper() ~= player.main_job then return '409 Conflict', '{"error":"job"}' end
        local n = equip_pieces(req.body)
        if n == 0 then return '400 Bad Request', '{"error":"empty"}' end
        return '200 OK', Export.json({ok = true, pieces = n})
    end
    if req.path == '/delete' and req.method == 'POST' then
        local q, SetPush = query_table(req.query), require('shared/utils/atelier/set_push')
        local job = asked_job(q)
        if not job then return '503 Service Unavailable', '{"error":"no job"}' end
        local path = (req.body or ''):match('^%s*(.-)%s*$')
        local result = q.mode == 'write' and SetPush.delete(job, path, q.hash) or SetPush.delete_preview(job, path)
        return '200 OK', Export.json(result)
    end
    if req.path == '/jobtest' then
        -- //gs c jobtest: POST starts or stops it (the body: the command's words), GET says where it is
        local JobTest = require('shared/utils/debug/job_test')
        if req.method ~= 'POST' then return '200 OK', Export.json(JobTest.status()) end
        local words = {}
        for word in (req.body or ''):gmatch('%S+') do words[#words + 1] = word end
        -- a diagnostic tool: its own error is the answer, not an empty reply
        local ok, result = pcall(JobTest.handle, words)
        return '200 OK', Export.json(ok and result or {ok = false, error = tostring(result)})
    end
    if req.path == '/porter_run' and req.method == 'POST' then
        -- //gs c po asked from the page: PorterPacker, then the wardrobes and the refill (porter_run.lua)
        return '200 OK', Export.json(require('shared/utils/wardrobe/porter_run').start())
    end
    if req.path == '/porter_write' and req.method == 'POST' then
        -- PorterPacker's unpack list from the sets in memory: the job loaded in game only
        local job = asked_job(query_table(req.query))
        if not (player and job == player.main_job) then return '409 Conflict', '{"error":"job not loaded"}' end
        local result = require('shared/utils/atelier/porter_lists').write(job)
        if result.ok then result.porterpacker = require('shared/utils/atelier/porter_lists').compare(job) end
        return '200 OK', Export.json(result)
    end
    if req.path == '/bag_plan' and req.method == 'POST' then
        -- the page's tidy-up plan, one move a line; played by //gs c bags go (shared/utils/wardrobe/bag_mover.lua)
        return '200 OK', Export.json(require('shared/utils/wardrobe/bag_mover').set_plan(req.body))
    end
    if req.path == '/config_write' and req.method == 'POST' then
        -- a setting changed in the page: the settings file's whole new text (shared/utils/atelier/atelier_configs.lua)
        local q = query_table(req.query)
        local job = asked_job(q)
        if not (job and player and player.name) then return '503 Service Unavailable', '{"error":"no job"}' end
        return '200 OK', Export.json(require('shared/utils/atelier/atelier_configs').write(player.name, job, q.file or '', req.body, q.hash,
            {slot = q.key, before = q.before, after = q.after}))
    end
    if req.path == '/push_history' then
        return '200 OK', Export.json({list = require('shared/utils/atelier/set_push').history()})
    end
    if req.path == '/push_undo' and req.method == 'POST' then
        return '200 OK', Export.json(require('shared/utils/atelier/set_push').undo(tonumber(query_table(req.query).id)))
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

-- the marker where it is (atelier/live.off, or saved/atelier_live.off before 2026-10-05), or where it goes
local function off_marker(to_write)
    if not (player and player.name) then return nil end
    local CharPaths = require('shared/utils/core/char_paths')
    if to_write then CharPaths.retire('atelier_live.off') return CharPaths.writable('atelier', 'atelier_live.off') end
    return CharPaths.file('atelier', 'atelier_live.off')
end

--- Whether the door may open for this character (no atelier_live.off marker).
--- @return boolean
function AtelierLive.allowed()
    local path = off_marker()
    local f = path and io.open(path, 'r')
    if f then f:close() return false end
    return true
end

--- Close the door, take its file and the page's way to it out.
function AtelierLive.stop()
    local live = windower._atelier_live
    if live and live.server then pcall(function() live.server:close() end) end
    windower._atelier_live = nil
    if player and player.name then os.remove(live_file(player.name)) end
    pcall(function() require('shared/utils/atelier/atelier_export').write_index() end)
end

--- Switch the door for this character: on (open now and at every load) or off.
--- @param on boolean
--- @return number|nil port when opened
function AtelierLive.set(on)
    if on then
        local path = off_marker()
        if path then os.remove(path) end
        if player and player.name then require('shared/utils/core/char_paths').retire('atelier_live.off') end
        return AtelierLive.start()
    end
    local path = off_marker(true)
    if path then write(path, 'Atelier live link off for this character: //gs c atelier live to open it again\n') end
    AtelierLive.stop()
    return nil
end

--- Open the door (once per addon load) and look at it every few frames during
--- this file load; a new load counts as a new version for the page.
--- @return number|nil port, string|nil error
-- A listening socket on that port, or nil when another program holds it. Not socket.bind():
-- it sets SO_REUSEADDR, and on Windows that lets a second box bind the same port as the
-- first, whose door then answers both (the second one's page gets "token" refusals)
local function listen_on(socket, port)
    local server = socket.tcp()
    if not server then return nil end
    if server:bind('127.0.0.1', port) and server:listen(32) then return server end
    server:close()
    return nil
end

function AtelierLive.start()
    if not (player and player.name) then return nil, 'no player' end
    local live = windower._atelier_live
    if not (live and live.server) then
        local socket = socket_lib()
        if not socket then return nil, 'LuaSocket not reachable' end
        local server, port
        for p = FIRST_PORT, FIRST_PORT + PORT_TRIES - 1 do
            server = listen_on(socket, p)
            if server then port = p break end
        end
        if not server then return nil, 'no free port' end
        server:settimeout(0)
        -- boot: a restarted addon opens the same port with the same token and counts its loads from 1
        -- again, so nothing else in /ping tells the page that the addon restarted between two of its
        -- pings (measured 2026-10-10: the door is back within 2 s, the page asks every 2 s)
        live = {server = server, port = port, token = token(), version = 0, boot = os.time()}
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

---============================================================================
--- Test of AtelierLink's request loop (scripts/atelier/AtelierLink/AtelierLink.lua)
---============================================================================
--- The loop runs in the game's frame: it must never wait. Fake non-blocking
--- sockets deliver a request in pieces over several frames, a page stops
--- midway, a big answer leaves in pieces; no call may block, a stalled client
--- is dropped after its time, the others are answered.
---
--- Run from data/: lua5.1 scripts/atelier/atelier_link_loop_test.lua
---
--- @file scripts/atelier/atelier_link_loop_test.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-21
---============================================================================

local done, failed = 0, 0
local function check(what, ok, detail)
    done = done + 1
    if not ok then
        failed = failed + 1
        print('FAILED ' .. what .. (detail and (': ' .. tostring(detail)) or ''))
    end
end

local root = (os.getenv('TEMP') or '.'):gsub('\\', '/') .. '/atelier_link_loop_' .. os.time() .. '/'
local function mkdir(p) os.execute('mkdir "' .. p:gsub('/', '\\'):gsub('\\$', '') .. '" 2>nul') end
mkdir(root .. 'addons/GearSwap/data/atelier')
local f = io.open(root .. 'addons/GearSwap/data/VERSION', 'wb'); f:write('3.9.0\n'); f:close()
local big = string.rep('x', 700000)
f = io.open(root .. 'addons/GearSwap/data/big.js', 'wb'); f:write(big); f:close()

-- A non-blocking socket: `pieces` arrive one per frame (nil = nothing this frame), sends take at most `take` bytes
local now, events, queue = 0, {}, {}
local function fake(pieces, take, close_after)
    local c = {pieces = pieces, take = take or 1e9, out = {}, closed = false}
    function c:settimeout() end
    function c:receive(n)
        local p = table.remove(self.pieces, 1)
        if p == nil and close_after and #self.pieces == 0 then return nil, 'closed', '' end
        if p == nil or p == false then return nil, 'timeout', '' end
        return nil, 'timeout', p
    end
    function c:send(s, i, j)
        local last = math.min(j, i + self.take - 1)
        self.out[#self.out + 1] = s:sub(i, last)
        return last
    end
    function c:close() self.closed = true end
    return c
end
package.loaded['socket'] = {
    gettime = function() return now end,
    tcp = function() return {bind = function() return true end, listen = function() return true end,
        settimeout = function() end, close = function() end, accept = function() return table.remove(queue, 1) end} end,
}
_addon = {}
windower = {windower_path = root, ffxi = {get_player = function() return {name = 'Hero'} end},
    dir_exists = function(p) return os.rename(p, p) ~= nil end, create_dir = mkdir,
    register_event = function(name, fn) events[name] = fn end, send_command = function() end, add_to_chat = function() end}
coroutine.schedule = function() end

dofile('scripts/atelier/AtelierLink/AtelierLink.lua')
events.load()
local token = io.open(root .. 'addons/GearSwap/data/atelier/link_Hero.js'):read('*a'):match('token: "(%x+)"')
local function frames(n) for _ = 1, n do now = now + 0.016; events.prerender() end end
local function answer(c) return table.concat(c.out) end

-- a request arriving in four pieces, one empty frame between
local body = 'VERSION\nbig.js'
local raw = 'POST /read HTTP/1.1\r\nOrigin: null\r\nX-Atelier-Token: ' .. token .. '\r\nContent-Length: ' .. #body .. '\r\n\r\n' .. body
local slow = fake({raw:sub(1, 20), false, raw:sub(21, 60), raw:sub(61, #raw - 3), false, raw:sub(#raw - 2)}, 100000)
-- a page that stops after its headers: its body never comes
local stalled = fake({'POST /file?path=x.lua HTTP/1.1\r\nX-Atelier-Token: ' .. token .. '\r\nContent-Length: 5000\r\n\r\nabc'})
-- a plain ping
local ping = fake({'GET /ping HTTP/1.1\r\nX-Atelier-Token: ' .. token .. '\r\n\r\n'})
queue = {slow, stalled, ping}

local t0 = os.clock()
frames(60)
check('a frame never waits', os.clock() - t0 < 2, os.clock() - t0)
check('the ping is answered at once', answer(ping):find('"player":"Hero"', 1, true) ~= nil, answer(ping):sub(1, 80))
check('the ping socket is closed', ping.closed)
local a = answer(slow)
check('the request in pieces is answered in full', a:sub(-(#big + 30)):find('700000\n' .. big, 1, true) ~= nil, #a)
check('the big answer left in several pieces', #slow.out >= 7, #slow.out)
check('VERSION in the answer', a:find('6\n3.9.0\n', 1, true) ~= nil)
check('the stalled client still waits within its time', not stalled.closed)
now = now + 25
frames(1)
check('the stalled client is dropped after its time', stalled.closed)
check('nothing written by the stalled request', io.open(root .. 'addons/GearSwap/data/x.lua') == nil)

-- not a request: dropped without an answer
local junk = fake({string.rep('z', 20000)})
queue = {junk}
frames(2)
check('a stream that is no request is dropped', junk.closed and #junk.out == 0)

local e = io.open(root .. 'addons/GearSwap/data/atelier/link_errors.txt')
check('no error noted', e == nil, e and e:read('*a'))
if e then e:close() end
os.execute('rmdir /s /q "' .. root:gsub('/', '\\'):gsub('\\$', '') .. '" 2>nul')
print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

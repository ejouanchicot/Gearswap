---============================================================================
--- Test of the live link's /export once the bags moved (shared/utils/atelier/atelier_live.lua route)
--- Run from data/: lua5.1 scripts/atelier/live_export_test.lua
--- @file scripts/atelier/live_export_test.lua
--- @author ejouanchicot
--- @date Created: 2026-10-24
---============================================================================
-- Offline check of atelier_live.lua's /export once the bags moved: the spread export is started and the page told
-- "building", never a build in one go unless the spread one cannot start. Run from GearSwap/data with lua5.1.
package.path = './?.lua;' .. package.path
windower = {ffxi = {get_player = function() return {name = 'Tetsouo'} end}, addon_path = './'}
player = {name = 'Tetsouo', main_job = 'WAR', sub_job = 'SAM'}

local calls = {}
local Export = {state = nil, enabled_v = true}
function Export.enabled() return Export.enabled_v end
function Export.spread_result() return Export.state, Export.state == 'ready' and '{"sets":1}' or nil end
function Export.export_spread(no_file) calls[#calls + 1] = 'spread no_file=' .. tostring(no_file); Export.state = Export.on_spread end
function Export.build() calls[#calls + 1] = 'build'; return {sets = 1} end
function Export.json() return '{"sets":1,"live":true}' end
package.loaded['shared/utils/atelier/atelier_export'] = Export
local BAGS = '20,80'
package.loaded['shared/utils/atelier/atelier_place'] = {bag_counts = function() return BAGS end}
local NOW = 1000
os.time = function() return NOW end

local src = assert(io.open('shared/utils/atelier/atelier_live.lua')):read('*a')
src = src:gsub('return AtelierLive%s*$', 'return route')
local route = assert(loadstring(src, 'atelier_live'))()
local live = {token = 't'}
local function get() return route({method = 'GET', path = '/export', query = '', headers = {['x-atelier-token'] = 't'}}, live) end

local fails = 0
local function case(name, setup, want_status, want_calls)
    calls = {}; setup()
    local status = get()
    local got = table.concat(calls, ', ')
    local ok = status:sub(1, 3) == want_status and got == want_calls
    if not ok then fails = fails + 1 end
    print((ok and 'ok   ' or 'FAIL ') .. name .. ': ' .. status .. ' | ' .. got)
end
-- the first look (a ping) is no move: an /export right after it is not kept waiting
local function ping() return route({method = 'GET', path = '/ping', query = '', headers = {['x-atelier-token'] = 't'}}, live) end
player.name = 'Tetsouo'
calls = {}; ping(); Export.state = nil; Export.on_spread = 'building'
case('page just opened, bags never moved: no wait', function() end, '503', 'spread no_file=false')
case('built after the load, bags unchanged', function() Export.state = 'ready' end, '200', '')
case('still building', function() Export.state = 'building' end, '503', '')
case('bags moved: spread started, page told building', function() Export.state = nil; Export.on_spread = 'building' end, '503', 'spread no_file=false')
case('bags moved, export switch off: no file', function() Export.state = nil; Export.on_spread = 'building'; Export.enabled_v = false end, '503', 'spread no_file=true')
case('spread done at once: its result', function() Export.state = nil; Export.on_spread = 'ready'; Export.enabled_v = true end, '200', 'spread no_file=false')
case('spread cannot start: built here as before', function() Export.state = nil; Export.on_spread = nil end, '200', 'spread no_file=false, build')
case('bags just moved: wait, no export started', function() Export.state = nil; Export.on_spread = 'building'; BAGS = '19,80'; NOW = NOW + 1 end, '503', '')
case('2 s later, still moving: wait', function() Export.state = nil; BAGS = '18,80'; NOW = NOW + 2 end, '503', '')
case('calm for 4 s: the spread export starts', function() Export.state = nil; NOW = NOW + 4 end, '503', 'spread no_file=false')
case('a ping sees the bags move, /export 1 s later waits', function() Export.state = nil; BAGS = '17,80'; ping(); NOW = NOW + 1 end, '503', '')
case('pings saw them still for 5 s: no wait at /export', function() Export.state = nil; NOW = NOW + 5; ping() end, '503', 'spread no_file=false')
case('a zone (no counts) then counts again: that is a move, it waits', function() Export.state = nil; NOW = NOW + 10; BAGS = nil; ping(); BAGS = '17,80'; NOW = NOW + 1; ping() end, '503', '')
print(fails == 0 and 'ALL OK' or (fails .. ' FAILED'))
os.exit(fails == 0 and 0 or 1)

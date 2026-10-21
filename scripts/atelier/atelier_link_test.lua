---============================================================================
--- Test of the AtelierLink addon's file doors (scripts/atelier/AtelierLink/AtelierLink.lua)
---============================================================================
--- The page's update hands its files to AtelierLink: /info, /read, /file,
--- /remove, in a Windower made of a temporary folder. Paths outside data/ are
--- refused, a data folder under git is never written, bytes come back as sent.
---
--- Run from data/: lua5.1 scripts/atelier/atelier_link_test.lua
---
--- @file scripts/atelier/atelier_link_test.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-21
---============================================================================

local done, failed = 0, 0
local function check(what, got, want)
    done = done + 1
    if got ~= want then
        failed = failed + 1
        print(('FAILED %s: got %s, wanted %s'):format(what, tostring(got), tostring(want)))
    end
end

local root = (os.getenv('TEMP') or '.'):gsub('\\', '/') .. '/atelier_link_test_' .. os.time() .. '/'
local function mkdir(p) os.execute('mkdir "' .. p:gsub('/', '\\'):gsub('\\$', '') .. '" 2>nul') end
local function is_dir(p) return os.rename(p, p) ~= nil end
mkdir(root .. 'addons/GearSwap/data/atelier')

_addon = {}
windower = {
    windower_path = root,
    ffxi = {get_player = function() return {name = 'Hero', main_job = 'WAR', sub_job = 'SAM'} end},
    dir_exists = function(p) return is_dir(p) end,
    create_dir = function(p) mkdir(p) end,
    register_event = function() end,
    send_command = function() end,
    add_to_chat = function() end,
}
coroutine.schedule = function() end
package.loaded['socket'] = {tcp = function() return nil end, gettime = function() return 0 end}

local Link = dofile('scripts/atelier/AtelierLink/AtelierLink.lua')
local data = root .. 'addons/GearSwap/data/'
local function call(method, path, body)
    local p, q = path:match('^([^?]*)%??(.*)$')
    return Link.route({method = method, path = p, query = q, headers = {}, body = body})
end

local f = io.open(data .. 'VERSION', 'wb'); f:write('4.0.0\r\n'); f:close()
local status, body = call('GET', '/info')
check('info answers', status, '200 OK')
check('info version', body:match('"version":"([^"]*)"'), '4.0.0')
check('info not under git', body:match('"git":(%a+)'), 'false')

local bytes = 'a\r\nb\0c\n'
check('write a nested file', (call('POST', '/file?path=shared%2Fnew%2Fdeep%2Ffile.lua', bytes)), '200 OK')
local st, out, ctype = call('POST', '/read', 'shared/new/deep/file.lua\nmissing.lua\nVERSION')
check('read answers bytes', ctype, 'application/octet-stream')
check('read: bytes as written, missing as -1', out, #bytes .. '\n' .. bytes .. '-1\n' .. '7\n4.0.0\r\n')

for _, bad in ipairs({'..%2Fescape.lua', 'shared%2F..%2F..%2Fx', '%2Fabs.lua', 'C%3A%2Fx.lua', 'a%5Cb.lua', ''}) do
    check('refused path ' .. bad, (call('POST', '/file?path=' .. bad, 'x')), '400 Bad Request')
end
check('refused path read as missing', select(2, call('POST', '/read', '../VERSION')), '-1\n')

check('remove a file', (call('POST', '/remove?path=shared/new/deep/file.lua')), '200 OK')
check('removed file reads as missing', select(2, call('POST', '/read', 'shared/new/deep/file.lua')), '-1\n')

mkdir(data .. '.git')
check('info under git', select(2, call('GET', '/info')):match('"git":(%a+)'), 'true')
check('no write under git', (call('POST', '/file?path=x.lua', 'x')), '409 Conflict')
check('no remove under git', (call('POST', '/remove?path=VERSION')), '409 Conflict')
check('reading still works under git', select(2, call('POST', '/read', 'VERSION')), '7\n4.0.0\r\n')
check('unknown door', (call('GET', '/nothing')), '404 Not Found')

os.execute('rmdir /s /q "' .. root:gsub('/', '\\'):gsub('\\$', '') .. '" 2>nul')
print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

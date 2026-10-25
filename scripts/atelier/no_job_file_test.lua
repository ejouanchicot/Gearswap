---============================================================================
--- Test of data/default.lua (shared/entry/no_job_file.lua): a job with no file
---============================================================================
--- GearSwap's sandbox played as refresh.lua does it (one environment, include and require setfenv'd to it), a fake
--- LuaSocket (gearswap.socket) and a temporary Windower folder for what the door writes: default.lua's get_sets
--- opens the door and says so in the chat; /ping says nofile, /export is refused, /addjob makes the job.
---
--- Run from data/: lua5.1 scripts/atelier/no_job_file_test.lua
---
--- @file scripts/atelier/no_job_file_test.lua
--- @author ejouanchicot
--- @date Created: 2026-10-25
---============================================================================
local done, failed = 0, 0
local function check(what, got, want)
    done = done + 1
    if got ~= want then failed = failed + 1; print(('FAILED %s: got %s, wanted %s'):format(what, tostring(got), tostring(want))) end
end
local function win(p) return (p:gsub('/', '\\')) end
local root = (os.getenv('TEMP') .. '/no_job_file_test_' .. os.time() .. '/'):gsub('\\', '/')
os.execute('mkdir "' .. win(root .. 'data/atelier') .. '" 2>nul')
os.execute('mkdir "' .. win(root .. 'data/Kaories') .. '" 2>nul')

-- the fake socket: a server whose accept() hands the queued requests, a client that reads one and keeps the answer
local queue, answers = {}, {}
local function client(raw)
    local lines, pos = {}, 1
    for l in (raw .. '\n'):gmatch('([^\n]*)\n') do lines[#lines + 1] = l end
    return {settimeout = function() end, close = function() end,
        receive = function(_, how) if how == '*l' then local l = lines[pos]; pos = pos + 1; return l end return '' end,
        send = function(_, text) answers[#answers + 1] = text end}
end
local socket = {gettime = os.time, tcp = function()
    return {bind = function() return 1 end, listen = function() return 1 end, settimeout = function() end, close = function() end,
        accept = function() return table.remove(queue, 1) end}
end}

local prerender, chat = nil, {}
local windower = {addon_path = root, windower_path = root, ffxi = setmetatable({get_player = function() return {name = 'Kaories'} end},
    {__index = function() return function() return nil end end}),
    raw_register_event = function(name, fn) if name == 'prerender' then prerender = fn end return 1 end,
    register_event = function() return 1 end, unregister_event = function() end, send_command = function() end,
    add_to_chat = function(_, text) chat[#chat + 1] = text end,
    get_dir = function() return {} end, dir_exists = function() return true end, create_dir = function() end,
    file_exists = function(p) local f = io.open(p, 'rb') if f then f:close() return true end return false end,
    text = {}, prim = {}}
local env = {}
local function load_in_env(path)
    if path:sub(-4) ~= '.lua' then path = path .. '.lua' end
    local f = assert(loadfile(path))
    setfenv(f, env)
    return f()
end
for k, v in pairs({gearswap = {socket = socket}, windower = windower, include = load_in_env, require = load_in_env,
    player = {name = 'Kaories', main_job = 'WHM', sub_job = 'SCH'}, string = string, math = math, table = table, os = os, io = io,
    type = type, tostring = tostring, tonumber = tonumber, pairs = pairs, ipairs = ipairs, next = next, select = select,
    unpack = unpack, pcall = pcall, error = error, assert = assert, setmetatable = setmetatable, getmetatable = getmetatable,
    rawget = rawget, rawset = rawset, coroutine = {schedule = function() end}, loadstring = loadstring, dofile = dofile,
    print = function(text) chat[#chat + 1] = 'print: ' .. tostring(text) end, add_to_chat = windower.add_to_chat,
    T = function(t) return t or {} end, S = function(t) return t or {} end, L = function(t) return t or {} end}) do env[k] = v end
env._G = env

-- the keys the last job file kept down for the next load (keybind_manager.lua unbind_all)
windower._keybind_manager_bound = {['^f1'] = 'gs c cycle CureMode', ['!f2'] = 'gs c afflatus'}
load_in_env('default.lua')
local ok, err = pcall(env.get_sets)
check('get_sets runs', ok, true)
if not ok then print('  ' .. tostring(err)) end
check('the flag is set', env.AtelierNoJobFile, true)
check('the door is open', prerender ~= nil, true)
check('the last job keys are released', next(windower._keybind_manager_bound), nil)
local unbinds = 0
for _, command in pairs((windower._command_queue or {}).by_key or {}) do
    if command:find('^unbind ') then unbinds = unbinds + 1 end
end
check('  through the paced queue', unbinds, 2)
local f = io.open(root .. 'data/atelier/live_Kaories.js', 'rb')
local door = f and f:read('*a') or ''
if f then f:close() end
local token = door:match('token: "(%x+)"')
check('the door file names a token', token ~= nil, true)
local said = table.concat(chat, '\n')
check('the chat says there is no file', said:find('no file for WHM/SCH', 1, true) ~= nil, true)

local function ask(method, target)
    answers = {}
    queue[1] = client(('%s %s HTTP/1.1\nx-atelier-token: %s\n'):format(method, target, token or ''))
    for _ = 1, 6 do prerender() end
    return answers[1] or ''
end
local ping = ask('GET', '/ping')
check('/ping answers', ping:match('^HTTP/1.1 (%d+)'), '200')
check('/ping says nofile', ping:find('"nofile":true', 1, true) ~= nil, true)
check('/ping names the job', ping:find('"job":"WHM"', 1, true) ~= nil, true)
check('/export refused', ask('GET', '/export'):match('^HTTP/1.1 (%d+)'), '503')
check('/simulate refused', ask('POST', '/simulate?kind=x'):match('^HTTP/1.1 (%d+)'), '503')
-- /addjob reaches job_adder (no template in the temporary folder: its own refusal, as an answer)
local add = ask('POST', '/addjob?job=WHM')
check('/addjob answers', add:match('^HTTP/1.1 (%d+)'), '200')
check('/addjob reached job_adder', add:find('"error":"template"', 1, true) ~= nil, true)
check('/reload answers', ask('POST', '/reload'):match('^HTTP/1.1 (%d+)'), '200')

os.execute('rmdir /s /q "' .. win(root) .. '" 2>nul')
print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

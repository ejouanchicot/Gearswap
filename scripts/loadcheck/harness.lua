---============================================================================
--- Load Check harness - one GearSwap job load played outside the game
---============================================================================
--- Simulates GearSwap's include/pathsearch with the real res/ files, runs the
--- entry file, get_sets() and the work scheduled in the first 10 seconds, and
--- prints tagged lines that check_load.py reads:
---   timings, files loaded (and loaded twice), send_command count, memory kept,
---   ENTRY LOAD ERROR / GET_SETS ERROR / SCHED_ERROR, CHAT (what the player would read),
---   SHARED_* (Lua's own tables changed), WINDOWER_LIB_IN_SANDBOX, PINS_SANDBOX
---   (a function of this load reachable from windower.*: it would survive a reload),
---   CHARREAD (every character file read), PCALL_FAIL.
--- Writes fp_<Player>_<MAIN>.txt (sets, states, commands, globals) in the
--- current folder, to compare two versions of the code.
---
--- Never run on the real folder: it writes saved/ files like the game does.
--- check_load.py runs it on a copy.
---
--- usage: lua5.1 harness.lua <Player> <MAIN> <SUB> <root of the copy, with addons/ and res/>
---
--- @file scripts/loadcheck/harness.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-17
---============================================================================
local ROOT = (arg[4] or os.getenv('LOADCHECK_ROOT') or error('root of the copy missing')):gsub('\\', '/'):gsub('/?$', '/')
local GS = ROOT .. 'addons/GearSwap/'
local PLAYER, MAIN, SUB = arg[1], arg[2], arg[3]
local CHAT = {}
local function chat(...) local parts = {} for i = 1, select('#', ...) do parts[#parts + 1] = tostring((select(i, ...))) end CHAT[#CHAT + 1] = table.concat(parts, ' ') end
local clock = os.clock

local stats, order = {}, {}
local stack = {}
local pcall_fail = {}
local sends = 0
SENT = {}
local scheduled = {}
local events = 0

local function exists(p) local f = io.open(p, 'rb') if f then f:close() return true end return false end

-- resources: real Windower res files, loaded lazily and timed
local res_time = {}
local res = setmetatable({}, {__index = function(t, k)
    local p = ROOT .. 'res/' .. k .. '.lua'
    if not exists(p) then return nil end
    local t0 = clock()
    local v = dofile(p)
    res_time[k] = clock() - t0
    rawset(t, k, v)
    return v
end})

-- generic stub: indexing yields stubs, calling yields a stub
local function stub()
    local s = {}
    return setmetatable(s, {
        __index = function(t, k) local v = stub(); rawset(t, k, v); return v end,
        __call = function() return stub() end,
    })
end

local player = {name = PLAYER, main_job = MAIN, sub_job = SUB, main_job_full = MAIN, sub_job_full = SUB,
    main_job_level = 99, sub_job_level = 53, id = 1, index = 1, status = 'Idle', status_id = 0,
    buffs = {}, hp = 1500, mp = 1500, tp = 0, max_hp = 1500, max_mp = 1500, hpp = 100, mpp = 100,
    vitals = {hp = 1500, mp = 1500, tp = 0, max_hp = 1500, max_mp = 1500, hpp = 100, mpp = 100},
    skills = {}, merits = {}, job_points = {}, equipment = {}, in_combat = false, target_index = 0}

local function items_bag()
    local b = {max = 80, count = 0, enabled = true}
    for i = 1, 80 do b[i] = {id = 0, count = 0, status = 0, slot = i, extdata = ''} end
    return b
end
local BAGS = {'inventory', 'safe', 'storage', 'temporary', 'locker', 'satchel', 'sack', 'case',
    'wardrobe', 'safe2', 'wardrobe2', 'wardrobe3', 'wardrobe4', 'wardrobe5', 'wardrobe6', 'wardrobe7', 'wardrobe8'}
local get_items_calls = 0

local ffxi = setmetatable({
    get_player = function() return {name = PLAYER, main_job = MAIN, sub_job = SUB, main_job_level = 99,
        sub_job_level = 53, id = 1, index = 1, status = 0, buffs = {}, vitals = player.vitals,
        skills = {}, merits = {}, job_points = {}, jobs = {}} end,
    get_items = function(bag)
        get_items_calls = get_items_calls + 1
        if bag then return items_bag() end
        local t = {max_gil = 0, gil = 0, equipment = {}}
        for _, n in ipairs(BAGS) do t[n] = items_bag() end
        return t
    end,
    get_party = function() return {p0 = {name = PLAYER, mob = {id = 1, index = 1, x = 0, y = 0, z = 0}}, party1_count = 1} end,
    get_info = function() return {zone = 1, logged_in = true, language = 'English', server = 1, mog_house = false} end,
    get_mob_by_target = function(t) if t == 'me' then return {id = 1, index = 1, name = PLAYER, x = 0, y = 0, z = 0, status = 0} end end,
    get_mob_by_id = function() return nil end,
    get_mob_by_index = function() return nil end,
    get_ability_recasts = function() return {} end,
    get_spell_recasts = function() return {} end,
    get_spells = function() return {} end,
    get_abilities = function() return {job_abilities = {}, weapon_skills = {}} end,
    get_key_items = function() return {} end,
    get_mob_array = function() return {} end,
    get_bag_info = function() return {max = 80, count = 0, enabled = true} end,
}, {__index = function() return function() return nil end end})

local windower = setmetatable({
    addon_path = GS, windower_path = ROOT, ffxi = ffxi,
    send_command = function(c) sends = sends + 1 SENT[#SENT+1] = tostring(c) end,
    add_to_chat = function(_, msg) chat(msg) end,
    register_event = function() events = events + 1 return events end,
    raw_register_event = function() events = events + 1 return events end,
    unregister_event = function() end,
    file_exists = exists,
    dir_exists = function(p) return true end,
    create_dir = function() end,
    get_dir = function() return {} end,
    get_windower_settings = function() return {ui_x_res = 1920, ui_y_res = 1080, x_res = 1920, y_res = 1080} end,
    text = stub(), prim = stub(), chat = stub(), packets = stub(),
    get_windower_settings = function() return {ui_x_res = 1920, ui_y_res = 1080, x_res = 1920, y_res = 1080} end,
    play_sound = function() end, get_mouse_position = function() return 0, 0 end,
}, {})

local function obj() -- texts/prims object
    local o = {}
    return setmetatable(o, {__index = function(t, k) return function(self, ...) return self == o and nil or nil end end})
end
local texts = {new = function() return obj() end, destroy = function() end}

-- env
local env = {}
local function pathsearch(str)
    local dirs = {GS .. 'libs-dev/', GS .. 'libs/', GS .. 'data/' .. PLAYER .. '/', GS .. 'data/common/', GS .. 'data/', ROOT .. 'addons/libs/'}
    for _, d in ipairs(dirs) do if exists(d .. str) then return d .. str end end
end

local loaded_libs = {}
local function include_user(str, into)
    if type(str) ~= 'string' then error('bad include ' .. tostring(str), 2) end
    str = str:lower()
    if loaded_libs[str] then return loaded_libs[str] end
    if str:sub(-4) ~= '.lua' then str = str .. '.lua' end
    local path = pathsearch(str)
    if not path then error('Cannot find the include file (' .. str .. ')', 2) end
    local key = path:gsub('^' .. GS:gsub('%p', '%%%0'), '')
    local s = stats[key]
    if not s then s = {count = 0, incl = 0, compile = 0, child = 0, bytes = 0} stats[key] = s order[#order + 1] = key end
    s.count = s.count + 1
    local WATCH = {['song_rotation_manager.lua'] = 'BRDSongConfig', ['message_colors.lua'] = 'RegionConfig',
        ['ui_formatter.lua'] = 'UIConfig', ['ui_manager.lua'] = 'UIConfig', ['ui_sections.lua'] = 'UIConfig'}
    local wname = WATCH[key:match('[^/]+$')]
    if wname and s.count == 1 then print(('WATCH first load %s: _G.%s %s'):format(key:match('[^/]+$'), wname, rawget(env, wname) and 'set' or 'NIL')) end
    local phase = rawget(env, '__require_cache_installed') and 'post' or 'pre'
    s[phase] = (s[phase] or 0) + 1
    if phase == 'post' and s.count > 1 then
        local who = {}
        for lvl = 2, 6 do local i = debug.getinfo(lvl, 'Sl') if i and i.short_src ~= 'harness.lua' then who[#who+1] = i.short_src:match('[^/\]+$') .. ':' .. i.currentline end end
        s.callers = s.callers or {}
        local w = table.concat(who, ' < ')
        s.callers[w] = (s.callers[w] or 0) + 1
    end
    local t0 = clock()
    local f, err = loadfile(path)
    local t1 = clock()
    s.compile = s.compile + (t1 - t0)
    if not f then error('Error loading file (' .. str .. '): ' .. err, 2) end
    local fh = io.open(path, 'rb') s.bytes = fh:seek('end') fh:close()
    stack[#stack + 1] = key
    local function finish(...)
        table.remove(stack)
        local dt = clock() - t0
        s.incl = s.incl + dt
        if #stack > 0 then stats[stack[#stack]].child = stats[stack[#stack]].child + dt end
        return ...
    end
    if into and type(into) == 'table' then
        setmetatable(into, {__index = env})
        setfenv(f, into)
        pcall(f, into)
        return finish(into)
    end
    setfenv(f, env)
    return finish(f())
end

local function logged_pcall(fn, ...)
    local r = {pcall(fn, ...)}
    if not r[1] then
        local msg = tostring(r[2]):sub(1, 400)
        pcall_fail[msg] = (pcall_fail[msg] or 0) + 1
    end
    return unpack(r)
end


local READS = {}
local function note_read(path, how)
    path = tostring(path):gsub('\\', '/')
    if path:find('/data/' .. PLAYER .. '/', 1, true) or path:lower():find('/data/' .. PLAYER:lower() .. '/', 1, true) then
        READS[#READS + 1] = how .. ' ' .. path
    end
end
local real_open = io.open
local io_proxy = setmetatable({open = function(path, mode, ...)
    if not mode or mode:find('r') then note_read(path, 'io.open') else note_read(path, 'WRITE') end
    return real_open(path, mode, ...)
end}, {__index = io})
local function dofile_proxy(path) note_read(path, 'dofile') return dofile(path) end
local empty = {}
local gearswap = {windower = windower, res = res, default_slot_map = {}, encumbrance_table = {}, pathsearch = function(t) return pathsearch(t[1]) end, gearswap_disabled = false}
local cor = {
    schedule = function(fn, delay) scheduled[#scheduled + 1] = {fn = fn, delay = tonumber(delay) or 0} end,
    sleep = function() end,
    create = coroutine.create, resume = coroutine.resume, yield = coroutine.yield, status = coroutine.status, wrap = coroutine.wrap,
    running = coroutine.running, close = function() end,
}

-- Minimal stand-ins for Windower's tables/sets/lists libs (its own libs need
-- Windower's patched Lua: methods on literals and booleans)
table.unpack = table.unpack or unpack
local function count(t) local n = 0 for _ in pairs(t) do n = n + 1 end return n end
local TM = {}
for k, v in pairs(table) do TM[k] = v end
TM.contains = function(t, v) for _, x in pairs(t) do if x == v then return true end end return false end
TM.length = count
TM.empty = function(t) return next(t) == nil end
TM.keyset = function(t) local r = {} for k in pairs(t) do r[k] = true end return r end
TM.copy = function(t) local r = {} for k, v in pairs(t) do r[k] = v end return setmetatable(r, getmetatable(t)) end
TM.update = function(t, o) for k, v in pairs(o or {}) do t[k] = v end return t end
TM.extend = function(t, o) for _, v in ipairs(o or {}) do t[#t + 1] = v end return t end
TM.map = function(t, f) local r = {} for k, v in pairs(t) do r[k] = f(v) end return r end
TM.filter = function(t, f) local r = {} for k, v in pairs(t) do if f(v) then r[k] = v end end return r end
TM.with = function(t, k, v) for _, x in pairs(t) do if type(x) == 'table' and x[k] == v then return x end end end
TM.find = function(t, v) for k, x in pairs(t) do if x == v then return k end end end
TM.append = function(t, v) t[#t + 1] = v return t end
TM.last = function(t) return t[#t] end
TM.clear = function(t) for k in pairs(t) do t[k] = nil end return t end
TM.it = function(t) local k return function() local v k, v = next(t, k) return v end end
TM.add = function(t, v) t[v] = true return t end
TM.tostring = function(t) return '{}' end
local TMETA = {__index = TM}
local T = function(t) return setmetatable(t or {}, TMETA) end
local SM = setmetatable({contains = function(s, v) return rawget(s, v) == true end, add = function(s, v) rawset(s, v, true) return s end,
    remove = function(s, v) rawset(s, v, nil) return s end, length = count, empty = function(s) return next(s) == nil end,
    it = function(s) local k return function() k = next(s, k) return k end end}, {__index = TM})
local S = function(t) local s = setmetatable({}, {__index = SM}) for _, v in pairs(t or {}) do s[v] = true end return s end
local LM = setmetatable({contains = TM.contains, append = TM.append, length = function(l) return #l end,
    last = TM.last, it = function(l) local i = 0 return function() i = i + 1 return l[i] end end}, {__index = TM})
local L = function(t) local l = setmetatable({}, {__index = LM}) for i, v in ipairs(t or {}) do l[i] = v end l.n = #l return l end
local Q = L
local SMETA = getmetatable('')
local strx = {startswith = function(s, p) return s:sub(1, #p) == p end, endswith = function(s, p) return p == '' or s:sub(-#p) == p end,
    contains = function(s, p) return s:find(p, 1, true) ~= nil end, trim = function(s) return (s:gsub('^%s+', ''):gsub('%s+$', '')) end,
    split = function(s, sep) local r = L{} for part in (s .. sep):gmatch('(.-)' .. sep:gsub('%p', '%%%0')) do r:append(part) end return r end,
    ucfirst = function(s) return s:sub(1, 1):upper() .. s:sub(2) end, slice = function(s, i, j) return s:sub(i, j) end}
for k, v in pairs(strx) do string[k] = string[k] or v end

for k, v in pairs({
    gearswap = gearswap, _global = {debug_mode = false}, _settings = {debug_mode = false}, _addon = {name = 'GearSwap'},
    equip = function() end, cancel_spell = function() end, change_target = function() end, cast_delay = function() end,
    print_set = function() end, set_combine = function(...) local r = {} for i = 1, select('#', ...) do local s = select(i, ...) if type(s) == 'table' then for a, b in pairs(s) do r[a] = b end end end return r end,
    disable = function() end, enable = function() end, send_command = function(c) sends = sends + 1 SENT[#SENT+1] = tostring(c) end,
    windower = windower, include = include_user, require = include_user,
    midaction = function() return false end, pet_midaction = function() return false end,
    set_language = function() end, show_swaps = function() end, debug_mode = false, include_path = function() end,
    register_unhandled_command = function() end, move_spell_target = function() end, language = 'english',
    string = string, math = math, table = table, T = T, S = S, L = L, Q = Q, set = SM, list = LM, queue = LM,
    pack = {}, functions = {}, os = os, texts = texts, bit = {band = function(a, b) return 0 end},
    type = type, tostring = tostring, tonumber = tonumber, pairs = pairs, ipairs = ipairs, print = chat,
    add_to_chat = function(_, msg) chat(msg) end, unpack = unpack, next = next, select = select, lua_base_path = GS,
    empty = empty, file = {}, loadstring = loadstring, assert = assert, error = error, pcall = logged_pcall,
    io = io_proxy, dofile = dofile_proxy, debug = debug, coroutine = cor, setmetatable = setmetatable,
    getmetatable = getmetatable, rawset = rawset, rawget = rawget, _libs = {},
    buffactive = {}, player = player, world = {area = 'Nowhere', zone = 'Nowhere', weather_element = 'None', day_element = 'Fire'},
    pet = {isvalid = false}, fellow = {isvalid = false}, alliance = {{count = 1}}, party = {count = 1},
    sets = {naked = {}},
}) do env[k] = v end
env._G = env
-- windower libs that the job code may require by name
loaded_libs['resources'] = res
loaded_libs['texts'] = texts
loaded_libs['packets'] = stub()
loaded_libs['config'] = stub()
loaded_libs['sets'] = stub()
loaded_libs['files'] = stub()
loaded_libs['extdata'] = stub()
loaded_libs['chat'] = stub()

-- ==== extra probes: shared tables, windower keys, memory ====
local SHARED = {string = string, table = table, math = math, os = os, io = io, coroutine = coroutine, debug = debug}
local shared_before = {}
for name, t in pairs(SHARED) do
    local snap = {}
    for k, v in pairs(t) do snap[k] = v end
    shared_before[name] = snap
end
local win_before = {}
for k in pairs(windower) do win_before[k] = true end
for _, r in ipairs({'items','spells','buffs','job_abilities','weapon_skills','jobs','monster_abilities','zones','elements','skills','item_descriptions','ability_recasts','spell_recasts','bags','slots','statuses','regions','weather','days','slips','key_items'}) do local _ = res[r] end
collectgarbage('collect') collectgarbage('collect')
local MEM0 = collectgarbage('count')

-- ============================================================
local entry = ('%s_%s.lua'):format(PLAYER, MAIN)
local T0 = clock()
local ok, err = pcall(include_user, entry)
if not ok then print('ENTRY LOAD ERROR', err) end
local t_file = clock() - T0
local t1 = clock()
if env.get_sets then
    local ok2, err2 = pcall(env.get_sets)
    if not ok2 then print('GET_SETS ERROR', err2) end
end
local t_getsets = clock() - t1

-- scheduled work (first 10 s)
local t2 = clock()
local ran = 0
table.sort(scheduled, function(a, b) return a.delay < b.delay end)
local sched_times = {}
local i = 1
while i <= #scheduled and ran < 400 do
    local s = scheduled[i]
    if s.delay <= 10 then
        local ts = clock()
        local sok, serr = pcall(s.fn)
        local d = clock() - ts
        sched_times[#sched_times + 1] = {d = d, delay = s.delay, err = (not sok) and tostring(serr):sub(1, 120) or nil,
            src = debug.getinfo(s.fn, 'S').short_src .. ':' .. debug.getinfo(s.fn, 'S').linedefined}
        ran = ran + 1
    end
    i = i + 1
end
local t_sched = clock() - t2
-- work still waiting when the 10 s are over: a reload then would leave it to run against this load's sandbox
local pending = {}
for n = i, #scheduled do
    local s = scheduled[n]
    local info = debug.getinfo(s.fn, 'S')
    local key = info.short_src:match('[^/\\]+$') .. ':' .. info.linedefined
    pending[key] = math.max(pending[key] or 0, s.delay)
end

-- ============================================================
print(('%s %s/%s  file=%.0fms  get_sets=%.0fms  scheduled(<=10s, %d runs)=%.0fms'):format(PLAYER, MAIN, SUB, t_file * 1000, t_getsets * 1000, ran, t_sched * 1000))
local nfiles, nloads, bytes, compile = 0, 0, 0, 0
for _, k in ipairs(order) do local s = stats[k] nfiles = nfiles + 1 nloads = nloads + s.count bytes = bytes + s.bytes * s.count compile = compile + s.compile end
print(('files=%d  loads=%d  bytes read=%.1f KB  compile=%.0fms  send_command=%d  events=%d  get_items=%d'):format(nfiles, nloads, bytes / 1024, compile * 1000, sends, events, get_items_calls))
local rt = 0 for k, v in pairs(res_time) do rt = rt + v end
local rl = {} for k, v in pairs(res_time) do rl[#rl + 1] = ('%s=%.0fms'):format(k, v * 1000) end
print('res loaded (offline parse, game has them preloaded): ' .. table.concat(rl, ' '))

local list = {}
for _, k in ipairs(order) do local s = stats[k] s.key = k s.self = s.incl - s.child list[#list + 1] = s end
table.sort(list, function(a, b) return a.self > b.self end)
print('\n-- top self time --')
for n = 1, math.min(25, #list) do local s = list[n]
    print(('%7.1fms self %7.1fms incl  x%-3d %6.1fKB  %s'):format(s.self * 1000, s.incl * 1000, s.count, s.bytes / 1024, s.key)) end
table.sort(list, function(a, b) return a.count > b.count end)
print('\n-- loaded more than once --')
for _, s in ipairs(list) do if s.count > 1 then print(('x%-3d pre=%-3d post=%-3d %6.1fms  %s'):format(s.count, s.pre or 0, s.post or 0, s.incl * 1000, s.key))
    for w, c in pairs(s.callers or {}) do print('        ' .. c .. 'x  ' .. w) end end end
table.sort(sched_times, function(a, b) return a.d > b.d end)
print('\n-- slowest scheduled --')
for n = 1, math.min(10, #sched_times) do local s = sched_times[n]
    print(('%7.1fms @%.1fs %s %s'):format(s.d * 1000, s.delay, s.src, s.err or '')) end
print('\n-- pcall failures (harness fidelity) --')
local pf = {} for m, c in pairs(pcall_fail) do pf[#pf + 1] = {m = m, c = c} end
table.sort(pf, function(a, b) return a.c > b.c end)
for n = 1, math.min(15, #pf) do print(('x%d %s'):format(pf[n].c, pf[n].m)) end

-- fingerprint for before/after comparison
local function dump(v, depth, seen)
    depth = depth or 0 seen = seen or {}
    if type(v) ~= 'table' then return type(v) == 'function' and 'fn' or tostring(v) end
    if seen[v] or depth > 6 then return '<ref>' end
    seen[v] = true
    local keys = {} for k in pairs(v) do keys[#keys+1] = tostring(k) end table.sort(keys)
    local out = {}
    for _, k in ipairs(keys) do local val = v[k] if val == nil then val = v[tonumber(k)] end out[#out+1] = k .. '=' .. dump(val, depth + 1, seen) end
    return '{' .. table.concat(out, ',') .. '}'
end
local fp = io.open('fp_' .. PLAYER .. '_' .. MAIN .. '.txt', 'w')
fp:write('SETS ', dump(env.sets), string.char(10))
local st = {}
for k, v in pairs(env.state or {}) do st[#st+1] = k .. '=' .. tostring(type(v) == 'table' and v.value) end
table.sort(st) fp:write('STATE ', table.concat(st, ' '), string.char(10))
local sent = {} for _, c in ipairs(SENT) do sent[#sent+1] = c end table.sort(sent)
fp:write('SENT ', table.concat(sent, string.char(10)), string.char(10))
local g = {} for k, v in pairs(env) do g[#g+1] = k .. ':' .. type(v) end table.sort(g)
fp:write('GLOBALS ', table.concat(g, ' '), string.char(10))
fp:close()

-- ==== extra probes report ====
local function line(tag, s) print(tag .. ' ' .. s) end
for name, t in pairs(SHARED) do
    local snap = shared_before[name]
    for k, v in pairs(t) do
        if snap[k] == nil then line('SHARED_ADDED', name .. '.' .. tostring(k))
        elseif snap[k] ~= v then line('SHARED_CHANGED', name .. '.' .. tostring(k)) end
    end
    for k in pairs(snap) do if t[k] == nil then line('SHARED_REMOVED', name .. '.' .. tostring(k)) end end
end
local wk = {}
for k in pairs(windower) do if not win_before[k] then wk[#wk + 1] = tostring(k) end end
table.sort(wk)
line('WINDOWER_KEYS', #wk .. ' ' .. table.concat(wk, ' '))
for _, k in ipairs(order) do
    if k:find('^%.%./libs/') or k:find('addons/libs/') then line('WINDOWER_LIB_IN_SANDBOX', k) end
end
for _, s in ipairs(sched_times) do if s.err then line('SCHED_ERROR', s.src .. ' ' .. s.err) end end
for m, c in pairs(pcall_fail) do line('PCALL_FAIL', c .. 'x ' .. m) end
for key, delay in pairs(pending) do line('PENDING', ('%s in %.1f s'):format(key, delay)) end
collectgarbage('collect') collectgarbage('collect')
local MEM1 = collectgarbage('count')
local gcount = 0 for _ in pairs(env) do gcount = gcount + 1 end
line('MEMORY', ('%.0f KB kept after load+scheduled, %d globals'):format(MEM1 - MEM0, gcount))
local fl = io.open('files_' .. PLAYER .. '_' .. MAIN .. '_' .. SUB .. '.txt', 'w')
for _, k in ipairs(order) do fl:write(k, '\t', stats[k].count, '\t', stats[k].bytes, '\n') end
fl:close()
-- functions of this load reachable from windower.*: they pin this sandbox after a reload
do
    local seen = {}
    local function walk(v, path, depth)
        if depth > 5 then return end
        if type(v) == 'function' then
            local ok, fe = pcall(getfenv, v)
            if ok and fe == env then line('PINS_SANDBOX', path) end
            local i = 1
            while true do
                local name, up = debug.getupvalue(v, i)
                if not name then break end
                if type(up) == 'table' or type(up) == 'function' then walk(up, path .. '^' .. name, depth + 1) end
                i = i + 1
            end
            return
        end
        if type(v) ~= 'table' or seen[v] or v == env then return end
        seen[v] = true
        for k, x in pairs(v) do walk(x, path .. '.' .. tostring(k), depth + 1) end
        local mt = getmetatable(v)
        if type(mt) == 'table' then walk(mt, path .. '<mt>', depth + 1) end
    end
    for _, k in ipairs(wk) do walk(windower[k], 'windower.' .. k, 0) end
end

for _, r in ipairs(READS) do line('CHARREAD', r) end
-- strip the colour codes: the report shows what the player reads
for _, m in ipairs(CHAT) do
    m = m:gsub('[\30\31].', ''):gsub('\\cs%([%d, ]*%)', ''):gsub('\\cr', ''):gsub('[%z\1-\9\11-\31]', ''):gsub('\n', ' / ')
    line('CHAT', m)
end
for _, k in ipairs(order) do if k:lower():find('data/' .. PLAYER:lower() .. '/', 1, true) then line('CHARREAD', 'include ' .. k) end end

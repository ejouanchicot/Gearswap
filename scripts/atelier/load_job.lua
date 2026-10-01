---============================================================================
--- Atelier offline export - load one job outside the game and export it
---============================================================================
--- Plays GearSwap's part (include paths, sandbox globals, Windower's table,
--- set, list and string helpers), loads <Char>_<JOB>.lua, runs get_sets() and
--- the work scheduled in the first 10 seconds, then writes the job's Atelier
--- file through shared/utils/atelier/atelier_export.lua, as //gs c atelier
--- does in game. What only the game knows (bags, buffs, party) is empty.
---
--- Run by atelier_all.py:
---   lua5.1 load_job.lua <Character> <JOB> <SUB> <ffxi_path>
---
--- @file    scripts/atelier/load_job.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-01
---============================================================================

local PLAYER, MAIN, SUB, FFXI = arg[1], arg[2], arg[3], arg[4]
local DATA = arg[0]:gsub('\\', '/'):match('^(.*)/scripts/atelier/[^/]*$') or '.'
local GS = DATA:match('^(.*/)data$') or (DATA .. '/../')
local ROOT = GS .. '../../'

local function exists(p) local f = io.open(p, 'rb') if f then f:close() return true end return false end
local function win(p) return (p:gsub('/', '\\')) end

-- Windower resources, read from its res/ folder when first asked for
local res = setmetatable({}, {__index = function(t, k)
    local p = ROOT .. 'res/' .. k .. '.lua'
    if not exists(p) then return nil end
    local v = dofile(p)
    rawset(t, k, v)
    return v
end})

-- Anything not played here: every field and call answers another stand-in
local function stub()
    return setmetatable({}, {
        __index = function(t, k) local v = stub() rawset(t, k, v) return v end,
        __call = function() return stub() end,
    })
end

local vitals = {hp = 1500, mp = 1500, tp = 0, max_hp = 1500, max_mp = 1500, hpp = 100, mpp = 100}
local player = {name = PLAYER, main_job = MAIN, sub_job = SUB, main_job_full = MAIN, sub_job_full = SUB,
    main_job_level = 99, sub_job_level = 53, id = 1, index = 1, status = 'Idle', status_id = 0,
    buffs = {}, hp = 1500, mp = 1500, tp = 0, max_hp = 1500, max_mp = 1500, hpp = 100, mpp = 100,
    vitals = vitals, skills = {}, merits = {}, job_points = {}, equipment = {}, in_combat = false, target_index = 0}

local function empty_bag()
    local b = {max = 80, count = 0, enabled = true}
    for i = 1, 80 do b[i] = {id = 0, count = 0, status = 0, slot = i, extdata = ''} end
    return b
end
local BAGS = {'inventory', 'safe', 'storage', 'temporary', 'locker', 'satchel', 'sack', 'case',
    'wardrobe', 'safe2', 'wardrobe2', 'wardrobe3', 'wardrobe4', 'wardrobe5', 'wardrobe6', 'wardrobe7', 'wardrobe8'}

local ffxi = setmetatable({
    get_player = function() return {name = PLAYER, main_job = MAIN, sub_job = SUB, main_job_level = 99,
        sub_job_level = 53, id = 1, index = 1, status = 0, buffs = {}, vitals = vitals,
        skills = {}, merits = {}, job_points = {}, jobs = {}} end,
    get_items = function(bag)
        if bag then return empty_bag() end
        local t = {max_gil = 0, gil = 0, equipment = {}}
        for _, n in ipairs(BAGS) do t[n] = empty_bag() end
        return t
    end,
    get_party = function() return {p0 = {name = PLAYER, mob = {id = 1, index = 1, x = 0, y = 0, z = 0}}, party1_count = 1} end,
    get_info = function() return {zone = 1, logged_in = true, language = 'English', server = 1, mog_house = false} end,
    get_mob_by_target = function(t) if t == 'me' then return {id = 1, index = 1, name = PLAYER, x = 0, y = 0, z = 0, status = 0} end end,
    get_ability_recasts = function() return {} end,
    get_spell_recasts = function() return {} end,
    get_spells = function() return {} end,
    get_abilities = function() return {job_abilities = {}, weapon_skills = {}} end,
    get_key_items = function() return {} end,
    get_mob_array = function() return {} end,
    get_bag_info = function() return {max = 80, count = 0, enabled = true} end,
}, {__index = function() return function() return nil end end})

local function get_dir(p)
    local list = {}
    local h = io.popen('dir /b "' .. win(p) .. '" 2>nul')
    if h then for line in h:lines() do list[#list + 1] = line end h:close() end
    return list
end

local windower = {
    addon_path = GS, windower_path = ROOT, ffxi_path = FFXI, ffxi = ffxi,
    send_command = function() end, add_to_chat = function() end,
    register_event = function() return 1 end, raw_register_event = function() return 1 end,
    unregister_event = function() end,
    file_exists = exists, dir_exists = function() return true end,
    create_dir = function(p) os.execute('mkdir "' .. win(p) .. '" 2>nul') end,
    get_dir = get_dir,
    get_windower_settings = function() return {ui_x_res = 1920, ui_y_res = 1080, x_res = 1920, y_res = 1080} end,
    text = stub(), prim = stub(), chat = stub(), packets = stub(),
    play_sound = function() end, get_mouse_position = function() return 0, 0 end,
    -- the Atelier switch on, so set_combine notes what each set inherits
    _atelier_on = true,
}

local function obj()
    local o = {}
    return setmetatable(o, {__index = function() return function() return nil end end})
end
local texts = {new = function() return obj() end, destroy = function() end}

local env = {}
local function pathsearch(str)
    local dirs = {GS .. 'libs-dev/', GS .. 'libs/', DATA .. '/' .. PLAYER .. '/', DATA .. '/common/', DATA .. '/', ROOT .. 'addons/libs/'}
    for _, d in ipairs(dirs) do if exists(d .. str) then return d .. str end end
end

local function include_user(str, into)
    if type(str) ~= 'string' then error('bad include ' .. tostring(str), 2) end
    str = str:lower()
    if str:sub(-4) ~= '.lua' then str = str .. '.lua' end
    local path = pathsearch(str)
    if not path then error('Cannot find the include file (' .. str .. ')', 2) end
    local f, err = loadfile(path)
    if not f then error('Error loading file (' .. str .. '): ' .. err, 2) end
    if type(into) == 'table' then
        setmetatable(into, {__index = env})
        setfenv(f, into)
        pcall(f, into)
        return into
    end
    setfenv(f, env)
    return f()
end

local scheduled = {}
local cor = {
    schedule = function(fn, delay) scheduled[#scheduled + 1] = {fn = fn, delay = tonumber(delay) or 0} end,
    sleep = function() end,
    create = coroutine.create, resume = coroutine.resume, yield = coroutine.yield, status = coroutine.status,
    wrap = coroutine.wrap, running = coroutine.running, close = function() end,
}

-- Stand-ins for Windower's tables / sets / lists libraries (the real ones need
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
TM.tostring = function() return '{}' end
local TMETA = {__index = TM}
local T = function(t) return setmetatable(t or {}, TMETA) end
local SM = setmetatable({contains = function(s, v) return rawget(s, v) == true end, add = function(s, v) rawset(s, v, true) return s end,
    remove = function(s, v) rawset(s, v, nil) return s end, length = count, empty = function(s) return next(s) == nil end,
    it = function(s) local k return function() k = next(s, k) return k end end}, {__index = TM})
local S = function(t) local s = setmetatable({}, {__index = SM}) for _, v in pairs(t or {}) do s[v] = true end return s end
local LM = setmetatable({contains = TM.contains, append = TM.append, length = function(l) return #l end,
    last = TM.last, it = function(l) local i = 0 return function() i = i + 1 return l[i] end end}, {__index = TM})
local L = function(t) local l = setmetatable({}, {__index = LM}) for i, v in ipairs(t or {}) do l[i] = v end l.n = #l return l end
local strx = {startswith = function(s, p) return s:sub(1, #p) == p end, endswith = function(s, p) return p == '' or s:sub(-#p) == p end,
    contains = function(s, p) return s:find(p, 1, true) ~= nil end, trim = function(s) return (s:gsub('^%s+', ''):gsub('%s+$', '')) end,
    split = function(s, sep) local r = L{} for part in (s .. sep):gmatch('(.-)' .. sep:gsub('%p', '%%%0')) do r:append(part) end return r end,
    ucfirst = function(s) return s:sub(1, 1):upper() .. s:sub(2) end, slice = function(s, i, j) return s:sub(i, j) end}
for k, v in pairs(strx) do string[k] = string[k] or v end

-- GearSwap's set_combine (set_merge in helper_functions.lua): only gear slots
-- are kept (sub-sets are not copied), under their default names, case-insensitive;
-- later sets win
local SLOT_NAME = {main = 'main', sub = 'sub', range = 'range', ranged = 'range', ammo = 'ammo',
    head = 'head', body = 'body', hands = 'hands', legs = 'legs', feet = 'feet', neck = 'neck', waist = 'waist',
    back = 'back', left_ear = 'left_ear', ear1 = 'left_ear', lear = 'left_ear',
    right_ear = 'right_ear', ear2 = 'right_ear', rear = 'right_ear',
    left_ring = 'left_ring', ring1 = 'left_ring', lring = 'left_ring',
    right_ring = 'right_ring', ring2 = 'right_ring', rring = 'right_ring'}
local function set_combine(...)
    local r = {}
    for i = 1, select('#', ...) do
        local s = select(i, ...)
        if type(s) == 'table' then
            for key, item in pairs(s) do
                local slot = type(key) == 'string' and SLOT_NAME[key:lower()]
                if slot then r[slot] = item end
            end
        end
    end
    return r
end

for k, v in pairs({
    gearswap = {res = res, default_slot_map = {}, encumbrance_table = {}, pathsearch = function(t) return pathsearch(t[1]) end, gearswap_disabled = false,
        windower = windower},
    _global = {debug_mode = false}, _settings = {debug_mode = false}, _addon = {name = 'GearSwap'},
    equip = function() end, cancel_spell = function() end, change_target = function() end, cast_delay = function() end,
    print_set = function() end, set_combine = set_combine, disable = function() end, enable = function() end,
    send_command = function() end, windower = windower, include = include_user, require = include_user,
    midaction = function() return false end, pet_midaction = function() return false end,
    set_language = function() end, show_swaps = function() end, debug_mode = false, include_path = function() end,
    register_unhandled_command = function() end, move_spell_target = function() end, language = 'english',
    string = string, math = math, table = table, T = T, S = S, L = L, Q = L, set = SM, list = LM, queue = LM,
    pack = {}, functions = {}, os = os, texts = texts, bit = {band = function() return 0 end},
    type = type, tostring = tostring, tonumber = tonumber, pairs = pairs, ipairs = ipairs, print = function() end,
    add_to_chat = function() end, unpack = unpack, next = next, select = select, lua_base_path = GS,
    empty = {name = 'empty'}, file = {}, loadstring = loadstring, assert = assert, error = error, pcall = pcall,
    io = io, dofile = dofile, debug = debug, coroutine = cor, setmetatable = setmetatable,
    getmetatable = getmetatable, rawset = rawset, rawget = rawget, _libs = {},
    buffactive = {}, player = player, world = {area = 'Nowhere', zone = 'Nowhere', weather_element = 'None', day_element = 'Fire'},
    pet = {isvalid = false}, fellow = {isvalid = false}, alliance = {{count = 1}}, party = {count = 1},
    sets = {naked = {}},
}) do env[k] = v end
env._G = env

-- Windower libraries the job code asks for by name
local preloaded = {resources = res, texts = texts, packets = stub(), config = stub(), sets = stub(),
    files = stub(), extdata = stub(), chat = stub()}
local plain_include = include_user
include_user = function(str, into)
    if type(str) == 'string' and preloaded[str:lower()] then return preloaded[str:lower()] end
    return plain_include(str, into)
end
env.include, env.require = include_user, include_user

-- set_combine noted from the first line, as config_loader does in game
pcall(function() include_user('shared/utils/atelier/atelier_export').install() end)

local ok, err = pcall(include_user, ('%s_%s.lua'):format(PLAYER, MAIN))
if ok and env.get_sets then ok, err = pcall(env.get_sets) end
if not ok then
    io.stderr:write('LOAD ERROR ' .. tostring(err) .. '\n')
    os.exit(2)
end

-- What the game runs in the first seconds after a load (keys, modes)
table.sort(scheduled, function(a, b) return a.delay < b.delay end)
local i = 1
while i <= #scheduled and i <= 400 do
    if scheduled[i].delay <= 10 then pcall(scheduled[i].fn) end
    i = i + 1
end

local AtelierExport = include_user('shared/utils/atelier/atelier_export')
local rel = AtelierExport.export()
if not rel then
    io.stderr:write('EXPORT FAILED\n')
    os.exit(3)
end
print(rel)

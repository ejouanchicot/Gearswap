---============================================================================
--- Foreign GearSwap evaluator - what another player's job file really builds
---============================================================================
--- Loads a foreign Mote-based job file outside the game, through OUR copy of
--- Mote's libraries, and writes as JSON what GearSwap would hold after the
--- load: every set (with set_combine resolved, variables and augments as
--- built), every Mote mode with its options and default, the keys it binds,
--- its macro book and lockstyle, the functions it defines and every name it
--- read that was nil (a set or a gear variable that does not exist).
---
--- The foreign file is untrusted: it runs in an environment without io,
--- os.execute, dofile, loadfile or loadstring; it may only include files of
--- its own folder or Mote's libraries.
---
---   lua5.1 foreign_eval.lua <foreign data dir> <Player> <JOB> <SUB> <file name> <out.json>
---
--- @file    scripts/convert/foreign_eval.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-16
---============================================================================

local FOREIGN, PLAYER, MAIN, SUB, FILE, OUT = arg[1], arg[2], arg[3], arg[4], arg[5], arg[6]
local DATA = arg[0]:gsub('\\', '/'):match('^(.*)/scripts/convert/[^/]*$') or '.'
local GS = DATA:match('^(.*/)data$') or (DATA .. '/../')
local ROOT = GS .. '../../'
FOREIGN = FOREIGN:gsub('\\', '/'):gsub('/?$', '/')
local SetDump = dofile(DATA .. '/scripts/convert/set_dump.lua')

local function exists(p) local f = io.open(p, 'rb') if f then f:close() return true end return false end

local res = setmetatable({}, {__index = function(t, k)
    local p = ROOT .. 'res/' .. k .. '.lua'
    if not exists(p) then return nil end
    local v = dofile(p)
    rawset(t, k, v)
    return v
end})

local function stub()
    return setmetatable({}, {
        __index = function(t, k) local v = stub() rawset(t, k, v) return v end,
        __call = function() return stub() end,
    })
end

---------------------------------------------------------------- what the file does, recorded
local report = {binds = {}, commands = {}, macro = nil, missing = {}, nil_args = {}, errors = {}}
local function where(level)
    local info = debug.getinfo(level, 'Sl')
    if not info then return '?' end
    return (info.short_src:match('[^/\\]+$') or info.short_src) .. ':' .. tostring(info.currentline)
end
-- level 3 from here by default: the function that read the name (a library reading its own
-- optional globals while the foreign file is deeper on the stack is not counted)
local function caller_in_foreign(level)
    level = level or 3
    local info = debug.getinfo(level, 'S')
    if not info then return nil end
    local src = info.source:gsub('\\', '/')
    if src:sub(1, 1) == '@' and src:sub(2, #FOREIGN + 1):lower() == FOREIGN:lower() then return level end
end

local function send_command(cmd)
    cmd = tostring(cmd)
    for part in (cmd .. ';'):gmatch('([^;]*);') do
        part = part:gsub('^%s+', ''):gsub('^@', '')
        if part:match('^bind ') or part:match('^unbind ') then
            report.binds[#report.binds + 1] = part
        elseif part ~= '' and not part:match('^wait ') then
            report.commands[#report.commands + 1] = part
        end
    end
end

---------------------------------------------------------------- Windower and GearSwap stand-ins (as load_job.lua)
local vitals = {hp = 1500, mp = 1500, tp = 0, max_hp = 1500, max_mp = 1500, hpp = 100, mpp = 100}
local player = {name = PLAYER, main_job = MAIN, sub_job = SUB, main_job_full = MAIN, sub_job_full = SUB,
    main_job_level = 99, sub_job_level = 53, id = 1, index = 1, status = 'Idle', status_id = 0,
    buffs = {}, hp = 1500, mp = 1500, tp = 0, max_hp = 1500, max_mp = 1500, hpp = 100, mpp = 100,
    vitals = vitals, skills = {}, merits = {}, job_points = {}, equipment = {}, in_combat = false, target_index = 0,
    inventory = {}, wardrobe = {}}

local ffxi = setmetatable({
    get_player = function() return {name = PLAYER, main_job = MAIN, sub_job = SUB, main_job_level = 99,
        sub_job_level = 53, id = 1, index = 1, status = 0, buffs = {}, vitals = vitals,
        skills = {}, merits = {}, job_points = {}, jobs = {}} end,
    get_items = function() return {max_gil = 0, gil = 0, equipment = {}} end,
    get_party = function() return {p0 = {name = PLAYER, mob = {id = 1, index = 1, x = 0, y = 0, z = 0}}, party1_count = 1} end,
    get_info = function() return {zone = 1, logged_in = true, language = 'English', server = 1, mog_house = false} end,
    get_mob_by_target = function(t) if t == 'me' then return {id = 1, index = 1, name = PLAYER, x = 0, y = 0, z = 0, status = 0} end end,
    get_ability_recasts = function() return {} end,
    get_spell_recasts = function() return {} end,
    get_spells = function() return {} end,
    get_abilities = function() return {job_abilities = {}, weapon_skills = {}} end,
    get_key_items = function() return {} end,
    get_mob_array = function() return {} end,
}, {__index = function() return function() return nil end end})

local windower = {
    addon_path = GS, windower_path = ROOT, ffxi = ffxi,
    send_command = send_command, add_to_chat = function() end,
    register_event = function() return 1 end, raw_register_event = function() return 1 end,
    unregister_event = function() end,
    file_exists = function() return false end, dir_exists = function() return false end,
    create_dir = function() end, get_dir = function() return {} end,
    get_windower_settings = function() return {ui_x_res = 1920, ui_y_res = 1080, x_res = 1920, y_res = 1080} end,
    text = stub(), prim = stub(), chat = stub(), packets = stub(),
    play_sound = function() end, get_mouse_position = function() return 0, 0 end,
}
local function obj() return setmetatable({}, {__index = function() return function() return nil end end}) end
local texts = {new = function() return obj() end, destroy = function() end}

local env = {}
-- the foreign folder first (its globals file), then Mote's libraries; nothing else on disk
local function pathsearch(str)
    for _, d in ipairs({FOREIGN, GS .. 'libs/'}) do if exists(d .. str) then return d .. str end end
end
local function include_user(str)
    if type(str) ~= 'string' then error('bad include ' .. tostring(str), 2) end
    str = str:lower()
    if str:sub(-4) ~= '.lua' then str = str .. '.lua' end
    local path = pathsearch(str)
    if not path then error('Cannot find the include file (' .. str .. ')', 2) end
    local f, err = loadfile(path)
    if not f then error('Error loading file (' .. str .. '): ' .. err, 2) end
    setfenv(f, env)
    return f()
end
local preloaded = {resources = res, texts = texts, packets = stub(), config = stub(), sets = stub(),
    files = stub(), extdata = stub(), chat = stub(), logger = stub(), tables = {}, strings = {}, lists = {},
    queues = {}, maths = {}, functions = {}, actions = stub(), ['dialog'] = stub()}
local function include_or_preloaded(str)
    if type(str) == 'string' then
        local k = str:lower():gsub('%.lua$', '')
        if preloaded[k] then return preloaded[k] end
    end
    return include_user(str)
end

local scheduled = {}
local cor = {
    schedule = function(fn, delay) scheduled[#scheduled + 1] = {fn = fn, delay = tonumber(delay) or 0} end,
    sleep = function() end,
    create = coroutine.create, resume = coroutine.resume, yield = coroutine.yield, status = coroutine.status,
    wrap = coroutine.wrap, running = coroutine.running, close = function() end,
}

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
    it = function(s) local k return function() k = next(s, k) return k end end,
    union = function(s, o) local r = setmetatable({}, getmetatable(s)) for k in pairs(s) do r[k] = true end for k in pairs(o or {}) do r[k] = true end return r end},
    {__index = TM})
local S = function(t) local s = setmetatable({}, {__index = SM, __add = SM.union}) for _, v in pairs(t or {}) do s[v] = true end return s end
local LM = setmetatable({contains = TM.contains, append = TM.append, length = function(l) return #l end,
    last = TM.last, it = function(l) local i = 0 return function() i = i + 1 return l[i] end end}, {__index = TM})
local L = function(t) local l = setmetatable({}, {__index = LM}) for i, v in ipairs(t or {}) do l[i] = v end l.n = #l return l end
local strx = {startswith = function(s, p) return s:sub(1, #p) == p end, endswith = function(s, p) return p == '' or s:sub(-#p) == p end,
    contains = function(s, p) return s:find(p, 1, true) ~= nil end, trim = function(s) return (s:gsub('^%s+', ''):gsub('%s+$', '')) end,
    split = function(s, sep) local r = L{} for part in (s .. sep):gmatch('(.-)' .. sep:gsub('%p', '%%%0')) do r:append(part) end return r end,
    ucfirst = function(s) return s:sub(1, 1):upper() .. s:sub(2) end, slice = function(s, i, j) return s:sub(i, j) end,
    lower = string.lower, upper = string.upper}
for k, v in pairs(strx) do string[k] = string[k] or v end

-- GearSwap's set_combine; a nil argument written in the foreign file is recorded (a set or
-- variable that does not exist). Level 4 from on_nil: on_nil, set_combine, its caller.
local set_combine = SetDump.set_combine(function(i)
    if caller_in_foreign(4) then report.nil_args[#report.nil_args + 1] = {at = where(4), arg = i} end
end)

local SAFE_OS = {time = os.time, clock = os.clock, date = os.date, difftime = os.difftime}
local empty = {name = 'empty'}
for k, v in pairs({
    gearswap = {res = res, default_slot_map = {}, encumbrance_table = {}, pathsearch = function(t) return pathsearch(t[1]) end,
        gearswap_disabled = false, windower = windower},
    _global = {debug_mode = false}, _settings = {debug_mode = false}, _addon = {name = 'GearSwap'},
    equip = function() end, cancel_spell = function() end, change_target = function() end, cast_delay = function() end,
    print_set = function() end, set_combine = set_combine, disable = function() end, enable = function() end,
    send_command = send_command, windower = windower, include = include_or_preloaded, require = include_or_preloaded,
    midaction = function() return false end, pet_midaction = function() return false end,
    set_language = function() end, show_swaps = function() end, debug_mode = false, include_path = function() end,
    register_unhandled_command = function() end, move_spell_target = function() end, language = 'english',
    string = string, math = math, table = table, T = T, S = S, L = L, Q = L, set = SM, list = LM, queue = LM,
    pack = {}, functions = {}, os = SAFE_OS, texts = texts, bit = {band = function() return 0 end},
    type = type, tostring = tostring, tonumber = tonumber, pairs = pairs, ipairs = ipairs, print = function() end,
    add_to_chat = function() end, unpack = unpack, next = next, select = select, lua_base_path = GS,
    empty = empty, file = {}, assert = assert, error = error, pcall = pcall,
    coroutine = cor, setmetatable = setmetatable, getmetatable = getmetatable, rawset = rawset, rawget = rawget,
    rawequal = rawequal, _libs = {}, buffactive = {}, player = player,
    world = {area = 'Nowhere', zone = 'Nowhere', weather_element = 'None', day_element = 'Fire'},
    pet = {isvalid = false}, fellow = {isvalid = false}, alliance = {{count = 1}}, party = {count = 1},
    sets = {naked = {}}, gear = {}, spell = nil,
    set_macro_page = function(page, book) report.macro = {book = tonumber(book), page = tonumber(page)} end,
}) do env[k] = v end
env._G = env

-- a global read that is nil, from the foreign file (the libraries probe their own optional globals);
-- a global first written by the foreign file
local foreign_globals = {}
-- a gear.* field read that is nil (gear is Mote-Include's table, watched when it is made)
local function watch_gear(g)
    setmetatable(g, {__index = function(_, k)
        local level = caller_in_foreign()
        if level then report.missing[#report.missing + 1] = {name = 'gear.' .. tostring(k), at = where(level)} end
    end})
end
env.gear = nil
setmetatable(env, {
    __index = function(_, k)
        local level = caller_in_foreign()
        if level then report.missing[#report.missing + 1] = {name = tostring(k), at = where(level)} end
    end,
    __newindex = function(t, k, v)
        if caller_in_foreign() then foreign_globals[k] = where(3) end
        rawset(t, k, v)
        if k == 'gear' and type(v) == 'table' and not getmetatable(v) then watch_gear(v) end
    end,
})

---------------------------------------------------------------- load
local function run(label, fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then report.errors[#report.errors + 1] = label .. ': ' .. tostring(err) end
    return ok
end
if run('load', include_user, FILE) and env.get_sets then run('get_sets', env.get_sets) end
table.sort(scheduled, function(a, b) return a.delay < b.delay end)
for i = 1, math.min(#scheduled, 400) do
    if scheduled[i].delay <= 10 then run('scheduled', scheduled[i].fn) end
end

---------------------------------------------------------------- sets
local json = SetDump.json
local out_sets = SetDump.walk(env.sets, empty)

---------------------------------------------------------------- modes
local modes = {}
local function mode_of(m)
    local tr = type(m) == 'table' and rawget(m, '_track')
    if not tr or tr._class ~= 'mode' then return nil end
    local r = {type = tr._type, description = tr._description}
    if tr._type == 'list' then
        r.options = {}
        for i = 1, tr._count do r.options[i] = rawget(m, i) end
        r.default = rawget(m, tr._default)
        r.current = rawget(m, tr._current)
    else
        r.default, r.current = tr._default, tr._current
    end
    return r
end
for k, v in pairs(env.state or {}) do modes[k] = mode_of(v) end

---------------------------------------------------------------- functions written by the foreign files
local functions = {}
for k, v in pairs(env) do
    if type(v) == 'function' then
        local info = debug.getinfo(v, 'S')
        local src = info.source:gsub('\\', '/')
        if src:sub(1, 1) == '@' and src:sub(2, #FOREIGN + 1):lower() == FOREIGN:lower() then
            functions[#functions + 1] = {name = k, file = src:match('[^/]+$'), from = info.linedefined, to = info.lastlinedefined}
        end
    end
end
table.sort(functions, function(a, b) return a.from < b.from end)

-- other globals the foreign files set (variables, tables) - the libraries' are skipped
local globals = {}
for k, at in pairs(foreign_globals) do
    if type(rawget(env, k)) ~= 'function' then globals[#globals + 1] = {name = tostring(k), at = at} end
end
table.sort(globals, function(a, b) return a.name < b.name end)

local custom = {}
for _, name in ipairs({'CustomMeleeGroups', 'CustomIdleGroups', 'CustomRangedGroups', 'CustomDefenseGroups', 'CustomClass'}) do
    local c = env.classes and env.classes[name]
    if type(c) == 'table' then
        local list = {}
        for _, v in ipairs(c) do list[#list + 1] = v end
        custom[name] = list
    end
end

local f = assert(io.open(OUT, 'wb'))
f:write(json({player = PLAYER, job = MAIN, sub = SUB, file = FILE, sets = out_sets, modes = modes,
    binds = report.binds, commands = report.commands, macro = report.macro, missing = report.missing,
    nil_args = report.nil_args, errors = report.errors, functions = functions, custom_classes = custom,
    globals = globals}))
f:close()
print(('%s %s: %d sets, %d errors, %d missing names, %d nil set_combine args'):format(PLAYER, MAIN, #out_sets,
    #report.errors, #report.missing, #report.nil_args))

-- what the file equips, scenario by scenario (probe.lua), when a spec is given
local SPEC, PROBE_OUT = arg[7], arg[8]
if SPEC and PROBE_OUT then
    local Probe = dofile(DATA .. '/scripts/convert/probe.lua')
    local sf = assert(io.open(SPEC, 'rb'))
    local spec = Probe.decode(sf:read('*a'))
    sf:close()
    local results = Probe.run(env, spec, {res = res, slot_name = SetDump.SLOT_NAME,
        piece = function(item) return SetDump.piece(item, empty) end})
    local pf = assert(io.open(PROBE_OUT, 'wb'))
    pf:write(json(results))
    pf:close()
end

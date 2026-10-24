---============================================================================
--- Test of the Atelier's "Add a job" (shared/utils/atelier/job_adder.lua)
---============================================================================
--- 1. Every template set file of _master/sets/ without its pieces: it still loads, it has the same set names
---    (sets, sub-sets, set_combine) as the template and no slot is left in any set.
--- 2. A job added to a character in a temporary Windower folder: the entry, the settings in their theme
---    folders, the sets without pieces, character_db.lua, the template's name made the character's (not on
---    @author lines), nothing written over, a second add refused.
---
--- Run from data/: lua5.1 scripts/atelier/job_adder_test.lua
---
--- @file scripts/atelier/job_adder_test.lua
--- @author ejouanchicot
--- @date Created: 2026-10-24
---============================================================================
package.path = './?.lua;' .. package.path

local done, failed = 0, 0
local function check(what, got, want)
    done = done + 1
    if got ~= want then failed = failed + 1; print(('FAILED %s: got %s, wanted %s'):format(what, tostring(got), tostring(want))) end
end
local function read(p) local f = io.open(p, 'rb'); if not f then return nil end local t = f:read('*a'); f:close(); return t end
local function win(p) return (p:gsub('/', '\\')) end
local function list(dir)
    local out, p = {}, io.popen('dir /b "' .. win(dir) .. '" 2>nul')
    for l in p:lines() do out[#out + 1] = l end
    p:close(); return out
end
windower = {addon_path = './', get_dir = list, dir_exists = function(d) return #list(d) > 0 or os.rename(d, d) ~= nil end,
    create_dir = function(d) os.execute('mkdir "' .. win(d) .. '" 2>nul') end}
local JobAdder = require('shared/utils/atelier/job_adder')

-- 1. the templates ------------------------------------------------------------------------------------------
local SLOTS = {main = 1, sub = 1, range = 1, ranged = 1, ammo = 1, head = 1, neck = 1, ear1 = 1, ear2 = 1, left_ear = 1,
    right_ear = 1, body = 1, hands = 1, ring1 = 1, ring2 = 1, left_ring = 1, right_ring = 1, back = 1, waist = 1, legs = 1, feet = 1}
-- loads a set file in a box of its own: GearSwap's set_combine (a merge) and whatever global it reads, as an empty table
local function load_sets(text, name)
    local env = setmetatable({}, {__index = function(_, k) if _G[k] ~= nil then return _G[k] end return setmetatable({}, {__index = function() return {} end}) end})
    -- the tables Mote makes before a set file runs (libs/Mote-Include.lua init_include)
    env.sets = {precast = {FC = {}, JA = {}, WS = {}, RA = {}}, midcast = {RA = {}, Pet = {}}, idle = {}, resting = {},
        engaged = {}, defense = {}, buff = {}}
    env.set_combine = function(...) local out = {}; for _, t in ipairs({...}) do if type(t) == 'table' then for k, v in pairs(t) do out[k] = v end end end; return out end
    env.include, env.require = function() end, function() return setmetatable({}, {__index = function() return function() return {} end end}) end
    local fn, err = loadstring(text, name)
    if not fn then return nil, err end
    setfenv(fn, env)
    local ok, e = pcall(fn)
    if not ok then return nil, e end
    return env.sets
end
-- every path of a set tree that is not a slot (the set names); a table met again under another name (an alias,
-- sets.a = sets.b) is walked again, only a loop is cut
local function names(t, prefix, out, stack)
    out, stack = out or {}, stack or {}
    if stack[t] then return out end
    stack[t] = true
    for k, v in pairs(t) do
        if not SLOTS[k] and type(v) == 'table' then
            local p = prefix .. '.' .. tostring(k)
            out[p] = true
            names(v, p, out, stack)
        end
    end
    stack[t] = nil
    return out
end
local function slots_left(t, stack)
    stack = stack or {}
    if stack[t] then return 0 end
    stack[t] = true
    local n = 0
    for k, v in pairs(t) do
        if SLOTS[k] then n = n + 1 elseif type(v) == 'table' then n = n + slots_left(v, stack) end
    end
    stack[t] = nil
    return n
end
local templates = 0
for _, file in ipairs(list('_master/sets')) do
    if file:match('^%l+_sets%.lua$') then
        local text = read('_master/sets/' .. file)
        local before, why = load_sets(text, file)
        if before then
            templates = templates + 1
            local after, err = load_sets(JobAdder.empty_sets(text), file .. ' emptied')
            check(file .. ' still loads', after ~= nil, true)
            if not after then print('  ' .. tostring(err)) else
                local a, b, missing, extra = names(before, 'sets'), names(after, 'sets'), 0, 0
                for p in pairs(a) do if not b[p] then missing = missing + 1 end end
                for p in pairs(b) do if not a[p] then extra = extra + 1 end end
                check(file .. ' set names kept', missing, 0)
                check(file .. ' no new name', extra, 0)
                check(file .. ' no piece left', slots_left(after), 0)
            end
        else print('(template not loadable alone: ' .. file .. ': ' .. tostring(why) .. ')') end
    end
end
check('templates checked', templates >= 20, true)

-- 2. a job added in a temporary Windower folder -----------------------------------------------------------
local root = (os.getenv('TEMP') .. '/job_adder_test_' .. os.time() .. '/'):gsub('\\', '/')
local data = root .. 'data/'
os.execute('mkdir "' .. win(data .. '_master/entry') .. '" 2>nul')
os.execute('xcopy /e /i /q "' .. win('_master/config/whm') .. '" "' .. win(data .. '_master/config/whm') .. '" >nul')
os.execute('mkdir "' .. win(data .. '_master/sets') .. '" 2>nul')
local function copy(a, b) local f = io.open(b, 'wb'); f:write(read(a)); f:close() end
copy('_master/entry/Tetsouo_WHM.lua', data .. '_master/entry/Tetsouo_WHM.lua')
copy('_master/sets/whm_sets.lua', data .. '_master/sets/whm_sets.lua')
os.execute('mkdir "' .. win(data .. 'Kaories/_common') .. '" 2>nul')
local f = io.open(data .. 'character_db.lua', 'wb')
f:write("return {\n    Kaories = {\n        jobs = { 'RDM', 'COR', 'GEO', 'PLD' },\n        role = 'alt',\n    },\n}\n"); f:close()
windower.addon_path = root
package.loaded['shared/utils/core/char_paths'] = nil
local r = JobAdder.add('whm', 'Kaories')
check('added', r.ok, true)
check('entry written', read(data .. 'Kaories/Kaories_WHM.lua') ~= nil, true)
check('entry names Kaories', (read(data .. 'Kaories/Kaories_WHM.lua') or ''):find('Kaories - WHM entry', 1, true) ~= nil, true)
check('entry keeps @author', (read(data .. 'Kaories/Kaories_WHM.lua') or ''):find('@author  ejouanchicot', 1, true) ~= nil, true)
check('keys in keys/', read(data .. 'Kaories/whm/keys/WHM_KEYBINDS.lua') ~= nil, true)
check('HUD in display/', read(data .. 'Kaories/whm/display/WHM_HUD.lua') ~= nil, true)
check('Cure config in combat/', read(data .. 'Kaories/whm/combat/WHM_CURE_CONFIG.lua') ~= nil, true)
local sets = read(data .. 'Kaories/whm/sets/whm_sets.lua') or ''
check('sets written', #sets > 0, true)
check('sets say where they come from', sets:find('made by the Atelier', 1, true) ~= nil, true)
check('no Tetsouo piece left', sets:find("'Nyame Helm'", 1, true) == nil and sets:find('Queller Rod', 1, true) == nil, true)
check('character_db has WHM', (read(data .. 'character_db.lua') or ''):find("'PLD', 'WHM'", 1, true) ~= nil, true)
local again = JobAdder.add('WHM', 'Kaories')
check('a second add is refused', again.error, 'exists')
check('unknown job refused', JobAdder.add('XYZ', 'Kaories').error, 'job')
-- a file already there is never written over
os.remove(data .. 'Kaories/Kaories_WHM.lua')
local mark = io.open(data .. 'Kaories/whm/keys/WHM_KEYBINDS.lua', 'wb'); mark:write('-- mine'); mark:close()
local r2 = JobAdder.add('WHM', 'Kaories')
check('re-add keeps the player file', read(data .. 'Kaories/whm/keys/WHM_KEYBINDS.lua'), '-- mine')
check('  and says it', #r2.kept > 0, true)
check('character_db not doubled', select(2, (read(data .. 'character_db.lua') or ''):gsub("'WHM'", '')), 1)
os.execute('rmdir /s /q "' .. win(root) .. '" 2>nul')
print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

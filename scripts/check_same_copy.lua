-- Finds the sets that ask the same copy of a piece for both rings or both earrings.
--
-- A piece pinned to a bag ({name = ..., bag = 'wardrobe 2'}) names one copy. Asked for both
-- slots of a pair, the game puts it in one and leaves the other as it was: the set looks right
-- as long as a piece from the set before stays there, and the slot stays empty otherwise
-- (found in game on 2026-10-09, WAR, two Moonlight Ring).
--
--   lua5.1 scripts/check_same_copy.lua <Character> [<Character>...]     from data/
--
-- Exits 1 when a set asks the same copy twice or a file does not load: run by scripts/run_tests.py on
-- Tetsouo and Kaories (the Atelier wrote 16 such sets on 2026-11-07, a push of one ring next to the other;
-- shared/utils/atelier/set_push.lua now gives the other copy).
--
-- Each <Character>/<job>/sets/<job>_sets.lua is run with GearSwap's globals stubbed, then every
-- table of `sets` is read. A file that does not load is listed, not skipped silently.
--
-- @file    scripts/check_same_copy.lua
-- @author  ejouanchicot

local JOBS = {'blm', 'blu', 'brd', 'bst', 'cor', 'dnc', 'drg', 'drk', 'geo', 'mnk', 'nin', 'pld', 'pup', 'rdm', 'rng',
    'run', 'sam', 'sch', 'smn', 'thf', 'war', 'whm'}
local PAIRS = {{'left_ring', 'right_ring'}, {'left_ear', 'right_ear'}}
local ALIAS = {ring1 = 'left_ring', ring2 = 'right_ring', lring = 'left_ring', rring = 'right_ring',
    ear1 = 'left_ear', ear2 = 'right_ear', lear = 'left_ear', rear = 'right_ear',
    left_earring = 'left_ear', right_earring = 'right_ear'}

package.path = './?.lua;' .. package.path

local function normal(set)
    local out = {}
    for key, value in pairs(set) do out[ALIAS[key] or key] = value end
    return out
end

local function stub_globals()
    local permissive = setmetatable({}, {__index = function() return function() end end})
    -- Mote creates sets.precast, sets.midcast... before the file runs: any missing table is made on demand
    local vivify
    vivify = {__index = function(t, key)
        if type(key) ~= 'string' then return nil end
        local made = setmetatable({}, vivify)
        rawset(t, key, made)
        return made
    end}
    _G.sets, _G.empty = setmetatable({}, vivify), {}
    _G.set_combine = function(...)
        local out = {}
        for i = 1, select('#', ...) do
            local set = select(i, ...)
            if type(set) == 'table' then for key, value in pairs(normal(set)) do out[key] = value end end
        end
        return out
    end
    _G.player = {name = 'X', main_job = 'WAR', sub_job = 'SAM', equipment = {}, inventory = {}}
    _G.windower = setmetatable({addon_path = './', ffxi = permissive}, {__index = function() return function() end end})
    _G.include, _G.send_command, _G.add_to_chat = function() end, function() end, function() end
    _G.state, _G.buffactive = setmetatable({}, {__index = function() return {} end}), {}
end

local function copy_of(piece)
    if type(piece) ~= 'table' or type(piece.name) ~= 'string' or type(piece.bag) ~= 'string' then return nil end
    local augments = type(piece.augments) == 'table' and table.concat(piece.augments, ';') or ''
    return piece.name .. ' [' .. piece.bag:lower() .. '] ' .. augments
end

local function walk(set, path, found, seen)
    if type(set) ~= 'table' or seen[set] then return end
    seen[set] = true
    local worn = normal(set)
    for _, pair in ipairs(PAIRS) do
        local a, b = copy_of(worn[pair[1]]), copy_of(worn[pair[2]])
        if a and a == b then found[#found + 1] = path .. '  ' .. pair[1] .. ' / ' .. pair[2] .. ' = ' .. a end
    end
    for key, value in pairs(set) do
        if type(value) == 'table' and type(key) == 'string' and not copy_of(value) and value.name == nil then
            walk(value, path .. '.' .. key, found, seen)
        end
    end
end

local total, not_loaded = 0, 0
for _, character in ipairs(arg) do
    for _, job in ipairs(JOBS) do
        local file = ('%s/%s/sets/%s_sets.lua'):format(character, job, job)
        local handle = io.open(file)
        if handle then
            handle:close()
            stub_globals()
            for name in pairs(package.loaded) do
                if name:find('^' .. character .. '/') then package.loaded[name] = nil end
            end
            local ok, err = pcall(dofile, file)
            if not ok then print(('NOT LOADED  %s: %s'):format(file, tostring(err))) not_loaded = not_loaded + 1 end
            local found = {}
            walk(sets, 'sets', found, {})
            table.sort(found)
            for _, line in ipairs(found) do print(('%s %s  %s'):format(character, job:upper(), line)) end
            total = total + #found
        end
    end
end
print(('%d set(s) asking the same copy for both slots'):format(total))
os.exit((total == 0 and not_loaded == 0) and 0 or 1)

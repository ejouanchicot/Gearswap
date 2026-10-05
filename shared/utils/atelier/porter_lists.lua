---============================================================================
--- Porter Lists - the job's pieces in PorterPacker's unpack list
---============================================================================
--- PorterPacker (addons/PorterPacker) packs every job's list on a swap but the
--- pieces of the job swapped to, its "unpack" list (data/<Char>/Active/<JOB>.lua,
--- else Inactive/). A piece the job's sets use that is missing there is packed
--- away, or left at the Porter Moogle; a piece no set uses any more is pulled
--- out for nothing. This module tells both, for the job loaded in game, and
--- writes the unpack list from the sets (the pack list is left as it is).
---
--- The job's pieces: every item named in its sets (sets.*, read in memory), its
--- Mote states' options and its <JOB>_WEAPONS.lua (shields, grips), kept when a
--- storage slip can hold them (only those can be at the Porter Moogle).
---
--- Used by shared/utils/atelier/atelier_export.lua (the export's porterpacker
--- block) and atelier_live.lua (POST /porter_write).
---
--- @file    shared/utils/atelier/porter_lists.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-06
---============================================================================

local PorterLists = {}

local SLOT_KEYS = {main = true, sub = true, range = true, ranged = true, ammo = true, head = true, neck = true,
    ear1 = true, ear2 = true, left_ear = true, right_ear = true, lear = true, rear = true, body = true, hands = true,
    ring1 = true, ring2 = true, left_ring = true, right_ring = true, lring = true, rring = true, back = true,
    waist = true, legs = true, feet = true}

local function resources()
    local ok, r = pcall(function() return (type(gearswap) == 'table' and gearswap.res) or require('resources') end)
    return ok and r or nil
end

--- {item id = true} for every item a storage slip can hold (Windower's res.slips: each slip's items, a 0 for a
--- bit no item uses).
local function storable_ids(res)
    local out = {}
    for _, slip in pairs(res.slips or {}) do
        for _, id in ipairs(type(slip) == 'table' and slip.items or {}) do if id and id > 0 then out[id] = true end end
    end
    return out
end

--- Item names (short and long, lower case) to their storable item ids.
local function name_index(res, storable)
    local out = {}
    for id in pairs(storable) do
        local it = res.items[id]
        if it then
            for _, n in ipairs({it.en, it.enl}) do
                if type(n) == 'string' then
                    local k = n:lower()
                    out[k] = out[k] or {}
                    out[k][#out[k] + 1] = id
                end
            end
        end
    end
    return out
end

--- Every string a table holds as a piece: a slot's value, a piece's name; sets inside sets walked once.
local function walk_sets(t, add, seen)
    if type(t) ~= 'table' or seen[t] then return end
    seen[t] = true
    if type(t.name) == 'string' then add(t.name) end
    for k, v in pairs(t) do
        if type(v) == 'string' and type(k) == 'string' and SLOT_KEYS[k:lower()] then add(v)
        elseif type(v) == 'table' then walk_sets(v, add, seen) end
    end
end

--- Every string anywhere in a config table (weapons, shields, grips): only item names will match.
local function walk_strings(t, add, seen)
    if type(t) ~= 'table' or seen[t] then return end
    seen[t] = true
    for k, v in pairs(t) do
        if type(k) == 'string' then add(k) end
        if type(v) == 'string' then add(v) elseif type(v) == 'table' then walk_strings(v, add, seen) end
    end
end

--- The storable item ids the loaded job uses: {id = true}.
local function wanted_ids(job, res, storable)
    local index, out = name_index(res, storable), {}
    local function add(name)
        for _, id in ipairs(index[name:lower()] or {}) do out[id] = true end
    end
    walk_sets(rawget(_G, 'sets'), add, {})
    -- Mote states: list modes keep their options at numeric indices (libs/Modes.lua)
    for _, st in pairs(rawget(_G, 'state') or {}) do
        if type(st) == 'table' and type(st._track) == 'table' and st._track._type == 'list' then
            for i = 1, st._track._count or 0 do if type(st[i]) == 'string' then add(st[i]) end end
        end
    end
    local ok, CharPaths = pcall(require, 'shared/utils/core/char_paths')
    if ok and CharPaths.optional then
        local okw, weapons = pcall(CharPaths.optional, 'job', job .. '_WEAPONS', job)
        if okw then walk_strings(weapons, add, {}) end
    end
    return out
end

--- PorterPacker's file for the job: Active/ first, then Inactive/ (its own lookup order), and where a new one goes.
local function list_file(job)
    local char = player and player.name
    if not char then return nil end
    local base = windower.windower_path .. 'addons/PorterPacker/data/' .. char .. '/'
    for _, dir in ipairs({'Active/', 'Inactive/'}) do
        local path = base .. dir .. job .. '.lua'
        local f = io.open(path, 'r')
        if f then f:close() return path, dir .. job .. '.lua', true end
    end
    if not windower.dir_exists(windower.windower_path .. 'addons/PorterPacker') then return nil end
    return base .. 'Active/' .. job .. '.lua', 'Active/' .. job .. '.lua', false
end

--- The unpack list as PorterPacker reads it: the split file's unpack, else the plain list (packs and unpacks alike).
local function current_names(path, exists)
    if not exists then return {}, nil end
    local ok, t = pcall(dofile, path)
    if not ok or type(t) ~= 'table' then return {}, 'unreadable' end
    if type(t.unpack) == 'table' then return t.unpack, 'split' end
    if type(t.pack) == 'table' then return t.pack, 'split' end
    return t, 'plain'
end

local function sorted_names(res, ids)
    local seen, out = {}, {}
    for id in pairs(ids) do
        local n = res.items[id] and res.items[id].en
        if n and not seen[n] then seen[n] = true out[#out + 1] = n end
    end
    table.sort(out, function(a, b) return a:lower() < b:lower() end)
    return out
end

--- The loaded job's list against PorterPacker's: what the sets use and the unpack list misses, what it holds
--- that no set uses.
--- @param job string the job loaded in game (its sets are the ones in memory)
--- @return table|nil {file, exists, form, add = {names}, remove = {names}, wanted = {names}}; nil without PorterPacker
function PorterLists.compare(job)
    local res = resources()
    if not (res and res.items and job) then return nil end
    local path, label, exists = list_file(job)
    if not path then return nil end
    local storable = storable_ids(res)
    if not next(storable) then return nil end
    local index, wanted = name_index(res, storable), wanted_ids(job, res, storable)
    local names, form = current_names(path, exists)
    local have = {}
    for _, n in ipairs(names) do
        if type(n) == 'string' then for _, id in ipairs(index[n:lower()] or {}) do have[id] = true end end
    end
    local add, remove = {}, {}
    for id in pairs(wanted) do if not have[id] then add[id] = true end end
    local listed = {}
    for _, n in ipairs(names) do
        if type(n) == 'string' then
            local ids, used = index[n:lower()] or {}, false
            for _, id in ipairs(ids) do if wanted[id] then used = true end end
            -- a name no storable item has is not PorterPacker's business: left alone
            if #ids > 0 and not used and not listed[n] then listed[n] = true remove[#remove + 1] = n end
        end
    end
    table.sort(remove, function(a, b) return a:lower() < b:lower() end)
    return {file = label, exists = exists, form = form, add = sorted_names(res, add), remove = remove,
        wanted = sorted_names(res, wanted)}
end

local function lua_list(names, indent)
    local out = {}
    for _, n in ipairs(names) do out[#out + 1] = indent .. ('%q'):format(n) .. ',' end
    return table.concat(out, '\n')
end

--- Writes the job's unpack list from its sets. A split file keeps its pack list and every line around the
--- unpack block; a plain list becomes a split file (pack: the old list and the sets' pieces); no file: one is
--- made in Active/. The file before is kept next to it (<JOB>.lua.bak, a name PorterPacker never loads).
--- @param job string the job loaded in game
--- @return table {ok, file, added, removed} or {ok = false, error}
function PorterLists.write(job)
    local cmp = PorterLists.compare(job)
    if not cmp then return {ok = false, error = 'no PorterPacker or no slips'} end
    if cmp.form == 'unreadable' then return {ok = false, error = 'unreadable list: ' .. cmp.file} end
    local path = list_file(job)
    local old = ''
    if cmp.exists then
        local f = io.open(path, 'r'); old = f:read('*a'); f:close()
        local b = io.open(path .. '.bak', 'w'); if b then b:write(old) b:close() end
    end
    local block = '    unpack = {\n' .. lua_list(cmp.wanted, '        ') .. '\n    },'
    local text
    local s, e = old:find('\n[ \t]*unpack%s*=%s*{[^}]*}%s*,?')
    if cmp.form == 'split' and s then
        -- the unpack block: from "unpack = {" to its closing brace (a list of strings: no brace inside)
        text = old:sub(1, s) .. block .. old:sub(e + 1)
    elseif cmp.form == 'split' then
        -- a split file with a pack list only: the unpack block goes before the table's closing brace
        local last = old:match('^.*()}')
        text = old:sub(1, last - 1) .. block .. '\n' .. old:sub(last)
    else
        -- a plain list (packs and unpacks alike) or no file: a split file, the old list kept as the pack list
        local pack, seen = {}, {}
        local okp, plain = pcall(dofile, path)
        for _, n in ipairs(cmp.form == 'plain' and okp and type(plain) == 'table' and plain or {}) do
            if type(n) == 'string' and not seen[n] then seen[n] = true pack[#pack + 1] = n end
        end
        for _, n in ipairs(cmp.wanted) do if not seen[n] then seen[n] = true pack[#pack + 1] = n end end
        text = ('-- %s storage list - %s\n-- unpack written by the GearSwap Atelier from the job\'s sets (shared/utils/atelier/porter_lists.lua)\n')
            :format(job, player.name)
            .. 'return {\n    pack = {\n' .. lua_list(pack, '        ') .. '\n    },\n' .. block .. '\n}\n'
    end
    if not cmp.exists then
        local dir = path:match('^(.*)/[^/]+$')
        windower.create_dir(dir:match('^(.*)/[^/]+$'))
        windower.create_dir(dir)
    end
    local f = io.open(path, 'w')
    if not f then return {ok = false, error = 'cannot write ' .. cmp.file} end
    f:write(text)
    f:close()
    return {ok = true, file = cmp.file, added = #cmp.add, removed = #cmp.remove}
end

_G.PorterLists = PorterLists
return PorterLists

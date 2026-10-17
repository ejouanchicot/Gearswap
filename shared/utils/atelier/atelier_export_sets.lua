---============================================================================
--- Atelier Export - the sets of the loaded job
---============================================================================
--- Every set under `sets`, as the Atelier page reads them: its pieces, the names it
--- is known under, the set it was built from and the slots that are its own (the
--- notes atelier_export.lua takes at each set_combine), and what a page override
--- replaced. Read by shared/utils/atelier/atelier_export.lua (build).
---
--- @file    shared/utils/atelier/atelier_export_sets.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-11 (out of atelier_export.lua)
---============================================================================

local ExportSets = {}

local SLOT_ALIAS = {
    main = 'main', sub = 'sub', range = 'range', ranged = 'range', ammo = 'ammo', head = 'head', neck = 'neck',
    ear1 = 'ear1', left_ear = 'ear1', lear = 'ear1', ear2 = 'ear2', right_ear = 'ear2', rear = 'ear2',
    body = 'body', hands = 'hands', ring1 = 'ring1', left_ring = 'ring1', lring = 'ring1',
    ring2 = 'ring2', right_ring = 'ring2', rring = 'ring2', back = 'back', waist = 'waist', legs = 'legs', feet = 'feet',
}
local MAX_DEPTH = 7

local function child_path(path, key)
    if type(key) == 'string' and key:match('^[%a_][%w_]*$') then return path .. '.' .. key end
    return path .. '["' .. tostring(key):gsub('"', '\\"') .. '"]'
end

local function slot_of(key)
    return type(key) == 'string' and SLOT_ALIAS[key:lower()]
end

--- A set's piece as {name, aug, augs}: aug is the short line under the item
--- (first 3 augments), augs every augment, which the page counts in the stats.
local function piece(value)
    if type(value) == 'string' then return {name = value} end
    if type(value) ~= 'table' or not value.name then return nil end
    local aug, augs
    if type(value.augments) == 'table' and #value.augments > 0 then
        augs = {}
        for i = 1, #value.augments do augs[i] = tostring(value.augments[i]) end
        aug = table.concat(augs, ' · ', 1, math.min(3, #augs))
    end
    -- bag (wardrobe N) and priority: where GearSwap takes the piece from, and its order in a swap
    local bag = type(value.bag) == 'string' and value.bag or nil
    local priority = tonumber(value.priority)
    return {name = value.name, aug = aug, augs = augs, bag = bag, priority = priority}
end

--- Gear slots of one table, or nil when it holds none.
local function pieces_of(tbl)
    local pieces, count = {}, 0
    for key, value in pairs(tbl) do
        local slot = slot_of(key)
        local p = slot and piece(value)
        if p then pieces[slot] = p count = count + 1 end
    end
    return count > 0 and pieces or nil
end

--- Every set under `sets`, first path wins; a table met again is an alias.
local function walk_sets(root)
    local path_of, out, order = {}, {}, {}
    local function walk(tbl, path, depth)
        if depth > MAX_DEPTH or type(tbl) ~= 'table' then return end
        if path_of[tbl] then
            local first = out[path_of[tbl]]
            if first then first.aliases = first.aliases or {} first.aliases[#first.aliases + 1] = path end
            return
        end
        path_of[tbl] = path
        local pieces = pieces_of(tbl)
        if not pieces and path ~= 'sets' then
            local leaf = true
            for key, value in pairs(tbl) do
                if type(value) == 'table' and not slot_of(key) then leaf = false break end
            end
            if leaf then pieces = {} end
        end
        if pieces then out[path] = {path = path, pieces = pieces, empty = next(pieces) == nil or nil} order[#order + 1] = path end
        local keys = {}
        for key, value in pairs(tbl) do
            if type(value) == 'table' and not slot_of(key) then keys[#keys + 1] = key end
        end
        table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
        for _, key in ipairs(keys) do walk(tbl[key], child_path(path, key), depth + 1) end
    end
    walk(root, 'sets', 0)
    return path_of, out, order
end

--- Base set and own slots from the set_combine notes.
local function add_provenance(path_of, out)
    local prov = rawget(_G, '__atelier_prov')
    if not prov then return end
    for tbl, args in pairs(prov) do
        local rec = path_of[tbl] and out[path_of[tbl]]
        if rec then
            local base = args[1]
            if type(base) == 'table' and path_of[base] and out[path_of[base]] then rec.base = path_of[base] end
            local own = {}
            for i = rec.base and 2 or 1, args.n do
                if type(args[i]) == 'table' then
                    for key in pairs(args[i]) do if slot_of(key) then own[#own + 1] = slot_of(key) end end
                end
            end
            rec.own = own
        end
    end
end

--- The last key of a set path (sets.midcast.Flash -> Flash, sets.precast.FC["Geist Wall"] -> Geist Wall).
local function last_key(path)
    return path:match('%["(.-)"%]$') or path:match('%.([%w_]+)$') or path
end

--- The names of the game's spells, job abilities and weapon skills (lower case), or nil without the resources.
local action_names
local function is_action(name)
    if action_names == nil then
        action_names = false
        -- GearSwap's resources as shared/utils/atelier/atelier_families.lua reads them (gearswap.res), else the global
        -- or the library: a plain rawget(_G, 'res') found nothing in game (the export kept Banishga)
        local ok, res = pcall(function() return (type(gearswap) == 'table' and gearswap.res) or res or rawget(_G, 'res') or require('resources') end)
        if ok and res then
            action_names = {}
            for _, kind in ipairs({'spells', 'job_abilities', 'weapon_skills'}) do
                for _, r in pairs(res[kind] or {}) do if r.en then action_names[r.en:lower()] = true end end
            end
        end
    end
    return action_names and action_names[name:lower()] or false
end

--- A set path as the export writes it (child_path): sets.midcast['Flash'] -> sets.midcast.Flash, ["Geist Wall"] kept.
local function canon_path(text)
    return (text:gsub("%[%s*['\"]([^'\"]+)['\"]%s*%]", function(key)
        return key:match('^[%a_][%w_]*$') and ('.' .. key) or ('["' .. key .. '"]')
    end))
end

--- The names the job's set file gives as copies of another set (`sets.engaged.MDT = sets.idle.MDT`): {copy = defined}.
local function file_copies()
    local out = {}
    local ok, CharPaths = pcall(require, 'shared/utils/core/char_paths')
    local job = player and player.main_job
    local path = ok and job and CharPaths.file('sets', job:lower() .. '_sets.lua', job)
    local f = path and io.open(path, 'r')
    if not f then return out end
    local text = f:read('*a')
    f:close()
    local name = "sets[%w_%.%[%]'\" ]*[%w_%]]"
    -- line by line (a copy on its own line, a comment after it allowed): consecutive copies all read
    for line in (text .. '\n'):gmatch('([^\n]*)\n') do
        local copy, defined = line:match('^%s*(' .. name .. ')%s*=%s*(' .. name .. ')%s*$')
        if not copy then copy, defined = line:match('^%s*(' .. name .. ')%s*=%s*(' .. name .. ')%s*%-%-') end
        if copy then out[canon_path(copy)] = canon_path(defined) end
    end
    return out
end

--- The sets under a renamed one take its new name, the old one kept as an alias: BLM's `sets.midcast['Comet'] =
--- sets.midcast['Elemental Magic']`, met first as Comet, left its Magic Burst set as sets.midcast.Comet.MagicBurst.
local function rename_under(path_of, out, order, from, old, new)
    for j = from, #order do
        local path = order[j]
        local rest = path:sub(#old + 1)
        if path:sub(1, #old) == old and rest:match('^[%.%[]') then
            local rec = out[path]
            rec.path = new .. rest
            rec.aliases = rec.aliases or {}
            rec.aliases[#rec.aliases + 1] = path
            out[path], out[rec.path] = nil, rec
            order[j] = rec.path
            for tbl, p in pairs(path_of) do if p == path then path_of[tbl] = rec.path end end
        end
    end
end

--- A set met under several names keeps the one it is defined under: the name the set file's copies point to
--- (`sets.engaged.MDT = sets.idle.MDT`: idle.MDT; alphabetical order put engaged first), else the first that is not a
--- spell, ability or weapon skill (`sets.midcast['Banishga'] = sets.midcast.SIRDEnmity`); the others become its aliases.
local function prefer_set_names(path_of, out, order)
    local copies = file_copies()
    for i, path in ipairs(order) do
        local rec = out[path]
        local defined = rec and rec.aliases and copies[path]
        local wanted = nil
        if defined then
            for _, alias in ipairs(rec.aliases) do if alias == defined then wanted = alias end end
        end
        if rec and rec.aliases and not wanted and is_action(last_key(path)) then
            for _, alias in ipairs(rec.aliases) do if not is_action(last_key(alias)) then wanted = alias break end end
        end
        if wanted then
            for k, alias in ipairs(rec.aliases) do
                if alias == wanted then
                    rec.aliases[k] = path
                    rec.path = alias
                    out[path], out[alias] = nil, rec
                    order[i] = alias
                    for tbl, p in pairs(path_of) do if p == path then path_of[tbl] = alias end end
                    rename_under(path_of, out, order, i + 1, path, alias)
                    break
                end
            end
        end
    end
end

local function collect_sets()
    local path_of, out, order = walk_sets(sets or {})
    prefer_set_names(path_of, out, order)
    add_provenance(path_of, out)
    -- what the set file gave before the page's overrides (shared/utils/atelier/set_overrides.lua)
    local ok, SetOverrides = pcall(require, 'shared/utils/atelier/set_overrides')
    for path, slots in pairs(ok and SetOverrides.was or {}) do
        local rec = out[path]
        if rec then
            rec.was = {}
            for slot, value in pairs(slots) do rec.was[slot] = value and piece(value) or {name = 'empty'} end
        end
    end
    local list = {}
    for _, path in ipairs(order) do list[#list + 1] = out[path] end
    return list
end

--- The sets of the loaded job, in the order of their paths.
--- @return table list of {path, pieces, aliases, base, own, was, empty}
ExportSets.collect = collect_sets

return ExportSets

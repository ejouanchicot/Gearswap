---============================================================================
--- Set Dump - the sets GearSwap holds, as plain data and JSON
---============================================================================
--- Shared by foreign_eval.lua (what a foreign file builds) and roundtrip.lua
--- (what our written file builds): every table under `sets` with its path,
--- its gear slots under GearSwap's default names, and the paths that are the
--- same table as an earlier one. Also GearSwap's set_combine, played offline.
---
--- @file    scripts/convert/set_dump.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-16
---============================================================================

local SetDump = {}

-- GearSwap's slot names, case-insensitive (equip_processing / set_merge)
SetDump.SLOT_NAME = {main = 'main', sub = 'sub', range = 'range', ranged = 'range', ammo = 'ammo',
    head = 'head', body = 'body', hands = 'hands', legs = 'legs', feet = 'feet', neck = 'neck', waist = 'waist',
    back = 'back', left_ear = 'left_ear', ear1 = 'left_ear', lear = 'left_ear',
    right_ear = 'right_ear', ear2 = 'right_ear', rear = 'right_ear',
    left_ring = 'left_ring', ring1 = 'left_ring', lring = 'left_ring',
    right_ring = 'right_ring', ring2 = 'right_ring', rring = 'right_ring'}
local SLOT_NAME = SetDump.SLOT_NAME

--- GearSwap's set_combine: gear slots only (sub-sets are not copied), default names,
--- later sets win. on_nil(i) is called for an argument that is nil.
--- @param on_nil function|nil
--- @return function
function SetDump.set_combine(on_nil)
    return function(...)
        local r = {}
        for i = 1, select('#', ...) do
            local s = select(i, ...)
            if type(s) == 'table' then
                for key, item in pairs(s) do
                    local slot = type(key) == 'string' and SLOT_NAME[key:lower()]
                    if slot then r[slot] = item end
                end
            elseif s == nil and on_nil then
                on_nil(i)
            end
        end
        return r
    end
end

--- JSON text of a Lua value (keys sorted, so two dumps compare as text).
--- @param v any
--- @return string
function SetDump.json(v)
    local t = type(v)
    if t == 'nil' then return 'null' end
    if t == 'boolean' or t == 'number' then return tostring(v) end
    if t == 'string' then
        return '"' .. v:gsub('[%c"\\]', function(c)
            if c == '"' then return '\\"' elseif c == '\\' then return '\\\\' end
            return ('\\u%04x'):format(c:byte())
        end) .. '"'
    end
    if t ~= 'table' then return '"<' .. t .. '>"' end
    local n, keys = #v, {}
    for k in pairs(v) do keys[#keys + 1] = k end
    if n > 0 and #keys == n then
        local parts = {}
        for i = 1, n do parts[i] = SetDump.json(v[i]) end
        return '[' .. table.concat(parts, ',') .. ']'
    end
    table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
    local parts = {}
    for _, k in ipairs(keys) do parts[#parts + 1] = SetDump.json(tostring(k)) .. ':' .. SetDump.json(v[k]) end
    return '{' .. table.concat(parts, ',') .. '}'
end

-- One piece as data: 'empty', a name, or {name, augments, bag, priority}
local function piece(item, empty)
    if item == empty then return 'empty' end
    if type(item) == 'string' then return item == '' and 'empty' or item end
    if type(item) == 'table' then
        if item.name == 'empty' then return 'empty' end
        -- Mote's gear.ElementalObi and kin: named at cast time by the job's code
        if item.name == '' then return '<dynamic>' end
        local p = {name = item.name}
        if type(item.augments) == 'table' then p.augments = item.augments end
        if item.bag then p.bag = item.bag end
        if item.priority then p.priority = item.priority end
        return p
    end
    return '<' .. type(item) .. '>'
end
SetDump.piece = piece

--- Every table under sets: {path, pieces, odd_keys} or {path, same_as}. A key that is
--- neither a slot nor a set (a typo: Head written for head, `wait`) goes in odd_keys.
--- @param sets table
--- @param empty table GearSwap's `empty`
--- @return table
function SetDump.walk(sets, empty)
    local out, seen = {}, {}
    local function walk(node, path)
        if seen[node] then
            out[#out + 1] = {path = path, same_as = seen[node]}
            return
        end
        seen[node] = path
        local pieces, children, odd = {}, {}, {}
        for k, v in pairs(node) do
            local slot = type(k) == 'string' and SLOT_NAME[k:lower()]
            if slot then
                pieces[slot] = piece(v, empty)
                if k:lower() ~= k then odd[#odd + 1] = k end
            elseif type(v) == 'table' and v ~= empty then
                children[#children + 1] = k
            else
                odd[#odd + 1] = tostring(k)
            end
        end
        local entry = {path = path, pieces = pieces}
        if next(odd) then entry.odd_keys = odd end
        out[#out + 1] = entry
        table.sort(children, function(a, b) return tostring(a) < tostring(b) end)
        for _, k in ipairs(children) do walk(node[k], path .. '[' .. SetDump.json(tostring(k)) .. ']') end
    end
    walk(sets, 'sets')
    return out
end

--- The tables Mote-Include's init_include makes under sets before init_gear_sets().
--- @return table
function SetDump.mote_skeleton()
    local sets = {naked = {}}
    sets.precast = {FC = {}, JA = {}, WS = {}, RA = {}}
    sets.midcast = {RA = {}, Pet = {}}
    sets.idle, sets.resting, sets.engaged, sets.defense, sets.buff = {}, {}, {}, {}, {}
    return sets
end

return SetDump

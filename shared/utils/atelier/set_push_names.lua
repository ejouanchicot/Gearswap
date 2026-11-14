---============================================================================
--- Set Push Names - the name a pushed piece is written with
---============================================================================
--- For shared/utils/atelier/set_push.lua (out of it on 2026-11-14: over 800 lines). A piece the set file already
--- names through a variable (`feet = Nyame.feet_b`, `ring1 = Acc.MoonlightRing1`) is written with that variable, read
--- from how the file's sets use it, from its gear modules and from the pieces it defines; the only copy the player
--- owns by its name; any other piece by its name and augments. The two slots of a pair (rings, earrings) never ask
--- the same copy of a piece kept apart by its bag: the slot asked takes the file's other name for it (holder,
--- changes_of).
---
--- @file    shared/utils/atelier/set_push_names.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-11-14 (moved out of set_push.lua)
---============================================================================

local Names = {}

local SetWriter = require('shared/utils/atelier/set_writer')

local function path_string(keys)
    local out = 'sets'
    for _, k in ipairs(keys) do
        out = k:match('^[%a_][%w_]*$') and (out .. '.' .. k) or (out .. '["' .. k:gsub('"', '\\"') .. '"]')
    end
    return out
end

local function node_of(keys)
    local node = rawget(_G, 'sets')
    for _, k in ipairs(keys) do
        node = type(node) == 'table' and rawget(node, k) or nil
    end
    return type(node) == 'table' and node or nil
end

--- The piece a loaded set holds in a slot, as the set file gave it (an override
--- of the page put back: SetOverrides.was).
local function loaded_piece(keys, slot)
    local ok, SetOverrides = pcall(require, 'shared/utils/atelier/set_overrides')
    local was = ok and SetOverrides.was and SetOverrides.was[path_string(keys)]
    if was and was[slot] ~= nil then return was[slot] or nil end
    local node = node_of(keys)
    if not node then return nil end
    for k, v in pairs(node) do
        if SetWriter.canon(k) == slot then return v end
    end
    return nil
end

local function piece_key(value)
    if type(value) == 'string' then return value .. '|' end
    if type(value) ~= 'table' or type(value.name) ~= 'string' then return nil end
    return value.name .. '|' .. table.concat(type(value.augments) == 'table' and value.augments or {}, '|')
end

local function note(by_copy, by_name, value, expr, all, copies)
    local key = piece_key(value)
    if not key then return end
    if copies and not copies[expr] then
        copies[expr] = {name = type(value) == 'table' and value.name or value,
            bag = type(value) == 'table' and type(value.bag) == 'string' and value.bag:lower() or nil}
    end
    if not by_copy[key] then by_copy[key] = expr end
    if all then
        all[key] = all[key] or {}
        local seen = false
        for _, e in ipairs(all[key]) do if e == expr then seen = true end end
        if not seen then table.insert(all[key], expr) end
    end
    -- a piece written by its name alone is a string: Windower's string library refuses s.name
    local name = type(value) == 'table' and value.name or value
    if key:sub(-1) == '|' and not by_name[name] then by_name[name] = expr end
end

--- The pieces of the gear modules the file requires (`local Armor = require('.../armor')`),
--- through the names the file gives them (`local Nyame = Armor.Nyame` -> Nyame.feet_b).
local function module_pieces(text, by_copy, by_name, all, copies)
    local modules = {}
    for name, mod in text:gmatch('local%s+([%a_][%w_]*)%s*=%s*require%s*%(?%s*[\'"]([^\'"]+)[\'"]') do
        local ok, m = pcall(require, mod)
        if ok and type(m) == 'table' then modules[name] = m end
    end
    local function scan(tbl, prefix)
        local keys = {}
        for k in pairs(tbl) do if type(k) == 'string' and k:match('^[%a_][%w_]*$') then keys[#keys + 1] = k end end
        table.sort(keys)
        for _, k in ipairs(keys) do
            local v = tbl[k]
            if type(v) == 'table' and type(v.name) == 'string' then note(by_copy, by_name, v, prefix .. '.' .. k, all, copies) end
        end
    end
    for alias, root, field in text:gmatch('local%s+([%a_][%w_]*)%s*=%s*([%a_][%w_]*)%.([%a_][%w_]*)') do
        local t = modules[root] and modules[root][field]
        if type(t) == 'table' then scan(t, alias) end
    end
    for name, m in pairs(modules) do scan(m, name) end
end

--- A piece written as a table in the text ({name = '...', augments = {'...', ...}}), or nil. A table holding other tables
--- (a set: `local IdleBase = {neck = {name = 'Kgt. Beads +2'}, ...}`) is not a piece: only its augments list may be one.
local function text_piece(tbl)
    local inner = tbl:sub(2, -2):gsub('augments%s*=%s*%b{}', '')
    if inner:find('{', 1, true) then return nil end
    -- a string in either quotes, the other kind inside it kept ('"Dbl.Atk."+10')
    local _, name = tbl:match([[name%s*=%s*(['"])(.-)%1]])
    if not name then return nil end
    local augs, list = {}, tbl:match('augments%s*=%s*(%b{})')
    for _, a in (list or ''):gmatch([[(['"])(.-)%1]]) do augs[#augs + 1] = a end
    local _, bag = tbl:match([[bag%s*=%s*(['"])(.-)%1]])
    return {name = name, augments = augs, bag = bag}
end

--- The pieces the file itself defines (`local SouvHead = {name = ...}`, `Cichol.da = {name = ...}`), read from its text:
--- a job the game has not loaded has no sets in memory to tell what each variable holds.
local function text_pieces(text, by_copy, by_name, all, copies)
    for var, tbl in text:gmatch('\n%s*local%s+([%a_][%w_]*)%s*=%s*(%b{})') do
        local p = text_piece(tbl)
        if p then note(by_copy, by_name, p, var, all, copies) end
    end
    for var, key, tbl in text:gmatch('\n%s*([%a_][%w_]*)%.([%a_][%w_]*)%s*=%s*(%b{})') do
        local p = var ~= 'sets' and text_piece(tbl)
        if p then note(by_copy, by_name, p, var .. '.' .. key, all, copies) end
    end
end

--- What the file's sets write through a variable: {copy key = expr}, {name = expr} for those
--- without augments; then the pieces of its gear modules and the ones the file defines (read from its text).
--- loaded: the job is the one in memory, its sets also tell what each variable they use holds (that wins).
--- Third: {copy key = every name the file has for it}, for the two copies of a ring kept apart by their bag.
--- Fourth: {name = {name, bag}}: what each name holds (bag lowercase, nil when not pinned).
local function variables(text, loaded)
    local by_copy, by_name, all, copies = {}, {}, {}, {}
    module_pieces(text, by_copy, by_name, all, copies)
    text_pieces(text, by_copy, by_name, all, copies)
    if not loaded then return by_copy, by_name, all, copies end
    local used_copy, used_name = {}, {}
    for _, def in ipairs(SetWriter.definitions(text)) do
        for _, e in ipairs(def.entries) do
            local expr = e.slot and text:sub(e.expr_from, e.expr_to)
            -- another set's piece (sets.Cure.left_ear) only exists below that set's definition: written into a
            -- set above it, the file stops loading (PLD FC.CureSelf, 2026-10-06); the piece is written plainly
            if expr and expr:match('^[%a_][%w_]*[%.%[][%w_%.%[%]\'"]*$') and expr ~= 'empty' and not expr:match('^sets[%.%[]') then
                note(used_copy, used_name, loaded_piece(def.keys, e.slot), expr, all, copies)
            end
        end
    end
    -- what the sets already write wins over the modules' other names for the same piece
    for k, v in pairs(used_copy) do by_copy[k] = v end
    for k, v in pairs(used_name) do by_name[k] = v end
    return by_copy, by_name, all, copies
end

-- The slots of a pair (SetWriter.ORDER names), each with the other one: the second slot first, so that when both are
-- asked it is the one that takes the other copy
local PAIRS = {{'ear2', 'ear1'}, {'ring2', 'ring1'}, {'ear1', 'ear2'}, {'ring1', 'ring2'}}

--- What a set already holds in a slot, for the pair check of changes_of: {expr} when its table writes the slot
--- (def: the set's own definition), else {name, bag} from the set the game loaded (keys: inherited from its base
--- too); nil when not known (a job not loaded, the slot from a base).
local function holder(text, def, keys, loaded)
    return function(slot)
        for _, e in ipairs(def and def.entries or {}) do
            if e.slot == slot then return {expr = text:sub(e.expr_from, e.expr_to)} end
        end
        local v = loaded and keys and loaded_piece(keys, slot)
        if type(v) == 'table' and type(v.name) == 'string' then
            return {name = v.name, bag = type(v.bag) == 'string' and v.bag:lower() or nil}
        end
        if type(v) == 'string' then return {name = v} end
        return nil
    end
end

--- {slot = expr | false} for SetWriter.edit.
--- held: holder() of the set written (or of its base for a new one), nil when not known
local function changes_of(req, text, loaded, held)
    local by_copy, by_name, all, copies = variables(text, loaded)
    local out = {}
    for slot, p in pairs(req.slots) do
        if p.kind == 'inherit' then out[slot] = false
        elseif p.kind == 'empty' then out[slot] = 'empty'
        elseif p.name and p.name ~= '' then
            local key = p.name .. '|' .. table.concat(p.augs, '|')
            out[slot] = by_copy[key] or (p.kind == 'one' and (by_name[p.name] or SetWriter.literal(p.name)))
                or SetWriter.literal(p.name, p.augs)
        end
    end
    -- the same piece in both slots of a pair, the file naming its copies apart (ChirichRing1 in wardrobe 1,
    -- ChirichRing2 in wardrobe 2): one name for both asked twice for the copy of one bag, and the game equipped
    -- one ring (2026-10-31). The other slot is the one asked with it, else the one the set already holds: a push of
    -- ring2 alone wrote Acc.MoonlightRing1 next to the set's own ring1 = Acc.MoonlightRing1 (WAR NaeglingKC.Group,
    -- 2026-11-07; 16 sets of Tetsouo and Kaories). The slot asked takes the file's other name for that piece
    for _, pair in ipairs(PAIRS) do
        local slot, other = pair[1], pair[2]
        local p, mine = req.slots[slot], out[slot]
        if p and mine and p.name and p.name ~= '' then
            local o
            if req.slots[other] then o = out[other] and {expr = out[other]} or nil
            elseif held then o = held(other) end
            if o and o.expr then
                local c = copies[o.expr]
                o.name, o.bag = o.name or (c and c.name), o.bag or (c and c.bag)
            end
            local c = copies[mine]
            local same = o and (o.expr == mine
                or (c and c.bag and o.bag and o.name == p.name and c.bag == o.bag))
            if same then
                for _, expr in ipairs(all[p.name .. '|' .. table.concat(p.augs, '|')] or {}) do
                    local e = copies[expr]
                    if expr ~= mine and expr ~= o.expr and not (e and e.bag and o.bag and e.bag == o.bag) then
                        out[slot] = expr
                        break
                    end
                end
            end
        end
    end
    return out
end

Names.path_string, Names.node_of, Names.loaded_piece = path_string, node_of, loaded_piece
Names.holder, Names.changes_of = holder, changes_of

return Names

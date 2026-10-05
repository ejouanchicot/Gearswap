---============================================================================
--- Set Overrides - pieces changed in the Atelier page, laid over the set files
---============================================================================
--- The Atelier page (data/atelier.html, Sets tab: try a piece, then "Save")
--- writes the pieces a player changes into <Char>/atelier/overrides/set_overrides.lua (saved/ before 2026-10-05).
--- The set files are never rewritten: deleting that file brings every set back.
---
--- Format of the file:
---   return {
---       PLD = {
---           ['sets.idle'] = { body = "Sakpata's Plate", ring1 = 'empty' },
---           ['sets.precast.WS["Savage Blade"]'] = {
---               back = { name = "Rudianos's Mantle", augments = { 'STR+20', 'Weapon skill damage +10%' } },
---           },
---       },
---   }
--- 'empty' is GearSwap's empty slot. A path that no longer exists is skipped.
--- Only the named set changes: a set built from it by set_combine was copied
--- when the set file ran and keeps its own pieces.
---
--- Applied by INIT_SYSTEMS.lua, right after Mote has run init_gear_sets().
---
--- @file shared/utils/atelier/set_overrides.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-01
---============================================================================

local SetOverrides = {}

local FILE = 'set_overrides.lua'

-- Every spelling GearSwap accepts for a slot, by the page's name
local SPELLINGS = {
    ear1 = {'ear1', 'left_ear', 'lear'}, ear2 = {'ear2', 'right_ear', 'rear'},
    ring1 = {'ring1', 'left_ring', 'lring'}, ring2 = {'ring2', 'right_ring', 'rring'},
    range = {'range', 'ranged'},
}

--- The overrides file of the character, read now, or nil when there is none.
--- @return table|nil {<JOB> = {path = {slot = piece}}}
function SetOverrides.read()
    local ok, CharPaths = pcall(require, 'shared/utils/core/char_paths')
    local path = ok and CharPaths and CharPaths.file('atelier', FILE)
    if not path then return nil end
    local ok_load, data = pcall(dofile, path)
    return (ok_load and type(data) == 'table') and data or nil
end

--- The table a path names ('sets.idle', 'sets.precast.WS["Savage Blade"]'), or nil.
local function resolve(path)
    if type(path) ~= 'string' or path:sub(1, 4) ~= 'sets' then return nil end
    local node, rest = rawget(_G, 'sets'), path:sub(5)
    while node and rest ~= '' do
        local name, after = rest:match('^%.([%w_%-]+)(.*)$')
        if not name then name, after = rest:match('^%["(.-)"%](.*)$') end
        if not name then return nil end
        node = type(node) == 'table' and rawget(node, name) or nil
        rest = after
    end
    return type(node) == 'table' and node or nil
end

--- The piece as GearSwap wants it: a name, a {name, augments} table or `empty`.
local function piece_of(value)
    if value == 'empty' then return rawget(_G, 'empty') or 'empty' end
    if type(value) == 'string' then return value end
    if type(value) == 'table' and type(value.name) == 'string' then
        return {name = value.name, augments = type(value.augments) == 'table' and value.augments or nil}
    end
    return nil
end

--- Lay the job's overrides over its sets. `SetOverrides.was[path][slot]` keeps
--- what the set file gave (false for nothing), for the Atelier export.
--- @param job string Job code ("PLD")
function SetOverrides.apply(job)
    SetOverrides.was = {}
    local data = job and SetOverrides.read()
    local mine = data and type(data[job]) == 'table' and data[job]
    if not mine then return end
    for path, slots in pairs(mine) do
        local set = resolve(path)
        if set and type(slots) == 'table' then
            local was = {}
            for slot, value in pairs(slots) do
                local p = piece_of(value)
                if p ~= nil then
                    local spellings = SPELLINGS[slot] or {slot}
                    for _, name in ipairs(spellings) do
                        if was[slot] == nil and rawget(set, name) ~= nil then was[slot] = rawget(set, name) end
                        set[name] = nil
                    end
                    if was[slot] == nil then was[slot] = false end
                    set[slot] = p
                end
            end
            SetOverrides.was[path] = was
        end
    end
end

--- The sets as the set files wrote them, for a while: every piece the overrides laid is put
--- back to the file's (SetOverrides.was). The Atelier's simulation runs an action this way to
--- show what the file alone would wear.
--- @return function restore Lays the overrides again
function SetOverrides.as_file()
    local saved = {}
    for path, was in pairs(SetOverrides.was or {}) do
        local set = resolve(path)
        if set then
            for slot, original in pairs(was) do
                local keep = {}
                for _, name in ipairs(SPELLINGS[slot] or {slot}) do keep[name] = rawget(set, name); set[name] = nil end
                if original ~= false then set[slot] = original end
                saved[#saved + 1] = {set = set, slot = slot, keep = keep}
            end
        end
    end
    return function()
        for _, e in ipairs(saved) do
            e.set[e.slot] = nil
            for name, v in pairs(e.keep) do e.set[name] = v end
        end
    end
end

return SetOverrides

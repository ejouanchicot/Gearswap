---============================================================================
--- Atelier Families - the spell families the midcast sets are named after
---============================================================================
--- MidcastManager picks a set under a skill by the spell's family (its
--- database_func, shared/utils/midcast/midcast_manager.lua steps P2-P7):
--- sets.midcast['Enfeebling Magic'].duration is worn by Sleep, Bind, Break and
--- Silence. The Atelier page (data/atelier.html) shows under such a set which
--- spells reach it, from the table built here, keyed by the set's parent:
---   ['Enfeebling Magic'], ['Enhancing Magic']   the spell databases
---   MndEnfeebles, IntEnfeebles                  BLM / SCH: the Enfeebling families
---                                               of white / black magic
---   ['Blue Magic']                              BLU: BLUSpellMap.category
---   Ninjutsu                                    NIN: Ninjutsu.family
---   Helix                                       SCH: Dark / Light helices
---   midcast                                     sets.midcast.Indi / .Geo (GEO) and
---                                               the song types (BRD: .Minne, .March...)
---
--- Written into data/atelier/index.js (window.ATELIER_FAMILIES) by
--- AtelierExport.write_index (shared/utils/atelier/atelier_export.lua). The
--- families read from the game's spell list need GearSwap's resources (in game).
---
--- @file shared/utils/atelier/atelier_families.lua
--- @author ejouanchicot
--- @version 1.1
--- @date Created: 2026-10-01 | Updated: 2026-10-02
---============================================================================

local AtelierFamilies = {}

-- skill name -> database module and the field that holds the family
local SOURCES = {
    {skill = 'Enfeebling Magic', module = 'shared/data/magic/ENFEEBLING_MAGIC_DATABASE', field = 'enfeebling_type'},
    {skill = 'Enhancing Magic', module = 'shared/data/magic/ENHANCING_MAGIC_DATABASE', field = 'spell_family'},
}

local function add(out, parent, family, name)
    if not (parent and family and name) then return end
    out[parent] = out[parent] or {}
    out[parent][family] = out[parent][family] or {}
    table.insert(out[parent][family], name)
end

-- A module's function, or nil when it does not load (the job's code is optional here)
local function fn(module, name)
    local ok, mod = pcall(require, module)
    return ok and type(mod) == 'table' and type(mod[name]) == 'function' and mod[name] or nil
end

-- The families read from the spell databases (Enfeebling, Enhancing)
local function from_databases(out)
    local enfeebling = {}
    for _, src in ipairs(SOURCES) do
        local ok, db = pcall(require, src.module)
        if ok and type(db) == 'table' and type(db.spells) == 'table' then
            for name, data in pairs(db.spells) do
                local family = type(data) == 'table' and data[src.field]
                if type(family) == 'string' and family ~= '' then
                    add(out, src.skill, family, name)
                    if src.skill == 'Enfeebling Magic' then enfeebling[name] = family end
                end
            end
        end
    end
    return enfeebling
end

-- A classifier's answer, nil when it fails (one spell must not lose the others)
local function safe(f, name)
    if not f then return nil end
    local ok, family = pcall(f, name)
    return ok and family or nil
end

-- The families read from the game's spell list (GearSwap's resources, in game)
local function from_spells(out, enfeebling)
    local ok_g, G = pcall(function() return gearswap end)
    local res = ok_g and type(G) == 'table' and G.res
    if not (res and res.spells) then return end
    local blu = fn('shared/jobs/blu/functions/logic/spell_map', 'category')
    local nin = fn('shared/jobs/nin/functions/logic/ninjutsu', 'family')
    local song = fn('shared/utils/midcast/midcast_manager', 'get_song_type')
    for _, line in pairs(res.spells) do
        local name = type(line) == 'table' and line.en
        if name then
            local skill = res.skills and res.skills[line.skill] and res.skills[line.skill].en
            -- BLM / SCH: white enfeebles under MndEnfeebles, black ones under IntEnfeebles
            if enfeebling[name] then
                add(out, line.type == 'WhiteMagic' and 'MndEnfeebles' or 'IntEnfeebles', enfeebling[name], name)
            end
            if skill == 'Blue Magic' and blu then add(out, 'Blue Magic', safe(blu, name), name) end
            if skill == 'Ninjutsu' and nin then add(out, 'Ninjutsu', safe(nin, name), name) end
            local helix = name:match('^(Nocto)helix') and 'Dark' or name:match('^(Lumino)helix') and 'Light'
            if helix then add(out, 'Helix', helix, name) end
            local geo = name:match('^(Indi)%-') or name:match('^(Geo)%-')
            if geo then add(out, 'midcast', geo, name) end
            if line.type == 'BardSong' and song then add(out, 'midcast', safe(song, name), name) end
        end
    end
end

--- The families and their spells, sorted, by the set's parent key (see header):
--- { ['Enfeebling Magic'] = { duration = {'Bind', 'Break', ...}, ... }, midcast = { Indi = {...} } }
--- A source that fails to load is left out.
--- @return table
function AtelierFamilies.collect()
    local out = {}
    local enfeebling = from_databases(out)
    pcall(from_spells, out, enfeebling)
    for _, families in pairs(out) do
        for _, list in pairs(families) do table.sort(list) end
    end
    return out
end

return AtelierFamilies

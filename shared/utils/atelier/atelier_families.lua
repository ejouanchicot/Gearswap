---============================================================================
--- Atelier Families - the spell families the midcast sets are named after
---============================================================================
--- MidcastManager picks a set under a skill by the spell's family, read from
--- the spell databases (shared/utils/midcast/midcast_manager.lua, step P7):
--- sets.midcast['Enfeebling Magic'].duration is worn by Sleep, Bind, Break and
--- Silence (enfeebling_type), sets.midcast['Enhancing Magic'].BarElement by the
--- Bar- spells (spell_family). The Atelier page (data/atelier.html) shows under
--- such a set which spells reach it, from the table built here.
---
--- Written into data/atelier/index.js (window.ATELIER_FAMILIES) by
--- AtelierExport.write_index (shared/utils/atelier/atelier_export.lua).
---
--- @file shared/utils/atelier/atelier_families.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-01
---============================================================================

local AtelierFamilies = {}

-- skill name -> database module and the field that holds the family
local SOURCES = {
    {skill = 'Enfeebling Magic', module = 'shared/data/magic/ENFEEBLING_MAGIC_DATABASE', field = 'enfeebling_type'},
    {skill = 'Enhancing Magic', module = 'shared/data/magic/ENHANCING_MAGIC_DATABASE', field = 'spell_family'},
}

--- The families of each skill and their spells, sorted:
--- { ['Enfeebling Magic'] = { duration = {'Bind', 'Break', ...}, ... }, ... }
--- A database that fails to load is left out.
--- @return table
function AtelierFamilies.collect()
    local out = {}
    for _, src in ipairs(SOURCES) do
        local ok, db = pcall(require, src.module)
        if ok and type(db) == 'table' and type(db.spells) == 'table' then
            local families = {}
            for name, data in pairs(db.spells) do
                local family = type(data) == 'table' and data[src.field]
                if type(family) == 'string' and family ~= '' then
                    families[family] = families[family] or {}
                    table.insert(families[family], name)
                end
            end
            for _, list in pairs(families) do table.sort(list) end
            out[src.skill] = families
        end
    end
    return out
end

return AtelierFamilies

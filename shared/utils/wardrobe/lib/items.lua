---  ═══════════════════════════════════════════════════════════════════════════
---   Wardrobe Organizer - Item Helpers
---  ═══════════════════════════════════════════════════════════════════════════
---   Read-only utilities that consult the FFXI resource database (`res.items`)
---   and walk the active GearSwap `sets` table to discover used item names.
---
---   Public functions:
---     Items.item_names(item_id)           - all name variants (en/enl/log) lowercase
---     Items.display_name(item_id)         - canonical English name (or 'id:N')
---     Items.is_equipment(item_id)         - true if has wearable slot bits
---     Items.is_used_name(id, used_set)    - true if any name variant is in used_set
---     Items.collect_used_names()          - walks _G.sets, returns {[name_lower]=true}
---
---   @file shared/utils/wardrobe/lib/items.lua
---  ═══════════════════════════════════════════════════════════════════════════

local Config = require('shared/utils/wardrobe/lib/config')
local res = require('resources')

local Items = {}

--- Return all name variants for an item (en, enl, english, english_log) lowercase.
function Items.item_names(item_id)
    local d = res.items[item_id]
    if not d then
        return {}
    end
    local names = {}
    for _, field in ipairs({'en', 'enl', 'english', 'english_log'}) do
        local n = d[field]
        if n and type(n) == 'string' and n ~= '' then
            table.insert(names, n:lower())
        end
    end
    return names
end

--- Canonical display name (English) or 'id:N' fallback.
function Items.display_name(item_id)
    local d = res.items[item_id]
    return (d and d.en) or ('id:' .. tostring(item_id))
end

--- True if the item has at least one wearable slot bit set.
--- This filters out consumables, food, key items, currency etc.
function Items.is_equipment(item_id)
    local d = res.items[item_id]
    return (d and d.slots and d.slots ~= 0) or false
end

--- Check if any name variant of `item_id` appears in the `used_names` set.
function Items.is_used_name(item_id, used_names)
    for _, n in ipairs(Items.item_names(item_id)) do
        if used_names[n] then
            return true
        end
    end
    return false
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SETS WALKING
---  ═══════════════════════════════════════════════════════════════════════════
--- Recursive walker. `visited` table prevents infinite loops on self-referential
--- sets. Hard depth cap at Config.MAX_WALK_DEPTH for pathological cases.

local function walk_sets(t, used, visited, depth)
    visited = visited or {}
    depth = depth or 0
    if depth > Config.MAX_WALK_DEPTH then
        return
    end
    if visited[t] then
        return
    end
    visited[t] = true

    for k, v in pairs(t) do
        if type(v) == 'string' and Config.SLOT_KEYS[k] then
            used[v:lower()] = true
        elseif type(v) == 'table' then
            walk_sets(v, used, visited, depth + 1)
        end
    end
end

--- Walk the active job's _G.sets table and return a set of used item names.
--- Returns nil if no sets table is loaded (e.g. no job active).
function Items.collect_used_names()
    if not _G.sets or type(_G.sets) ~= 'table' then
        return nil
    end
    local used = {}
    walk_sets(_G.sets, used)
    return used
end

return Items

---============================================================================
--- Wardrobe Organizer - Item Helpers
---============================================================================
--- Read-only utilities that consult the FFXI resource database (`res.items`)
--- and walk the active GearSwap `sets` table to discover used item names.
---
--- Public functions:
---   Items.item_names(item_id)           - all name variants lowercase
---   Items.display_name(item_id)         - canonical English name (or 'id:N')
---   Items.is_equipment(item_id)         - true if the organizer may move it
---   Items.is_used_name(id, used_set)    - true if any name variant is in used_set
---   Items.add_always_kept(used)         - adds KEEP_ITEMS and, if needed, warp items
---   Items.collect_used_names()          - used names of the scope (Config.SCOPE)
---
--- @file shared/utils/wardrobe/lib/items.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-05-01
---============================================================================

local Config = require('shared/utils/wardrobe/lib/config')
local res = require('resources')

local Items = {}

--- Return all name variants for an item (en, enl, english, english_log) lowercase.
--- @param item_id number Item id
--- @return table Array of lowercase names (empty if unknown id)
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
--- @param item_id number Item id
--- @return string Name
function Items.display_name(item_id)
    local d = res.items[item_id]
    return (d and d.en) or ('id:' .. tostring(item_id))
end

--- True for equipment the organizer may move: at least one wearable slot bit
--- (not consumables, key items...), and not a NEVER_MOVE item of the config,
--- which the organizer then never sees.
--- @param item_id number Item id
--- @return boolean
function Items.is_equipment(item_id)
    local d = res.items[item_id]
    if not (d and d.slots and d.slots ~= 0) then return false end
    local frozen = Config.RULES and Config.RULES.never_move
    if frozen and next(frozen) then
        for _, n in ipairs(Items.item_names(item_id)) do
            if frozen[n] then return false end
        end
    end
    return true
end

--- Check if any name variant of `item_id` appears in the `used_names` set.
--- @param item_id number Item id
--- @param used_names table Set {[name_lower] = true}
--- @return boolean
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
        -- A slot holds either a name or an advanced entry {name=, augments=,
        -- bag=, priority=}; the entry is the piece, not a nested set.
        local name = Config.SLOT_KEYS[k]
            and ((type(v) == 'string' and v) or (type(v) == 'table' and type(v.name) == 'string' and v.name))
        if name then
            used[name:lower()] = true
        elseif type(v) == 'table' then
            walk_sets(v, used, visited, depth + 1)
        end
    end
end

--- Can everything sent to overflow still be equipped from where it lands?
--- FFXI equips from inventory and wardrobes only; Sack, Case and Satchel are
--- storage. A character overflowing into wardrobes loses nothing by it.
--- @return boolean
local function overflow_stays_reachable()
    local bags = Config.OVERFLOW_BAGS or {}
    if #bags == 0 then return true end
    for _, bag_id in ipairs(bags) do
        local bag = res.bags[bag_id]
        if not (bag and bag.equippable) then
            return false
        end
    end
    return true
end

--- Mark the items a feature needs but no gear set names.
---
--- KEEP_ITEMS is always honoured: it is an explicit choice.
---
--- The warp and teleport rings are added only when overflow leads somewhere
--- unequippable. Pinning 65 warp items costs primary-bag slots, and a
--- character overflowing into wardrobes does not need it - the warp system
--- searches every equippable bag, so the rings work fine out there.
--- @param used table Set of lowercase item names, modified in place
--- @return table The same table
function Items.add_always_kept(used)
    for _, name in ipairs(Config.KEEP_ITEMS or {}) do
        used[tostring(name):lower()] = true
    end

    if overflow_stays_reachable() then
        return used
    end

    -- Prefer the scanned list when the character has one: it names the rings
    -- actually owned instead of all 65 the database knows.
    local owned_ok, WarpOwned = pcall(require, 'shared/utils/wardrobe/lib/warp_owned')
    local names = owned_ok and WarpOwned and WarpOwned.load() or nil

    if not names then
        local ok, WarpDatabase = pcall(require, 'shared/utils/warp/database/warp_database_core')
        if ok and WarpDatabase and WarpDatabase.get_all_item_names then
            names = WarpDatabase.get_all_item_names()
        end
    end

    for _, name in ipairs(names or {}) do
        used[tostring(name):lower()] = true
    end

    return used
end

--- Used item names of the scope: the active job's _G.sets ('active_job'),
--- or every job's set files ('all_jobs'), plus KEEP and the warp items.
--- Returns nil if no sets table is loaded (e.g. no job active).
--- @return table|nil Set {[name_lower] = true}
function Items.collect_used_names()
    if not _G.sets or type(_G.sets) ~= 'table' then
        return nil
    end
    local used = {}
    if Config.SCOPE == 'all_jobs' then
        local ok, Auditor = pcall(require, 'shared/utils/equipment/wardrobe_auditor')
        if ok and Auditor and Auditor.collect_all_used_names then
            for name in pairs(Auditor.collect_all_used_names()) do used[name] = true end
        end
    end
    walk_sets(_G.sets, used)
    return Items.add_always_kept(used)
end

return Items

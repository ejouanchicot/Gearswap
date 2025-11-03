---============================================================================
--- Warp Database - Nations + Jeuno (4 destinations, 4 items)
---============================================================================
--- Contains warp items for the three nations and Jeuno.
--- Destinations: San d'Oria, Bastok, Windurst, Jeuno
---
--- @file warp_database_nations.lua
--- @author Tetsouo
--- @version 4.0 - Modular Architecture
--- @date 2025-10-28
---============================================================================

local WarpDatabaseCore = require('shared/utils/warp/database/warp_database_core')
local DEST = WarpDatabaseCore.DESTINATIONS

local NationsDB = {}

---============================================================================
--- NATION + JEUNO ITEMS (4 items)
---============================================================================

local ITEMS = {
    [DEST.SAN_DORIA] = {
        [16039] = {
            name = 'Kingdom Earring',
            slot = 'ears',
            priority = 1,
            max_charges = 30,
            recast_delay = 3600,       -- 1 hour
            level = 20,
            cast_time = 8,
            cast_delay = 30,
            notes = "Southern San d'Oria",
        },
    },

    [DEST.BASTOK] = {
        [16040] = {
            name = 'Republic Earring',
            slot = 'ears',
            priority = 1,
            max_charges = 30,
            recast_delay = 3600,       -- 1 hour
            level = 20,
            cast_time = 8,
            cast_delay = 30,
            notes = 'Bastok Markets',
        },
    },

    [DEST.WINDURST] = {
        [16041] = {
            name = 'Federation Earring',
            slot = 'ears',
            priority = 1,
            max_charges = 30,
            recast_delay = 3600,       -- 1 hour
            level = 20,
            cast_time = 8,
            cast_delay = 30,
            notes = 'Windurst Waters',
        },
    },

    [DEST.JEUNO] = {
        [16042] = {
            name = 'Duchy Earring',
            slot = 'ears',
            priority = 1,
            max_charges = 30,
            recast_delay = 3600,       -- 1 hour
            level = 30,
            cast_time = 8,
            cast_delay = 30,
            notes = 'Upper Jeuno',
        },
    },
}

---============================================================================
--- PUBLIC API (Standard Interface)
---============================================================================

function NationsDB.get_items(destination_key)
    local destination_items = ITEMS[destination_key]
    if not destination_items then
        return {}
    end

    local items_array = {}
    for item_id, item_data in pairs(destination_items) do
        table.insert(items_array, {
            item_id = item_id,
            data = item_data
        })
    end

    table.sort(items_array, function(a, b)
        return a.data.priority < b.data.priority
    end)

    return items_array
end

function NationsDB.get_item_by_id(item_id)
    for destination_key, destination_items in pairs(ITEMS) do
        local item_data = destination_items[item_id]
        if item_data then
            return item_data, destination_key
        end
    end
    return nil, nil
end

function NationsDB.count_items()
    local count = 0
    for _, destination_items in pairs(ITEMS) do
        for _ in pairs(destination_items) do
            count = count + 1
        end
    end
    return count
end

return NationsDB

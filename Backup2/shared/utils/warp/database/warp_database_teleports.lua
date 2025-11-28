---============================================================================
--- Warp Database - Teleport Crags (6 destinations, 9 items)
---============================================================================
--- Contains all items that teleport to the 6 crag locations.
--- Destinations: Holla, Dem, Mea, Vahzl, Yhoat, Altep
---
--- @file warp_database_teleports.lua
--- @author Tetsouo
--- @version 4.0 - Modular Architecture
--- @date 2025-10-28
---============================================================================

local WarpDatabaseCore = require('shared/utils/warp/database/warp_database_core')
local DEST = WarpDatabaseCore.DESTINATIONS

local TeleportsDB = {}

---============================================================================
--- TELEPORT CRAG ITEMS (9 items across 6 destinations)
---============================================================================

local ITEMS = {
    [DEST.CRAG_HOLLA] = {
        [14661] = {
            name = 'Holla Ring',
            slot = 'ring',
            priority = 1,
            max_charges = 10,
            recast_delay = 3600,       -- 1 hour
            level = 65,
            cast_time = 8,
            cast_delay = 30,
            notes = 'Reusable, 10 charges',
        },
        [26176] = {
            name = 'Dim. Ring (Holla)',
            slot = 'ring',
            priority = 2,
            max_charges = 1,
            recast_delay = 600,        -- 10 minutes
            level = 99,
            cast_time = 8,
            cast_delay = 8,
            notes = 'Consumable-like',
        },
    },

    [DEST.CRAG_DEM] = {
        [14662] = {
            name = 'Dem Ring',
            slot = 'ring',
            priority = 1,
            max_charges = 10,
            recast_delay = 3600,       -- 1 hour
            level = 65,
            cast_time = 8,
            cast_delay = 30,
        },
        [26177] = {
            name = 'Dim. Ring (Dem)',
            slot = 'ring',
            priority = 2,
            max_charges = 1,
            recast_delay = 600,        -- 10 minutes
            level = 99,
            cast_time = 8,
            cast_delay = 8,
        },
    },

    [DEST.CRAG_MEA] = {
        [14663] = {
            name = 'Mea Ring',
            slot = 'ring',
            priority = 1,
            max_charges = 10,
            recast_delay = 3600,       -- 1 hour
            level = 65,
            cast_time = 8,
            cast_delay = 30,
        },
        [26178] = {
            name = 'Dim. Ring (Mea)',
            slot = 'ring',
            priority = 2,
            max_charges = 1,
            recast_delay = 600,        -- 10 minutes
            level = 99,
            cast_time = 8,
            cast_delay = 8,
        },
    },

    [DEST.CRAG_VAHZL] = {
        [14664] = {
            name = 'Vahzl Ring',
            slot = 'ring',
            priority = 1,
            max_charges = 10,
            recast_delay = 3600,       -- 1 hour
            level = 65,
            cast_time = 8,
            cast_delay = 30,
        },
    },

    [DEST.CRAG_YHOAT] = {
        [14665] = {
            name = 'Yhoat Ring',
            slot = 'ring',
            priority = 1,
            max_charges = 10,
            recast_delay = 3600,       -- 1 hour
            level = 65,
            cast_time = 8,
            cast_delay = 30,
        },
    },

    [DEST.CRAG_ALTEP] = {
        [14666] = {
            name = 'Altep Ring',
            slot = 'ring',
            priority = 1,
            max_charges = 10,
            recast_delay = 3600,       -- 1 hour
            level = 65,
            cast_time = 8,
            cast_delay = 30,
        },
    },
}

---============================================================================
--- PUBLIC API (Standard Interface)
---============================================================================

function TeleportsDB.get_items(destination_key)
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

function TeleportsDB.get_item_by_id(item_id)
    for destination_key, destination_items in pairs(ITEMS) do
        local item_data = destination_items[item_id]
        if item_data then
            return item_data, destination_key
        end
    end
    return nil, nil
end

function TeleportsDB.count_items()
    local count = 0
    for _, destination_items in pairs(ITEMS) do
        for _ in pairs(destination_items) do
            count = count + 1
        end
    end
    return count
end

return TeleportsDB

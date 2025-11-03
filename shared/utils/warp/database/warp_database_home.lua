---============================================================================
--- Warp Database - Home Point / Warp Items
---============================================================================
--- Contains all items that warp to home point (Warp spell equivalent).
--- Total: 5 items
---
--- @file warp_database_home.lua
--- @author Tetsouo
--- @version 4.0 - Modular Architecture
--- @date 2025-10-28
---============================================================================

local WarpDatabaseCore = require('shared/utils/warp/database/warp_database_core')
local DEST = WarpDatabaseCore.DESTINATIONS

local HomeDB = {}

---============================================================================
--- HOME POINT ITEMS (5 items)
---============================================================================

local ITEMS = {
    [DEST.HOME_POINT] = {
        [28540] = {
            name = 'Warp Ring',
            slot = 'ring',
            priority = 1,
            max_charges = 1,
            recast_delay = 600,        -- 10 minutes
            level = 1,
            cast_time = 8,             -- VERIFIED
            cast_delay = 8,            -- VERIFIED
            notes = 'Standard warp ring',
        },

        [4181] = {
            name = 'Instant Warp',
            slot = 'item',
            priority = 2,
            max_charges = 0,           -- Consumable
            recast_delay = 0,
            level = 1,
            cast_time = 10,            -- VERIFIED (usable item)
            cast_delay = 0,            -- VERIFIED (no delay)
            notes = 'Consumable scroll',
        },

        [17588] = {
            name = 'Treat Staff II',
            slot = 'main',
            priority = 3,
            max_charges = 1,
            recast_delay = 72000,      -- 20 hours
            level = 2,
            cast_time = 8,             -- VERIFIED
            cast_delay = 30,           -- VERIFIED
            notes = 'Weapon slot',
        },

        [17040] = {
            name = 'Warp Cudgel',
            slot = 'main',
            priority = 4,
            max_charges = 30,
            recast_delay = 60,         -- 1 minute
            level = 36,
            cast_time = 8,             -- VERIFIED
            cast_delay = 3,            -- VERIFIED (special!)
            notes = 'Blocks weapon slot',
        },

        [17566] = {
            name = 'Treat Staff',
            slot = 'main',
            priority = 5,
            max_charges = 1,
            recast_delay = 72000,      -- 20 hours
            level = 1,
            cast_time = 0,             -- VERIFIED (latent - no cast)
            cast_delay = 0,            -- VERIFIED (latent - no cast)
            notes = 'Latent effect',
        },
    },
}

---============================================================================
--- PUBLIC API
---============================================================================

--- Get all items for a destination (sorted by priority)
--- @param destination_key string Destination constant
--- @return table Array of {data={item fields}, item_id=number}
function HomeDB.get_items(destination_key)
    local destination_items = ITEMS[destination_key]
    if not destination_items then
        return {}
    end

    -- Convert to array and sort by priority
    local items_array = {}
    for item_id, item_data in pairs(destination_items) do
        table.insert(items_array, {
            item_id = item_id,
            data = item_data
        })
    end

    -- Sort by priority (lower = higher priority)
    table.sort(items_array, function(a, b)
        return a.data.priority < b.data.priority
    end)

    return items_array
end

--- Get item data by item ID
--- @param item_id number Item ID
--- @return table|nil Item data
--- @return string|nil Destination key
function HomeDB.get_item_by_id(item_id)
    for destination_key, destination_items in pairs(ITEMS) do
        local item_data = destination_items[item_id]
        if item_data then
            return item_data, destination_key
        end
    end
    return nil, nil
end

--- Count total items in this module
--- @return number Item count
function HomeDB.count_items()
    local count = 0
    for _, destination_items in pairs(ITEMS) do
        for _ in pairs(destination_items) do
            count = count + 1
        end
    end
    return count
end

return HomeDB

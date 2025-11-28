---============================================================================
--- Warp Database - Cities, Chocobo Stables & Conquest (15 destinations, 17 items)
---============================================================================
--- Contains:
---   - Outpost Cities: Selbina, Mhaura, Rabao, Kazham, Norg (5)
---   - Expansion Cities: Tavnazia, Whitegate, Nashmau, Adoulin (4)
---   - Chocobo Stables: San d'Oria, Bastok, Windurst, Jeuno (4)
---   - Conquest Outpost: Current outpost (1)
---   - Adoulin City: Adoulin Castle Gates (1)
---
--- @file warp_database_cities_chocobo_conquest.lua
--- @author Tetsouo
--- @version 4.0 - Modular Architecture
--- @date 2025-10-28
---============================================================================

local WarpDatabaseCore = require('shared/utils/warp/database/warp_database_core')
local DEST = WarpDatabaseCore.DESTINATIONS

local CitiesDB = {}

---============================================================================
--- ALL ITEMS (17 items across 15 destinations)
---============================================================================

local ITEMS = {
    -- OUTPOST CITIES (5)
    [DEST.SELBINA] = {[16043] = {name='Selbina Earring', slot='ears', priority=1, max_charges=30, recast_delay=3600, level=25, cast_time=8, cast_delay=30}},
    [DEST.MHAURA] = {[16044] = {name='Mhaura Earring', slot='ears', priority=1, max_charges=30, recast_delay=3600, level=25, cast_time=8, cast_delay=30}},
    [DEST.RABAO] = {[16045] = {name='Rabao Earring', slot='ears', priority=1, max_charges=30, recast_delay=3600, level=30, cast_time=8, cast_delay=30}},
    [DEST.KAZHAM] = {[16046] = {name='Kazham Earring', slot='ears', priority=1, max_charges=30, recast_delay=3600, level=30, cast_time=8, cast_delay=30}},
    [DEST.NORG] = {[16047] = {name='Norg Earring', slot='ears', priority=1, max_charges=30, recast_delay=3600, level=40, cast_time=8, cast_delay=30}},

    -- EXPANSION CITIES (4)
    [DEST.TAVNAZIA] = {
        [14672] = {name='Tavnazian Ring', slot='ring', priority=1, max_charges=1, recast_delay=86400, level=60, cast_time=8, cast_delay=30},
        [16048] = {name='Safehold Earring', slot='ears', priority=2, max_charges=30, recast_delay=3600, level=40, cast_time=8, cast_delay=30},
    },
    [DEST.WHITEGATE] = {[16049] = {name='Empire Earring', slot='ears', priority=1, max_charges=30, recast_delay=3600, level=40, cast_time=8, cast_delay=30}},
    [DEST.NASHMAU] = {[16050] = {name='Nashmau Earring', slot='ears', priority=1, max_charges=30, recast_delay=3600, level=50, cast_time=8, cast_delay=30}},
    [DEST.ADOULIN] = {[26523] = {name="Delegate's Garb", slot='body', priority=1, max_charges=1, recast_delay=72000, level=1, cast_time=8, cast_delay=30}},

    -- CHOCOBO STABLES (4)
    [DEST.STABLE_SANDORIA] = {[13179] = {name='Kgd. Stable Collar', slot='neck', priority=1, max_charges=10, recast_delay=3600, level=15, cast_time=8, cast_delay=30}},
    [DEST.STABLE_BASTOK] = {[13180] = {name='Rep. Stable Medal', slot='neck', priority=1, max_charges=10, recast_delay=3600, level=15, cast_time=8, cast_delay=30}},
    [DEST.STABLE_WINDURST] = {[13181] = {name='Fed. Stable Scarf', slot='neck', priority=1, max_charges=10, recast_delay=3600, level=15, cast_time=8, cast_delay=30}},
    [DEST.STABLE_JEUNO] = {[25585] = {name='Bl. Chocobo Cap', slot='head', priority=1, max_charges=1, recast_delay=72000, level=1, cast_time=8, cast_delay=30}},

    -- CONQUEST OUTPOST (1)
    [DEST.CONQUEST_OUTPOST] = {
        [15541] = {name='Homing Ring', slot='ring', priority=1, max_charges=30, recast_delay=3600, level=1, cast_time=8, cast_delay=30, notes='Current outpost'},
        [15542] = {name='Return Ring', slot='ring', priority=2, max_charges=10, recast_delay=3600, level=1, cast_time=8, cast_delay=30, notes='Current outpost'},
    },
}

---============================================================================
--- PUBLIC API (Standard Interface)
---============================================================================

function CitiesDB.get_items(destination_key)
    local destination_items = ITEMS[destination_key]
    if not destination_items then return {} end

    local items_array = {}
    for item_id, item_data in pairs(destination_items) do
        table.insert(items_array, {item_id = item_id, data = item_data})
    end

    table.sort(items_array, function(a, b) return a.data.priority < b.data.priority end)
    return items_array
end

function CitiesDB.get_item_by_id(item_id)
    for destination_key, destination_items in pairs(ITEMS) do
        local item_data = destination_items[item_id]
        if item_data then return item_data, destination_key end
    end
    return nil, nil
end

function CitiesDB.count_items()
    local count = 0
    for _, destination_items in pairs(ITEMS) do
        for _ in pairs(destination_items) do count = count + 1 end
    end
    return count
end

return CitiesDB

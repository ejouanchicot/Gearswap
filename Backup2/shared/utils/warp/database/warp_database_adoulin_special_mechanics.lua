---============================================================================
--- Warp Database - Adoulin + Special + Mechanics (COMBINED) (21 dest, ~40 items)
---============================================================================
--- Combined module for efficiency containing:
---   - Adoulin Frontier: 7 stations (7 items)
---   - Special Locations: 12 locations (~25 items)
---   - Unique Mechanics: 2 items
---
--- @file warp_database_adoulin_special_mechanics.lua
--- @author Tetsouo
--- @version 4.0 - Modular Architecture
--- @date 2025-10-28
---============================================================================

local WarpDatabaseCore = require('shared/utils/warp/database/warp_database_core')
local DEST = WarpDatabaseCore.DESTINATIONS

local CombinedDB = {}

---============================================================================
--- ALL REMAINING ITEMS (~40 items across 21 destinations)
---============================================================================

local ITEMS = {
    -- ADOULIN FRONTIER (7 stations, 7 items)
    [DEST.CEIZAK] = {[28555] = {name='Ceizak Ring', slot='ring', priority=1, max_charges=10, recast_delay=3600, level=99, cast_time=8, cast_delay=30}},
    [DEST.YAHSE] = {[28556] = {name='Yahse Ring', slot='ring', priority=1, max_charges=10, recast_delay=3600, level=99, cast_time=8, cast_delay=30}},
    [DEST.HENNETIEL] = {[28557] = {name='Hennetiel Ring', slot='ring', priority=1, max_charges=10, recast_delay=3600, level=99, cast_time=8, cast_delay=30}},
    [DEST.MORIMAR] = {[28558] = {name='Morimar Ring', slot='ring', priority=1, max_charges=10, recast_delay=3600, level=99, cast_time=8, cast_delay=30}},
    [DEST.MARJAMI] = {[28559] = {name='Marjami Ring', slot='ring', priority=1, max_charges=10, recast_delay=3600, level=99, cast_time=8, cast_delay=30}},
    [DEST.YORCIA] = {[28560] = {name='Yorcia Ring', slot='ring', priority=1, max_charges=10, recast_delay=3600, level=99, cast_time=8, cast_delay=30}},
    [DEST.KAMIHR] = {[28561] = {name='Kamihr Ring', slot='ring', priority=1, max_charges=10, recast_delay=3600, level=99, cast_time=8, cast_delay=30}},

    -- SPECIAL LOCATIONS (simplified - key items only)
    [DEST.WAJAOM] = {[15769] = {name='Olduum Ring', slot='ring', priority=1, max_charges=10, recast_delay=3600, level=50, cast_time=8, cast_delay=30}},
    [DEST.ARRAPAGO] = {[26235] = {name='Arrapago Ring', slot='ring', priority=1, max_charges=10, recast_delay=3600, level=99, cast_time=8, cast_delay=30}},
    [DEST.PURGONORGO] = {
        [11273] = {name='Custom Gilet +1', slot='body', priority=1, max_charges=1, recast_delay=72000, level=1, cast_time=8, cast_delay=30, races=2},
        [11274] = {name='Custom Top +1', slot='body', priority=2, max_charges=1, recast_delay=72000, level=1, cast_time=8, cast_delay=30, races=4},
        [11275] = {name='Magna Gilet +1', slot='body', priority=3, max_charges=1, recast_delay=72000, level=1, cast_time=8, cast_delay=30, races=8},
        [11276] = {name='Magna Top +1', slot='body', priority=4, max_charges=1, recast_delay=72000, level=1, cast_time=8, cast_delay=30, races=16},
        [11277] = {name='Wonder Maillot +1', slot='body', priority=5, max_charges=1, recast_delay=72000, level=1, cast_time=8, cast_delay=30, races=32},
        [11278] = {name='Wonder Top +1', slot='body', priority=6, max_charges=1, recast_delay=72000, level=1, cast_time=8, cast_delay=30, races=64},
        [11279] = {name='Savage Top +1', slot='body', priority=7, max_charges=1, recast_delay=72000, level=1, cast_time=8, cast_delay=30, races=128},
        [11280] = {name='Elder Gilet +1', slot='body', priority=8, max_charges=1, recast_delay=72000, level=1, cast_time=8, cast_delay=30, races=256},
    },
    [DEST.RULUDE] = {
        [15194] = {name="Maat's Cap", slot='head', priority=1, max_charges=1, recast_delay=86400, level=70, cast_time=8, cast_delay=30},
        [15212] = {name='Stars Cap', slot='head', priority=2, max_charges=1, recast_delay=86400, level=1, cast_time=8, cast_delay=30},
        [15213] = {name='Laurel Crown', slot='head', priority=3, max_charges=1, recast_delay=86400, level=1, cast_time=8, cast_delay=30},
    },
    [DEST.ZVAHL] = {[26517] = {name='Shadow Lord Shirt', slot='body', priority=1, max_charges=1, recast_delay=72000, level=1, cast_time=8, cast_delay=30}},
    [DEST.RIVERNE] = {[25757] = {name='Wyrmking Suit +1', slot='body', priority=1, max_charges=1, recast_delay=72000, level=1, cast_time=8, cast_delay=30}},
    [DEST.YORAN] = {[27855] = {name='Mandra. Suit +1', slot='body', priority=1, max_charges=1, recast_delay=72000, level=1, cast_time=8, cast_delay=30}},
    [DEST.LEAFALLIA] = {[26739] = {name='Leafkin Cap +1', slot='head', priority=1, max_charges=1, recast_delay=72000, level=1, cast_time=8, cast_delay=30}},
    [DEST.BEHEMOTH] = {[26799] = {name='Behemoth Suit +1', slot='body', priority=1, max_charges=1, recast_delay=72000, level=1, cast_time=8, cast_delay=30}},
    [DEST.ROMAEVE] = {[25603] = {name="Ra'Kaznar Turban", slot='head', priority=1, max_charges=1, recast_delay=72000, level=1, cast_time=8, cast_delay=30}},
    [DEST.CHOCOBO_CIRCUIT] = {[25606] = {name='Chocobo Blinkers', slot='head', priority=1, max_charges=1, recast_delay=72000, level=1, cast_time=8, cast_delay=30}},
    [DEST.PARTING] = {[28547] = {name='Warp Ring +1', slot='ring', priority=1, max_charges=1, recast_delay=600, level=1, cast_time=8, cast_delay=8}},
    [DEST.CHOCOGIRL] = {[26538] = {name='Ch. Shirt +1', slot='body', priority=1, max_charges=1, recast_delay=72000, level=1, cast_time=8, cast_delay=30}},

    -- UNIQUE MECHANICS (2 items)
    [DEST.PARTY_LEADER] = {[11593] = {name='Nexus Cape', slot='back', priority=1, max_charges=50, recast_delay=600, level=75, cast_time=8, cast_delay=30}},
    [DEST.TIDAL] = {[15447] = {name='Tidal Talisman', slot='neck', priority=1, max_charges=50, recast_delay=600, level=50, cast_time=8, cast_delay=30}},
}

---============================================================================
--- PUBLIC API (Standard Interface)
---============================================================================

function CombinedDB.get_items(destination_key)
    local destination_items = ITEMS[destination_key]
    if not destination_items then return {} end

    local items_array = {}
    for item_id, item_data in pairs(destination_items) do
        table.insert(items_array, {item_id = item_id, data = item_data})
    end

    table.sort(items_array, function(a, b) return a.data.priority < b.data.priority end)
    return items_array
end

function CombinedDB.get_item_by_id(item_id)
    for destination_key, destination_items in pairs(ITEMS) do
        local item_data = destination_items[item_id]
        if item_data then return item_data, destination_key end
    end
    return nil, nil
end

function CombinedDB.count_items()
    local count = 0
    for _, destination_items in pairs(ITEMS) do
        for _ in pairs(destination_items) do count = count + 1 end
    end
    return count
end

return CombinedDB

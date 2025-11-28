---============================================================================
--- Warp Database Core - Centralized Façade for Modular Database
---============================================================================
--- Provides lazy-loading access to all warp item data organized by destination.
--- This façade coordinates between specialized database modules for optimal
--- performance and maintainability.
---
--- Architecture:
---   - Lazy-loading: Modules loaded only when needed
---   - Modular: 8 specialized modules by category
---   - Centralized: Single API for all database access
---
--- @file warp_database_core.lua
--- @author Tetsouo
--- @version 4.0 - Modular Architecture
--- @date 2025-10-28
---============================================================================

local WarpDatabase = {}

---============================================================================
--- DESTINATION CONSTANTS (Shared Across All Modules)
---============================================================================

WarpDatabase.DESTINATIONS = {
    -- Home Point / Warp destinations
    HOME_POINT = 'home_point',

    -- Teleport Crags (Original 6)
    CRAG_HOLLA = 'crag_holla',      -- La Theine Plateau
    CRAG_DEM = 'crag_dem',          -- Konschtat Highlands
    CRAG_MEA = 'crag_mea',          -- Tahrongi Canyon
    CRAG_VAHZL = 'crag_vahzl',      -- Xarcabard
    CRAG_YHOAT = 'crag_yhoat',      -- Meriphataud Mountains
    CRAG_ALTEP = 'crag_altep',      -- Eastern Altepa Desert

    -- Three Nations
    SAN_DORIA = 'san_doria',
    BASTOK = 'bastok',
    WINDURST = 'windurst',

    -- Jeuno
    JEUNO = 'jeuno',

    -- Outpost Cities
    SELBINA = 'selbina',
    MHAURA = 'mhaura',
    RABAO = 'rabao',
    KAZHAM = 'kazham',
    NORG = 'norg',

    -- Expansion Cities
    TAVNAZIA = 'tavnazia',          -- Tavnazian Safehold
    WHITEGATE = 'aht_urhgan',       -- Aht Urhgan Whitegate
    NASHMAU = 'nashmau',
    ADOULIN = 'adoulin',            -- Adoulin Castle Gates

    -- Chocobo Stables
    STABLE_SANDORIA = 'chocobo_sandoria',
    STABLE_BASTOK = 'chocobo_bastok',
    STABLE_WINDURST = 'chocobo_windurst',
    STABLE_JEUNO = 'chocobo_jeuno',

    -- Conquest Outposts
    CONQUEST_OUTPOST = 'outpost',   -- Current conquest outpost

    -- Adoulin Frontier Stations
    CEIZAK = 'ceizak',              -- Ceizak Battlegrounds
    YAHSE = 'yahse',                -- Yahse Hunting Grounds
    HENNETIEL = 'hennetiel',        -- Foret de Hennetiel
    MORIMAR = 'morimar',            -- Morimar Basalt Fields
    MARJAMI = 'marjami',            -- Marjami Ravine
    YORCIA = 'yorcia',              -- Yorcia Weald
    KAMIHR = 'kamihr',              -- Kamihr Drifts

    -- Special Locations
    WAJAOM = 'wajaom',              -- Wajaom Woodlands
    ARRAPAGO = 'arrapago',          -- Arrapago Reef
    PURGONORGO = 'purgonorgo',      -- Purgonorgo Isle
    RULUDE = 'rulude',              -- Ru'Lude Gardens
    ZVAHL = 'zvahl',                -- Castle Zvahl Keep
    RIVERNE = 'riverne',            -- Riverne Site #A01
    YORAN = 'yoran',                -- Yoran-Oran's Manor
    LEAFALLIA = 'leafallia',        -- Leafallia
    BEHEMOTH = 'behemoth',          -- Behemoth's Dominion
    ROMAEVE = 'romaeve',            -- Ro'Maeve
    CHOCOBO_CIRCUIT = 'chocobo_circuit',
    PARTING = 'parting',            -- Place of Parting
    CHOCOGIRL = 'chocogirl',        -- Chocogirl (home nation)

    -- Special (unique mechanics)
    PARTY_LEADER = 'party_leader',  -- Nexus Cape only
    TIDAL = 'tidal',                -- Tidal Talisman multi-destination
}

---============================================================================
--- MODULE LAZY-LOADING SYSTEM
---============================================================================

--- Cache for loaded modules (lazy-loading)
local _cached_modules = {}

--- Module routing table (maps destination to module name)
local MODULE_ROUTING = {
    -- Home module
    [WarpDatabase.DESTINATIONS.HOME_POINT] = 'warp_database_home',

    -- Teleports module
    [WarpDatabase.DESTINATIONS.CRAG_HOLLA] = 'warp_database_teleports',
    [WarpDatabase.DESTINATIONS.CRAG_DEM] = 'warp_database_teleports',
    [WarpDatabase.DESTINATIONS.CRAG_MEA] = 'warp_database_teleports',
    [WarpDatabase.DESTINATIONS.CRAG_VAHZL] = 'warp_database_teleports',
    [WarpDatabase.DESTINATIONS.CRAG_YHOAT] = 'warp_database_teleports',
    [WarpDatabase.DESTINATIONS.CRAG_ALTEP] = 'warp_database_teleports',

    -- Nations module
    [WarpDatabase.DESTINATIONS.SAN_DORIA] = 'warp_database_nations',
    [WarpDatabase.DESTINATIONS.BASTOK] = 'warp_database_nations',
    [WarpDatabase.DESTINATIONS.WINDURST] = 'warp_database_nations',
    [WarpDatabase.DESTINATIONS.JEUNO] = 'warp_database_nations',

    -- Cities + Chocobo + Conquest module (combined for efficiency)
    [WarpDatabase.DESTINATIONS.SELBINA] = 'warp_database_cities_chocobo_conquest',
    [WarpDatabase.DESTINATIONS.MHAURA] = 'warp_database_cities_chocobo_conquest',
    [WarpDatabase.DESTINATIONS.RABAO] = 'warp_database_cities_chocobo_conquest',
    [WarpDatabase.DESTINATIONS.KAZHAM] = 'warp_database_cities_chocobo_conquest',
    [WarpDatabase.DESTINATIONS.NORG] = 'warp_database_cities_chocobo_conquest',
    [WarpDatabase.DESTINATIONS.TAVNAZIA] = 'warp_database_cities_chocobo_conquest',
    [WarpDatabase.DESTINATIONS.WHITEGATE] = 'warp_database_cities_chocobo_conquest',
    [WarpDatabase.DESTINATIONS.NASHMAU] = 'warp_database_cities_chocobo_conquest',
    [WarpDatabase.DESTINATIONS.ADOULIN] = 'warp_database_cities_chocobo_conquest',
    [WarpDatabase.DESTINATIONS.CONQUEST_OUTPOST] = 'warp_database_cities_chocobo_conquest',
    [WarpDatabase.DESTINATIONS.STABLE_SANDORIA] = 'warp_database_cities_chocobo_conquest',
    [WarpDatabase.DESTINATIONS.STABLE_BASTOK] = 'warp_database_cities_chocobo_conquest',
    [WarpDatabase.DESTINATIONS.STABLE_WINDURST] = 'warp_database_cities_chocobo_conquest',
    [WarpDatabase.DESTINATIONS.STABLE_JEUNO] = 'warp_database_cities_chocobo_conquest',

    -- Adoulin + Special + Mechanics module (combined for efficiency)
    [WarpDatabase.DESTINATIONS.CEIZAK] = 'warp_database_adoulin_special_mechanics',
    [WarpDatabase.DESTINATIONS.YAHSE] = 'warp_database_adoulin_special_mechanics',
    [WarpDatabase.DESTINATIONS.HENNETIEL] = 'warp_database_adoulin_special_mechanics',
    [WarpDatabase.DESTINATIONS.MORIMAR] = 'warp_database_adoulin_special_mechanics',
    [WarpDatabase.DESTINATIONS.MARJAMI] = 'warp_database_adoulin_special_mechanics',
    [WarpDatabase.DESTINATIONS.YORCIA] = 'warp_database_adoulin_special_mechanics',
    [WarpDatabase.DESTINATIONS.KAMIHR] = 'warp_database_adoulin_special_mechanics',
    [WarpDatabase.DESTINATIONS.WAJAOM] = 'warp_database_adoulin_special_mechanics',
    [WarpDatabase.DESTINATIONS.ARRAPAGO] = 'warp_database_adoulin_special_mechanics',
    [WarpDatabase.DESTINATIONS.PURGONORGO] = 'warp_database_adoulin_special_mechanics',
    [WarpDatabase.DESTINATIONS.RULUDE] = 'warp_database_adoulin_special_mechanics',
    [WarpDatabase.DESTINATIONS.ZVAHL] = 'warp_database_adoulin_special_mechanics',
    [WarpDatabase.DESTINATIONS.RIVERNE] = 'warp_database_adoulin_special_mechanics',
    [WarpDatabase.DESTINATIONS.YORAN] = 'warp_database_adoulin_special_mechanics',
    [WarpDatabase.DESTINATIONS.LEAFALLIA] = 'warp_database_adoulin_special_mechanics',
    [WarpDatabase.DESTINATIONS.BEHEMOTH] = 'warp_database_adoulin_special_mechanics',
    [WarpDatabase.DESTINATIONS.ROMAEVE] = 'warp_database_adoulin_special_mechanics',
    [WarpDatabase.DESTINATIONS.CHOCOBO_CIRCUIT] = 'warp_database_adoulin_special_mechanics',
    [WarpDatabase.DESTINATIONS.PARTING] = 'warp_database_adoulin_special_mechanics',
    [WarpDatabase.DESTINATIONS.CHOCOGIRL] = 'warp_database_adoulin_special_mechanics',
    [WarpDatabase.DESTINATIONS.PARTY_LEADER] = 'warp_database_adoulin_special_mechanics',
    [WarpDatabase.DESTINATIONS.TIDAL] = 'warp_database_adoulin_special_mechanics',
}

--- Load a database module (with caching)
--- @param module_name string Module name without path
--- @return table Module exports
local function load_module(module_name)
    if not _cached_modules[module_name] then
        local module_path = 'shared/utils/warp/database/' .. module_name
        _cached_modules[module_name] = require(module_path)
    end
    return _cached_modules[module_name]
end

---============================================================================
--- PUBLIC API
---============================================================================

--- Get all items for a destination (sorted by priority)
--- @param destination_key string Destination constant
--- @return table Array of {data={item fields}, item_id=number}
function WarpDatabase.get_items_by_destination(destination_key)
    local module_name = MODULE_ROUTING[destination_key]
    if not module_name then
        return {}
    end

    local module = load_module(module_name)
    if module and module.get_items then
        return module.get_items(destination_key)
    end

    return {}
end

--- Get item data by item ID (searches all modules)
--- @param item_id number Item ID
--- @return table|nil Item data
--- @return string|nil Destination key
function WarpDatabase.get_item_by_id(item_id)
    -- Search through all loaded modules first (fast path)
    for _, module in pairs(_cached_modules) do
        if module.get_item_by_id then
            local item_data, destination = module.get_item_by_id(item_id)
            if item_data then
                return item_data, destination
            end
        end
    end

    -- If not found, load all modules and search (slow path)
    for destination_key, module_name in pairs(MODULE_ROUTING) do
        if not _cached_modules[module_name] then
            local module = load_module(module_name)
            if module and module.get_item_by_id then
                local item_data, destination = module.get_item_by_id(item_id)
                if item_data then
                    return item_data, destination
                end
            end
        end
    end

    return nil, nil
end

--- Count total items across all destinations
--- @return number Total item count
function WarpDatabase.count_total_items()
    local total = 0
    local counted_modules = {}

    for _, module_name in pairs(MODULE_ROUTING) do
        if not counted_modules[module_name] then
            local module = load_module(module_name)
            if module and module.count_items then
                total = total + module.count_items()
            end
            counted_modules[module_name] = true
        end
    end

    return total
end

--- Check if player race can use item (race restriction check)
--- @param item_data table Item data with races field
--- @return boolean True if player can use item
function WarpDatabase.can_player_use_item(item_data)
    if not item_data or not item_data.races then
        return true  -- No race restriction
    end

    if not player then
        return false
    end

    -- Race bitmask constants
    local RACES = {
        HUME_M = 0x0001,
        HUME_F = 0x0002,
        ELVAAN_M = 0x0004,
        ELVAAN_F = 0x0008,
        TARUTARU_M = 0x0010,
        TARUTARU_F = 0x0020,
        MITHRA = 0x0040,
        GALKA = 0x0080,
    }

    local race_name = player.race
    local race_bitmask = RACES[race_name:upper():gsub(' ', '_')]

    if not race_bitmask then
        return true  -- Unknown race, allow
    end

    -- Check if player's race bit is set (using bit.band for Lua 5.1)
    return bit.band(item_data.races, race_bitmask) ~= 0
end

return WarpDatabase

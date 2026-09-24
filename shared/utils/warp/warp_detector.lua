---============================================================================
--- Warp Detector - Warp/teleport spell and item classification
---============================================================================
--- Classifies:
---   1. BLM spells (Warp, Warp II, Retrace, Escape) - Lv17-55
---   2. WHM spells (Teleport-*, Recall-*) - Lv36-53
---   3. Warp items listed in the warp database (warp_item_database.lua):
---      rings, earrings, necks, body/head items, weapons, Instant Warp
---
--- Also registers an `action` listener meant to report the player's warp item
--- use to callbacks (see WarpEquipment.init).
---
--- @file shared/utils/warp/warp_detector.lua
--- @author Tetsouo
--- @version 2.1
--- @date Created: 2025-10-27
---============================================================================

local WarpDetector = {}

---============================================================================
--- LOAD ITEM DATABASE
---============================================================================

local WarpItemDB = require('shared/utils/warp/warp_item_database')

---============================================================================
--- CONSTANTS
---============================================================================

-- Warp spell names (case-insensitive detection)
local WARP_SPELL_PATTERNS = {
    'warp',      -- Warp, Warp II
    'teleport',  -- Teleport-Holla, Teleport-Dem, etc.
    'recall',    -- Recall-Jugner, Recall-Pashh, etc.
    'retrace',   -- Retrace
    'escape'     -- Escape
}

-- Warp spell exact names (for precise detection)
local WARP_SPELLS = {
    ['Warp'] = {duration = 12, type = 'spell'},
    ['Warp II'] = {duration = 12, type = 'spell'},
    ['Retrace'] = {duration = 12, type = 'spell'},
    ['Escape'] = {duration = 8, type = 'spell'},

    -- Teleport spells
    ['Teleport-Holla'] = {duration = 12, type = 'spell'},
    ['Teleport-Dem'] = {duration = 12, type = 'spell'},
    ['Teleport-Mea'] = {duration = 12, type = 'spell'},
    ['Teleport-Altep'] = {duration = 12, type = 'spell'},
    ['Teleport-Yhoat'] = {duration = 12, type = 'spell'},
    ['Teleport-Vahzl'] = {duration = 12, type = 'spell'},

    -- Recall spells
    ['Recall-Jugner'] = {duration = 12, type = 'spell'},
    ['Recall-Pashh'] = {duration = 12, type = 'spell'},
    ['Recall-Meriph'] = {duration = 12, type = 'spell'}
}

---============================================================================
--- DETECTION FUNCTIONS
---============================================================================

--- Check if a spell is a warp/teleport spell
--- @param spell table The spell object
--- @return boolean True if warp spell
--- @return table|nil Warp data if detected
function WarpDetector.is_warp_spell(spell)
    if not spell or not spell.name then
        return false, nil
    end

    -- Exact match first (fastest)
    if WARP_SPELLS[spell.name] then
        return true, WARP_SPELLS[spell.name]
    end

    -- Pattern match (fallback for new spells)
    local spell_lower = spell.name:lower()
    for _, pattern in ipairs(WARP_SPELL_PATTERNS) do
        if spell_lower:find(pattern) then
            return true, {duration = 12, type = 'spell'}
        end
    end

    return false, nil
end

--- Check if player has BLM main or sub (can cast warp spells)
--- @return boolean True if BLM available
function WarpDetector.has_blm()
    if not player then return false end

    local main_job = player.main_job or ''
    local sub_job = player.sub_job or ''

    return main_job == 'BLM' or sub_job == 'BLM'
end

--- Check if player has WHM main or sub (can cast teleport/recall)
--- @return boolean True if WHM available
function WarpDetector.has_whm()
    if not player then return false end

    local main_job = player.main_job or ''
    local sub_job = player.sub_job or ''

    return main_job == 'WHM' or sub_job == 'WHM'
end

--- Check if an item is a warp item (using WarpItemDB)
--- @param item_id number The item ID
--- @return boolean True if warp item
--- @return table|nil Warp item data if detected (with full database info)
function WarpDetector.is_warp_item(item_id)
    if not item_id then return false, nil end

    -- Search in WarpItemDB
    local item_data, destination = WarpItemDB.get_item_by_id(item_id)

    if item_data then
        -- Return data compatible with old format + extended info
        return true, {
            name = item_data.name,
            slot = item_data.slot,
            duration = item_data.cast_time + item_data.cast_delay,  -- Total cast duration
            destination = destination,
            -- Extended database info
            max_charges = item_data.max_charges,
            recast_delay = item_data.recast_delay,
            level = item_data.level,
            cast_time = item_data.cast_time,
            cast_delay = item_data.cast_delay,
            priority = item_data.priority,
            races = item_data.races,
            notes = item_data.notes
        }
    end

    return false, nil
end

---============================================================================
--- ACTION EVENT DETECTION (for item usage)
---============================================================================

_G.warp_detector_callbacks = _G.warp_detector_callbacks or {}

--- Register a callback for warp detection
--- @param callback function Function to call when warp detected
function WarpDetector.register_callback(callback)
    table.insert(_G.warp_detector_callbacks, callback)
end

--- Clear all registered callbacks (called by init_action_listener on every load)
function WarpDetector.clear_callbacks()
    _G.warp_detector_callbacks = {}
end

--- Initialize action event listener for item usage detection.
--- Called on every job-file load: GearSwap drops every sandbox listener at the
--- load. The id is kept on `windower.*` with its load
--- (windower._gs_reload_count); only an id from this same load is
--- unregistered, since an older one is already gone and could now belong to
--- another listener (cf dualbox_sync_ipc.init_listener).
function WarpDetector.init_action_listener()
    -- Also drops any callback registered earlier in this load, including the
    -- one WarpEquipment.init() registers just before calling this function.
    WarpDetector.clear_callbacks()

    if not windower or not windower.register_event then return end

    if windower._warp_detector_event_id
       and windower._warp_detector_event_load == windower._gs_reload_count then
        pcall(windower.unregister_event, windower._warp_detector_event_id)
    end

    windower._warp_detector_event_id = windower.register_event('action', function(act)
        if not act then return end

        -- Category 9 = Item usage
        if act.category ~= 9 then return end

        if not player or act.actor_id ~= player.id then return end

        local item_id = act.param
        local is_warp, warp_data = WarpDetector.is_warp_item(item_id)

        if is_warp then
            for _, callback in ipairs(_G.warp_detector_callbacks) do
                pcall(callback, 'item', warp_data)
            end
        end
    end)
    windower._warp_detector_event_load = windower._gs_reload_count
end

---============================================================================
--- PUBLIC API
---============================================================================

--- Get list of all warp spell names
--- @return table List of warp spell names
function WarpDetector.get_warp_spells()
    local spell_list = {}
    for spell_name, _ in pairs(WARP_SPELLS) do
        table.insert(spell_list, spell_name)
    end
    return spell_list
end

--- Get list of all warp item IDs (from WarpItemDB), each id once.
--- The database is split per destination module, so it is walked through
--- its DESTINATIONS keys (there is no flat item table to iterate).
--- @return table List of warp item IDs
function WarpDetector.get_warp_items()
    local item_list, seen = {}, {}

    for _, destination in pairs(WarpItemDB.DESTINATIONS or {}) do
        for _, entry in ipairs(WarpItemDB.get_items_by_destination(destination) or {}) do
            if entry.item_id and not seen[entry.item_id] then
                seen[entry.item_id] = true
                table.insert(item_list, entry.item_id)
            end
        end
    end

    return item_list
end

--- Get items for a specific destination (sorted by priority)
--- @param destination string Destination key (e.g. 'home_point', 'crag_holla')
--- @return table Sorted list of items for that destination
function WarpDetector.get_items_by_destination(destination)
    return WarpItemDB.get_items_by_destination(destination)
end

--- Get all available destinations
--- Known issue: WarpItemDB has no get_all_destinations(); no caller today.
--- @return table List of destination keys
function WarpDetector.get_all_destinations()
    return WarpItemDB.get_all_destinations()
end

--- Count total warp items in database
--- @return number Total item count
function WarpDetector.count_warp_items()
    return WarpItemDB.count_total_items()
end

--- Access to WarpItemDB for advanced queries
WarpDetector.ItemDB = WarpItemDB

return WarpDetector

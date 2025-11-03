---============================================================================
--- Cast Helpers - Shared Helper Functions for Casting System
---============================================================================
--- Provides utility functions used by spell_caster and item_user modules.
---
--- @file cast_helpers.lua
--- @author Tetsouo
--- @version 4.0 - Modular Architecture
--- @date 2025-10-28
---============================================================================

local CastHelpers = {}

---============================================================================
--- INVENTORY CHECKING
---============================================================================

--- Check if player has an item in inventory (by name OR by ID)
--- Uses same method as equipment_checker (items[bag_name] with string keys)
--- @param item_name string Item name to check
--- @param item_id number|nil Optional item ID to check as well
--- @return boolean True if player has the item
function CastHelpers.has_item(item_name, item_id)
    local items = windower.ffxi.get_items()
    if not items then
        return false
    end

    -- Equippable bags (same as equipment_checker - STRING KEYS not numeric!)
    local EQUIPPABLE_BAGS = {
        'inventory',    -- Bag 0
        'wardrobe',     -- Bag 8
        'wardrobe2',    -- Bag 10
        'wardrobe3',    -- Bag 11
        'wardrobe4',    -- Bag 12
        'wardrobe5',    -- Bag 13
        'wardrobe6',    -- Bag 14
        'wardrobe7',    -- Bag 15
        'wardrobe8'     -- Bag 16
    }

    -- Load resources for item name lookups
    local res = require('resources')

    -- Check all equippable bags using STRING keys (like equipment_checker)
    for _, bag_name in ipairs(EQUIPPABLE_BAGS) do
        local bag_items = items[bag_name]
        if bag_items and type(bag_items) == 'table' then
            for _, item in ipairs(bag_items) do
                if item and item.id and item.id > 0 then
                    -- Check by ID (most reliable)
                    if item_id and item.id == item_id then
                        return true
                    end

                    -- Check by name
                    local res_item = res.items[item.id]
                    if res_item and res_item.en and res_item.en:lower() == item_name:lower() then
                        return true
                    end
                end
            end
        end
    end

    return false
end

---============================================================================
--- RING ID MAPPING
---============================================================================

--- Ring name to item ID mapping (from res/items.lua)
CastHelpers.RING_IDS = {
    ['Warp Ring'] = 28540,
    ['Holla Ring'] = 14661,
    ['Dem Ring'] = 14662,
    ['Mea Ring'] = 14663,
    ['Vahzl Ring'] = 14664,
    ['Yhoat Ring'] = 14665,
    ['Altep Ring'] = 14666,
    ['Dim. Ring (Holla)'] = 26176,
    ['Dim. Ring (Dem)'] = 26177,
    ['Dim. Ring (Mea)'] = 26178
}

--- Get ring ID by name
--- @param ring_name string Ring name
--- @return number|nil Ring ID, or nil if not found
function CastHelpers.get_ring_id(ring_name)
    return CastHelpers.RING_IDS[ring_name]
end

--- Check if player has a specific ring
--- @param ring_name string Ring name
--- @return boolean True if player has the ring
function CastHelpers.has_ring(ring_name)
    local ring_id = CastHelpers.get_ring_id(ring_name)
    if not ring_id then
        return false
    end
    return CastHelpers.has_item(ring_name, ring_id)
end

return CastHelpers

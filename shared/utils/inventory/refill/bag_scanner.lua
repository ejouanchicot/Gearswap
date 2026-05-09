---  ═══════════════════════════════════════════════════════════════════════════
---   Bag Scanner - Count items across FFXI inventory bags
---  ═══════════════════════════════════════════════════════════════════════════
---   Pure helper extracted from refill_manager.lua. Counts total stack quantity
---   AND returns the list of slot positions for a given item ID in a specific
---   bag (inventory, sack, case, satchel...).
---
---   The slot positions are needed by the move queue to issue precise
---   put_item / get_item calls.
---
---   @file    shared/utils/inventory/refill/bag_scanner.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-09 (extracted from refill_manager.lua)
---  ═══════════════════════════════════════════════════════════════════════════

local BagScanner = {}

--- Count total quantity of an item in a specific bag.
--- @param items_data table  Result of windower.ffxi.get_items()
--- @param bag_key string    'inventory' | 'sack' | 'case' | 'satchel' | etc.
--- @param target_id number  Item resource ID to search for
--- @return number Total count across all stacks
--- @return table  List of {slot=number, count=number} for each matching stack
function BagScanner.count_item_in_bag(items_data, bag_key, target_id)
    local bag = items_data[bag_key]
    if not bag or type(bag) ~= 'table' then
        return 0, {}
    end

    local total = 0
    local slots = {}

    for slot, item in pairs(bag) do
        if type(slot) == 'number' and type(item) == 'table' and item.id
           and item.id == target_id and item.count and item.count > 0 then
            total = total + item.count
            table.insert(slots, {slot = slot, count = item.count})
        end
    end

    return total, slots
end

return BagScanner

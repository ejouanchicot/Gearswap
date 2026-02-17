---  ═══════════════════════════════════════════════════════════════════════════
---   Refill Manager - Restock consumables from Mog Case/Sack
---  ═══════════════════════════════════════════════════════════════════════════
---   Scans inventory for consumable items and pulls from Mog Case / Mog Sack
---   to maintain target quantities (default 12 each).
---
---   Usage: //gs c refill  (or //gs c rf)
---
---   @file    shared/utils/inventory/refill_manager.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    2026-02-14
---  ═══════════════════════════════════════════════════════════════════════════

local RefillManager = {}

local res = require('resources')

---  ═══════════════════════════════════════════════════════════════════════════
---   CONFIGURATION
---  ═══════════════════════════════════════════════════════════════════════════

--- Items to maintain in inventory with target quantities
local REFILL_ITEMS = {
    { name = 'Panacea',      target = 12 },
    { name = 'Antacid',      target = 12 },
    { name = 'Holy Water',   target = 12 },
    { name = 'Remedy',       target = 12 },
    { name = 'Prism Powder', target = 12 },
    { name = 'Silent Oil',   target = 12 },
}

--- Source bags in priority order (Case first, then Sack)
local SOURCE_BAGS = {
    { key = 'case', id = 7, display = 'Case' },
    { key = 'sack', id = 6, display = 'Sack' },
}

local INVENTORY_BAG_ID = 0

--- Delay between move operations (seconds) to respect FFXI packet rate
local MOVE_DELAY = 0.6

---  ═══════════════════════════════════════════════════════════════════════════
---   ITEM ID RESOLUTION
---  ═══════════════════════════════════════════════════════════════════════════

--- Resolve item name to resource ID via res.items
--- @param item_name string The English item name
--- @return number|nil Item ID or nil if not found
local function resolve_item_id(item_name)
    local lower_name = item_name:lower()
    for id, item_data in pairs(res.items) do
        if item_data and item_data.en and item_data.en:lower() == lower_name then
            return id
        end
    end
    return nil
end

--- Build lookup table for all target items (cached)
local item_id_cache = {}

local function ensure_item_ids()
    if next(item_id_cache) then return true end

    for _, refill_item in ipairs(REFILL_ITEMS) do
        local id = resolve_item_id(refill_item.name)
        if id then
            item_id_cache[refill_item.name] = id
        end
    end

    return next(item_id_cache) ~= nil
end

---  ═══════════════════════════════════════════════════════════════════════════
---   BAG SCANNING
---  ═══════════════════════════════════════════════════════════════════════════

--- Count total quantity of an item in a specific bag
--- @param items_data table Data from windower.ffxi.get_items()
--- @param bag_key string Bag string key (e.g., 'inventory', 'sack', 'case')
--- @param target_id number Item resource ID to search for
--- @return number Total count
--- @return table List of {slot=number, count=number} for each matching stack
local function count_item_in_bag(items_data, bag_key, target_id)
    local bag = items_data[bag_key]
    if not bag or type(bag) ~= 'table' then
        return 0, {}
    end

    local total = 0
    local slots = {}

    for slot, item in pairs(bag) do
        if type(slot) == 'number' and type(item) == 'table'
            and item.id and item.id == target_id
            and item.count and item.count > 0 then
            total = total + item.count
            table.insert(slots, { slot = slot, count = item.count })
        end
    end

    return total, slots
end

---  ═══════════════════════════════════════════════════════════════════════════
---   IN-GAME DISPLAY
---  ═══════════════════════════════════════════════════════════════════════════

local gray   = string.char(0x1F, 160)
local green  = string.char(0x1F, 158)
local yellow = string.char(0x1F, 50)
local red    = string.char(0x1F, 167)
local cyan   = string.char(0x1F, 123)

--- Display the refill report in-game chat
--- @param results table List of {name, target, current, deficit, moved, short, source}
local function show_report(results)
    local sep = string.rep("=", 74)

    add_to_chat(121, gray .. sep)
    add_to_chat(121, yellow .. "[REFILL] " .. cyan .. "Inventory Restock Report")
    add_to_chat(121, gray .. sep)

    local total_moved = 0
    local total_short = 0
    local max_name_len = 14

    for _, r in ipairs(results) do
        local pad = string.rep(" ", math.max(1, max_name_len - #r.name))
        local line

        if r.deficit <= 0 then
            -- Already at target
            line = green .. "  " .. r.name .. pad .. ": "
                .. yellow .. r.current .. "/" .. r.target
                .. gray .. " (OK)"

        elseif r.moved > 0 and r.short <= 0 then
            -- Fully refilled
            line = cyan .. "  " .. r.name .. pad .. ": "
                .. gray .. r.current .. "/" .. r.target
                .. green .. " -> " .. yellow .. (r.current + r.moved) .. "/" .. r.target
                .. cyan .. "  (+" .. r.moved .. " " .. r.source .. ")"
            total_moved = total_moved + r.moved

        elseif r.moved > 0 and r.short > 0 then
            -- Partially refilled
            line = red .. "  " .. r.name .. pad .. ": "
                .. gray .. r.current .. "/" .. r.target
                .. yellow .. " -> " .. (r.current + r.moved) .. "/" .. r.target
                .. cyan .. "  (+" .. r.moved .. " " .. r.source .. ")"
                .. red .. " Manque " .. r.short
            total_moved = total_moved + r.moved
            total_short = total_short + r.short

        else
            -- Nothing available at all
            line = red .. "  " .. r.name .. pad .. ": "
                .. yellow .. r.current .. "/" .. r.target
                .. red .. "  Stock epuise! Manque " .. r.short
            total_short = total_short + r.short
        end

        add_to_chat(121, line)
    end

    add_to_chat(121, gray .. sep)

    if total_moved > 0 then
        add_to_chat(121, green .. "  Transferes: " .. yellow .. total_moved .. " items")
    end
    if total_short > 0 then
        add_to_chat(121, red .. "  Manquants:  " .. yellow .. total_short .. red .. " (restock Case/Sack!)")
    end
    if total_moved == 0 and total_short == 0 then
        add_to_chat(121, green .. "  Inventaire complet!")
    end

    add_to_chat(121, gray .. sep)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MAIN REFILL LOGIC
---  ═══════════════════════════════════════════════════════════════════════════

--- Execute the full refill operation
--- @return boolean Success
function RefillManager.refill()
    if not player then
        add_to_chat(167, '[REFILL] Erreur: pas connecte')
        return false
    end

    -- Resolve item IDs from resources
    if not ensure_item_ids() then
        add_to_chat(167, '[REFILL] Erreur: impossible de resoudre les IDs des items')
        return false
    end

    -- Read all bag contents
    local items_data = windower.ffxi.get_items()
    if not items_data then
        add_to_chat(167, '[REFILL] Erreur: impossible de lire l\'inventaire')
        return false
    end

    -- Build refill plan
    local results = {}
    local move_queue = {}

    for _, refill_item in ipairs(REFILL_ITEMS) do
        local item_id = item_id_cache[refill_item.name]

        if not item_id then
            -- Item not found in resources (shouldn't happen for known items)
            table.insert(results, {
                name = refill_item.name,
                target = refill_item.target,
                current = 0,
                deficit = refill_item.target,
                moved = 0,
                short = refill_item.target,
                source = '',
            })
        else
            -- Count current inventory
            local inv_count = count_item_in_bag(items_data, 'inventory', item_id)
            local deficit = refill_item.target - inv_count

            local result = {
                name = refill_item.name,
                target = refill_item.target,
                current = inv_count,
                deficit = deficit,
                moved = 0,
                short = 0,
                source = '',
            }

            if deficit > 0 then
                local remaining = deficit
                local sources = {}

                -- Try each source bag (Case first, then Sack)
                for _, source in ipairs(SOURCE_BAGS) do
                    if remaining <= 0 then break end

                    local available, slots = count_item_in_bag(items_data, source.key, item_id)
                    if available > 0 then
                        -- Queue moves from matching slots in this bag
                        for _, slot_info in ipairs(slots) do
                            if remaining <= 0 then break end
                            local to_move = math.min(remaining, slot_info.count)

                            table.insert(move_queue, {
                                bag_id = source.id,
                                slot = slot_info.slot,
                                count = to_move,
                                item_name = refill_item.name,
                            })

                            remaining = remaining - to_move
                            result.moved = result.moved + to_move

                            -- Track which bags contributed
                            if not sources[source.display] then
                                sources[source.display] = true
                                table.insert(sources, source.display)
                            end
                        end
                    end
                end

                result.short = math.max(0, remaining)
                result.source = table.concat(sources, '+')
            end

            table.insert(results, result)
        end
    end

    -- Execute move queue with delays
    if #move_queue > 0 then
        local function execute_move(index)
            if index > #move_queue then
                -- All moves complete — show report
                show_report(results)
                return
            end

            local move = move_queue[index]
            windower.ffxi.move_item(move.bag_id, INVENTORY_BAG_ID, move.slot, move.count)

            -- Schedule next move after delay
            coroutine.schedule(function()
                execute_move(index + 1)
            end, MOVE_DELAY)
        end

        add_to_chat(121, cyan .. "[REFILL] "
            .. yellow .. "Transfert en cours... ("
            .. #move_queue .. " operations)")
        execute_move(1)
    else
        -- Nothing to move, show report immediately
        show_report(results)
    end

    return true
end

return RefillManager

---  ═══════════════════════════════════════════════════════════════════════════
---   Refill Manager - Restock consumables from Mog Case/Sack (Facade)
---  ═══════════════════════════════════════════════════════════════════════════
---   Scans inventory for consumable items and pulls from Mog Case / Mog Sack
---   to maintain target quantities. Items above target are pushed back to a
---   configurable store_bag (default Case). Items belonging to OTHER jobs'
---   refill lists are detected as "foreign" and pushed back too.
---
---   Usage: //gs c refill  (or //gs c rf)
---
---   This file is now a thin orchestrator (~150 lines). The actual logic
---   lives in 4 specialized sub-modules under refill/:
---     • item_resolver   - lazy item name -> resource ID lookup with cache
---     • bag_scanner     - count item stacks across FFXI bags
---     • config_resolver - load per-character refill configs + foreign detection
---     • refill_panels   - 74-char ASCII display (start banner, report, errors)
---
---   Public API: RefillManager.refill() - single entry point.
---
---   @file    shared/utils/inventory/refill_manager.lua
---   @author  Tetsouo
---   @version 2.0 - Modular refactor (840 lines -> 150 lines facade + 4 modules)
---   @date    2026-02-14 (initial), 2026-05-09 (refactor)
---  ═══════════════════════════════════════════════════════════════════════════

local ItemResolver    = require('shared/utils/inventory/refill/item_resolver')
local BagScanner      = require('shared/utils/inventory/refill/bag_scanner')
local ConfigResolver  = require('shared/utils/inventory/refill/config_resolver')
local RefillPanels    = require('shared/utils/inventory/refill/refill_panels')

local RefillManager = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   ORCHESTRATION CONSTANTS
---  ═══════════════════════════════════════════════════════════════════════════

--- Source bags scanned in priority order (Case first, then Sack)
local SOURCE_BAGS = {
    {key = 'case', id = 7, display = 'Case'},
    {key = 'sack', id = 6, display = 'Sack'}
}

local INVENTORY_BAG_ID = 0

--- Delay between move operations (seconds) to respect FFXI packet rate
local MOVE_DELAY = 0.6

---  ═══════════════════════════════════════════════════════════════════════════
---   PUBLIC API
---  ═══════════════════════════════════════════════════════════════════════════

--- What is already in the bag, and which spelling of it is there.
---
--- An entry can name several variants - {'Squid Sushi +1', 'Squid Sushi'} -
--- and they all count towards the same target. The one actually held decides
--- the name shown in the report.
--- @param variants table Resolved variants, preferred first
--- @param items_data table windower.ffxi.get_items()
--- @return number count held, table|nil the variant that is held
local function count_held(variants, items_data)
    local inv_count = 0
    local present_variant = nil
    for _, v in ipairs(variants) do
        local n = BagScanner.count_item_in_bag(items_data, 'inventory', v.id)
        inv_count = inv_count + n
        if n > 0 and not present_variant then
            present_variant = v
        end
    end
    return inv_count, present_variant
end

--- How many to end up holding.
---
--- `target = 'all'` means take everything there is rather than stop at a
--- number, so it resolves to what is held plus what the other bags can give.
--- @return number Effective target
local function effective_target(refill_item, variants, inv_count, items_data)
    if refill_item.target ~= 'all' then
        return refill_item.target
    end

    local available = 0
    for _, v in ipairs(variants) do
        for _, source in ipairs(SOURCE_BAGS) do
            available = available + BagScanner.count_item_in_bag(items_data, source.key, v.id)
        end
    end
    return inv_count + available
end

--- Moves that push the excess back to the store bag.
--- @return table moves, number how many were actually queued
local function queue_surplus(variants, surplus, items_data, store_info)
    local moves = {}
    local remaining = surplus
    for _, v in ipairs(variants) do
        if remaining <= 0 then break end
        local _, inv_slots = BagScanner.count_item_in_bag(items_data, 'inventory', v.id)
        for _, slot_info in ipairs(inv_slots) do
            if remaining <= 0 then break end
            local to_move = math.min(remaining, slot_info.count)
            table.insert(moves, {
                bag_id = INVENTORY_BAG_ID, dst_id = store_info.id,
                slot = slot_info.slot, count = to_move,
                item_name = v.name, is_surplus = true
            })
            remaining = remaining - to_move
        end
    end
    return moves, surplus - remaining
end

--- Moves that pull the shortfall out of Case and Sack.
---
--- Variants are tried in order, so the preferred spelling is taken first and
--- the lesser one only makes up the difference.
--- @return table moves, number pulled, number still short, string sources, table pulled variant names
local function queue_deficit(variants, deficit, items_data)
    local moves, sources, pulled_variants = {}, {}, {}
    local remaining, moved = deficit, 0

    for _, v in ipairs(variants) do
        if remaining <= 0 then break end
        for _, source in ipairs(SOURCE_BAGS) do
            if remaining <= 0 then break end
            local available, slots = BagScanner.count_item_in_bag(items_data, source.key, v.id)
            if available > 0 then
                for _, slot_info in ipairs(slots) do
                    if remaining <= 0 then break end
                    local to_move = math.min(remaining, slot_info.count)
                    table.insert(moves, {
                        bag_id = source.id, slot = slot_info.slot,
                        count = to_move, item_name = v.name
                    })
                    remaining = remaining - to_move
                    moved = moved + to_move
                    if not sources[source.display] then
                        sources[source.display] = true
                        table.insert(sources, source.display)
                    end
                    pulled_variants[v.name] = true
                end
            end
        end
    end

    return moves, moved, math.max(0, remaining), table.concat(sources, '+'), pulled_variants
end

--- Plan one line of the refill list.
--- @return table result row, table moves to queue
local function plan_item(refill_item, items_data, store_info)
    local variants = ItemResolver.resolve_variants(refill_item.name)

    if #variants == 0 then
        local display = (type(refill_item.name) == 'table')
                        and refill_item.name[1] or tostring(refill_item.name)
        local fallback_target = (type(refill_item.target) == 'number')
                                and refill_item.target or 0
        return {
            name = display, target = fallback_target, current = 0,
            deficit = fallback_target, moved = 0, short = fallback_target, source = ''
        }, {}
    end

    local inv_count, present_variant = count_held(variants, items_data)
    local target = effective_target(refill_item, variants, inv_count, items_data)
    local deficit = target - inv_count

    local result = {
        name = (present_variant and present_variant.name) or variants[1].name,
        target = target, current = inv_count,
        deficit = deficit, moved = 0, short = 0, source = '',
        surplus = 0, surplus_dest = nil
    }
    local moves = {}

    if deficit < 0 then
        local surplus_moves, pushed = queue_surplus(variants, -deficit, items_data, store_info)
        moves = surplus_moves
        result.surplus = pushed
        result.surplus_dest = store_info.display
    elseif deficit > 0 then
        local pull_moves, moved, short, sources, pulled = queue_deficit(variants, deficit, items_data)
        moves = pull_moves
        result.moved, result.short, result.source = moved, short, sources

        -- Nothing of this item was held, so name the row after whichever
        -- variant was actually pulled rather than the preferred spelling.
        if not present_variant then
            for _, v in ipairs(variants) do
                if pulled[v.name] then
                    result.name = v.name
                    break
                end
            end
        end
    end

    return result, moves
end

--- Push out anything in the bag that belongs to another job's list.
---
--- Omelette Sandwich on WAR is PLD's food: it is not surplus of this job's
--- line, it has no business in the bag at all.
--- @return table moves, table result rows
local function sweep_foreign_items(items_data, list, store_info)
    local foreign_set = ConfigResolver.build_foreign_items_set(player.name, list)
    local moves, foreign_results, rows = {}, {}, {}

    local inv_items = items_data.inventory
    if type(inv_items) == 'table' then
        for slot, it in pairs(inv_items) do
            if type(slot) == 'number' and type(it) == 'table' and it.id
               and it.count and it.count > 0 and foreign_set[it.id] then
                local display = foreign_set[it.id]
                table.insert(moves, {
                    bag_id = INVENTORY_BAG_ID, dst_id = store_info.id,
                    slot = slot, count = it.count,
                    item_name = display, is_surplus = true
                })
                foreign_results[display] = foreign_results[display]
                                           or {moved = 0, dest = store_info.display}
                foreign_results[display].moved = foreign_results[display].moved + it.count
            end
        end
    end

    for name, info in pairs(foreign_results) do
        table.insert(rows, {
            name = name, target = 0, current = info.moved,
            deficit = -info.moved, moved = 0, short = 0, source = '',
            surplus = info.moved, surplus_dest = info.dest, is_foreign = true
        })
    end

    return moves, rows
end


--- Execute the full refill operation: scan inventory, compute deficits,
--- push surplus, pull from Case/Sack, push foreign items, display report.
--- @return boolean Success
function RefillManager.refill()
    if not player then
        RefillPanels.show_error('Player not connected')
        return false
    end

    local items_data = windower.ffxi.get_items()
    if not items_data then
        RefillPanels.show_error('Could not read inventory')
        return false
    end

    -- Which list applies to the job being played, and where surplus goes
    local list, source_label, store_info = ConfigResolver.resolve_list_for_player()
    RefillPanels.show_start(source_label, store_info.display, #list)

    local results = {}
    local move_queue = {}

    for _, refill_item in ipairs(list) do
        local result, moves = plan_item(refill_item, items_data, store_info)
        table.insert(results, result)
        for _, m in ipairs(moves) do
            table.insert(move_queue, m)
        end
    end

    local foreign_moves, foreign_rows = sweep_foreign_items(items_data, list, store_info)
    for _, m in ipairs(foreign_moves) do
        table.insert(move_queue, m)
    end
    for _, row in ipairs(foreign_rows) do
        table.insert(results, row)
    end

    -- Execute move queue with delays
    if #move_queue > 0 then
        local function execute_move(index)
            if index > #move_queue then
                -- All moves complete - show report
                RefillPanels.show_report(results)
                return
            end

            local move = move_queue[index]
            if move.is_surplus then
                -- INV -> store_bag: use put_item (canonical for inv->bag)
                windower.ffxi.put_item(move.dst_id, move.slot, move.count)
            else
                -- bag -> INV: use get_item (canonical for bag->inv)
                windower.ffxi.get_item(move.bag_id, move.slot, move.count)
            end

            -- Schedule next move after delay
            coroutine.schedule(function()
                execute_move(index + 1)
            end, MOVE_DELAY)
        end

        RefillPanels.show_progress(#move_queue)
        execute_move(1)
    else
        RefillPanels.show_report(results)
    end

    return true
end

return RefillManager

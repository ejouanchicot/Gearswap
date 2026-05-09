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

    -- Resolve which list to use for the active job/subjob + store_bag for surplus
    local list, source_label, store_info = ConfigResolver.resolve_list_for_player()
    RefillPanels.show_start(source_label, store_info.display, #list)

    -- Build refill plan: each entry can have multiple item variants (e.g.
    -- {'Squid Sushi +1', 'Squid Sushi'}). Total count across variants counts
    -- toward `target`; pulls prefer the FIRST variant.
    local results = {}
    local move_queue = {}

    for _, refill_item in ipairs(list) do
        local variants = ItemResolver.resolve_variants(refill_item.name)

        if #variants == 0 then
            -- Could not resolve any variant in res.items
            local display = (type(refill_item.name) == 'table') and refill_item.name[1] or tostring(refill_item.name)
            local fallback_target = (type(refill_item.target) == 'number') and refill_item.target or 0
            table.insert(results, {
                name = display, target = fallback_target, current = 0,
                deficit = fallback_target, moved = 0, short = fallback_target, source = ''
            })
        else
            -- Count current inventory across ALL variants
            local inv_count = 0
            local present_variant = nil -- first variant that is present in inventory
            for _, v in ipairs(variants) do
                local n = BagScanner.count_item_in_bag(items_data, 'inventory', v.id)
                inv_count = inv_count + n
                if n > 0 and not present_variant then
                    present_variant = v
                end
            end
            -- Display name: variant present in inv, else preferred variant
            local display_name = (present_variant and present_variant.name) or variants[1].name

            -- Resolve effective target. `target = 'all'` means "pull every piece
            -- available across inv + case + sack, never cap".
            local target = refill_item.target
            if target == 'all' then
                local available = 0
                for _, v in ipairs(variants) do
                    for _, source in ipairs(SOURCE_BAGS) do
                        available = available + BagScanner.count_item_in_bag(items_data, source.key, v.id)
                    end
                end
                target = inv_count + available
            end
            local deficit = target - inv_count

            local result = {
                name = display_name, target = target, current = inv_count,
                deficit = deficit, moved = 0, short = 0, source = '',
                surplus = 0, surplus_dest = nil
            }

            -- ---- SURPLUS: inv has more than target -> push back to store_bag ---
            if deficit < 0 then
                local surplus = -deficit
                local remaining_surplus = surplus
                for _, v in ipairs(variants) do
                    if remaining_surplus <= 0 then break end
                    local _, inv_slots = BagScanner.count_item_in_bag(items_data, 'inventory', v.id)
                    for _, slot_info in ipairs(inv_slots) do
                        if remaining_surplus <= 0 then break end
                        local to_move = math.min(remaining_surplus, slot_info.count)
                        table.insert(move_queue, {
                            bag_id = INVENTORY_BAG_ID, dst_id = store_info.id,
                            slot = slot_info.slot, count = to_move,
                            item_name = v.name, is_surplus = true
                        })
                        remaining_surplus = remaining_surplus - to_move
                    end
                end
                result.surplus = surplus - remaining_surplus
                result.surplus_dest = store_info.display
            end

            -- ---- DEFICIT: pull from Case/Sack (preferred variants first) -----
            if deficit > 0 then
                local remaining = deficit
                local sources = {}
                local pulled_variants = {} -- track which variant was pulled

                for _, v in ipairs(variants) do
                    if remaining <= 0 then break end
                    for _, source in ipairs(SOURCE_BAGS) do
                        if remaining <= 0 then break end
                        local available, slots = BagScanner.count_item_in_bag(items_data, source.key, v.id)
                        if available > 0 then
                            for _, slot_info in ipairs(slots) do
                                if remaining <= 0 then break end
                                local to_move = math.min(remaining, slot_info.count)
                                table.insert(move_queue, {
                                    bag_id = source.id, slot = slot_info.slot,
                                    count = to_move, item_name = v.name
                                })
                                remaining = remaining - to_move
                                result.moved = result.moved + to_move
                                if not sources[source.display] then
                                    sources[source.display] = true
                                    table.insert(sources, source.display)
                                end
                                if not pulled_variants[v.name] then
                                    pulled_variants[v.name] = true
                                end
                            end
                        end
                    end
                end

                result.short = math.max(0, remaining)
                result.source = table.concat(sources, '+')
                -- If preferred variant was missing in inv but we pulled it, update display
                if not present_variant then
                    for _, v in ipairs(variants) do
                        if pulled_variants[v.name] then
                            result.name = v.name
                            break
                        end
                    end
                end
            end

            table.insert(results, result)
        end
    end

    -- ====================================================================
    -- FOREIGN ITEMS: items in inventory that belong to OTHER jobs' refill
    -- lists (e.g. Omelette Sandwich on WAR - PLD's food). Push them all to
    -- the store_bag so the inventory only keeps the active job's items.
    -- ====================================================================
    local foreign_set = ConfigResolver.build_foreign_items_set(player.name, list)
    local foreign_results = {} -- {[item_name] = {moved=N, dest=str}}
    local inv_items = items_data.inventory
    if type(inv_items) == 'table' then
        for slot, it in pairs(inv_items) do
            if type(slot) == 'number' and type(it) == 'table' and it.id
               and it.count and it.count > 0 and foreign_set[it.id] then
                local display = foreign_set[it.id]
                table.insert(move_queue, {
                    bag_id = INVENTORY_BAG_ID, dst_id = store_info.id,
                    slot = slot, count = it.count,
                    item_name = display, is_surplus = true
                })
                foreign_results[display] = foreign_results[display] or {moved = 0, dest = store_info.display}
                foreign_results[display].moved = foreign_results[display].moved + it.count
            end
        end
    end
    -- Append a "foreign" result row for each pushed item type
    for name, info in pairs(foreign_results) do
        table.insert(results, {
            name = name, target = 0, current = info.moved,
            deficit = -info.moved, moved = 0, short = 0, source = '',
            surplus = info.moved, surplus_dest = info.dest, is_foreign = true
        })
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

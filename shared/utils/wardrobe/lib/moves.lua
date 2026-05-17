---  ═══════════════════════════════════════════════════════════════════════════
---   Wardrobe Organizer - Physical Move Primitives
---  ═══════════════════════════════════════════════════════════════════════════
---   Slot-precise FFXI item moves via windower.ffxi.get_item / put_item.
---   These functions send packets to the server; they do NOT wait for confirmation.
---   Callers must space their calls (see Config.POST_BURST_DELAY) to avoid
---   silent rate-limit rejections.
---
---   Public functions:
---     Moves.space_in(bag_id)            - free slots in a bag (0 if bag disabled)
---     Moves.pull_slot(src_bag, src_slot) - get_item from a specific source slot
---     Moves.push_slot(inv_slot, dst_bag) - put_item from a specific inv slot
---     Moves.find_inv_slot(item_id)      - first inv slot containing item_id
---     Moves.first_pinned_bag(id, pinned_bags)
---                                       - resolve first pin bag for an item id
---
---   @file shared/utils/wardrobe/lib/moves.lua
---  ═══════════════════════════════════════════════════════════════════════════

local Config = require('shared/utils/wardrobe/lib/config')
local Log = require('shared/utils/wardrobe/lib/log')
local Items = require('shared/utils/wardrobe/lib/items')

local Moves = {}

local INV_BAG = Config.INV_BAG
local dlog = Log.dlog
local bag_name = Log.bag_name

--- Free slots in a bag (0 if bag is disabled).
function Moves.space_in(bag_id)
    local b = windower.ffxi.get_bag_info(bag_id)
    return (b and b.enabled) and (b.max - b.count) or 0
end

--- Pull a SPECIFIC slot from a bag into inventory.
--- Returns (success, reason). Failure reasons: 'inv_full', 'empty', 'invalid'.
function Moves.pull_slot(src_bag, src_slot)
    if Moves.space_in(INV_BAG) <= 0 then
        dlog(('  pull SKIP %s[%d]: inv full'):format(bag_name(src_bag), src_slot))
        return false, 'inv_full'
    end
    local items = windower.ffxi.get_items(src_bag)
    if not items or not items[src_slot] then
        dlog(('  pull SKIP %s[%d]: empty slot'):format(bag_name(src_bag), src_slot))
        return false, 'empty'
    end
    local it = items[src_slot]
    if not it.id or it.id == 0 or it.status ~= 0 then
        dlog(
            ('  pull SKIP %s[%d]: invalid (id=%s status=%s)'):format(
                bag_name(src_bag),
                src_slot,
                tostring(it.id),
                tostring(it.status)
            )
        )
        return false, 'invalid'
    end
    dlog(('  pull get_item(%s[%d], id=%d, %d)'):format(bag_name(src_bag), src_slot, it.id, it.count or 1))
    windower.ffxi.get_item(src_bag, src_slot, it.count or 1)
    return true, 'ok'
end

--- Push a SPECIFIC inventory slot to a target bag.
--- Returns (success, reason). Failure reasons: 'dst_full', 'empty', 'invalid'.
function Moves.push_slot(inv_slot, dst_bag)
    if Moves.space_in(dst_bag) <= 0 then
        dlog(('  push SKIP inv[%d]>>%s: dst full'):format(inv_slot, bag_name(dst_bag)))
        return false, 'dst_full'
    end
    local items = windower.ffxi.get_items(INV_BAG)
    if not items or not items[inv_slot] then
        dlog(('  push SKIP inv[%d]: empty'):format(inv_slot))
        return false, 'empty'
    end
    local it = items[inv_slot]
    if not it.id or it.id == 0 or it.status ~= 0 then
        return false, 'invalid'
    end
    dlog(('  push put_item(%s, inv[%d], id=%d, %d)'):format(bag_name(dst_bag), inv_slot, it.id, it.count or 1))
    windower.ffxi.put_item(dst_bag, inv_slot, it.count or 1)
    return true, 'ok'
end

--- Find an inventory slot containing item_id (returns slot index or nil).
function Moves.find_inv_slot(item_id)
    local items = windower.ffxi.get_items(INV_BAG)
    if not items then
        return nil
    end
    for slot_idx, it in ipairs(items) do
        if it.id == item_id and it.status == 0 then
            return slot_idx
        end
    end
    return nil
end

--- Resolve the first pin bag for an item id (used by drain logic when we
--- don't have a snapshot entry, only an item id).
--- Returns nil if not pinned.
function Moves.first_pinned_bag(item_id, pinned_bags)
    if not pinned_bags then
        return nil
    end
    for _, n in ipairs(Items.item_names(item_id)) do
        local pins = pinned_bags[n]
        if pins and pins[1] then
            return pins[1]
        end
    end
    return nil
end

--- Resolve ALL pin bags for an item id, in declaration order. Used for
--- multi-instance items (e.g. Chirich Ring +1 with bag='wardrobe 1' and
--- bag='wardrobe 2'): when one pin is full the drainer can fall back to
--- the next.
--- @return table list of bag ids (empty if not pinned)
function Moves.all_pinned_bags(item_id, pinned_bags)
    local out = {}
    if not pinned_bags then return out end
    for _, n in ipairs(Items.item_names(item_id)) do
        local pins = pinned_bags[n]
        if pins then
            for _, b in ipairs(pins) do table.insert(out, b) end
            return out  -- first matching name wins
        end
    end
    return out
end

--- Like all_pinned_bags, but reorders pins to prefer those that DO NOT yet
--- contain a copy of this item. Solves the "dual ring" case (Chirich Ring +1
--- pinned to W1 + W2) where one copy is already in W1: the inv copy must go
--- to W2, not stack onto W1.
---
--- Status is intentionally NOT filtered: a bazaar/equipped/linkshell-locked
--- copy still physically occupies a slot in the bag, so the moveable copy
--- must go to a DIFFERENT pin bag. (Without this, a bazaar Moonlight Ring in
--- W1 would not "claim" W1 and the normal copy would land in W1 too.)
---
--- Returns: pins-with-no-copy first, then pins-already-having-a-copy as fallback.
function Moves.unclaimed_pins_first(item_id, pinned_bags)
    local pins = Moves.all_pinned_bags(item_id, pinned_bags)
    if #pins <= 1 then return pins end
    local unclaimed, claimed = {}, {}
    for _, b in ipairs(pins) do
        local items = windower.ffxi.get_items(b)
        local has_copy = false
        if items then
            for _, it in ipairs(items) do
                if it.id == item_id then
                    has_copy = true; break
                end
            end
        end
        if has_copy then
            table.insert(claimed, b)
        else
            table.insert(unclaimed, b)
        end
    end
    -- Empty pins first, occupied pins as last-resort fallback
    local out = {}
    for _, b in ipairs(unclaimed) do table.insert(out, b) end
    for _, b in ipairs(claimed)   do table.insert(out, b) end
    return out
end

return Moves

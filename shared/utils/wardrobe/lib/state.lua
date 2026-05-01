---  ═══════════════════════════════════════════════════════════════════════════
---   Wardrobe Organizer - State Recensement
---  ═══════════════════════════════════════════════════════════════════════════
---   Builds the algorithm's state table by scanning W1-W6 + W8 and categorizing
---   each item as either "needs to leave W1/W2" (w1w2_unused) or "needs to be
---   promoted from W3-W6" (w3w6_used). Honors `bag = 'wardrobe N'` pins via a
---   greedy claim_pool (multi-instance items each claim a different pin slot).
---
---   Public functions:
---     State.pin_target_for(entry, pinned_bags, claim_pool)
---           - resolve a pin target for one entry (mutates claim_pool)
---     State.snapshot_bag(bag_id, used_names)
---           - list of {bag, slot, id, count, name, used} entries in a bag
---     State.build_state()
---           - full state object: see returned table shape below
---     State.dlog_state(state, label)
---           - dump state summary to debug log
---
---   @file shared/utils/wardrobe/lib/state.lua
---  ═══════════════════════════════════════════════════════════════════════════

local Config = require('shared/utils/wardrobe/lib/config')
local Log    = require('shared/utils/wardrobe/lib/log')
local Items  = require('shared/utils/wardrobe/lib/items')
local Moves  = require('shared/utils/wardrobe/lib/moves')

local State = {}

local dlog       = Log.dlog
local space_in   = Moves.space_in
local INV_BAG    = Config.INV_BAG

--- Resolve the pinned target bag for an entry, given a `pinned_bags` map
--- (item_name_lower -> { bag_id_1, bag_id_2, ... }). Multi-instance items
--- are assigned greedily: each physical copy claims the next free pin slot.
--- Prefers claiming the bag the item is currently in (avoids needless moves).
--- `claim_pool[name]` = { remaining = { bag_id, ... } }  (mutated).
--- Returns nil if not pinned or pin slots exhausted.
function State.pin_target_for(entry, pinned_bags, claim_pool)
    for _, n in ipairs(Items.item_names(entry.id)) do
        local pins = pinned_bags[n]
        if pins and #pins > 0 then
            if not claim_pool[n] then
                local remaining = {}
                for _, b in ipairs(pins) do table.insert(remaining, b) end
                claim_pool[n] = {remaining = remaining}
            end
            local pool = claim_pool[n]
            -- Prefer claiming the bag the item is already in
            for i, b in ipairs(pool.remaining) do
                if b == entry.bag then
                    table.remove(pool.remaining, i)
                    return b
                end
            end
            if #pool.remaining > 0 then
                return table.remove(pool.remaining, 1)
            end
            return nil  -- more instances than pin slots
        end
    end
    return nil
end

--- Snapshot all equipment items in a single bag.
--- Returns a list of entries: {bag, slot, id, count, name, used, target=nil}.
function State.snapshot_bag(bag_id, used_names)
    local entries = {}
    local items = windower.ffxi.get_items(bag_id)
    if not items then return entries end
    for slot_idx, item in ipairs(items) do
        if item.id and item.id > 0 and item.status == 0 and Items.is_equipment(item.id) then
            table.insert(entries, {
                bag    = bag_id,
                slot   = slot_idx,
                id     = item.id,
                count  = item.count or 1,
                name   = Items.display_name(item.id),
                used   = Items.is_used_name(item.id, used_names),
                target = nil,
            })
        end
    end
    return entries
end

---  ═══════════════════════════════════════════════════════════════════════════
---   Returned state shape:
---     {
---        used_names    = { [name_lower] = true },     -- items used by active job
---        pinned_bags   = { [name_lower] = {bag,...} }, -- pins from sets
---        inv_free      = N,
---        wardrobe_free = { [bag_id] = N, ... },
---        items_by_bag  = { [bag_id] = { entry, ... } },
---        w1w2_unused   = list of entries currently in W1/W2 needing eviction
---        w3w6_used     = list of entries currently in W3-W6 needing promotion
---     }
---  ═══════════════════════════════════════════════════════════════════════════
function State.build_state()
    local used_names = Items.collect_used_names()
    if not used_names then
        return nil, 'no sets table found (run from a job-loaded GearSwap context)'
    end

    -- Load pinned bags map (item_name_lower -> { bag_id, ... }) from Auditor
    local pinned_bags = {}
    local ok, Auditor = pcall(require, 'shared/utils/equipment/wardrobe_auditor')
    if ok and Auditor and Auditor.build_pinned_bags then
        local ok2, pb = pcall(Auditor.build_pinned_bags)
        if ok2 and type(pb) == 'table' then pinned_bags = pb end
    end

    local state = {
        used_names    = used_names,
        pinned_bags   = pinned_bags,
        inv_free      = space_in(INV_BAG),
        wardrobe_free = {},
        items_by_bag  = {},
        w1w2_unused   = {},
        w3w6_used     = {},
    }

    for _, b in ipairs(Config.ALL_WARDROBES) do
        state.wardrobe_free[b] = space_in(b)
        state.items_by_bag[b]  = State.snapshot_bag(b, used_names)
    end

    -- Assign target bag to each entry. Pinned items get their pin's bag.
    -- Used unpinned items target W1/W2 (kind='primary'). Unused unpinned
    -- items target overflow (kind='overflow').
    local claim_pool = {}
    for _, b in ipairs(Config.ALL_WARDROBES) do
        for _, e in ipairs(state.items_by_bag[b]) do
            local pin = State.pin_target_for(e, pinned_bags, claim_pool)
            if pin then
                e.target = pin
                e.is_pinned = true
            elseif e.used then
                e.target_kind = 'primary'   -- "any of W1/W2" - resolved at execution
            else
                e.target_kind = 'overflow'  -- "any of W3-W6, W8"
            end
        end
    end

    -- Build move queues. An entry needs to move if:
    --   - Pinned and current_bag != target_bag
    --   - target_kind = 'primary' AND current_bag is in OVERFLOW (need to promote)
    --   - target_kind = 'overflow' AND current_bag is in PRIMARY (need to evict)
    local PRIMARY_SET = {}
    for _, b in ipairs(Config.PRIMARY_BAGS) do PRIMARY_SET[b] = true end

    for _, b in ipairs(Config.ALL_WARDROBES) do
        for _, e in ipairs(state.items_by_bag[b]) do
            if e.is_pinned then
                if e.bag ~= e.target then
                    if PRIMARY_SET[e.bag] then
                        table.insert(state.w1w2_unused, e)
                    else
                        table.insert(state.w3w6_used, e)
                    end
                end
            elseif e.target_kind == 'primary' then
                if not PRIMARY_SET[e.bag] then
                    table.insert(state.w3w6_used, e)
                end
            elseif e.target_kind == 'overflow' then
                if PRIMARY_SET[e.bag] then
                    table.insert(state.w1w2_unused, e)
                end
                -- Already in overflow → no move needed
            end
        end
    end

    return state
end

--- Dump a state summary to the debug log.
function State.dlog_state(state, label)
    dlog(('===== %s ====='):format(label))
    dlog(('  inv_free=%d  W1=%d W2=%d W3=%d W4=%d W5=%d W6=%d W8=%d'):format(
        state.inv_free,
        state.wardrobe_free[8] or -1, state.wardrobe_free[10] or -1,
        state.wardrobe_free[11] or -1, state.wardrobe_free[12] or -1,
        state.wardrobe_free[13] or -1, state.wardrobe_free[14] or -1,
        state.wardrobe_free[16] or -1))
    dlog(('  used_names=%d  w1w2_unused=%d  w3w6_used=%d'):format(
        (function() local n=0 for _ in pairs(state.used_names) do n=n+1 end return n end)(),
        #state.w1w2_unused, #state.w3w6_used))
end

return State

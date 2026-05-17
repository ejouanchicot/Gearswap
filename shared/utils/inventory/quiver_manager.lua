---  ═══════════════════════════════════════════════════════════════════════════
---   Quiver Manager - Auto-open ammo quivers when stack runs low
---  ═══════════════════════════════════════════════════════════════════════════
---   Watches a paired (ammo / quiver) item and auto-uses the quiver to
---   replenish the ammo stack when the count drops at or below a threshold.
---
---   Typical use: hooked from job_aftercast for spell.type == 'RangedAttack'.
---
---   Constraints:
---     • FFXI's `/item` command only works on inventory items, so the quiver
---       must be in the main inventory bag. The refill manager keeps it there.
---     • Ammo (Acid Bolt, etc.) is equipment, so the wardrobe organizer keeps
---       it in W1/W2 - we count it across inventory + all wardrobes.
---     • A throttle guards against the 1-2s gap between firing the use-item
---       and FFXI updating the inventory count, which would otherwise re-fire.
---
---   @file    shared/utils/inventory/quiver_manager.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-03
---  ═══════════════════════════════════════════════════════════════════════════

local QuiverManager = {}

--- Bag string keys scanned for ammo (matches windower.ffxi.get_items()).
--- Inventory + every wardrobe; W7 (craft) included for completeness.
local AMMO_BAGS = {
    'inventory',
    'wardrobe', 'wardrobe2', 'wardrobe3', 'wardrobe4',
    'wardrobe5', 'wardrobe6', 'wardrobe7', 'wardrobe8'
}

--- Re-arm window after firing a use-item. FFXI updates the inventory count
--- ~1-2s later; without this, the next ranged attack would see the same low
--- count and open a second quiver.
local OPEN_COOLDOWN = 8.0

--- Per-quiver-name last-use timestamp.
local last_open = {}

--- Count total instances of an item in a bag.
--- @param bag table|nil  windower.ffxi.get_items()[bag_key]
--- @param target_id number
--- @return number
local function count_in_bag(bag, target_id)
    if type(bag) ~= 'table' then return 0 end
    local total = 0
    for slot, item in pairs(bag) do
        if type(slot) == 'number' and type(item) == 'table'
           and item.id == target_id and item.count and item.count > 0 then
            total = total + item.count
        end
    end
    return total
end

--- Lazy-built name->id index over res.items (covers en/enl/log forms).
local _name_to_id = nil

local function build_name_index()
    local res = require('resources')
    local idx = {}
    for id, data in pairs(res.items) do
        if data then
            for _, field in ipairs({'en', 'enl', 'name', 'name_log'}) do
                local v = data[field]
                if type(v) == 'string' then
                    local key = v:lower()
                    if not idx[key] then idx[key] = id end
                end
            end
        end
    end
    return idx
end

local function resolve_id(name)
    if not _name_to_id then _name_to_id = build_name_index() end
    return _name_to_id[name:lower()]
end

--- Check if a quiver should be opened, and open it if so.
--- @param ammo_name string    e.g. 'Acid Bolt'
--- @param quiver_name string  e.g. 'Ac. Bolt Quiver'
--- @param threshold number    open when ammo total <= threshold
--- @return boolean opened     true if a use-item was sent
function QuiverManager.check_and_refill(ammo_name, quiver_name, threshold)
    if not ammo_name or not quiver_name or not threshold then
        return false
    end

    local now = os.clock()
    if last_open[quiver_name] and (now - last_open[quiver_name]) < OPEN_COOLDOWN then
        return false
    end

    local ammo_id = resolve_id(ammo_name)
    local quiver_id = resolve_id(quiver_name)
    if not ammo_id or not quiver_id then
        return false
    end

    local items = windower.ffxi.get_items()
    if not items then return false end

    -- Count ammo across inventory + all wardrobes
    local ammo_total = 0
    for _, bag_key in ipairs(AMMO_BAGS) do
        ammo_total = ammo_total + count_in_bag(items[bag_key], ammo_id)
    end

    if ammo_total > threshold then
        return false
    end

    -- Quiver must be in inventory for /item to work
    local quiver_in_inv = count_in_bag(items.inventory, quiver_id)
    if quiver_in_inv <= 0 then
        local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if ok and MessageFormatter and MessageFormatter.show_warning then
            MessageFormatter.show_warning(
                ('%s: %d left, no %s in inventory!'):format(ammo_name, ammo_total, quiver_name))
        end
        return false
    end

    last_open[quiver_name] = now
    send_command(('input /item "%s" <me>'):format(quiver_name))

    local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
    if ok and MessageFormatter and MessageFormatter.show_success then
        MessageFormatter.show_success(
            ('%s low (%d) -> opening %s'):format(ammo_name, ammo_total, quiver_name))
    end

    return true
end

return QuiverManager

---============================================================================
--- Atelier Export - every bag of the character, as the game holds it
---============================================================================
--- The content of each bag (inventory, wardrobes, satchel, sack, case, and the
--- Mog House's safes, storage and locker as the game last showed them): every
--- item with its count and, for a piece, the augments of that very copy. The
--- Atelier page's "My character" tab shows them bag by bag (bags_view.js), to
--- see where everything is before tidying up. Nil outside the game.
--- Read by shared/utils/atelier/atelier_export.lua (build).
---
--- @file    shared/utils/atelier/atelier_export_bags.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-11
---============================================================================

local ExportBags = {}

-- The bags in the order the page shows them: what is on the character, then the Mog House.
-- (3, temporary items, is left out: it empties itself)
local BAGS = {
    {id = 0, name = 'Inventory', place = 'self'},
    {id = 8, name = 'Wardrobe', place = 'self'}, {id = 10, name = 'Wardrobe 2', place = 'self'},
    {id = 11, name = 'Wardrobe 3', place = 'self'}, {id = 12, name = 'Wardrobe 4', place = 'self'},
    {id = 13, name = 'Wardrobe 5', place = 'self'}, {id = 14, name = 'Wardrobe 6', place = 'self'},
    {id = 15, name = 'Wardrobe 7', place = 'self'}, {id = 16, name = 'Wardrobe 8', place = 'self'},
    {id = 5, name = 'Mog Satchel', place = 'self'}, {id = 6, name = 'Mog Sack', place = 'self'},
    {id = 7, name = 'Mog Case', place = 'self'},
    {id = 1, name = 'Mog Safe', place = 'house'}, {id = 9, name = 'Mog Safe 2', place = 'house'},
    {id = 2, name = 'Storage', place = 'house'}, {id = 4, name = 'Mog Locker', place = 'house'},
}

--- What the page needs to know of an item, once per item id.
--- @param r table the item's entry in res.items
--- @return table {name, cat, stack, send}: its name, the game's category (Weapon, Armor, Usable, General...), its
--- stack size, and whether it can be sent to another character of the player's (a mule)
local function describe(r)
    local ok, Catalog = pcall(require, 'shared/utils/atelier/atelier_catalog')
    return {name = r.en, cat = r.category, stack = (r.stack or 1) > 1 and r.stack or nil,
        send = ok and Catalog.sendable(r) or nil}
end

--- The items of one bag: {id, n, augs}, in the bag's own order.
--- @param bag table windower.ffxi.get_items(bag id)
--- @param res table the game's resources
--- @param info table {item id as text = describe(...)}, filled as items are met
--- @param ids table list of the item ids met, filled too
--- @param augments function the augments of one copy (atelier_export_char.lua)
--- @return table
local function items_of(bag, res, info, ids, augments)
    local list = {}
    for _, item in ipairs(bag) do
        local r = type(item) == 'table' and item.id and item.id > 0 and res.items[item.id]
        if r then
            local key = tostring(item.id)
            if not info[key] then
                info[key] = describe(r)
                ids[#ids + 1] = item.id
            end
            list[#list + 1] = {id = item.id, n = item.count or 1, augs = augments(item)}
        end
    end
    return list
end

--- Every bag of the character.
--- @param augments function the augments of one copy of an item (a function: its item -> list or nil)
--- @return table|nil {at, bags = {{id, name, place, max, count, items}}, items = {id = {name, cat, stack}}}
--- @return table list of the item ids met (their icons are written with the export)
function ExportBags.collect(augments)
    local ok, res = pcall(require, 'resources')
    if not (ok and res and res.items and windower.ffxi and windower.ffxi.get_items) then return nil, {} end
    local bags, info, ids, held = {}, {}, {}, 0
    for _, def in ipairs(BAGS) do
        local okb, bag = pcall(windower.ffxi.get_items, def.id)
        -- a bag the game does not hold (outside the game, a wardrobe not bought) has no size
        if okb and type(bag) == 'table' and type(bag.max) == 'number' and bag.max > 0 then
            bags[#bags + 1] = {id = def.id, name = def.name, place = def.place, max = bag.max,
                count = type(bag.count) == 'number' and bag.count or nil, enabled = bag.enabled ~= false,
                items = items_of(bag, res, info, ids, augments)}
            held = held + #bags[#bags].items
        end
    end
    -- nothing anywhere: not a character's bags (the export made outside the game plays empty ones)
    if #bags == 0 or held == 0 then return nil, {} end
    return {at = os.date('%Y-%m-%d %H:%M'), bags = bags, items = info}, ids
end

return ExportBags

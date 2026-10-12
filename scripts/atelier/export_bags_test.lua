---============================================================================
--- Test - the bag export never records bags the game has only half sent
---============================================================================
--- Plays atelier_export_bags.lua against a game made of tables: every bag
--- sent, only the inventory sent (just after a login), a worn piece whose
--- wardrobe is not sent yet, and no game at all.
--- Run from data/: lua5.1 scripts/atelier/export_bags_test.lua
---
--- @file    scripts/atelier/export_bags_test.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-11
---============================================================================

package.path = './?.lua;' .. package.path

local failed, done = 0, 0
local function check(what, got, want)
    done = done + 1
    if got ~= want then
        failed = failed + 1
        print(('FAIL  %s: got %s, wanted %s'):format(what, tostring(got), tostring(want)))
    end
end

local BAG_IDS = {0, 1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}
local game

-- a game: {bag id = {item ids}}, and what is worn as {slot = {bag, index}}
local function new_game(held, worn)
    game = {bags = {}, equipment = {}}
    for _, id in ipairs(BAG_IDS) do
        local bag = {max = 80, count = 0, enabled = true}
        for i, item in ipairs(held[id] or {}) do bag[i] = {id = item, count = 1} bag.count = i end
        game.bags[id] = bag
    end
    for slot, at in pairs(worn or {}) do
        game.equipment[slot], game.equipment[slot .. '_bag'] = at[2], at[1]
    end
end

package.preload['resources'] = function() return {items = setmetatable({}, {__index = function(_, id)
    return {en = 'Item ' .. id, category = 'Armor', stack = 1} end})} end
package.preload['shared/utils/atelier/atelier_catalog'] = function() return {sendable = function() return true end} end
windower = {ffxi = {get_items = function(bag, index)
    if not bag then return {equipment = game.equipment} end
    if index then return game.bags[bag] and game.bags[bag][index] or {id = 0} end
    return game.bags[bag]
end}}

local Bags = require('shared/utils/atelier/atelier_export_bags')
local no_augs = function() return nil end

-- 1. every bag sent
new_game({[0] = {10, 11}, [8] = {20, 21}, [5] = {30}}, {head = {8, 2}})
check('bags all sent are read', Bags.read(), true)
local out = Bags.collect(no_augs)
check('and exported', out ~= nil and #out.bags, 16)
check('with the wardrobe', out and #out.bags[2].items, 2)

-- 2. just after a login: the inventory only
new_game({[0] = {10, 11}})
check('the inventory alone is not every bag', Bags.read(), false)
check('nothing exported', Bags.collect(no_augs), nil)

-- 3. a worn piece whose wardrobe is not sent yet, another bag already there
new_game({[0] = {10}, [5] = {30}}, {head = {8, 2}})
check('a worn piece missing from its wardrobe', Bags.read(), false)
check('nothing exported either', Bags.collect(no_augs), nil)

-- 4. nothing worn, things outside the inventory
new_game({[0] = {10}, [6] = {40}})
check('nothing worn, a sack with something', Bags.read(), true)

-- 5. no game
windower.ffxi.get_items = function() error('no game') end
check('no game: not read', Bags.read(), false)

-- 6. a command moved things (//gs c bags go, //gs c wo): the time the live link's ping carries is set once the
-- wait is over, not before
local waits = {}
coroutine.schedule = function(fn, delay) waits[#waits + 1] = {fn = fn, delay = delay} end
windower._bags_changed = nil
Bags.changed(8)
check('bags moved: nothing said before the wait', windower._bags_changed, nil)
check('bags moved: the wait asked for', waits[1] and waits[1].delay, 8)
waits[1].fn()
check('bags moved: the time is kept for the ping', type(windower._bags_changed), 'string')

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

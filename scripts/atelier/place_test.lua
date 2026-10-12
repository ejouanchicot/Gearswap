---============================================================================
--- Test of the place sent to the Atelier page (shared/utils/atelier/atelier_place.lua)
---============================================================================
--- Where the character stands, read from a game made of tables: the zone, the
--- Mog House, the moogles around with their distance, the bags open there.
---
--- Run from data/: lua5.1 scripts/atelier/place_test.lua
---
--- @file scripts/atelier/place_test.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-12
---============================================================================

package.path = './?.lua;' .. package.path

local done, failed = 0, 0
local function check(what, got, want)
    done = done + 1
    if got ~= want then
        failed = failed + 1
        print(('FAILED %s: got %s, wanted %s'):format(what, tostring(got), tostring(want)))
    end
end

local game = {logged_in = true, zone = 246, mog_house = false, mobs = {}}
windower = {ffxi = {
    get_info = function() return {logged_in = game.logged_in, zone = game.zone, mog_house = game.mog_house} end,
    get_player = function() return game.logged_in and {status = 0} or nil end,
    get_mob_array = function() return game.mobs end,
    get_bag_info = function() return {enabled = true, max = 80, count = 10} end,
    get_items = function() return {} end,
}}
package.preload['resources'] = function() return {zones = {[246] = {en = 'Port Jeuno'}}, items = {}} end
package.preload['shared/utils/messages/info_block'] = function() return {show = function() end} end

local Place = require('shared/utils/atelier/atelier_place')
local function bag(place, name)
    for _, b in ipairs(place.bags) do if b.name == name then return b end end
end

-- 1. outside the Mog House, a Porter Moogle at 3 yalms, another NPC, a player named like one, a far Nomad Moogle
game.mobs = {
    [5] = {name = 'Porter Moogle', is_npc = true, valid_target = true, distance = 9},
    [6] = {name = 'Shop Keeper', is_npc = true, valid_target = true, distance = 1},
    [7] = {name = 'Moogleman', is_npc = false, valid_target = true, distance = 1},
    [8] = {name = 'Nomad Moogle', is_npc = true, valid_target = true, distance = 400},
    [9] = {name = 'Moogle', is_npc = true, valid_target = false, distance = 4},
}
local place = Place.read()
check('the zone by its name', place.zone, 'Port Jeuno')
check('not in the Mog House', place.mog_house, false)
check('two moogles seen (not the shop, the player, the one not shown)', #place.moogles, 2)
check('the nearest first', place.moogles[1].name, 'Porter Moogle')
check('its distance in yalms', place.moogles[1].dist, 3)
check('within reach', place.moogles[1].near, true)
check('the far one is not', place.moogles[2].near, false)
check('twenty yalms away', place.moogles[2].dist, 20)
check('the inventory is open', bag(place, 'Inventory').open, true)
check('the Mog Safe is closed outside', bag(place, 'Mog Safe').open, false)
check('and says why', bag(place, 'Mog Safe').why, 'only in the Mog House')
game.mobs[8].distance = 16
place = Place.read()
check('a Nomad Moogle within reach is said', place.moogles[2].near, true)
check('it does not open the Mog Safe to the tidy-up', bag(place, 'Mog Safe').open, false)
game.mobs[8].distance = 400

check('how full the bags are, one number a bag', Place.bag_counts(), ('10,'):rep(15) .. '10')

-- 2. in the Mog House
game.mog_house = true
place = Place.read()
check('in the Mog House', place.mog_house, true)
check('the Mog Safe is open there', bag(place, 'Mog Safe').open, true)
check('the Storage too', bag(place, 'Storage').open, true)

-- 3. a zone the resources do not name, nobody around
game.zone, game.mobs = 999, {}
place = Place.read()
check('an unknown zone has no name', place.zone, nil)
check('no moogle', #place.moogles, 0)

-- 4. outside the game
game.logged_in = false
check('not logged in: nothing', Place.read(), nil)

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

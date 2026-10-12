---============================================================================
--- Atelier Place - where the character stands, for the Atelier page
---============================================================================
--- Read at every /ping of the live link (atelier_live.lua): the zone, whether
--- the character is in the Mog House, the moogles around (any NPC whose name
--- holds "Moogle": Porter, Nomad, the Mog House's own, and whatever else the
--- game shows) with their distance, and the bags the game opens there
--- (BagMover.bags_here: the very test //gs c bags go makes before a move).
--- It reads the game and changes nothing.
---
--- @file shared/utils/atelier/atelier_place.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-12
---============================================================================

local Place = {}

-- Yalms within which an NPC can be talked to
local REACH = 6

--- The moogles the game shows around the character, the nearest first.
--- @return table {{name, dist (yalms, one decimal), near (within reach)}}
local function moogles()
    local list = {}
    local ok, mobs = pcall(windower.ffxi.get_mob_array)
    for _, mob in pairs(ok and type(mobs) == 'table' and mobs or {}) do
        if type(mob) == 'table' and mob.valid_target and mob.is_npc and type(mob.name) == 'string'
            and mob.name:find('Moogle', 1, true) and type(mob.distance) == 'number' then
            local dist = math.sqrt(mob.distance)                -- the game gives the distance squared
            list[#list + 1] = {name = mob.name, dist = math.floor(dist * 10 + 0.5) / 10, near = dist <= REACH}
        end
    end
    table.sort(list, function(a, b) return a.dist < b.dist end)
    return list
end

--- Whether an NPC of that name stands within reach of the character.
--- @param name string
--- @return boolean
function Place.near(name)
    for _, m in ipairs(moogles()) do
        if m.name == name and m.near then return true end
    end
    return false
end

--- How full every bag is, as one short text ("23,80,68,..."): whatever moved an item (a command, the player, another
--- addon, a synthesis) changes it, and the page then reads the bags again. Nil outside the game.
--- @return string|nil
function Place.bag_counts()
    local counts = {}
    for _, id in ipairs({0, 1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}) do
        local ok, info = pcall(windower.ffxi.get_bag_info, id)
        if not ok or type(info) ~= 'table' then return nil end
        counts[#counts + 1] = tostring(info.count or 0)
    end
    return table.concat(counts, ',')
end

--- Where the character stands. Nil outside the game.
--- @return table|nil {zone, zone_id, mog_house, moogles, bags = {{id, name, open, why}}}
function Place.read()
    local info = windower.ffxi.get_info and windower.ffxi.get_info() or nil
    if not (info and info.logged_in and windower.ffxi.get_player()) then return nil end
    local ok, res = pcall(require, 'resources')
    local zone = ok and res and res.zones and res.zones[info.zone]
    local ok_b, bags = pcall(function() return require('shared/utils/wardrobe/bag_mover').bags_here() end)
    return {zone = zone and zone.en or nil, zone_id = info.zone, mog_house = info.mog_house == true,
        moogles = moogles(), bags = ok_b and bags or nil}
end

return Place

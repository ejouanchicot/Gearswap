---============================================================================
--- Slip Reader - what the storage slips hold, without Windower's slips library
---============================================================================
--- A storage slip is an item whose extdata has one bit per piece it can hold
--- (the game's res/slips: each slip's item id and its list of pieces, in bit
--- order). This reads those bits from the bags.
---
--- It replaces `require('slips')`, which must NOT be called from a job file.
--- GearSwap gives the sandbox `require = include_user`, which shares a
--- library only when the addon has loaded it AND the library returns a table.
--- slips.lua is not loaded by the addon, so it runs inside the sandbox; it
--- requires lists.lua, which returns nothing, so that one runs inside the
--- sandbox too, and so does tables.lua for the same reason. tables.lua then
--- wraps table.sort and table.concat, on the `table` the sandbox shares with
--- the addon, around the functions that are there: the ones the load before
--- left. One link a load, each held by the next: no load's sandbox was ever
--- freed again (about 4 MB a job change), and each sort went through every
--- link. Found in game on 2026-10-12 (//gs c jobtest, by elimination: a load
--- was freed unless the Atelier export had read the slips in it).
---
--- Same answers as the library for what the project used of it: the slips'
--- item ids in order, a slip's number, the bags a slip can be in, and the
--- pieces each slip holds.
---
--- @file    shared/utils/equipment/slip_reader.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-12
---============================================================================

local SlipReader = {}

--- The bags a slip can be in, as windower.ffxi.get_items() names them (the library's default_storages).
SlipReader.storages = {'inventory', 'safe', 'storage', 'locker', 'satchel', 'sack', 'case', 'wardrobe', 'safe2',
    'wardrobe2', 'wardrobe3', 'wardrobe4', 'wardrobe5', 'wardrobe6', 'wardrobe7', 'wardrobe8'}

--- The game's slips (the addon's own resources, shared with the sandbox).
local function slip_lines()
    local G = rawget(_G, 'gearswap')
    local res = type(G) == 'table' and G.res or nil
    if not res then
        local ok, loaded = pcall(require, 'resources')
        res = ok and loaded or nil
    end
    return res and res.slips or nil
end

-- res.slips never changes: built once a load. number() is asked for every item of every bag
-- (SlipItems.bags_ready), and rebuilding the sorted list each time was most of the export's stage 7.
local built_list, built_by_id

--- The slips in their order: {{id = the slip's item id, number, items = its pieces in bit order}}, and by item id.
--- @return table list, table by_id
function SlipReader.slips()
    if built_list then return built_list, built_by_id end
    local list, by_id, keys = {}, {}, {}
    local lines = slip_lines()
    for key, line in pairs(type(lines) == 'table' and lines or {}) do
        if type(key) == 'number' and type(line) == 'table' and line.item_id then keys[#keys + 1] = key end
    end
    table.sort(keys)
    for number, key in ipairs(keys) do
        local line = lines[key]
        local slip = {id = line.item_id, number = number, items = line.items or {}}
        list[number], by_id[slip.id] = slip, slip
    end
    if #list > 0 then built_list, built_by_id = list, by_id end
    return list, by_id
end

--- Whether an item is a storage slip, and its number.
--- @param id number item id
--- @return number|nil the slip's number (1 for Storage Slip 01)
function SlipReader.number(id)
    local _, by_id = SlipReader.slips()
    return by_id[id] and by_id[id].number or nil
end

--- The pieces a slip item holds: every bit set in its extdata names the piece at that place of the slip's list.
local function held(slip, extdata, into)
    for position = 0, #extdata * 8 - 1 do
        local byte = extdata:byte(math.floor(position / 8) + 1)
        if math.floor(byte / 2 ^ (position % 8)) % 2 ~= 0 then
            local piece = slip.items[position + 1]
            if piece then into[#into + 1] = piece end
        end
    end
end

--- The pieces each slip of the character holds.
--- @return table {slip item id = {piece ids}}, one entry a slip the game has (empty when the character has none
---   of its pieces, or not the slip), as the library's get_player_items
function SlipReader.player_items()
    local list, by_id = SlipReader.slips()
    local out = {}
    for _, slip in ipairs(list) do out[slip.id] = {} end
    local ok, items = pcall(windower.ffxi.get_items)
    if not ok or type(items) ~= 'table' then return out end
    for _, storage in ipairs(SlipReader.storages) do
        for _, item in ipairs(type(items[storage]) == 'table' and items[storage] or {}) do
            local slip = type(item) == 'table' and by_id[item.id]
            if slip and type(item.extdata) == 'string' then held(slip, item.extdata, out[slip.id]) end
        end
    end
    return out
end

return SlipReader

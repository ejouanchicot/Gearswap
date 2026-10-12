---============================================================================
--- Test of the slip reader (shared/utils/equipment/slip_reader.lua)
---============================================================================
--- The reader against the game's own list of slips (Windower's res/slips.lua)
--- and bags made of tables: which pieces a slip holds from the bits of its
--- extdata, the slips' numbers, and that Windower's slips library is named
--- nowhere in the job code any more (required from a job file, it keeps every
--- load in memory: see slip_reader.lua).
---
--- Run from data/: lua5.1 scripts/atelier/slip_reader_test.lua
---
--- @file scripts/atelier/slip_reader_test.lua
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

-- the game's slips, from Windower's resources (data/ is addons/GearSwap/data)
local lines = dofile('../../../res/slips.lua')
package.loaded['resources'] = {slips = lines}
local bags = {}
windower = {ffxi = {get_items = function() return bags end}}

local Slips = require('shared/utils/equipment/slip_reader')
local list, by_id = Slips.slips()
check('every slip of the game, in order', #list >= 33, true)
check('the first is Storage Slip 01', lines[1].item_id, list[1].id)
check('a slip knows its number', Slips.number(list[7].id), 7)
check('another item is no slip', Slips.number(4153), nil)

--- A slip's extdata with these bits set (0 = the first piece of its list).
local function extdata(bits, bytes)
    local out = {}
    for i = 1, bytes do out[i] = 0 end
    for _, bit in ipairs(bits) do
        local at = math.floor(bit / 8) + 1
        out[at] = out[at] + 2 ^ (bit % 8)
    end
    return string.char(unpack(out))
end

-- slip 02 in the satchel with its 1st, 10th and 16th pieces; slip 05 in a wardrobe with its 3rd; slip 09 not owned
local two, five = list[2], list[5]
bags = {inventory = {{id = 4153, count = 12, extdata = ''}}, satchel = {{id = 0}, {id = two.id, extdata = extdata({0, 9, 15}, 24)}},
    wardrobe3 = {{id = five.id, extdata = extdata({2}, 24)}}}
local held = Slips.player_items()
check('three pieces on slip 02', #held[two.id], 3)
check('its first', held[two.id][1], two.items[1])
check('its tenth', held[two.id][2], two.items[10])
check('its sixteenth', held[two.id][3], two.items[16])
check('one piece on slip 05, found in a wardrobe', held[five.id][1], five.items[3])
check('a slip that is not owned holds nothing', #held[list[9].id], 0)
check('one entry a slip of the game', (function() local n = 0 for _ in pairs(held) do n = n + 1 end return n end)(), #list)

-- a bit past the end of the slip's list names no piece
bags = {satchel = {{id = two.id, extdata = extdata({#two.items + 3}, 24)}}}
check('a bit with no piece is ignored', #Slips.player_items()[two.id], 0)

-- outside the game: no bag, no error
windower.ffxi.get_items = function() error('no game') end
check('no game: nothing held, no error', #Slips.player_items()[two.id], 0)

-- Windower's slips library is required nowhere in the job code
local named = {}
local pipe = io.popen('findstr /s /m /c:"\'slips\'" shared\\*.lua 2>nul')
for line in pipe:lines() do
    local text = io.open(line):read('*a'):gsub('%-%-[^\n]*', '')
    if text:find("require[%s(,]*['\"]slips['\"]") or text:find("require,%s*['\"]slips['\"]") then named[#named + 1] = line end
end
pipe:close()
check('no job file requires the slips library (' .. table.concat(named, ' ') .. ')', #named, 0)

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

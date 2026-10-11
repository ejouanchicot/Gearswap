---============================================================================
--- Test: the bag mover never loses an item
---============================================================================
--- shared/utils/wardrobe/bag_mover.lua plays the Atelier page's tidy-up plan.
--- This plays it against a game made of tables: bags, get_item and put_item
--- that move an item the way the game does, and that can be told to ignore a
--- call (the game refusing one under load). After every run, every item that
--- was in the bags is counted again: none may be missing, none may appear.
---
---   lua5.1 scripts/atelier/bag_mover_test.lua        (from data/)
---
--- @file    scripts/atelier/bag_mover_test.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-11
---============================================================================

package.path = './?.lua;' .. package.path
local failed = 0
local function check(what, got, want)
    if got ~= want then
        failed = failed + 1
        print(('FAIL %s: got %s, wanted %s'):format(what, tostring(got), tostring(want)))
    else
        print('ok   ' .. what)
    end
end

-- 1. the file touches a bag through two calls only
local source = io.open('shared/utils/wardrobe/bag_mover.lua'):read('*a')
local code = source:gsub('%-%-[^\n]*', '')
local allowed = {get_items = true, get_bag_info = true, get_info = true, get_player = true, get_item = true, put_item = true}
local other = {}
for name in code:gmatch('windower%.ffxi%.([%w_]+)') do if not allowed[name] then other[#other + 1] = name end end
check('only get_item and put_item change a bag (other calls: ' .. table.concat(other, ' ') .. ')', #other, 0)
for _, word in ipairs({'drop_item', 'inject', 'send_command', 'packets', 'os.remove', 'use_item', 'trade'}) do
    check('the code never says "' .. word .. '"', code:find(word, 1, true) == nil, true)
end

-- the game, as tables
local bags, mog_house, ignore, said, tasks, status
local function new_game()
    bags, mog_house, ignore, said, tasks, status = {}, false, {}, {}, {}, 0
    for _, id in ipairs({0, 1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}) do bags[id] = {max = 80, items = {}} end
end
local function add(bag, id, count, status)
    local slot = #bags[bag].items + 1
    bags[bag].items[slot] = {id = id, count = count or 1, status = status or 0}
    return slot
end
local function view(bag)
    local out = {}
    for i = 1, bags[bag].max do out[i] = bags[bag].items[i] or {id = 0, count = 0, status = 0} end
    return out
end
local function used(bag) local n = 0 for _, it in pairs(bags[bag].items) do if it.id > 0 then n = n + 1 end end return n end
local function free_slot(bag) for i = 1, bags[bag].max do local it = bags[bag].items[i] if not it or it.id == 0 then return i end end end
local function move(from, slot, to)
    local it, dest = bags[from].items[slot], free_slot(to)
    if not it or it.id == 0 or not dest then return end
    bags[to].items[dest], bags[from].items[slot] = it, {id = 0, count = 0, status = 0}
end
windower = {ffxi = {
    get_items = function(bag) return view(bag) end,
    get_bag_info = function(bag) return bags[bag] and {max = bags[bag].max, count = used(bag), enabled = true} or nil end,
    get_info = function() return {mog_house = mog_house, logged_in = true} end,
    get_player = function() return {status = status} end,
    get_item = function(bag, slot) if not ignore.get then move(bag, slot, 0) end end,
    put_item = function(bag, slot) if not ignore.put then move(0, slot, bag) end end,
}}
player = {name = 'Test'}
coroutine.schedule = function(fn) tasks[#tasks + 1] = fn end
local function run_all() local n = 0 while #tasks > 0 and n < 5000 do n = n + 1 table.remove(tasks, 1)() end end
package.preload['shared/utils/messages/info_block'] = function() return {show = function(b) said[#said + 1] = b.title end} end
package.preload['shared/utils/core/char_paths'] = function() return {writable = function() return os.tmpname() end} end

--- Every item of every bag, as one sorted line: what must be the same before and after.
local function census()
    local all = {}
    for _, bag in pairs(bags) do for _, it in pairs(bag.items) do if it.id > 0 then all[#all + 1] = it.id .. 'x' .. it.count .. 's' .. it.status end end end
    table.sort(all)
    return table.concat(all, ' ')
end
local function count_in(bag, id) local n = 0 for _, it in pairs(bags[bag].items) do if it.id == id then n = n + it.count end end return n end
local function fresh() windower._bag_mover = nil package.loaded['shared/utils/wardrobe/bag_mover'] = nil return require('shared/utils/wardrobe/bag_mover') end

-- 2. the plan: only well-formed lines are taken
new_game()
local Mover = fresh()
local r = Mover.set_plan('100\t8\t10\tRing\n200\t8\t8\tSame bag\nabc\n300\t8\t99\tUnknown bag\n400\t6\t7\tCrystal\n')
check('two good lines taken', r.moves, 2)
check('three bad lines refused', r.refused, 3)

-- 3. a plain run: everything arrives, nothing is lost
new_game()
add(8, 100) add(8, 101) add(6, 400, 12) add(0, 500, 3)
local before = census()
Mover = fresh()
Mover.set_plan('100\t8\t10\tRing\n101\t8\t11\tCape\n400\t6\t7\tCrystal\n500\t0\t5\tMeat\n')
Mover.preview()
check('a preview moves nothing', census() == before and count_in(8, 100) == 1, true)
Mover.start() run_all()
check('the ring is in Wardrobe 2', count_in(10, 100), 1)
check('the stack of crystals is in the Mog Case, whole', count_in(7, 400), 12)
check('the meat went from the inventory to the Satchel', count_in(5, 500), 3)
check('nothing is left in the inventory', used(0), 0)
check('every item is still there', census(), before)

-- 4. what cannot be moved is skipped, not forced
new_game()
add(8, 100, 1, 5)                                  -- worn
add(8, 101) for _ = 1, 80 do add(11, 900) end      -- its bag is full
add(8, 102)                                        -- to a Mog House bag, outside
before = census()
Mover = fresh()
Mover.set_plan('100\t8\t10\tWorn ring\n101\t8\t11\tCape\n102\t8\t1\tOld hat\n')
Mover.start() run_all()
check('a worn piece stays', count_in(8, 100), 1)
check('a piece whose bag is full stays', count_in(8, 101), 1)
check('a Mog House bag is not used outside', count_in(8, 102), 1)
check('every item is still there', census(), before)
mog_house = true
Mover.start() run_all()
check('in the Mog House it goes to the Mog Safe', count_in(1, 102), 1)
check('every item is still there', census(), before)

-- 5. the game ignores the call that takes an item out: the run stops, the item has not moved
new_game()
add(8, 100) add(8, 101)
before = census()
Mover = fresh()
Mover.set_plan('100\t8\t10\tRing\n101\t8\t10\tCape\n')
ignore.get = true
Mover.start() run_all()
check('the run stopped', windower._bag_mover.running, false)
check('the ring has not moved', count_in(8, 100), 1)
check('the next move was not tried', count_in(8, 101), 1)
check('every item is still there', census(), before)

-- 6. the game ignores the call that puts it away: the run stops, the item waits in the inventory
new_game()
add(8, 100) add(8, 101)
before = census()
Mover = fresh()
Mover.set_plan('100\t8\t10\tRing\n101\t8\t10\tCape\n')
ignore.put = true
Mover.start() run_all()
check('the run stopped', windower._bag_mover.running, false)
check('the ring waits in the inventory', count_in(0, 100), 1)
check('every item is still there', census(), before)

-- 7. the inventory is full: nothing is taken out
new_game()
add(8, 100) for _ = 1, 80 do add(0, 900) end
before = census()
Mover = fresh()
Mover.set_plan('100\t8\t10\tRing\n')
Mover.start() run_all()
check('with a full inventory the ring stays', count_in(8, 100), 1)
check('every item is still there', census(), before)

-- 8. stopped by the player in the middle
new_game()
for i = 1, 10 do add(8, 100 + i) end
before = census()
Mover = fresh()
local lines = {}
for i = 1, 10 do lines[i] = (100 + i) .. '\t8\t10\tPiece ' .. i end
Mover.set_plan(table.concat(lines, '\n'))
Mover.start()
for _ = 1, 7 do if #tasks > 0 then table.remove(tasks, 1)() end end
Mover.stop() run_all()
check('stopped: not everything moved', used(10) < 10, true)
check('every item is still there', census(), before)

-- 9. not idle (engaged, in an event): nothing starts, and a run stops before its next move
new_game()
add(8, 100) add(8, 101)
before = census()
Mover = fresh()
Mover.set_plan('100\t8\t10\tRing\n101\t8\t10\tCape\n')
status = 1
Mover.start() run_all()
check('engaged: nothing moves', count_in(8, 100) + count_in(8, 101), 2)
status = 0
Mover.start()
if #tasks > 0 then table.remove(tasks, 1)() end      -- the first piece is in hand: its move is finished, the next is not begun
status = 4
run_all()
check('an event in the middle: the run stopped', windower._bag_mover.running, false)
check('the second piece was not taken', count_in(8, 101), 1)
check('every item is still there', census(), before)
status = 0
Mover.start() run_all()
check('idle again: go takes up where it stopped', count_in(10, 101), 1)
check('every item is still there', census(), before)

-- 10. a plan made for another character is not played
new_game()
add(8, 100)
Mover = fresh()
Mover.set_plan('100\t8\t10\tRing\n')
player = {name = 'Other'}
Mover.start() run_all()
check('another character: nothing moves', count_in(8, 100), 1)

print(failed == 0 and '\nno item can be lost: every run leaves every item in a bag' or ('\n' .. failed .. ' check(s) failed'))
os.exit(failed == 0 and 0 or 1)

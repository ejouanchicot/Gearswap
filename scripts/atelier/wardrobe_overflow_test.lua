---============================================================================
--- Test of the organizer's overflow packing (shared/utils/wardrobe/lib/phases.lua)
---============================================================================
--- Phase 2 empties the used bags while the first overflow bags are still full
--- of the next job's gear, so it spills into the last one. Once Phase 3 has made
--- room, Phases.compact_overflow brings back what the run pushed there, and only
--- that. Played against a game made of tables: no item may be lost or doubled.
---
--- Run from data/: lua5.1 scripts/atelier/wardrobe_overflow_test.lua
---
--- @file scripts/atelier/wardrobe_overflow_test.lua
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

-- The game: bags of fixed size, a slot holds an item id or 0
local INV, W1, W3, W4, W8 = 0, 8, 11, 12, 16
local bags
local function new_game(def)
    bags = {}
    for id, b in pairs(def) do
        bags[id] = {}
        for slot = 1, b.max do bags[id][slot] = b[slot] or 0 end
    end
end
local function count(bag, id)
    local n = 0
    for _, held in ipairs(bags[bag]) do if held == id or (id == nil and held ~= 0) then n = n + 1 end end
    return n
end
local function total()
    local n = 0
    for bag in pairs(bags) do n = n + count(bag) end
    return n
end
local function free_slot(bag)
    for slot, held in ipairs(bags[bag]) do if held == 0 then return slot end end
end

local tasks = {}
coroutine.schedule = function(fn) tasks[#tasks + 1] = fn end
local function run()
    local guard = 0
    while #tasks > 0 and guard < 500 do guard = guard + 1 table.remove(tasks, 1)() end
end

windower = {ffxi = {get_items = function(bag)
    local list = {}
    for slot, id in ipairs(bags[bag]) do list[slot] = {id = id, status = 0} end
    return list
end}}

local used = {}
package.loaded['shared/utils/wardrobe/lib/config'] = {INV_BAG = INV, BURST_SIZE = 4, STUCK_LIMIT = 3, MAX_STEPS = 100,
    MOVE_DELAY = 0, POST_BURST_DELAY = 0, TRULY_STUCK_THRESHOLD = 3, PRIMARY_BAGS = {W1}, OVERFLOW_BAGS = {W3, W4, W8}}
package.loaded['shared/utils/wardrobe/lib/log'] = {dlog = function() end, bag_name = tostring}
package.loaded['shared/utils/wardrobe/lib/items'] = {is_equipment = function() return true end,
    is_used_name = function(id) return used[id] == true end, display_name = tostring}
package.loaded['shared/utils/wardrobe/lib/state'] = {pin_target_for = function() return nil end}
package.loaded['shared/utils/wardrobe/lib/moves'] = {
    space_in = function(bag) return #bags[bag] - count(bag) end,
    unclaimed_pins_first = function() return {} end,
    all_pinned_bags = function() return {} end,
    pull_slot = function(bag, slot)
        local to = free_slot(INV)
        if not to or bags[bag][slot] == 0 then return false end
        bags[INV][to], bags[bag][slot] = bags[bag][slot], 0
        return true
    end,
    push_slot = function(slot, bag)
        local to = free_slot(bag)
        if not to or bags[INV][slot] == 0 then return false end
        bags[bag][to], bags[INV][slot] = bags[INV][slot], 0
        return true
    end}

local Phases = require('shared/utils/wardrobe/lib/phases')
local state = {used_names = {}, pinned_bags = {}}

-- 1. the old job's six pieces leave W1 while W3 and W4 are full: they spill into W8, where the player keeps
-- a piece of the same kind (50) and a second copy of a spilled one (1)
new_game({[INV] = {max = 10}, [W1] = {max = 8, 1, 2, 3, 4, 5, 6},
    [W3] = {max = 4, 101, 102, 103, 60}, [W4] = {max = 3, 104, 61, 62}, [W8] = {max = 12, 50, 1}})
used = {[101] = true, [102] = true, [103] = true, [104] = true}
local before = total()
Phases.forget_spilled()
Phases.empty_w1w2(state, function() end)
run()
check('phase 2: W1 emptied', count(W1), 0)
check('phase 2: the six pieces spilled into the last bag', count(W8), 8)

-- 2. the fill takes the new job's gear out of W3 and W4 (played by hand: four slots freed)
for _, bag in ipairs({W3, W4}) do
    for slot, id in ipairs(bags[bag]) do
        if used[id] then bags[bag][slot] = 0 bags[W1][free_slot(W1)] = id end
    end
end

local ended = 0
Phases.compact_overflow(state, function() ended = ended + 1 end)
run()
check('pack: it ended once', ended, 1)
check('pack: the first overflow bag is full again', count(W3), 4)
check('pack: then the second', count(W4), 3)
check('pack: four came back, four stayed', count(W8), 4)
check('pack: the piece the player keeps there did not move', count(W8, 50), 1)
check('pack: nothing left in the inventory', count(INV), 0)
check('pack: no item lost or doubled', total(), before)
check('pack: one copy of the doubled piece came back at most', count(W3, 1) + count(W4, 1) <= 1, true)

-- 3. nothing pushed by the run: nothing is pulled, whatever the room
new_game({[INV] = {max = 10}, [W1] = {max = 8}, [W3] = {max = 4}, [W4] = {max = 3}, [W8] = {max = 12, 50, 51, 52}})
Phases.forget_spilled()
Phases.compact_overflow(state, function() end)
run()
check('nothing spilled: the last bag is left as it is', count(W8), 3)

-- 4. no room in the earlier bags: nothing is pulled
new_game({[INV] = {max = 10}, [W1] = {max = 8, 1, 2}, [W3] = {max = 2, 60, 61}, [W4] = {max = 1, 62}, [W8] = {max = 12}})
used = {}
Phases.forget_spilled()
Phases.empty_w1w2(state, function() end)
run()
Phases.compact_overflow(state, function() end)
run()
check('no room earlier: the spill stays in the last bag', count(W8), 2)
check('no room earlier: nothing in the inventory', count(INV), 0)

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

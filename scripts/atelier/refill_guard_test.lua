---============================================================================
--- Test: the refill never moves what it did not plan to move
---============================================================================
--- shared/utils/inventory/refill_manager.lua plans its moves on one reading of
--- the bags and sends them one by one. Played against a game made of tables:
--- when a slot changes between the plan and the move (something else took the
--- item's place), that move is not sent.
---
--- Run from data/: lua5.1 scripts/atelier/refill_guard_test.lua
---
--- @file scripts/atelier/refill_guard_test.lua
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

-- ids: 10 Remedy (listed, target 12), 20 Sushi (another job's list), 99 Beastmen's Seal (in no list)
local BAGS, sent, errors, tasks, before_moves
local KEYS = {[0] = 'inventory', [7] = 'case'}
local function new_game()
    BAGS = {inventory = {[1] = {id = 10, count = 20, status = 0}, [2] = {id = 20, count = 6, status = 0},
        [3] = {id = 99, count = 2, status = 0}}, case = {[1] = {id = 10, count = 30, status = 0}}}
    sent, errors, tasks, before_moves = {}, {}, {}, nil
end

player = {name = 'Test'}
coroutine.schedule = function(fn) tasks[#tasks + 1] = fn end
windower = {ffxi = {
    get_items = function(bag, slot)
        if bag == nil then return BAGS end
        return (BAGS[KEYS[bag]] or {})[slot] or {id = 0, count = 0, status = 0}
    end,
    put_item = function(bag, slot, count) sent[#sent + 1] = ('put %d x%d'):format(BAGS.inventory[slot].id, count) end,
    get_item = function(bag, slot, count) sent[#sent + 1] = ('get %d x%d'):format(BAGS[KEYS[bag]][slot].id, count) end,
}}
package.loaded['shared/utils/inventory/refill/item_resolver'] = {
    resolve_variants = function(name) return name == 'Remedy' and {{id = 10, name = 'Remedy'}} or {} end}
package.loaded['shared/utils/inventory/refill/config_resolver'] = {
    resolve_list_for_player = function()
        return {{name = 'Remedy', target = 12}}, 'test', {id = 7, display = 'Case', sources = {{key = 'case', id = 7, display = 'Case'}}}
    end,
    build_foreign_items_set = function() return {[20] = 'Sushi'} end,
    default_sources = function() return {} end}
package.loaded['shared/utils/inventory/refill/refill_panels'] = {show_start = function() end,
    -- called once the plan is made, before the first move: where the test changes the bags
    show_progress = function() if before_moves then before_moves() end end,
    show_report = function() end, show_error = function(msg) errors[#errors + 1] = msg end}
package.loaded['shared/utils/debug/trace_log'] = {log = function() end}
local told = 0
package.loaded['shared/utils/atelier/atelier_export_bags'] = {changed = function() told = told + 1 end}

local Refill = require('shared/utils/inventory/refill_manager')
local function run() while #tasks > 0 do table.remove(tasks, 1)() end end

-- 1. nothing changes: the surplus of the listed item and the other job's item go back, the seal is never named
new_game()
Refill.refill() run()
check('the surplus goes back', sent[1], 'put 10 x8')
check('the other job\'s item goes back', sent[2], 'put 20 x6')
check('two moves, no more', #sent, 2)
check('nothing said', #errors, 0)
check('the page is told once, at the end', told, 1)

-- 2. between the plan and the second move, a seal takes the slot of the other job's item: that move is not sent
new_game()
Refill.refill()
BAGS.inventory[2] = {id = 99, count = 2, status = 0}
run()
check('the first move is sent', sent[1], 'put 10 x8')
check('the seal in the changed slot is not moved', #sent, 1)
check('and it is said', #errors, 1)

-- 3. the planned item is still there but fewer of it, or worn: not moved either
new_game()
Refill.refill()
BAGS.inventory[2].count = 3
run()
check('fewer than planned: not moved', #sent, 1)
new_game()
BAGS.inventory[1] = {id = 10, count = 20, status = 0}
Refill.refill()
BAGS.inventory[2].status = 5
run()
check('no longer free to move: not moved', #sent, 1)

-- 4. a slot emptied in a source bag after the plan: the pull is not sent
new_game()
BAGS.inventory[1].count = 4
before_moves = function()
    BAGS.case[1] = {id = 0, count = 0, status = 0}
    BAGS.inventory[2] = {id = 0, count = 0, status = 0}
end
Refill.refill() run()
check('an emptied source slot: nothing is pulled, nothing pushed (' .. table.concat(sent, ', ') .. ')', #sent, 0)
check('and it is said once', #errors, 1)

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

---============================================================================
--- Test of the hooks every entry shares (shared/utils/core/entry_kit.lua)
---============================================================================
--- The first macro book and lockstyle come even when the keybinds did not
--- load (the facade defines them only after user_setup), and a newer load
--- drops them, and so does the old sandbox's user_setup() on a subjob change;
--- unload cancels then unbinds; a subjob change goes to
--- JobChangeManager with the job of the game.
---
--- Run from data/: lua5.1 scripts/atelier/entry_kit_test.lua
---
--- @file scripts/atelier/entry_kit_test.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-15
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

-- a clock of our own for coroutine.schedule
local now, queue = 0, {}
coroutine.schedule = function(fn, delay) queue[#queue + 1] = {at = now + delay, fn = fn} end
local function run_until(t)
    while true do
        table.sort(queue, function(a, b) return a.at < b.at end)
        local nxt = queue[1]
        if not nxt or nxt.at > t then break end
        table.remove(queue, 1)
        now = nxt.at
        nxt.fn()
    end
    now = t
end

player = {main_job = 'WAR', sub_job = 'SAM'}
windower = {_load_gen = 1, ffxi = {get_player = function() return {main_job = 'WAR', sub_job = 'SAM'} end}}
package.loaded['shared/utils/debug/trace_log'] = {log = function() end}

local calls = {}
local JCM = {
    on_job_change = function(main, sub) calls[#calls + 1] = 'change ' .. main .. '/' .. sub end,
    cancel_all = function() calls[#calls + 1] = 'cancel' end,
}
package.loaded['shared/utils/core/job_change_manager'] = JCM

local EntryKit = require('shared/utils/core/entry_kit')

-- 1. keybinds failed: the two functions do not exist during user_setup
select_default_macro_book, select_default_lockstyle = nil, nil
EntryKit.macro_and_lockstyle(8)
-- get_sets() then includes the facade
select_default_macro_book = function() calls[#calls + 1] = 'macro' end
select_default_lockstyle = function() calls[#calls + 1] = 'lockstyle' end
run_until(1)
check('macro book once the facade is there', calls[1], 'macro')
check('lockstyle not yet', calls[2], nil)
run_until(9)
check('lockstyle after its delay', calls[2], 'lockstyle')

-- 2. a newer load before the 0.2 s: nothing from the old one
calls = {}
EntryKit.macro_and_lockstyle(8)
windower._load_gen = 2
run_until(20)
check('a newer load drops the old macro book', #calls, 0)

-- 2b. a subjob change: Mote calls user_setup() again in the old sandbox, with
-- player.sub_job already the new one; the reload sends the book, not this call
calls = {}
windower._load_gen = 3
_G.JobChangeManagerSTATE = {current_sub_job = 'SAM'}
player = {main_job = 'WAR', sub_job = 'DNC'}
EntryKit.macro_and_lockstyle(8)
run_until(40)
check('no macro book from the old sandbox on a subjob change', #calls, 0)
check('reload pending seen', EntryKit.reload_pending(), true)

-- 2c. the reload (state seeded with the new subjob): the book goes out
_G.JobChangeManagerSTATE = {current_sub_job = 'DNC'}
windower.ffxi.get_player = function() return {main_job = 'WAR', sub_job = 'DNC'} end
EntryKit.macro_and_lockstyle(8)
run_until(60)
check('macro book from the reload', calls[1], 'macro')
check('lockstyle from the reload', calls[2], 'lockstyle')

-- 2d. no subjob in the game, or no state seeded: never taken for a change
_G.JobChangeManagerSTATE = {current_sub_job = 'DNC'}
player = {main_job = 'WAR', sub_job = nil}
check('no subjob: no reload pending', EntryKit.reload_pending(), false)
_G.JobChangeManagerSTATE = nil
player = {main_job = 'WAR', sub_job = 'DNC'}
check('no state: no reload pending', EntryKit.reload_pending(), false)
windower.ffxi.get_player = function() return {main_job = 'WAR', sub_job = 'SAM'} end
player = {main_job = 'WAR', sub_job = 'SAM'}

-- 3. unload: cancel first, then the keys
calls = {}
EntryKit.unload({unbind_all = function() calls[#calls + 1] = 'unbind' end})
check('unload cancels', calls[1], 'cancel')
check('unload unbinds', calls[2], 'unbind')
EntryKit.unload(nil)
check('unload without keys', calls[3], 'cancel')

-- 4. subjob change: the game's main job, the entry's when player is not readable
calls = {}
EntryKit.sub_job_change('WAR', 'DNC')
player = nil
EntryKit.sub_job_change('WAR', 'NIN')
check('subjob change with the game job', calls[1], 'change WAR/DNC')
check('subjob change without player', calls[2], 'change WAR/NIN')

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

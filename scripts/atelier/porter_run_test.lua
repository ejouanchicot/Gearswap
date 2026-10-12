---============================================================================
--- Test of //gs c po (shared/utils/wardrobe/porter_run.lua)
---============================================================================
--- The chain PorterPacker, wardrobes, refill against a game made of tables:
--- what is sent with a Porter Moogle within reach, without one, without the
--- addon, and when the character is not idle.
---
--- Run from data/: lua5.1 scripts/atelier/porter_run_test.lua
---
--- @file scripts/atelier/porter_run_test.lua
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

local game, sent, synced
local function new_game()
    game = {status = 0, installed = true, mobs = {}}
    sent, synced = {}, 0
end
player = {name = 'Test', main_job = 'WAR'}
windower = {windower_path = 'X:/', dir_exists = function() return game.installed end,
    send_command = function(cmd) sent[#sent + 1] = cmd end,
    ffxi = {
        get_player = function() return game.status and {status = game.status} or nil end,
        get_mob_array = function() return game.mobs end,
    }}
package.loaded['shared/utils/messages/info_block'] = {show = function() end}
package.loaded['shared/utils/atelier/porter_lists'] = {sync = function() synced = synced + 1 end}

local PorterRun = require('shared/utils/wardrobe/porter_run')
local function moogle(yalms)
    return {name = 'Porter Moogle', is_npc = true, valid_target = true, distance = yalms * yalms}
end

-- 1. a Porter Moogle within reach: PorterPacker, which starts the wardrobes itself when it has finished
new_game()
game.mobs = {moogle(3)}
local r = PorterRun.start()
check('within reach: started', r.ok, true)
check('PorterPacker asked', r.porter, true)
check('one command sent', #sent, 1)
check('PorterPacker, then the wardrobes', sent[1], 'lua load PorterPacker; wait 1; po then gs c wo')
check('its list is brought up to date first', synced, 1)

-- 2. the moogle is too far: the wardrobes alone
new_game()
game.mobs = {moogle(15)}
r = PorterRun.start()
check('too far: PorterPacker not asked', r.porter, false)
check('the wardrobes alone', sent[1], 'gs c wo')
check('nothing else', #sent, 1)

-- 3. PorterPacker is not installed: the wardrobes alone, even beside a moogle
new_game()
game.mobs, game.installed = {moogle(2)}, false
r = PorterRun.start()
check('not installed: the wardrobes alone', sent[1], 'gs c wo')
check('its list is not touched', synced, 0)

-- 4. not idle (fighting, in an event), or outside the game: nothing is sent
new_game()
game.mobs, game.status = {moogle(2)}, 1
r = PorterRun.start()
check('engaged: not started', r.ok, false)
check('engaged: nothing sent', #sent, 0)
game.status = nil
r = PorterRun.start()
check('outside the game: nothing sent', #sent, 0)

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

---============================================================================
--- Test of Widened Compass first (shared/jobs/geo/functions/logic/geo_auto_abilities.lua)
--- Run from data/: lua5.1 scripts/atelier/widened_compass_test.lua
--- @file scripts/atelier/widened_compass_test.lua
--- @author ejouanchicot
--- @date Created: 2026-11-13
---============================================================================
-- A Geo- on a listed monster: Widened Compass, then the Geo- once its buff is up; the bot's own Geo- sent during
-- the wait is cancelled, only this module's recast goes (no second Geo-, no Full Circle throwing the bubble away).
package.path = './?.lua;' .. package.path

local clock, sent, buff, ready, follow = 0, {}, false, true, nil
os.clock = function() return clock end
send_command = function(c) sent[#sent + 1] = c end
windower = {}
local config = {widened_compass_on = {'Aita'}}
package.loaded['shared/utils/core/job_config'] = {get = function(_, k, d) local v = config[k] if v == nil then return d end return v end}
package.loaded['shared/utils/core/auto_options'] = {on = function() return false end}
package.loaded['shared/utils/precast/ability_helper'] = {
    is_buff_active = function() return buff end,
    is_ability_ready = function() return ready end,
    follow_up = function(_, fn) follow = fn end,
    try_ability = function() end,
}
local G = dofile('shared/jobs/geo/functions/logic/geo_auto_abilities.lua')

local fails = 0
local function check(name, ok) if not ok then fails = fails + 1 end print((ok and 'ok   ' or 'FAIL ') .. name) end
local function cast(target)
    local args = {}
    G.apply({skill = 'Geomancy', english = 'Geo-Gravity', target = {name = target or 'Aita', id = 77}}, args)
    return args.cancel == true or args.handled == true
end
local function count(cmd) local n = 0 for _, c in ipairs(sent) do if c == cmd then n = n + 1 end end return n end

check('Geo- on Aita: cancelled for Widened Compass', cast())
check('Widened Compass sent', count('input /ja "Widened Compass" <me>') == 1)
clock = 1
check('the bot\'s Geo- during the wait: cancelled', cast())
check('no second Widened Compass', count('input /ja "Widened Compass" <me>') == 1)
buff = true
follow()
check('buff up: the Geo- sent once', count('input /ma "Geo-Gravity" 77') == 1)
check('that recast goes through', not cast())
clock = 3
check('the bot\'s Geo- right after: cancelled', cast())
clock = 10
check('guard over, buff up: a Geo- goes as is', not cast())

windower._geo_compass_wait, buff, sent = nil, false, {}
check('another monster: untouched', not cast('Degei'))
ready = false
check('Widened Compass on recast: the Geo- goes', not cast())
config.widened_compass_on = {}
ready = true
check('list empty: off', not cast())

print(fails == 0 and 'ALL OK' or (fails .. ' FAILED'))
os.exit(fails == 0 and 0 or 1)

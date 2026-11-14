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
local outside, allowed, fc_queued
os.clock = function() return clock end
send_command = function(c) sent[#sent + 1] = c end
windower = {}
local config = {widened_compass_on = {'Aita'}}
package.loaded['shared/utils/core/job_config'] = {get = function(_, k, d) local v = config[k] if v == nil then return d end return v end}
local fc_on = false
package.loaded['shared/utils/core/auto_options'] = {on = function(k) return k == 'geo_full_circle' and fc_on end}
package.loaded['shared/jobs/geo/functions/logic/luopan_behind'] = {behind_on = function() return false end}
package.loaded['shared/utils/precast/ability_helper'] = {
    is_buff_active = function() return buff end,
    is_ability_ready = function() return ready end,
    follow_up = function(_, fn) follow = fn end,
    try_ability = function() end,
    -- the ability queue (shared/utils/precast/ability_queue.lua): what the compass tells it is recorded
    queue = function() return {
        sent_outside = function(a) outside = a end,
        allow_next = function(s) allowed = s end,
        queued = function(a) return a == fc_queued end,
    } end,
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
check('the queue told: Widened Compass sent outside it', outside == 'Widened Compass')
check('the queue told: its Geo- recast not held back', allowed == 'Geo-Gravity')
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

-- auto Full Circle (geo_full_circle) and the ability queue
config.widened_compass_on, sent, outside, allowed = {}, {}, nil, nil
fc_on, pet = true, {isvalid = true}
local later
coroutine = {schedule = function(fn) later = fn end}
check('luopan out: Geo- cancelled for Full Circle', cast())
check('Full Circle sent', count('input /ja "Full Circle" <me>') == 1)
check('the queue told: Full Circle sent outside it', outside == 'Full Circle')
later()
check('the Geo- recast after it, not held back', allowed == 'Geo-Gravity' and count('input /ma "Geo-Gravity" 77') == 1)
windower._geo_full_circle_replay, sent = nil, {}
fc_queued = 'Full Circle'
check('a Full Circle waiting in the queue: Geo- cancelled', cast())
check('  no second Full Circle sent', count('input /ja "Full Circle" <me>') == 0)

print(fails == 0 and 'ALL OK' or (fails .. ' FAILED'))
os.exit(fails == 0 and 0 or 1)

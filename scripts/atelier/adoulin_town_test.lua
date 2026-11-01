---============================================================================
--- Test of the town set laid on the idle in Adoulin (base_set_builder.lua)
---============================================================================
--- In Adoulin, sets.Adoulin (Councilor's Garb: Movement speed +25% there) goes on
--- top of the town set (sets.idle.Town, the city's set since 2026-11-01), itself on
--- the idle set. Empty, as "+ Add a job" writes it (job_adder.lua: the sets without
--- their pieces), it once left the idle alone there: the town set alone is worn
--- then. In any other city the town set, out of town nothing.
---
--- Run from data/: lua5.1 scripts/atelier/adoulin_town_test.lua
---
--- @file scripts/atelier/adoulin_town_test.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-31
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

package.loaded['shared/utils/messages/message_formatter'] = {}
package.loaded['shared/utils/equipment/weapon_resolver'] = {}

function set_combine(...)
    local out = {}
    for _, s in ipairs({...}) do for k, v in pairs(s) do out[k] = v end end
    return out
end
-- GearSwap's areas.Cities (a list with :contains) and Lua strings' :contains (Windower's string library)
local cities = {['Bastok Markets'] = true, ['Western Adoulin'] = true, ['Eastern Adoulin'] = true}
areas = {Cities = {contains = function(_, z) return cities[z] == true end}}
string.contains = function(s, x) return s:find(x, 1, true) ~= nil end

local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')
local idle = {legs = 'Idle Legs', body = 'Idle Body'}
local town = {legs = 'Carmine Cuisses +1'}
local function lay(area)
    world = {area = area}
    local result, in_town = BaseSetBuilder.lay_town_set(idle, town)
    return result, in_town
end

sets = {Adoulin = {body = "Councilor's Garb"}}
local r, t = lay('Western Adoulin')
check('Adoulin with the Garb: laid', t, true)
check('  its body', r.body, "Councilor's Garb")
check('  over the town set (its legs)', r.legs, 'Carmine Cuisses +1')

sets = {Adoulin = {}}
r, t = lay('Eastern Adoulin')
check('Adoulin set empty: still a town set laid', t, true)
check('  the town set worn', r.legs, 'Carmine Cuisses +1')
check('  the idle body kept', r.body, 'Idle Body')

sets = {}
r, t = lay('Western Adoulin')
check('no Adoulin set: the town set', r.legs, 'Carmine Cuisses +1')

sets = {Adoulin = {body = "Councilor's Garb"}}
r, t = lay('Bastok Markets')
check('another city: the town set', r.legs, 'Carmine Cuisses +1')
check('  not the Adoulin set', r.body, 'Idle Body')

r, t = lay('La Theine Plateau')
check('out of town: nothing laid', t, false)
check('  the idle as it is', r.legs, 'Idle Legs')

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

---============================================================================
--- Test of the GEO escort (shared/jobs/geo/functions/GEO_COMMANDS.lua)
---============================================================================
--- //gs c escort Indi-Regen Tetsouo <profile>: Silmaril off, profile loaded,
--- Full Circle, the Indi- cast here, then follow: at the aftercast, or when
--- the Indi- effect lands if the end of the cast never arrives.
---
--- Run from data/: lua5.1 scripts/atelier/geo_escort_test.lua
---
--- @file scripts/atelier/geo_escort_test.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-17
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

-- Every module the command file loads is a table that accepts anything
local any = setmetatable({}, {__index = function() return function() return false end end})
local real_require = require
require = function(name)
    if name == 'shared/utils/core/job_config' then return {get = function(_, _, d) return d end} end
    local ok, mod = pcall(real_require, name)
    if ok and name:find('GEO_COMMANDS') then return mod end
    return any
end

local sent, queue = {}, {}
send_command = function(cmd) sent[#sent + 1] = cmd end
coroutine.schedule = function(fn, delay) queue[#queue + 1] = {fn = fn, delay = delay} end
local REGEN = {en = 'Indi-Regen', element = 6, cast_time = 3}
res = {spells = {with = function(_, _, name) return name == 'Indi-Regen' and REGEN or nil end}}
windower = {}
pet = {isvalid = true}
state = {}

dofile('shared/jobs/geo/functions/GEO_COMMANDS.lua')

local function escort()
    sent, queue = {}, {}
    job_self_command({'escort', 'Indi-Regen', 'Tetsouo', 'Kaories/Sortie/GEO/Escorte'}, {})
end
local function has(cmd)
    for _, c in ipairs(sent) do if c == cmd then return true end end
    return false
end
local function run_casts()
    for _, q in ipairs(queue) do if q.delay == 2 then q.fn() end end
end

-- 1. Silmaril off, profile loaded, Full Circle, then the Indi- cast here
escort()
check('silmaril off + load', sent[1], 'sm off; sm load Kaories/Sortie/GEO/Escorte; sm follow off')
check('full circle', sent[2], 'input /ja "Full Circle" <me>')
run_casts()
check('indi cast here', has('input /ma "Indi-Regen" <me>'), true)
check('no sm on', has('sm on'), false)

-- 2. aftercast: follow
geo_escort_on_aftercast({english = 'Indi-Regen'})
check('follow at aftercast', sent[#sent], 'sm follow Tetsouo')

-- 3. no aftercast, the effect lands: follow once
escort()
local n = #sent
indi_change({element_id = 6}, false)
check('old effect lost: no follow', #sent, n)
indi_change({element_id = 6}, true)
check('effect landed: follow', sent[#sent], 'sm follow Tetsouo')
geo_escort_on_aftercast({english = 'Indi-Regen'})
check('then no second follow', #sent, n + 1)

-- 4. another Indi- landing does not count
escort()
n = #sent
indi_change({element_id = 3}, true)
check('other element: no follow', #sent, n)

-- 5. nothing at all: the timer follows
for _, q in ipairs(queue) do if q.delay ~= 2 then q.fn() end end
check('timer follows', sent[#sent], 'sm follow Tetsouo')

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

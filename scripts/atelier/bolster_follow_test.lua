---============================================================================
--- Test of GEO Bolster Follow (shared/jobs/geo/functions/logic/bolster_follow.lua)
---============================================================================
--- Bolster gained with no luopan: Blaze of Glory. Bolster lost with a luopan
--- placed under Blaze of Glory: Ecliptic Attrition; placed without: Full Circle.
--- Off unless GEO_CONFIG says bolster_follow = true.
---
--- Run from data/: lua5.1 scripts/atelier/bolster_follow_test.lua
---
--- @file scripts/atelier/bolster_follow_test.lua
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

-- The game: buffs up, the luopan, ready abilities. A /ja sent goes through at once.
local game = {buffs = {}, luopan = false, ready = {}}
local option = true
local sent, queue = {}, {}
send_command = function(cmd)
    sent[#sent + 1] = cmd
    local ja = cmd:match('/ja "([^"]+)"')
    if ja == 'Blaze of Glory' then game.buffs['Blaze of Glory'] = true end
    if ja == 'Full Circle' then game.luopan = false end
    if ja then game.ready[ja] = false end
end
coroutine.schedule = function(fn) queue[#queue + 1] = fn end
local function run_coroutines()
    while #queue > 0 do table.remove(queue, 1)() end
end
windower = {ffxi = {get_mob_by_target = function()
    return game.luopan and {name = 'Luopan', hpp = 80} or nil
end}}
buffactive = setmetatable({}, {__index = function(_, k) return game.buffs[k] end})
package.loaded['shared/utils/precast/ability_helper'] = {
    is_ability_ready = function(name) return game.ready[name] ~= false end,
    is_buff_active = function(name) return game.buffs[name] == true end,
}
package.loaded['shared/utils/core/job_config'] = {get = function(job, key, default)
    if job == 'GEO' and key == 'bolster_follow' then return option end
    return default
end}
local BF = require('shared/jobs/geo/functions/logic/bolster_follow')

local function fresh()
    game = {buffs = {}, luopan = false, ready = {}}
    sent, queue = {}, {}
    windower._geo_luopan_bog, windower._geo_bolster_seq = nil, nil
end
local function cast_geo()
    BF.note_cast({skill = 'Geomancy', english = 'Geo-Frailty'})
    game.buffs['Blaze of Glory'] = nil
    game.luopan = true
end
local function bolster(gain)
    game.buffs['Bolster'] = gain or nil
    BF.on_buff_change('Bolster', gain)
    run_coroutines()
end

-- 1. Bolster with no luopan: BoG, the Geo- carries it, then Ecliptic Attrition once Bolster ends
fresh()
bolster(true)
check('BoG under Bolster', sent[1], 'input /ja "Blaze of Glory" <me>')
check('BoG sent once', #sent, 1)
cast_geo()
sent = {}
bolster(false)
check('EA after Bolster', sent[1], 'input /ja "Ecliptic Attrition" <me>')
check('EA sent once', #sent, 1)

-- 2. luopan already out when Bolster comes: no BoG; Full Circle once Bolster ends
fresh()
game.luopan = true
windower._geo_luopan_bog = false
bolster(true)
check('no BoG with a luopan out', #sent, 0)
bolster(false)
check('Full Circle after Bolster', sent[1], 'input /ja "Full Circle" <me>')
check('Full Circle sent once', #sent, 1)

-- 3. luopan gone before Bolster ends: nothing
fresh()
bolster(true)
cast_geo()
game.luopan = false
sent = {}
bolster(false)
check('no luopan at the end: nothing', #sent, 0)

-- 4. BoG not ready: nothing sent, no error
fresh()
game.ready['Blaze of Glory'] = false
bolster(true)
check('BoG on recast: nothing', #sent, 0)

-- 5. EA on recast at the end: nothing (no Full Circle of a BoG luopan)
fresh()
bolster(true)
cast_geo()
game.ready['Ecliptic Attrition'] = false
sent = {}
bolster(false)
check('EA on recast: nothing', #sent, 0)

-- 6. a refused BoG (bot casting) is sent again
fresh()
local refused = true
local real = send_command
send_command = function(cmd)
    if refused and cmd:find('Blaze of Glory') then refused = false; sent[#sent + 1] = cmd; return end
    real(cmd)
end
bolster(true)
check('BoG retried after a refusal', #sent, 2)
send_command = real

-- 7. option off: nothing at all
fresh()
option = false
bolster(true)
cast_geo()
bolster(false)
check('option off: nothing', #sent, 0)

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

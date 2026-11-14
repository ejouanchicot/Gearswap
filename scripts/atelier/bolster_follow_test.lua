---============================================================================
--- Test of GEO Bolster Follow (shared/jobs/geo/functions/logic/bolster_follow.lua)
---============================================================================
--- Bolster gained: a luopan out (placed before it, so not boosted) gets Full
--- Circle, then Blaze of Glory; no luopan: Blaze of Glory. Bolster lost with a
--- luopan placed under Blaze of Glory: Ecliptic Attrition; placed without: Full
--- Circle. The luopan remembers whether it went out under Bolster. Every ability
--- through the real ability queue (shared/utils/precast/ability_queue.lua).
--- The reactions are off unless GEO_CONFIG says bolster_follow = true.
---
--- Run from data/: lua5.1 scripts/atelier/bolster_follow_test.lua
---
--- @file scripts/atelier/bolster_follow_test.lua
--- @author ejouanchicot
--- @version 2.0 - through the ability queue, luopan placed under Bolster (2026-11-14)
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

-- a virtual clock
local now, jobs = 0, {}
os.clock = function() return now end
coroutine.schedule = function(fn, d) jobs[#jobs + 1] = {at = now + (d or 0), fn = fn} end
local function run()
    while #jobs > 0 do
        table.sort(jobs, function(a, b) return a.at < b.at end)
        local job = table.remove(jobs, 1)
        now = job.at
        job.fn()
    end
end

-- The game: buffs up, the luopan, ready abilities. A /ja goes through unless refused.
local game, option, sent, refuse
local Queue
send_command = function(cmd)
    sent[#sent + 1] = cmd
    local ja = cmd:match('/ja "([^"]+)"')
    if not ja then return end
    if refuse[ja] and refuse[ja] > 0 then refuse[ja] = refuse[ja] - 1 return end
    if ja == 'Blaze of Glory' then game.buffs['Blaze of Glory'] = true end
    if ja == 'Full Circle' then game.luopan = false end
    game.ready[ja] = false
    Queue.note_end({action_type = 'Ability'})
end
_G.midaction = function() return false end
windower = {ffxi = {get_mob_by_target = function()
    return game.luopan and {name = 'Luopan', hpp = 80} or nil
end}}
buffactive = setmetatable({}, {__index = function(_, k) return game.buffs[k] end})
package.loaded['shared/utils/debug/trace_log'] = {log = function() end}
local Helper = {
    is_ability_ready = function(name) return game.ready[name] ~= false end,
    is_buff_active = function(name) return game.buffs[name] == true end,
    queue = function() return Queue end,
}
package.loaded['shared/utils/precast/ability_helper'] = Helper
package.loaded['shared/utils/core/job_config'] = {get = function(job, key, default)
    if job == 'GEO' and key == 'bolster_follow' then return option end
    return default
end}
local BF = require('shared/jobs/geo/functions/logic/bolster_follow')

local function fresh()
    game = {buffs = {}, luopan = false, ready = {}}
    option, sent, refuse, jobs, now = true, {}, {}, {}, 0
    windower._geo_luopan_bog, windower._geo_luopan_bolster = nil, nil
    Queue = dofile('shared/utils/precast/ability_queue.lua')
end
local function cast_geo()
    BF.note_cast({skill = 'Geomancy', english = 'Geo-Frailty'})
    game.buffs['Blaze of Glory'] = nil
    game.luopan = true
end
local function bolster(gain)
    game.buffs['Bolster'] = gain or nil
    BF.on_buff_change('Bolster', gain)
    run()
end
local function count(ja)
    local n = 0
    for _, c in ipairs(sent) do if c == 'input /ja "' .. ja .. '" <me>' then n = n + 1 end end
    return n
end

-- 1. Bolster with no luopan: BoG, the Geo- carries both, then Ecliptic Attrition once Bolster ends
fresh()
bolster(true)
check('BoG under Bolster', sent[1], 'input /ja "Blaze of Glory" <me>')
check('BoG sent once', #sent, 1)
cast_geo()
check('luopan placed under Bolster: remembered', BF.placed_under_bolster(), true)
check('luopan placed with BoG: remembered', BF.placed_with_bog(), true)
sent = {}
bolster(false)
check('EA after Bolster', sent[1], 'input /ja "Ecliptic Attrition" <me>')
check('EA sent once', #sent, 1)
check('Bolster over: luopan no longer counted as boosted', BF.placed_under_bolster(), false)

-- 2. a luopan out placed before Bolster: Full Circle, then BoG (Bolster does not boost it)
fresh()
cast_geo()
check('luopan placed before Bolster', BF.placed_under_bolster(), false)
bolster(true)
check('Bolster on an old luopan: Full Circle first', sent[1], 'input /ja "Full Circle" <me>')
check('  then BoG', sent[2], 'input /ja "Blaze of Glory" <me>')
check('  nothing else', #sent, 2)

-- 3. the same with BoG on recast: Full Circle alone
fresh()
cast_geo()
game.ready['Blaze of Glory'] = false
bolster(true)
check('old luopan, BoG on recast: Full Circle', sent[1], 'input /ja "Full Circle" <me>')
check('  alone', #sent, 1)

-- 4. luopan gone before Bolster ends: nothing
fresh()
bolster(true)
cast_geo()
game.luopan = false
sent = {}
bolster(false)
check('no luopan at the end: nothing', #sent, 0)

-- 5. BoG not ready, no luopan: nothing sent, no error
fresh()
game.ready['Blaze of Glory'] = false
bolster(true)
check('BoG on recast: nothing', #sent, 0)

-- 6. EA on recast at the end: nothing (no Full Circle of a BoG luopan)
fresh()
bolster(true)
cast_geo()
game.ready['Ecliptic Attrition'] = false
sent = {}
bolster(false)
check('EA on recast: nothing', #sent, 0)

-- 7. a luopan without BoG when Bolster ends: Full Circle (the bot places it again)
fresh()
game.ready['Blaze of Glory'] = false
bolster(true)
cast_geo()
windower._geo_luopan_bog = false
sent = {}
bolster(false)
check('no BoG on the luopan at the end: Full Circle', sent[1], 'input /ja "Full Circle" <me>')

-- 8. a refused BoG (bot casting) is sent again
fresh()
refuse['Blaze of Glory'] = 1
bolster(true)
check('BoG retried after a refusal', count('Blaze of Glory'), 2)

-- 9. option off: nothing at all, the luopan still tracked
fresh()
option = false
bolster(true)
cast_geo()
check('option off: luopan still tracked', BF.placed_under_bolster(), true)
bolster(false)
check('option off: nothing', #sent, 0)
check('option off: Bolster over still counted', BF.placed_under_bolster(), false)

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

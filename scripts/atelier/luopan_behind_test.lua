---============================================================================
--- Test of shared/jobs/geo/functions/logic/luopan_behind.lua
--- Run from data/: lua5.1 scripts/atelier/luopan_behind_test.lua
--- @file scripts/atelier/luopan_behind_test.lua
--- @author ejouanchicot
--- @date Created: 2026-11-13
---============================================================================
-- The offset matches Silmaril's own (Geomancy_Actions.Luopan_Offset, "Back", copied below as written in C#), the
-- action packet of a Geo- on a monster gets it, nothing else is touched, and a Geo- is cancelled while a luopan is out.
package.path = './?.lua;' .. package.path

local config = {luopan_behind = 5}
package.loaded['shared/utils/core/job_config'] = {get = function(_, key, default)
    local v = config[key]
    if v == nil then return default end
    return v
end}
local pet_mob = nil
windower = {ffxi = {get_mob_by_target = function(t) return t == 'pet' and pet_mob or nil end},
    raw_register_event = function() return 1 end}

local LuopanBehind = dofile('shared/jobs/geo/functions/logic/luopan_behind.lua')

local fails = 0
local function check(name, ok, detail)
    if not ok then fails = fails + 1 end
    print((ok and 'ok   ' or 'FAIL ') .. name .. (detail and (': ' .. detail) or ''))
end
local function near(a, b) return math.abs(a - b) < 1e-9 end

-- Silmaril.ViewModel.Actions.Geomancy_Actions.Luopan_Offset, case "Back", line for line
local function silmaril_back(heading, offset)
    local num = heading
    num = (not (num < 0.0)) and (math.pi * 2.0 - num) or math.abs(num)
    num = num + math.pi
    return math.cos(num) * offset, math.sin(num) * offset
end
for _, h in ipairs({0, 0.7, math.pi / 2, math.pi, 2.9, -0.4, -math.pi / 2, -3.0}) do
    local x, y = LuopanBehind.offset(h, 5)
    local sx, sy = silmaril_back(h, 5)
    check(('offset same as Silmaril, heading %.2f'):format(h), near(x, sx) and near(y, sy),
        ('%.3f,%.3f vs %.3f,%.3f'):format(x, y, sx, sy))
    check(('offset is 5 yalms long, heading %.2f'):format(h), near(math.sqrt(x * x + y * y), 5))
end

-- packets as tables: parse copies, build hands the table back
local fake_packets = {
    parse = function(_, data) local t = {} for k, v in pairs(data) do t[k] = v end return t end,
    build = function(p) return p end,
}
local spells = {[811] = {en = 'Geo-Frailty'}, [800] = {en = 'Indi-Fury'}, [275] = {en = 'Absorb-TP'}}
local mobs = {[100] = {spawn_type = 16, heading = 0.7, name = 'Vampire Leech'}, [5] = {spawn_type = 13, heading = 1, name = 'Hysoka'}}
local deps = {packets = fake_packets, spells = spells, mob_by_index = function(i) return mobs[i] end}
local function packet(t)
    local p = {Category = 3, Param = 811, ['Target Index'] = 100, ['X Offset'] = 0, ['Y Offset'] = 0, ['Z Offset'] = 0}
    for k, v in pairs(t or {}) do p[k] = v end
    return p
end

local out = LuopanBehind.rewrite(packet(), 5, deps)
local sx, sy = silmaril_back(0.7, 5)
check('Geo- on a monster: offset written', out and near(out['X Offset'], sx) and near(out['Y Offset'], sy) and out['Z Offset'] == 0)
check('Geo- on a monster: target and spell kept', out and out['Target Index'] == 100 and out.Param == 811 and out.Category == 3)
check('not a spell (engage)', LuopanBehind.rewrite(packet({Category = 2}), 5, deps) == nil)
check('another spell (Absorb-TP)', LuopanBehind.rewrite(packet({Param = 275}), 5, deps) == nil)
check('an Indi-', LuopanBehind.rewrite(packet({Param = 800}), 5, deps) == nil)
check('a Geo- on a player', LuopanBehind.rewrite(packet({['Target Index'] = 5}), 5, deps) == nil)
check('target gone', LuopanBehind.rewrite(packet({['Target Index'] = 999}), 5, deps) == nil)
check('offset already set (Silmaril page)', LuopanBehind.rewrite(packet({['X Offset'] = 1.5}), 5, deps) == nil)

-- precast while a luopan is out
local function precast(name)
    local args = {}
    local cancelled = LuopanBehind.skip_while_out({english = name}, args)
    return cancelled, args.cancel == true
end
pet_mob = {name = 'Luopan', hpp = 80}
windower._stand_behind = {on = false}
check('behind off: luopan out, Geo- goes (the game decides)', not precast('Geo-Frailty'))
check('behind off: no rewrite wanted', not LuopanBehind.behind_on())
windower._stand_behind = nil
check('behind never started: not on', not LuopanBehind.behind_on())
windower._stand_behind = {on = true}
check('behind on: on', LuopanBehind.behind_on())
local c1, a1 = precast('Geo-Frailty')
check('luopan out: Geo- cancelled', c1 and a1)
local c2 = precast('Indi-Fury')
check('luopan out: Indi- goes', not c2)
pet_mob = {name = 'Luopan', hpp = 0}
check('dead luopan: Geo- goes', not precast('Geo-Frailty'))
pet_mob = nil
check('no luopan: Geo- goes', not precast('Geo-Frailty'))
pet_mob = {name = 'Luopan', hpp = 80}
config.luopan_behind = 0
check('setting off: nothing cancelled', not precast('Geo-Frailty'))
check('setting off: distance nil', LuopanBehind.distance() == nil)
config.luopan_behind = 5
check('setting on: distance 5', LuopanBehind.distance() == 5)

-- lead: a monster walking to its target gets the bubble ahead of it, half the way, at most `max` yalms
do
    local tank = {name = 'Tetsouo', spawn_type = 13, x = 90, y = 0}
    local function walker(t) local m = {name = 'Vampire Leech', spawn_type = 16, x = 100, y = 0, heading = -math.pi,
        target_index = 7} for k, v in pairs(t or {}) do m[k] = v end return m end
    local lmobs = {[7] = tank}
    local ldeps = {packets = fake_packets, spells = spells, mob_by_index = function(i) return lmobs[i] end}
    local function lead(m) lmobs[101] = m return LuopanBehind.rewrite_lead(packet({['Target Index'] = 101}), 6, ldeps) end

    local o = lead(walker())
    check('lead: 10 yalms from the tank, 5 ahead (half)', o and near(o['X Offset'], -5) and near(o['Y Offset'], 0) and o['Z Offset'] == 0)
    tank.x = 70
    o = lead(walker())
    check('lead: 30 yalms away, capped at 6', o and near(o['X Offset'], -6) and near(o['Y Offset'], 0))
    o = lead(walker({heading = -math.pi + math.rad(30)}))
    check('lead: facing 30 deg off, still walking to it', o ~= nil)
    check('lead: facing away, bubble on it', lead(walker({heading = 0})) == nil)
    tank.x = 97
    check('lead: on its target (3 yalms), bubble on it', lead(walker()) == nil)
    tank.x = 90
    check('lead: no target, bubble on it', lead(walker({target_index = 0})) == nil)
    ldeps.mob_by_id = function(id) return id == 1001 and tank or nil end
    o = lead(walker({target_index = 0, claim_id = 1001}))
    check('lead: no target given, the claimer instead', o and near(o['X Offset'], -5) and near(o['Y Offset'], 0))
    check('lead: no target, claimer unknown, bubble on it', lead(walker({target_index = 0, claim_id = 999})) == nil)
    -- the shifted point kept within 15 yalms of this character
    ldeps.me = function() return {x = 114, y = 0} end            -- 14 yalms behind the mob, on the far side
    o = lead(walker())                                           -- 5 ahead would be 19 from me: 1 ahead only
    check('lead: shortened to stay within reach', o and near(o['X Offset'], -1), o and o['X Offset'])
    ldeps.me = function() return {x = 116, y = 0} end            -- the mob itself 16 away: no lead
    check('lead: mob past the reach, bubble on it', lead(walker()) == nil)
    ldeps.me = function() return {x = 95, y = 5} end             -- beside the path: the full lead fits
    o = lead(walker())
    check('lead: in reach, full lead', o and near(o['X Offset'], -5))
    ldeps.me = nil
    check('lead: an Indi-, untouched', LuopanBehind.rewrite_lead(packet({Param = 800, ['Target Index'] = 101}), 6, ldeps) == nil)
    tank.x, tank.y = 100, 10            -- target straight "north": the offset follows the target, not the axis
    o = lead(walker({heading = -math.atan2(10, 0)}))
    check('lead: towards the target whatever the axis', o and near(o['X Offset'], 0) and near(o['Y Offset'], 5))
    config.luopan_lead = 0
    check('lead setting off: nil', LuopanBehind.lead_max() == nil)
    config.luopan_lead = 6
    check('lead setting on: 6', LuopanBehind.lead_max() == 6)
end

print(fails == 0 and 'ALL OK' or (fails .. ' FAILED'))
os.exit(fails == 0 and 0 or 1)

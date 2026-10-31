---============================================================================
--- Test of the sets each PLD stance wears (logic/set_builder.lua)
---============================================================================
--- Since 2026-10-31 the tank stances fight in their idle set (PDT: sets.idle.PDT;
--- MDT and Tanking: sets.idle.MDT; no sets.engaged.PDT / .MDT), DPS and Hoxne
--- in their engaged build; standing, DPS and Hoxne wear the idle set their
--- Idle Defense mode names (MDT by default, MDT too in a file without the mode).
--- Played with each set holding its own name in the body slot, outside town.
---
--- Run from data/: lua5.1 scripts/atelier/pld_stance_sets_test.lua
---
--- @file scripts/atelier/pld_stance_sets_test.lua
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
package.loaded['shared/utils/equipment/ampulla_lock'] = {stance_ammo = function(r) return r end}
-- the character's PLD_WEAPONS.lua: a shield for Burtgang, the stance's default for any other one-handed weapon
local WEAPONS = {shields = {PDT = {Burtgang = 'Duban', default = 'Duban'}, MDT = {Burtgang = 'Aegis', default = 'Aegis'},
    DPS = {Naegling = 'Duban', default = 'Duban'}}, grips = {Shining = 'Telopanos Grip'}}
package.loaded['shared/utils/core/char_paths'] = {optional = function() return WEAPONS end}
function set_combine(...)
    local out = {}
    for _, s in ipairs({...}) do for k, v in pairs(s) do out[k] = v end end
    return out
end
string.contains = function(s, x) return s:find(x, 1, true) ~= nil end
areas = {Cities = {contains = function() return false end}}
world = {area = 'La Theine Plateau'}

local SetBuilder = require('shared/jobs/pld/functions/logic/set_builder')
local function mode(v) return {value = v, current = v} end

sets = {idle = {PDT = {body = 'idle.PDT'}, MDT = {body = 'idle.MDT'}}, engaged = {DPS = {body = 'engaged.DPS'}, Hoxne = {body = 'engaged.Hoxne'}}}
local engaged_base, idle_base = {body = 'sets.engaged'}, {body = 'sets.idle'}

local function wear(stance, idle_defense)
    state = {HybridMode = mode(stance), MainWeapon = mode('Burtgang'), IdleDefense = idle_defense and mode(idle_defense) or nil}
    return SetBuilder.build_engaged_set(engaged_base).body, SetBuilder.build_idle_set(idle_base).body
end

local e, i = wear('PDT', 'MDT')
check('PDT fights in idle.PDT', e, 'idle.PDT')
check('PDT idles in idle.PDT', i, 'idle.PDT')
e, i = wear('MDT', 'PDT')
check('MDT fights in idle.MDT', e, 'idle.MDT')
check('MDT idles in idle.MDT (Idle Defense does not move it)', i, 'idle.MDT')
e, i = wear('Tanking', 'PDT')
check('Tanking fights in idle.MDT', e, 'idle.MDT')
check('Tanking idles in idle.MDT', i, 'idle.MDT')
e, i = wear('DPS', 'MDT')
check('DPS fights in engaged.DPS', e, 'engaged.DPS')
check('DPS, Idle Defense MDT: idles in idle.MDT', i, 'idle.MDT')
e, i = wear('DPS', 'PDT')
check('DPS, Idle Defense PDT: idles in idle.PDT', i, 'idle.PDT')
e, i = wear('Hoxne', 'PDT')
check('Hoxne fights in engaged.Hoxne', e, 'engaged.Hoxne')
check('Hoxne, Idle Defense PDT: idles in idle.PDT', i, 'idle.PDT')
e, i = wear('DPS', nil)
check('DPS in a file without Idle Defense: idles in idle.MDT', i, 'idle.MDT')
-- the shield: the weapon's own line, else the stance's default, but a grip and a weapon set's own off hand
sets.Malevo = {main = 'Malevolence'}
sets.Shining = {main = 'Shining One'}
sets.BurtgangKC = {main = 'Burtgang', sub = 'Kraken Club'}
local function shield(stance, weapon)
    state = {HybridMode = mode(stance), MainWeapon = mode(weapon)}
    return SetBuilder.build_idle_set(idle_base).sub
end
check('PDT + Burtgang: its own line (Duban)', shield('PDT', 'Burtgang'), 'Duban')
check('PDT + Malevolence: the stance default (Duban)', shield('PDT', 'Malevo'), 'Duban')
check('MDT + Malevolence: the stance default (Aegis)', shield('MDT', 'Malevo'), 'Aegis')
check('DPS + Malevolence: the stance default (Duban)', shield('DPS', 'Malevo'), 'Duban')
check('PDT + Shining One: its grip, no shield', shield('PDT', 'Shining'), 'Telopanos Grip')
check('PDT + BurtgangKC: its Kraken Club, no shield', shield('PDT', 'BurtgangKC'), 'Kraken Club')
-- Sortie Aminon (SORTIE_CONFIG.lua): Tanking, but StanceWeapon Naegling and Shield Aegis
WEAPONS.stance_weapon = {Tanking = 'Burtgang'}
WEAPONS.shields.Tanking = {Naegling = 'Duban', Burtgang = 'Aegis'}
sets.Burtgang, sets.Naegling = {main = 'Burtgang'}, {main = 'Naegling'}
state = {HybridMode = mode('Tanking'), MainWeapon = mode('Burtgang'), StanceWeapon = mode('Naegling'), Shield = mode('Aegis')}
local aminon = SetBuilder.build_engaged_set(engaged_base)
check('Aminon: Tanking holds Naegling (StanceWeapon)', aminon.main, 'Naegling')
check('Aminon: with Aegis (Shield), not the Tanking rule\'s Duban', aminon.sub, 'Aegis')
check('Aminon: fights in idle.MDT', aminon.body, 'idle.MDT')
state = {HybridMode = mode('Tanking'), MainWeapon = mode('Naegling'), StanceWeapon = mode('Auto'), Shield = mode('Auto')}
local tank = SetBuilder.build_engaged_set(engaged_base)
check('Tanking otherwise: Burtgang + Aegis', tank.main .. ' + ' .. tank.sub, 'Burtgang + Aegis')
-- Xp On (a Crawlers' Nest pull): sets.idleXp / sets.meleeXp hold their own weapons, Duban over the stance's shield
sets.idleXp = {main = 'Burtgang', sub = 'Duban', body = 'idleXp'}
sets.meleeXp = {main = 'Malevolence', sub = 'Duban', body = 'meleeXp'}
state = {HybridMode = mode('MDT'), MainWeapon = mode('Burtgang'), Xp = mode('On')}
local xi, xe = SetBuilder.build_idle_set(idle_base), SetBuilder.build_engaged_set(engaged_base)
check("Xp On idle: Burtgang + Duban, not MDT's Aegis", xi.main .. ' + ' .. xi.sub, 'Burtgang + Duban')
check('Xp On fighting: Malevolence + Duban', xe.main .. ' + ' .. xe.sub, 'Malevolence + Duban')
check('Xp On fighting: meleeXp laid over', xe.body, 'meleeXp')
state.Xp = mode('Off')
check("Xp Off: the stance's shield again (MDT: Aegis)", SetBuilder.build_idle_set(idle_base).sub, 'Aegis')
sets.idleXp, sets.meleeXp = nil, nil
-- an idle set missing: Mote's set stays
sets.idle.PDT = nil
e, i = wear('PDT', 'MDT')
check('PDT with no sets.idle.PDT: the engaged base', e, 'sets.engaged')

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

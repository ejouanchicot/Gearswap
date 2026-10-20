---============================================================================
--- Test of Combat Mode's weapon choice (shared/utils/core/combat_mode.lua)
---============================================================================
--- //gs c sortie melee locks Naegling + Blurred Shield; sortie aminon then sets
--- Shield Aegis with Combat Mode still On: the lock has to open for the new
--- shield, then close on it.
---
--- Run from data/: lua5.1 scripts/atelier/combat_mode_shield_test.lua
---
--- @file scripts/atelier/combat_mode_shield_test.lua
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

local mode_value = 'On'
package.loaded['shared/utils/core/optional_state'] = {create = function()
    return {value = function() return mode_value end}
end}
windower = {}
player = {main_job = 'PLD', equipment = {main = 'Naegling'}}
local function M(v) return {current = v, value = v} end
state = {MainWeapon = M('Naegling'), Shield = M('Blurred Shield +1'), StanceWeapon = M('Auto'), HybridMode = M('DPS')}
local disabled, enabled = 0, 0
disable = function() disabled = disabled + 1 end
enable = function() enabled = enabled + 1 end
equip = function() end
sets = {}

local CombatMode = require('shared/utils/core/combat_mode')

-- melee: the lock closes on Naegling + Blurred Shield
check('first lock', CombatMode.apply(), nil)
check('locked', windower._combat_mode_locked ~= nil, true)

-- nothing changed: the lock stays, no re-dress
check('same choice: kept', CombatMode.apply(), nil)
check('same choice: not opened', enabled, 0)

-- aminon: Shield Aegis, StanceWeapon Naegling, Combat Mode still On
state.Shield = M('Aegis')
state.StanceWeapon = M('Naegling')
state.HybridMode = M('Tanking')
local after = CombatMode.apply()
check('new shield: lock opened', enabled, 1)
check('new shield: lock waits for the gear', type(after), 'function')
after()
check('new shield: then locked again', CombatMode.apply(), nil)

-- a HybridMode change alone keeps the weapons held (Combat Mode is the weapon lock)
state.HybridMode = M('PDT')
check('mode only: kept', CombatMode.apply(), nil)
check('mode only: not opened', enabled, 1)

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

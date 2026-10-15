---============================================================================
--- Test of the owner's idle while a pet is out (BaseSetBuilder.idle_without_pet)
---============================================================================
--- Mote takes sets.idle.Pet as the base when a pet is out, then lays Kiting
--- or a defense set on it before DRG and PUP see it: the owner's idle must
--- come back with Kiting kept, and a base Mote did not take from a Pet node
--- is left alone.
---
--- Run from data/: lua5.1 scripts/atelier/idle_without_pet_test.lua
---
--- @file scripts/atelier/idle_without_pet_test.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-15
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
-- Mote-Include.lua, as it is
function apply_defense(base)
    if state.DefenseMode.current ~= 'None' then base = set_combine(base, sets.defense.PDT) end
    return base
end
function apply_kiting(base)
    if state.Kiting.value and sets.Kiting then base = set_combine(base, sets.Kiting) end
    return base
end

sets = {
    idle = {body = 'Owner Body', feet = 'Owner Feet', Pet = {body = 'Pet Body'}, PDT = {body = 'PDT Body'}},
    Kiting = {feet = 'Kiting Feet'},
    defense = {PDT = {head = 'PDT Head'}},
}
state = {IdleMode = {current = 'Normal'}, DefenseMode = {current = 'None'}, Kiting = {value = true}, Buff = {}}
pet = {isvalid = true}
buffactive = {}
world = {area = 'Ceizak Battlegrounds'}
areas = {Cities = {contains = function(_, area) return area == 'Bastok Markets' end}}

local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')

-- 1. pet out, Kiting on: Mote gave sets.idle.Pet + Kiting
local got = BaseSetBuilder.idle_without_pet(apply_kiting(sets.idle.Pet))
check('owner body under Kiting', got.body, 'Owner Body')
check('Kiting kept', got.feet, 'Kiting Feet')

-- 2. a defense mode too
state.DefenseMode.current = 'Physical'
got = BaseSetBuilder.idle_without_pet(apply_kiting(apply_defense(sets.idle.Pet)))
check('owner body under defense', got.body, 'Owner Body')
check('defense kept', got.head, 'PDT Head')
state.DefenseMode.current = 'None'

-- 3. no pet: what Mote built stays
pet.isvalid = false
local base = apply_kiting(sets.idle)
check('no pet: untouched', BaseSetBuilder.idle_without_pet(base), base)
pet.isvalid = true

-- 4. an IdleMode child without .Pet: Mote never took a Pet node
state.IdleMode.current = 'PDT'
base = apply_kiting(sets.idle.PDT)
check('idle mode without Pet: untouched', BaseSetBuilder.idle_without_pet(base), base)
state.IdleMode.current = 'Normal'

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

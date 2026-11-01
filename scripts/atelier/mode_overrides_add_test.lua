---============================================================================
--- Test of the values the Atelier adds to a mode (shared/utils/core/mode_overrides.lua, '+Mode')
---============================================================================
--- A weapon added in the Atelier ("+ Set", Weapons, Add a weapon) goes at the
--- end of its cycle, the value worn now kept; a value already there and a
--- mode the job lacks are handled; a start value still works beside it.
--- Mote's own modes (libs/Modes.lua), not an imitation.
---
--- Run from data/: lua5.1 scripts/atelier/mode_overrides_add_test.lua
---
--- @file scripts/atelier/mode_overrides_add_test.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-11-01
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

-- Mote's modes, as GearSwap loads them
dofile('../libs/Modes.lua')
local errors = {}
package.loaded['shared/utils/messages/message_formatter'] = {show_error = function(m) errors[#errors + 1] = m end}
local ModeOverrides = dofile('shared/utils/core/mode_overrides.lua')
local function list(m) local out = {} for _, v in ipairs(m) do out[#out + 1] = v end return table.concat(out, ',') end

-- 1. a weapon added at the end, the one worn now kept
state = {MainWeapon = M{['description'] = 'Main Weapon', 'Naegling', 'Colada', 'Maxentius'}, IdleMode = M{'Normal', 'DT'}}
state.MainWeapon:set('Colada')
ModeOverrides.read = function() return {RDM = {['+MainWeapon'] = {'Daybreak'}, IdleMode = 'DT'}} end
ModeOverrides.apply('RDM')
check('the cycle', list(state.MainWeapon), 'Naegling,Colada,Maxentius,Daybreak')
check('the weapon worn now kept', state.MainWeapon.current, 'Colada')
check('its description kept', state.MainWeapon.description, 'Main Weapon')
check('a start value beside it', state.IdleMode.current, 'DT')
state.MainWeapon:cycle(); state.MainWeapon:cycle()
check('cycled to the new weapon', state.MainWeapon.current, 'Daybreak')
check('nothing refused', #errors, 0)
check('told to the export', ModeOverrides.added_values().MainWeapon[1], 'Daybreak')

-- 2. a value already in the cycle: not twice; a mode the job lacks: named once
state = {MainWeapon = M{'Naegling', 'Daybreak'}}
errors = {}
ModeOverrides.read = function() return {RDM = {['+MainWeapon'] = {'Daybreak', 'Bunzi\'s Rod'}, ['+SubWeapon'] = {'Genmei'}}} end
ModeOverrides.apply('RDM')
check('no double', list(state.MainWeapon), 'Naegling,Daybreak,Bunzi\'s Rod')
check('the missing mode named', #errors == 1 and errors[1]:find('+SubWeapon', 1, true) ~= nil, true)

-- 3. common scope: a mode the job lacks is skipped silently
state = {MainWeapon = M{'Naegling'}}
errors = {}
ModeOverrides.read = function() return {common = {['+Shield'] = {'Aegis'}}} end
ModeOverrides.apply('RDM')
check('common, missing mode: silent', #errors, 0)

-- 4. once per load: a second apply on the same state adds nothing
state = {MainWeapon = M{'Naegling'}}
ModeOverrides.read = function() return {RDM = {['+MainWeapon'] = {'Daybreak'}}} end
ModeOverrides.apply('RDM'); ModeOverrides.apply('RDM')
check('applied once', list(state.MainWeapon), 'Naegling,Daybreak')

-- 5. a start value naming the weapon added: the values are added first, the start value then holds
state = {MainWeapon = M{'Naegling', 'Colada'}}
errors = {}
ModeOverrides.read = function() return {RDM = {MainWeapon = 'Daybreak', ['+MainWeapon'] = {'Daybreak'}}} end
ModeOverrides.apply('RDM')
check('start value on the weapon added', state.MainWeapon.current, 'Daybreak')
check('start value not refused', #errors, 0)

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

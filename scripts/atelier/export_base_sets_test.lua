---============================================================================
--- Test of the export's base sets (shared/utils/atelier/atelier_export_sets.lua)
---============================================================================
--- A new player's PLD file writes `sets.precast.FC = {}`, then
--- `sets.precast.FC['Flash'] = sets.precast.FC` and FC.CureSelf under it: a
--- table with no piece holding others read as a folder, and the page showed
--- neither the Fast Cast set nor its self Cure one (2026-10-31). Mote's fallback
--- sets (FC, WS, idle, engaged) are sets even empty.
---
--- Run from data/: lua5.1 scripts/atelier/export_base_sets_test.lua
---
--- @file scripts/atelier/export_base_sets_test.lua
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

package.loaded['shared/utils/core/char_paths'] = {file = function() return nil end}
package.loaded['resources'] = {spells = {}}
player = {main_job = 'PLD'}

local function paths(build)
    sets = {precast = {FC = {}, JA = {}, WS = {}}, midcast = {}, idle = {}, engaged = {}}
    build()
    package.loaded['shared/utils/atelier/atelier_export_sets'] = nil
    local out = {}
    for _, rec in ipairs(require('shared/utils/atelier/atelier_export_sets').collect()) do out[rec.path] = rec end
    return out
end

-- the new player's file: an empty Fast Cast set, its spells pointing at it, the self Cure one under it
local got = paths(function()
    sets.precast.FC = {}
    sets.precast.FC.CureSelf = {}
    sets.precast.FC['Flash'] = sets.precast.FC
    sets.precast.FC['Phalanx'] = sets.precast.FC
    sets.precast.JA.Provoke = {head = 'Loess Barbuta +1'}
    sets.midcast.Flash = {head = 'Loess Barbuta +1'}
end)
check('empty sets.precast.FC is a set', got['sets.precast.FC'] ~= nil, true)
check('its spells are its names', got['sets.precast.FC'] and #(got['sets.precast.FC'].aliases or {}), 2)
check('sets.precast.FC.CureSelf is a set', got['sets.precast.FC.CureSelf'] ~= nil, true)
-- Mote's groups that are not sets stay folders (holding sets of their own)
check('sets.precast.JA is no set', got['sets.precast.JA'], nil)
check('sets.midcast is no set', got['sets.midcast'], nil)

-- an empty idle holding its stances, and the engaged one
got = paths(function()
    sets.idle.PDT = {body = 'Sakpata\'s Plate'}
    sets.engaged.DPS = {}
end)
check('empty sets.idle with idle.PDT: both sets', (got['sets.idle'] ~= nil) and (got['sets.idle.PDT'] ~= nil), true)
check('empty sets.engaged with engaged.DPS: both sets', (got['sets.engaged'] ~= nil) and (got['sets.engaged.DPS'] ~= nil), true)

-- a filled Fast Cast set: as before, one set with its names
got = paths(function()
    sets.precast.FC = {head = 'Carmine Mask +1'}
    sets.precast.FC['Flash'] = sets.precast.FC
end)
check('filled sets.precast.FC: its piece', got['sets.precast.FC'] and got['sets.precast.FC'].pieces.head.name, 'Carmine Mask +1')

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

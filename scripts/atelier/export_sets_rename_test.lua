---============================================================================
--- Test of the export's set names (shared/utils/atelier/atelier_export_sets.lua)
---============================================================================
--- Tetsouo's BLM set file writes `sets.midcast['Comet'] = sets.midcast['Elemental
--- Magic']`: one table under two names. The export met it first as Comet and
--- renamed it Elemental Magic, but its Magic Burst set stayed
--- sets.midcast.Comet.MagicBurst, and the page showed no Elemental Magic Magic
--- Burst set. The sets under a renamed one must follow it.
---
--- Run from data/: lua5.1 scripts/atelier/export_sets_rename_test.lua
---
--- @file scripts/atelier/export_sets_rename_test.lua
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

-- the set file's copy lines, as file_copies reads them
local tmp = os.tmpname()
local f = io.open(tmp, 'w')
f:write("sets.midcast['Comet']            = sets.midcast['Elemental Magic']\n")
f:write("sets.midcast['Comet'].MagicBurst = sets.midcast['Elemental Magic'].MagicBurst\n")
f:close()
package.loaded['shared/utils/core/char_paths'] = {file = function() return tmp end}
package.loaded['resources'] = {spells = {{en = 'Comet'}, {en = 'Impact'}}}
player = {main_job = 'BLM'}

local nuke = {main = "Bunzi's Rod", head = 'Wicce Petasos +3'}
nuke.MagicBurst = {main = "Bunzi's Rod", head = 'Ea Hat +1'}
nuke.MagicBurst.acc = {main = "Bunzi's Rod", head = 'Wicce Petasos +3'}
sets = {midcast = {['Elemental Magic'] = nuke, Comet = nuke}}

local ExportSets = require('shared/utils/atelier/atelier_export_sets')
local by = {}
for _, rec in ipairs(ExportSets.collect()) do by[rec.path] = rec end

local function has_alias(path, alias)
    for _, a in ipairs((by[path] or {}).aliases or {}) do if a == alias then return true end end
    return false
end
check('nuke set under its own name', by['sets.midcast["Elemental Magic"]'] ~= nil, true)
check('Magic Burst set under the nuke set', by['sets.midcast["Elemental Magic"].MagicBurst'] ~= nil, true)
check('its accuracy version too', by['sets.midcast["Elemental Magic"].MagicBurst.acc'] ~= nil, true)
check('no Comet.MagicBurst set left', by['sets.midcast.Comet.MagicBurst'], nil)
check('Comet kept as an alias', has_alias('sets.midcast["Elemental Magic"]', 'sets.midcast.Comet'), true)
check('Comet.MagicBurst kept as an alias', has_alias('sets.midcast["Elemental Magic"].MagicBurst', 'sets.midcast.Comet.MagicBurst'), true)
check('Magic Burst head', ((by['sets.midcast["Elemental Magic"].MagicBurst'] or {}).pieces or {}).head and by['sets.midcast["Elemental Magic"].MagicBurst'].pieces.head.name, 'Ea Hat +1')

os.remove(tmp)
print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

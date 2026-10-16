---============================================================================
--- Our probe - what our GearSwap equips for a converted character
---============================================================================
--- Loads <Char>_<JOB>.lua offline with the Atelier's harness and plays the
--- spec's scenarios through probe.lua, to compare with what the foreign file
--- equipped (compare_probes.js).
---
--- The harness is the first part of scripts/atelier/load_job.lua, read at run
--- time and cut before its export: this script never writes the character's
--- exports or saved files. Run it on a scratch copy of data/ all the same.
---
---   lua5.1 our_probe.lua <Character> <JOB> <SUB> <spec.json> <out.json>
---
--- @file    scripts/convert/our_probe.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-16
---============================================================================

local PLAYER, MAIN, SUB, SPEC, OUT = arg[1], arg[2], arg[3], arg[4], arg[5]
local DATA = arg[0]:gsub('\\', '/'):match('^(.*)/scripts/convert/[^/]*$') or '.'
local SetDump = dofile(DATA .. '/scripts/convert/set_dump.lua')
local Probe = dofile(DATA .. '/scripts/convert/probe.lua')

local f = assert(io.open(DATA .. '/scripts/atelier/load_job.lua', 'rb'))
local text = f:read('*a')
f:close()
local cut = text:find("local AtelierExport = include_user('shared/utils/atelier/atelier_export')", 1, true)
assert(cut, 'load_job.lua changed: its export line was not found')
local chunk = assert(loadstring(text:sub(1, cut - 1) .. '\nreturn env, res\n', '=load_job (harness)'))

arg = {[0] = DATA .. '/scripts/atelier/load_job.lua', PLAYER, MAIN, SUB, 'C:/nowhere'}
local env, res = chunk()

local sf = assert(io.open(SPEC, 'rb'))
local spec = Probe.decode(sf:read('*a'))
sf:close()
local empty = env.empty
local results = Probe.run(env, spec, {res = res, slot_name = SetDump.SLOT_NAME,
    piece = function(item) return SetDump.piece(item, empty) end})
local out = assert(io.open(OUT, 'wb'))
out:write(SetDump.json(results))
out:close()
print(('%s %s: %d scenarios played'):format(PLAYER, MAIN, #spec))

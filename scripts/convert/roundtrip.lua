---============================================================================
--- Round trip - what a written sets file builds, to compare with the source
---============================================================================
--- Runs one of our sets files the way init_gear_sets() does (after Mote's
--- skeleton, with GearSwap's set_combine and `empty`) and writes its sets as
--- set_dump.lua does, so write_sets.js can be checked against what the
--- foreign file built: same pieces under each (renamed) path.
---
---   lua5.1 roundtrip.lua <job_sets.lua> <out.json> [<gear file> <JOB>]
---
--- With a gear file (write_gear.js: his 0_AugGear tables), the sets file's
--- include of it runs that file, for that main job.
---
--- @file    scripts/convert/roundtrip.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-16
---============================================================================

local FILE, OUT, GEAR, JOB = arg[1], arg[2], arg[3], arg[4]
local DATA = arg[0]:gsub('\\', '/'):match('^(.*)/scripts/convert/[^/]*$') or '.'
local SetDump = dofile(DATA .. '/scripts/convert/set_dump.lua')

local empty = {name = 'empty'}
local errors = {}
local env = {sets = SetDump.mote_skeleton(), empty = empty, pairs = pairs, ipairs = ipairs,
    set_combine = SetDump.set_combine(function(i) errors[#errors + 1] = 'nil argument ' .. i .. ' to set_combine' end)}
env.player = {main_job = JOB}
env.include = function(path)
    if not (GEAR and tostring(path):lower():match('0_auggear')) then error('include ' .. tostring(path)) end
    local g = assert(loadfile(GEAR))
    setfenv(g, env)
    return g()
end
local f, err = loadfile(FILE)
if not f then
    errors[#errors + 1] = err
else
    setfenv(f, env)
    local ok, e = pcall(f)
    if not ok then errors[#errors + 1] = tostring(e) end
end
local out = assert(io.open(OUT, 'wb'))
out:write(SetDump.json({sets = SetDump.walk(env.sets, empty), errors = errors}))
out:close()

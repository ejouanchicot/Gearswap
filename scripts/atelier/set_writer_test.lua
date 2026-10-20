---============================================================================
--- Test of the set writer on a set_combine closed on a line of its own
---============================================================================
--- shared/utils/atelier/set_writer.lua: a set written
---
---   sets.engaged.PDT =
---       set_combine(
---       EngagedBase,
---       { ... }
---   )
---
--- ends at its `)`, not at its table's `}`. A new set (".Solo") written after it once
--- landed between the two and broke the file (')' expected); deleting it left the `)`.
---
--- Run from data/: lua5.1 scripts/atelier/set_writer_test.lua
---
--- @file scripts/atelier/set_writer_test.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-21
---============================================================================

package.path = './?.lua;' .. package.path

local done, failed = 0, 0
local function check(what, ok, detail)
    done = done + 1
    if not ok then
        failed = failed + 1
        print(('FAILED %s%s'):format(what, detail and (': ' .. detail) or ''))
    end
end
local function compiles(text)
    local f, err = loadstring(text)
    return f ~= nil, err
end

local SetWriter = require('shared/utils/atelier/set_writer')

local FILE = table.concat({
    "local EngagedBase = {}",
    "sets.engaged = {}",
    "",
    "-- PDT Engaged",
    "sets.engaged.PDT =",
    "    set_combine(",
    "    EngagedBase,",
    "    {",
    "        ammo = 'Coiste Bodhar',",
    "        head = 'Hjarrandi Helm',",
    "    }",
    ")",
    "",
    "sets.engaged.MDT = set_combine(sets.engaged.PDT, {",
    "    head = 'Nyame Helm',",
    "})",
    "",
}, '\n')

local defs = SetWriter.definitions(FILE)
check('the three sets found', #defs == 3, tostring(#defs))
local pdt = SetWriter.find(FILE, 'sets.engaged.PDT')
check('PDT found', pdt ~= nil)
check('PDT ends at its parenthesis', pdt and pdt.stop and FILE:sub(pdt.stop, pdt.stop) == ')')
check('PDT block holds the parenthesis', pdt and SetWriter.block(FILE, pdt):match('%)$') ~= nil)

-- a version created right after it (SetWriter.create, the page's ".Solo")
local out = SetWriter.create(FILE, pdt, 'Solo', {head = "'Sulevia Mask'"})
local ok, err = compiles(out)
check('create after a multi-line set_combine compiles', ok, err)
check('the new set comes after the )', out:find('%)\nsets%.engaged%.PDT%.Solo') ~= nil, out)

-- the same through create_at (set_push.lua create_new) and create_plain
out = SetWriter.create_at(FILE, pdt, 'sets.engaged.PDT.Solo', 'sets.engaged.PDT', {'engaged', 'PDT', 'Solo'}, {head = "'X'"})
ok, err = compiles(out)
check('create_at compiles', ok, err)
out = SetWriter.create_plain(FILE, pdt, 'sets.engaged.PDT.Solo', {'engaged', 'PDT', 'Solo'}, {head = "'X'"})
ok, err = compiles(out)
check('create_plain compiles', ok, err)

-- deleting it takes its parenthesis with it
out = SetWriter.remove(FILE, {pdt})
ok, err = compiles(out)
check('remove compiles', ok, err)
check('remove leaves no lone )', not out:find('\n%)\n'), out)

-- a set on one line keeps ending at its own brace and parenthesis
local mdt = SetWriter.find(FILE, 'sets.engaged.MDT')
check('MDT ends at its parenthesis', mdt and mdt.stop and FILE:sub(mdt.stop, mdt.stop) == ')')
out = SetWriter.create(FILE, mdt, 'Solo', {head = "'X'"})
ok, err = compiles(out)
check('create after a one-line set_combine compiles', ok, err)

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

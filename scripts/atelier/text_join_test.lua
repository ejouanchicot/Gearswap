---============================================================================
--- Test of shared/utils/core/text_join.lua, and of the export's JSON built with it
--- Run from data/: lua5.1 scripts/atelier/text_join_test.lua
--- @file scripts/atelier/text_join_test.lua
--- @author ejouanchicot
--- @date Created: 2026-11-13
---============================================================================
-- 1. join() gives exactly what Lua's table.concat gives, edge cases included.
-- 2. With Windower's table.concat in place (libs/tables.lua, the one the game has), the export's json() on a catalog
--    the size of Kaories RDM/WHM's (1 102 entries, ~300 KB) stays a few MB: it took 315 MB in game before join().
package.path = './?.lua;' .. package.path
local join = dofile('shared/utils/core/text_join.lua').join

local fails = 0
local function check(name, ok, detail)
    if not ok then fails = fails + 1 end
    print((ok and 'ok   ' or 'FAIL ') .. name .. (detail and (': ' .. detail) or ''))
end

local native = table.concat
local cases = {
    {name = 'empty', parts = {}, sep = ','},
    {name = 'one', parts = {'a'}, sep = ','},
    {name = 'two', parts = {'a', 'b'}, sep = ','},
    {name = 'odd count', parts = {'a', 'b', 'c', 'd', 'e'}, sep = ', '},
    {name = 'empty pieces', parts = {'', 'x', '', ''}, sep = ','},
    {name = 'no separator', parts = {'ab', 'cd', 'ef'}},
    {name = 'numbers', parts = {1, 2.5, 'x'}, sep = '|'},
}
for _, c in ipairs(cases) do
    local want, got = native(c.parts, c.sep), join(c.parts, c.sep)
    check('same as table.concat: ' .. c.name, want == got, ('%q vs %q'):format(want, got))
end
local many = {}
for i = 1, 1000 do many[i] = tostring(i) end
check('same as table.concat: 1000 pieces', native(many, ',') == join(many, ','))

-- the export's json(), taken from the file, on a catalog like RDM/WHM's
local src = assert(io.open('shared/utils/atelier/atelier_export.lua')):read('*a')
local fns = assert(src:match('(local function sorted_keys%(value%).-\nend)\n')) .. '\n'
    .. assert(src:match('(local function json%(value%).-\nend)\n'))
local catalog = {}
for i = 1, 1102 do
    catalog[i] = {path = 'sets.midcast.Enfeebling.Set' .. i, group = 'midcast.{Spell}', from = 'job', parent = true,
        base = 'sets.midcast', when = 'Casting that spell, its own set when it has one (' .. i .. ')',
        fr = 'Quand tu lances ce sort, son propre set s\226\128\153il en a un (' .. i .. ').'}
end

local lib = io.open('../../libs/tables.lua')
local windower_concat = lib and lib:read('*a'):match('(function table%.concat%(t, delim, from, to%).-\nend)\n')
if lib then lib:close() end
check("Windower's table.concat found (addons/libs/tables.lua)", windower_concat ~= nil)
if windower_concat then
    table.it = function(t) local k = nil return function() local v; k, v = next(t, k); return v, k end end
    assert(loadstring(windower_concat))()
end

local env = setmetatable({join = join}, {__index = _G})
local chunk = assert(loadstring(fns .. '\nreturn json'))
setfenv(chunk, env)
local json = chunk()
collectgarbage('collect'); collectgarbage('stop')
local kb0, t0 = collectgarbage('count'), os.clock()
local text = json(catalog)
local grown, ms = collectgarbage('count') - kb0, (os.clock() - t0) * 1000
collectgarbage('restart')
table.concat = native
check(('json of a %d KB catalog stays under 20 MB with Windower\'s table.concat'):format(#text / 1024),
    grown < 20 * 1024, ('%d KB, %d ms'):format(grown, ms))
check('json output still valid at both ends', text:sub(1, 2) == '[{' and text:sub(-2) == '}]')

print(fails == 0 and 'ALL OK' or (fails .. ' FAILED'))
os.exit(fails == 0 and 0 or 1)

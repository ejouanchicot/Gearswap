---============================================================================
--- Test of the old-load watch (shared/utils/debug/env_watch.lua)
---============================================================================
--- Tables standing for the sandboxes of three loads: one kept by a function
--- stored on windower, one kept by nothing, and the live one. The watch must
--- say which is still in memory.
---
--- Run from data/: lua5.1 scripts/atelier/env_watch_test.lua
---
--- @file scripts/atelier/env_watch_test.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-12
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

windower = {_load_gen = 0}
local Watch = require('shared/utils/debug/env_watch')

--- One older load: a table noted the way mark() notes the live sandbox.
local function old_load(gen, keep)
    local env = {name = 'sandbox ' .. gen}
    windower._env_watch = rawget(windower, '_env_watch') or setmetatable({}, {__mode = 'k'})
    windower._env_watch[env] = gen
    if keep then keep(env) end
end

old_load(1, function(env) windower.kept = {handler = function() return env end} end)
old_load(2)
old_load(3, function(env) windower.list = {{}, {deep = {env = env}}} end)
windower._load_gen = 4
Watch.mark()

local alive = Watch.survivors()
check('two older loads are still in memory', #alive, 2)
check('the first', alive[1], 1)
check('and the third (the second was freed)', alive[2], 3)

-- the functions kept on windower are named, with where they were written; a function buried deeper than the
-- look goes is not reached, and a large table is left closed
windower.deep = {a = {b = {c = {d = {e = function() end}}}}}
windower.big = {}
for i = 1, 5000 do windower.big[i] = {} end
windower.big[5000].fn = function() end
local stored = Watch.stored_functions()
check('one function found', #stored, 1)
check('by its path', stored[1].path, 'windower.kept.handler')
check('with where it was written', stored[1].where:match('^env_watch_test%.lua:%d+$') ~= nil, true)
windower.deep, windower.big = nil, nil

-- once nothing keeps them, they are gone
windower.kept, windower.list = nil, nil
check('freed once nothing holds them', #Watch.survivors(), 0)

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

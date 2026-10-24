---============================================================================
--- Test of the journals' rotation and the dated files' pruning (shared/utils/core/log_keeper.lua)
--- Run from data/: lua5.1 scripts/atelier/log_keeper_test.lua
--- @file scripts/atelier/log_keeper_test.lua
--- @author ejouanchicot
--- @date Created: 2026-10-24
---============================================================================
-- Offline check of shared/utils/core/log_keeper.lua in a temporary Windower folder. Run from GearSwap/data with lua5.1.
package.path = './?.lua;' .. package.path
local root = (os.getenv('TEMP') .. '/log_keeper_test_' .. os.time() .. '/'):gsub('\\', '/')
local function win(p) return (p:gsub('/', '\\')) end
local function mkdir(p) os.execute('mkdir "' .. win(p) .. '" 2>nul') end
local function write(p, n) local f = assert(io.open(p, 'wb')); f:write(string.rep('x', n)); f:close() end
local function exists(p) local f = io.open(p, 'rb'); if f then f:close() return true end return false end
windower = {addon_path = root, get_dir = function(dir)
    local out, p = {}, io.popen('dir /b "' .. win(dir) .. '" 2>nul')
    for l in p:lines() do out[#out + 1] = l end
    p:close(); return out end}

local done, failed = 0, 0
local function check(what, got, want)
    done = done + 1
    if got ~= want then failed = failed + 1; print(('FAILED %s: got %s, wanted %s'):format(what, tostring(got), tostring(want))) end
end
local LK = require('shared/utils/core/log_keeper')
local logs = root .. 'data/Tetsouo/logs/'
for _, d in ipairs({'craft', 'fights', 'enhtest', 'sortie', 'rolls'}) do mkdir(logs .. d) end

-- rotation
write(logs .. 'craft/synth.log', 3 * 1024 * 1024)
write(logs .. 'craft/synth.old.log', 10)
write(logs .. 'rolls/random_deal.log', 1000)
check('3 MB journal moved', LK.rotate(logs .. 'craft/synth.log'), true)
check('  gone from its name', exists(logs .. 'craft/synth.log'), false)
local f = io.open(logs .. 'craft/synth.old.log', 'rb'); local size = f:seek('end'); f:close()
check('  the old copy is it (the older one replaced)', size, 3 * 1024 * 1024)
check('small journal kept', LK.rotate(logs .. 'rolls/random_deal.log'), false)
check('missing journal: nothing', LK.rotate(logs .. 'craft/none.log'), false)

-- pruning, counted from 2026-10-24
local now = os.time({year = 2026, month = 10, day = 24, hour = 12})
write(logs .. 'fights/2026-08-01_hits.log', 10)     -- 84 days: deleted
write(logs .. 'fights/2026-08-25_hits.log', 10)     -- 60 days: kept
write(logs .. 'fights/2026-10-13_hits.log', 10)     -- kept
write(logs .. 'enhtest/2026-07-14.log', 10)         -- deleted
write(logs .. 'sortie/2026-06-02_2110.log', 10)     -- deleted
write(logs .. 'sortie/2026-10-22_2037.log', 10)     -- kept
write(logs .. 'sortie/notes.txt', 10)               -- no date: kept
write(logs .. 'rolls/2020-01-01_old.log', 10)       -- not a dated folder: kept
check('files deleted', LK.prune('Tetsouo', now), 3)
for name, want in pairs({['fights/2026-08-01_hits.log'] = false, ['fights/2026-08-25_hits.log'] = true, ['fights/2026-10-13_hits.log'] = true,
    ['enhtest/2026-07-14.log'] = false, ['sortie/2026-06-02_2110.log'] = false, ['sortie/2026-10-22_2037.log'] = true,
    ['sortie/notes.txt'] = true, ['rolls/2020-01-01_old.log'] = true}) do
    check('  ' .. name, exists(logs .. name), want)
end
check('no character: nothing', LK.prune(nil, now), 0)
-- which topics CharPaths.log rotates: never the trace nor a day's or a run's file (a boss's raw lines kept whole)
for topic, want in pairs({craft = true, rolls = true, dualbox = true, trace = false, fights = false, enhtest = false, sortie = false}) do
    check('rotates ' .. topic, LK.rotates(topic), want)
end
check('prune_once twice: the second does nothing', (function() LK.prune_once('Tetsouo'); return windower._logs_pruned.Tetsouo end)(), true)

os.execute('rmdir /s /q "' .. win(root) .. '" 2>nul')
print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

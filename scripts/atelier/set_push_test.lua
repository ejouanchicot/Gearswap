---============================================================================
--- Test of a push of two copies of one ring (shared/utils/atelier/set_push.lua)
---============================================================================
--- A set file naming the copies of a ring apart by their bag (the PLD template:
--- ChirichRing1 = wardrobe 1, ChirichRing2 = wardrobe 2) and the page pushing that
--- ring in both slots: each slot gets a name of its own. Both slots once got
--- ChirichRing1, the game was asked twice for the copy of wardrobe 1 and equipped
--- one ring (2026-10-31). Played on the PLD template emptied as "+ Add a job"
--- makes it (job_adder.lua), the job not loaded and loaded.
---
--- Run from data/: lua5.1 scripts/atelier/set_push_test.lua
---
--- @file scripts/atelier/set_push_test.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-31
---============================================================================

package.path = './?.lua;' .. package.path

local done, failed = 0, 0
local function check(what, got, want)
    done = done + 1
    if got ~= want then failed = failed + 1; print(('FAILED %s: got %s, wanted %s'):format(what, tostring(got), tostring(want))) end
end
local function read(p) local f = io.open(p, 'rb'); if not f then return nil end local t = f:read('*a'); f:close(); return t end
local function win(p) return (p:gsub('/', '\\')) end
local function list(dir)
    local out, p = {}, io.popen('dir /b "' .. win(dir) .. '" 2>nul')
    for l in p:lines() do out[#out + 1] = l end
    p:close(); return out
end

local root = (os.getenv('TEMP') .. '/set_push_test_' .. os.time() .. '/'):gsub('\\', '/')
local sets_dir = root .. 'data/Newbie/pld/sets/'
os.execute('mkdir "' .. win(sets_dir) .. '" 2>nul')
os.execute('mkdir "' .. win(root .. 'data/Newbie/_common') .. '" 2>nul')
windower = {addon_path = root, get_dir = list, dir_exists = function(d) return #list(d) > 0 or os.rename(d, d) ~= nil end,
    create_dir = function(d) os.execute('mkdir "' .. win(d) .. '" 2>nul') end,
    ffxi = {get_player = function() return {name = 'Newbie'} end}}
player = {name = 'Newbie', main_job = 'WAR'}

local JobAdder = require('shared/utils/atelier/job_adder')
local f = io.open(sets_dir .. 'pld_sets.lua', 'wb')
f:write(JobAdder.empty_sets(read('_master/sets/pld_sets.lua'))); f:close()
local SetPush = require('shared/utils/atelier/set_push')

-- the line the set's ring1 / ring2 is written with in the preview
local function rings(r)
    local after = r.after or ''
    return (after:match('ring1%s*=%s*([^,}\n]+)') or 'none'):gsub('%s+$', ''),
        (after:match('ring2%s*=%s*([^,}\n]+)') or 'none'):gsub('%s+$', '')
end

for _, loaded in ipairs({false, true}) do
    player.main_job = loaded and 'PLD' or 'WAR'
    if loaded then sets = {idle = {}, engaged = {}} end
    local tag = loaded and 'job loaded: ' or 'job not loaded: '
    local r = SetPush.preview('PLD', 'sets.idle\nring1\tone\tChirich Ring +1\nring2\tone\tChirich Ring +1')
    check(tag .. 'preview made', r.ok, true)
    if not r.ok then print('  error ' .. tostring(r.error)) end
    local a, b = rings(r)
    check(tag .. 'ring1 the copy of wardrobe 1', a, 'ChirichRing1')
    check(tag .. 'ring2 the copy of wardrobe 2', b, 'ChirichRing2')
    local r2 = SetPush.preview('PLD', 'sets.idle\nring1\tone\tStikini Ring +1\nring2\tone\tChirich Ring +1')
    local c, d = rings(r2)
    check(tag .. 'two rings: Stikini kept', c, 'StikiRing1')
    check(tag .. 'two rings: Chirich kept', d, 'ChirichRing1')
    -- a ring the file names once: both slots by its name (GearSwap finds the two copies itself)
    local r3 = SetPush.preview('PLD', "sets.idle\nring1\tone\tShneddick Ring +1\nring2\tone\tShneddick Ring +1")
    local e, g = rings(r3)
    check(tag .. 'a ring named once: ring1 by its name', e, "'Shneddick Ring +1'")
    check(tag .. 'a ring named once: ring2 by its name', g, "'Shneddick Ring +1'")
end

-- one slot of the pair pushed, the other already holding a copy of that ring (2026-11-07, WAR NaeglingKC.Group:
-- ring2 alone pushed, written Acc.MoonlightRing1 next to the set's ring1 = Acc.MoonlightRing1; 16 such sets)
local template = JobAdder.empty_sets(read('_master/sets/pld_sets.lua'))
local function with_idle(body)
    local t = template:gsub('\nsets%.idle = {}\n', '\nsets.idle = ' .. body .. '\n', 1)
    local w = io.open(sets_dir .. 'pld_sets.lua', 'wb'); w:write(t); w:close()
end
for _, loaded in ipairs({false, true}) do
    player.main_job = loaded and 'PLD' or 'WAR'
    sets = loaded and {idle = {}, engaged = {}} or nil
    local tag = loaded and 'job loaded: ' or 'job not loaded: '
    with_idle('{ring1 = ChirichRing1}')
    local _, b = rings(SetPush.preview('PLD', 'sets.idle\nring2\tone\tChirich Ring +1'))
    check(tag .. 'ring2 alone next to ring1 = ChirichRing1: the other copy', b, 'ChirichRing2')
    with_idle('{ring1 = ChirichRing2}')
    _, b = rings(SetPush.preview('PLD', 'sets.idle\nring2\tone\tChirich Ring +1'))
    check(tag .. 'ring2 alone next to ring1 = ChirichRing2: the other copy', b, 'ChirichRing1')
    with_idle('{ring2 = ChirichRing1}')
    local a = rings(SetPush.preview('PLD', 'sets.idle\nring1\tone\tChirich Ring +1'))
    check(tag .. 'ring1 alone next to ring2 = ChirichRing1: the other copy', a, 'ChirichRing2')
    with_idle('{ring1 = StikiRing1}')
    _, b = rings(SetPush.preview('PLD', 'sets.idle\nring2\tone\tChirich Ring +1'))
    check(tag .. 'ring2 alone next to another ring: unchanged', b, 'ChirichRing1')
end
-- the job loaded, ring1 not written in the set's own table (it comes from its base): read from the set in memory
player.main_job = 'PLD'
with_idle('{}')
sets = {idle = {left_ring = {name = 'Chirich Ring +1', bag = 'wardrobe 1'}}, engaged = {}}
local _, b = rings(SetPush.preview('PLD', 'sets.idle\nring2\tone\tChirich Ring +1'))
check('job loaded: ring1 inherited (wardrobe 1), ring2 alone: the other copy', b, 'ChirichRing2')

os.execute('rmdir /s /q "' .. win(root) .. '" 2>nul')
print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

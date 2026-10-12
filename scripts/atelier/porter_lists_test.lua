---============================================================================
--- Test of the job's pieces written to PorterPacker's lists (porter_lists.lua)
---============================================================================
--- A piece of the job's lockstyle counts among the job's pieces: it goes to
--- the unpack list (out on this job) and, when the pack list does not name it,
--- to the pack list (stored when another job is played). Played on a list file
--- written to a temporary folder; nothing of the real addon is touched.
---
--- Run from data/: lua5.1 scripts/atelier/porter_lists_test.lua
---
--- @file scripts/atelier/porter_lists_test.lua
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

-- a temporary Windower folder holding addons/PorterPacker/data/Test/Active/PLD.lua
local root = (os.getenv('TEMP') or '.'):gsub('\\', '/') .. '/porter_lists_test/'
local dir = root .. 'addons/PorterPacker/data/Test/Active'
os.execute('mkdir "' .. dir:gsub('/', '\\') .. '" 2>nul')
local path = dir .. '/PLD.lua'
local function put(text) local f = assert(io.open(path, 'w')) f:write(text) f:close() end
local function list() return dofile(path) end
local function has(t, name) for _, n in ipairs(t) do if n == name then return true end end return false end

-- the game: four storable pieces (ids 1-4) and one a slip cannot hold (5)
local ITEMS = {[1] = {en = 'Set Body'}, [2] = {en = 'Old Hat'}, [3] = {en = 'Style Mask'}, [4] = {en = 'Shared Ring'},
    [5] = {en = 'Loose Cape'}}
package.loaded['resources'] = {items = ITEMS, slips = {{items = {1, 2, 3, 4, 0}}}}
local lock = {}
package.loaded['shared/utils/lockstyle/lockstyle_pieces'] = {of_job = function() return lock end}
package.loaded['shared/utils/core/char_paths'] = {optional = function() return nil end}
package.loaded['shared/utils/messages/message_formatter'] = {show_info = function() end, show_error = function() end}
windower = {windower_path = root, dir_exists = function() return true end, create_dir = function() end}
player = {name = 'Test', main_job = 'PLD'}
sets = {idle = {body = 'Set Body', back = 'Loose Cape'}}

local PorterLists = require('shared/utils/atelier/porter_lists')
local SPLIT = 'return {\n    pack = {\n        -- the catalog\n        "Set Body",\n        "Old Hat",\n        "Shared Ring",\n    },\n'
    .. '    unpack = {\n        "Set Body",\n    },\n}\n'

-- 1. nothing of the lockstyle: the list is as it should be
put(SPLIT)
local cmp = PorterLists.compare('PLD')
check('the set piece is wanted, nothing to add', #cmp.add, 0)
check('nothing to add to the pack list', #cmp.pack_add, 0)

-- 2. the job's lockstyle wears a mask no list names, a ring the catalog names, and a cape no slip holds
lock = {[3] = true, [4] = true, [5] = true}
cmp = PorterLists.compare('PLD')
check('the mask and the ring are to take out on this job', table.concat(cmp.add, ', '), 'Shared Ring, Style Mask')
check('only the mask is unknown to the pack list', table.concat(cmp.pack_add, ', '), 'Style Mask')
PorterLists.sync('PLD')
local t = list()
check('unpack: the set piece stays', has(t.unpack, 'Set Body'), true)
check('unpack: the mask is added', has(t.unpack, 'Style Mask'), true)
check('unpack: the ring is added', has(t.unpack, 'Shared Ring'), true)
check('unpack: what no slip holds is not', has(t.unpack, 'Loose Cape'), false)
check('pack: the mask is added (stored on the other jobs)', has(t.pack, 'Style Mask'), true)
check('pack: the catalog is kept whole', has(t.pack, 'Old Hat') and has(t.pack, 'Set Body') and has(t.pack, 'Shared Ring'), true)
check('pack: one more name, no more', #t.pack, 4)
local text = io.open(path):read('*a')
check('the comment of the pack list is kept', text:find('-- the catalog', 1, true) ~= nil, true)

-- 3. done once: a second pass changes nothing
cmp = PorterLists.compare('PLD')
check('second pass: nothing to add', #cmp.add + #cmp.pack_add, 0)
PorterLists.sync('PLD')
check('second pass: the file is the same', io.open(path):read('*a'), text)

-- 4. the lockstyle no longer wears the mask: the page's button takes it out of unpack, the pack list keeps it
lock = {}
cmp = PorterLists.compare('PLD')
check('no longer worn: offered for removal', table.concat(cmp.remove, ', '), 'Shared Ring, Style Mask')
PorterLists.write('PLD')
t = list()
check('unpack: back to the set piece alone', #t.unpack, 1)
check('pack: still names it', has(t.pack, 'Style Mask'), true)

os.remove(path) os.remove(path .. '.bak')
print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

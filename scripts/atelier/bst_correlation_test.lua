---============================================================================
--- Test of the BST monster correlation in the chat (logic/ecosystem_manager.lua)
---============================================================================
--- The template's BST_ECOSYSTEM_DATA.lua and BST_PET_DATA.lua, read as the entry
--- reads them: an ecosystem's correlation, a pet found by the name the game
--- gives it (no spaces), the line said when a pet comes out (job_pet_change).
---
--- Run from data/: lua5.1 scripts/atelier/bst_correlation_test.lua
---
--- @file scripts/atelier/bst_correlation_test.lua
--- @author ejouanchicot
--- @date Created: 2026-10-28
---============================================================================
package.path = './?.lua;' .. package.path
local done, failed = 0, 0
local function check(what, got, want)
    done = done + 1
    if got ~= want then failed = failed + 1; print(('FAILED %s: got %s, wanted %s'):format(what, tostring(got), tostring(want))) end
end
local said = {}
package.loaded['shared/utils/messages/message_formatter'] = setmetatable({
    show_bst_correlation = function(eco, strong, weak, pet) said[#said + 1] = {eco, strong, weak, pet} end,
}, {__index = function() return function() end end})
package.loaded.resources = {items = {}}
_G.BSTEcosystemData = dofile('_master/config/bst/BST_ECOSYSTEM_DATA.lua')
_G.BSTBeastPetData = dofile('_master/config/bst/BST_PET_DATA.lua')
local Eco = require('shared/jobs/bst/functions/logic/ecosystem_manager')

local s, w = Eco.correlation('Beast')
check('Beast strong', s, 'Lizard'); check('Beast weak', w, 'Plantoid')
s, w = Eco.correlation('Amorph')
check('Amorph strong', s, 'Bird'); check('Amorph weak', w, 'Aquan')
check('no correlation (Luminian)', Eco.correlation('Luminian'), nil)

local eco, shown = Eco.ecosystem_of('BlackbeardRandy')
check('game name -> ecosystem', eco, 'Beast'); check('  spelled', shown, 'Blackbeard Randy')
check('spaced name', (Eco.ecosystem_of('Swooping Zhivago')), 'Bird')
check('unknown pet', Eco.ecosystem_of('NotAPet'), nil)

-- the chat line when a pet comes out (BST_STATUS.lua job_pet_change)
dofile('shared/jobs/bst/functions/BST_STATUS.lua')
said = {}
job_pet_change({name = 'WarlikePatrick'}, true)
check('a pet out: one line', #said, 1)
check('  its family', said[1] and said[1][1], 'Lizard')
check('  beats', said[1] and said[1][2], 'Vermin')
check('  beaten by', said[1] and said[1][3], 'Beast')
check('  named', said[1] and said[1][4], 'Warlike Patrick')
said = {}
job_pet_change({name = 'WarlikePatrick'}, false)
check('a pet gone: nothing', #said, 0)

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)

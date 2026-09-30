---  ═══════════════════════════════════════════════════════════════════════════
---   SMN Refill - what //gs c rf keeps in your inventory on SMN
---  ═══════════════════════════════════════════════════════════════════════════
---   Every line is a comment: SMN uses the common list of
---   _common/inventory/REFILL_CONFIG.lua (default_list). Uncomment what you
---   want:
---
---     M.extra    added to the common list (an item already in it takes
---                the target written here)
---     M.default  a list of its own, in place of the common one
---     M.subjobs  a list per subjob (wins over both)
---
---   An item: { name = 'Remedy', target = 12 }
---   Variants, best first: { name = {'Sublime Sushi +1', 'Sublime Sushi'}, target = 12 }
---   M.store_bag / M.source_bags work as in REFILL_CONFIG.lua, for SMN only.
---
---   @file    smn/inventory/SMN_REFILL.lua
---   @author  ejouanchicot
---   @date    Created: 2026-09-30
---  ═══════════════════════════════════════════════════════════════════════════

local M = {}

-- Food for SMN, on top of the common list:
-- M.extra = {
--     {name = {'Sublime Sushi +1', 'Sublime Sushi'}, target = 12},
-- }

-- Or a whole list of its own:
-- M.default = {
--     {name = 'Remedy', target = 12},
--     {name = 'Echo Drops', target = 12},
-- }

-- Or per subjob (the other subjobs keep the list above):
-- M.subjobs = {
--     DNC = {
--         {name = 'Remedy', target = 12},
--     },
-- }

return M

---  ═══════════════════════════════════════════════════════════════════════════
---   Refill Configuration - the bags //gs c rf uses
---  ═══════════════════════════════════════════════════════════════════════════
---   Read by shared/utils/inventory/refill/config_resolver.lua on every
---   //gs c rf (and after //gs c craft / uncraft). After editing:
---   //lua reload gearswap.
---
---   The bags you can name (the ones the game opens anywhere; the Mog Safe,
---   Storage and Locker only open in the Mog House):
---       'case', 'sack', 'satchel', 'wardrobe1' ... 'wardrobe8'
---   Wardrobes only hold equipment (ammo for instance), not food or medicine.
---
---   source_bags: where missing items are taken from, in this order.
---       RefillConfig.source_bags = {'case', 'sack', 'satchel'}
---       RefillConfig.source_bags = {'satchel', 'case'}      -- Satchel first
---       RefillConfig.source_bags = {'sack', 'wardrobe4'}    -- ammo in W4
---   store_bag: where extra and other jobs' items are put back (one bag).
---       RefillConfig.store_bag = 'case'
---   store_foreign / foreign_characters / never_store: which items of your
---   other lists go back to store_bag (see below).
---
---   These apply to every job. A job's own list (<job>/inventory/<JOB>_REFILL.lua)
---   or the craft list (_common/inventory/CRAFT_REFILL.lua) can set its own
---   source_bags / store_bag the same way; its values win over these.
---
---   default_list: what every job refills (below); a job's file adds to it
---   (M.extra), replaces it (M.default) or sets a list per subjob
---   (M.subjobs). subjobs: the common list per subjob.
---
---   @file    common/inventory/REFILL_CONFIG.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-30
---  ═══════════════════════════════════════════════════════════════════════════

local RefillConfig = {}

-- Where missing items are taken from, in order
RefillConfig.source_bags = {'case', 'sack', 'satchel'}

-- Where extra items are put back
RefillConfig.store_bag = 'case'

-- An item of one of your other refill lists, sitting in the inventory but
-- not in the list of the job you are on, goes back to store_bag:
--   'mine'  your own lists only (this character's folder)
--   'all'   other characters' lists too (an item of theirs traded to you):
--           RefillConfig.store_foreign = 'all'
--           RefillConfig.foreign_characters = {'Tetsouo', 'Kaories'}
--           (empty: every character folder, frozen ones included)
--   false   never: only the surplus of the active list goes back
RefillConfig.store_foreign = 'mine'
RefillConfig.foreign_characters = {}

-- Items never put back, whatever the lists say (kept by hand)
-- Example: RefillConfig.never_store = {'Echo Drops', 'Holy Water'}
RefillConfig.never_store = {}

-- The common list: what every job keeps in the inventory, unless its own
-- file (<job>/inventory/<JOB>_REFILL.lua) adds to it (M.extra) or replaces
-- it (M.default). An item: {name = 'Remedy', target = 12}; variants, best
-- first: {name = {'Sublime Sushi +1', 'Sublime Sushi'}, target = 12}.
RefillConfig.default_list = {
    {name = 'Panacea', target = 12},
    {name = 'Antacid', target = 12},
    {name = 'Holy Water', target = 12},
    {name = 'Remedy', target = 12},
    {name = 'Prism Powder', target = 12},
    {name = 'Silent Oil', target = 12},
}

-- The common list for a subjob, for every job without a list of its own for
-- it. /DNC has Spectral Jig: no Powder / Oil.
-- RefillConfig.subjobs = {
--     DNC = {
--         {name = 'Panacea', target = 12},
--         {name = 'Antacid', target = 12},
--         {name = 'Holy Water', target = 12},
--         {name = 'Remedy', target = 12},
--     },
-- }

-- The ammo's quiver / pouch is opened after a ranged attack when the ammo
-- left (inventory + wardrobes) is at or under this, per job (the defaults);
-- false: that job never opens one.
RefillConfig.quiver_open_at = {COR = 15, THF = 5, RNG = 15}

return RefillConfig

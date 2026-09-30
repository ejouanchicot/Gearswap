---============================================================================
--- Craft Refill Configuration - what the refill keeps while crafting
---============================================================================
--- Used instead of the job's refill list while a craft or fishing set is on
--- (//gs c craft, //gs c fish). The refill runs by itself 2.5 s after
--- //gs c craft; //gs c rf runs it by hand.
---
--- Write one line per item: its exact name and how many to hold.
---     { name = 'Item Name', target = 12 },
---     { name = {'Item Name +1', 'Item Name'}, target = 12 },  -- +1 first
---     { name = 'Item Name', target = 'all' },                 -- take them all
--- Anything from your other refill lists that is in the inventory goes back
--- to the store bag; items in no list (your materials) are never touched.
--- An empty list moves nothing but those.
---
--- The bags: config/REFILL_CONFIG.lua, or here for crafting only:
---     M.source_bags = {'satchel', 'case'}
---     M.store_bag   = 'satchel'
---
--- @file    config/craft/CRAFT_REFILL.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-30
---============================================================================

local M = {}

M.default = {
    -- { name = 'Item Name', target = 12 },
}

return M

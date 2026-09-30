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
---
---   These apply to every job. A job's own list (config/<job>/<JOB>_REFILL.lua)
---   or the craft list (config/craft/CRAFT_REFILL.lua) can set its own
---   source_bags / store_bag the same way; its values win over these.
---   What to refill is in those list files, not here.
---
---   @file    config/REFILL_CONFIG.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-30
---  ═══════════════════════════════════════════════════════════════════════════

local RefillConfig = {}

-- Where missing items are taken from, in order
RefillConfig.source_bags = {'case', 'sack', 'satchel'}

-- Where extra items are put back
RefillConfig.store_bag = 'case'

return RefillConfig

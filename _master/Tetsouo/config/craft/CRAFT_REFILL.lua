---============================================================================
--- Craft Refill Configuration - Tetsouo
---============================================================================
--- Activated automatically when a craft set is currently equipped (via
--- //gs c craft / //gs c fish). Replaces the active job's refill list while
--- crafting so the inventory holds only craft-relevant consumables.
---
--- Detection: refill/config_resolver.lua asks _G.CraftManager.is_active()
--- (craft_manager.lua owns the craft session state).
---
--- Format: same as job refill configs (BLM_REFILL.lua etc.).
---   - store_bag : 'case' | 'sack' | 'satchel'  - destination for surplus
---   - default   : list of {name=..., target=...} entries
---   - subjobs   : optional sub-config table (unused for craft)
---
--- @file    Tetsouo/config/craft/CRAFT_REFILL.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-05-01
---============================================================================

local M = {}

M.store_bag = 'case'

-- While craft is active we only need synthesis-skill food.
-- Everything else (medicines, sneak/invis items, regular DD food) gets
-- detected as "foreign" and pushed back to the store_bag automatically.
M.default = {
    { name = 'Coconut Rusk',   target = 12 },
    { name = 'Kitron Macaron', target = 12 },
}

return M

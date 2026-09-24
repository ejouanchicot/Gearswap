---============================================================================
--- BLM Lockstyle Configuration
---============================================================================
--- Defines lockstyle sets for Black Mage job per subjob.
---
--- @file config/blm/BLM_LOCKSTYLE.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-15
---============================================================================

local BLMLockstyleConfig = {}

-- Lockstyle applied on BLM, whatever the subjob
BLMLockstyleConfig.default = 5

-- Not read: LockstyleManager only uses .default and .get_style(subjob).
-- This table would need a get_style() function (see BST_LOCKSTYLE.lua) to apply.
BLMLockstyleConfig.by_subjob = {
    ['SCH'] = 5,  -- BLM/SCH
    ['RDM'] = 5,  -- BLM/RDM
    ['WHM'] = 5,  -- BLM/WHM
}

return BLMLockstyleConfig

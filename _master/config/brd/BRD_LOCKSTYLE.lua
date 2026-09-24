---============================================================================
--- BRD Lockstyle Configuration
---============================================================================
--- Defines the lockstyle set for Bard job (cosmetic appearance).
---
--- @file config/brd/BRD_LOCKSTYLE.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-13
---============================================================================

local BRDLockstyleConfig = {}

-- Lockstyle applied on BRD, whatever the subjob
BRDLockstyleConfig.default = 7

-- Not read: LockstyleManager only uses .default and .get_style(subjob).
-- This table would need a get_style() function (see BST_LOCKSTYLE.lua) to apply.
BRDLockstyleConfig.by_subjob = {
    ['WHM'] = 7,  -- Bard/White Mage
    ['RDM'] = 7,  -- Bard/Red Mage
    ['NIN'] = 7,  -- Bard/Ninja
    ['DNC'] = 7,  -- Bard/Dancer
}

return BRDLockstyleConfig

---============================================================================
--- BRD Lockstyle Configuration
---============================================================================
--- Defines the lockstyle set for Bard job (cosmetic appearance).
---
--- @file config/brd/BRD_LOCKSTYLE.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2025-10-13
---============================================================================

local BRDLockstyleConfig = {}

-- Lockstyle applied on BRD, whatever the subjob
BRDLockstyleConfig.default = 7

-- Lockstyle per subjob (shared/utils/lockstyle/lockstyle_manager.lua resolve_style): a subjob
-- listed here wears its set, any other subjob the default
BRDLockstyleConfig.by_subjob = {
    ['WHM'] = 7,  -- Bard/White Mage
    ['RDM'] = 7,  -- Bard/Red Mage
    ['NIN'] = 7,  -- Bard/Ninja
    ['DNC'] = 7,  -- Bard/Dancer
}

return BRDLockstyleConfig

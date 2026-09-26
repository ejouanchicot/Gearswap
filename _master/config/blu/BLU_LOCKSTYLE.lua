---============================================================================
--- BLU Lockstyle Configuration - Visual Appearance Management
---============================================================================
--- Lockstyle set for Blue Mage, with optional per-subjob overrides.
--- Numbers are the in-game /lockstyle set numbers.
---
--- @file    config/blu/BLU_LOCKSTYLE.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-26
---============================================================================

local BLULockstyleConfig = {}

-- Default lockstyle (used if no subjob-specific config)
BLULockstyleConfig.default = 1

-- Lockstyle per subjob (optional)
BLULockstyleConfig.by_subjob = {
    -- ['WAR'] = 1,  -- BLU/WAR
}

return BLULockstyleConfig

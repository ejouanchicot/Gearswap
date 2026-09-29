---============================================================================
--- DRG Lockstyle Configuration - Visual Appearance Management
---============================================================================
--- Lockstyle set for Dragoon, with optional per-subjob overrides.
--- Numbers are the in-game /lockstyle set numbers.
---
--- Example:
---   DRGLockstyleConfig.default = 12
---   DRGLockstyleConfig.by_subjob = { ['WAR'] = 13 }
---
--- @file    config/drg/DRG_LOCKSTYLE.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

local DRGLockstyleConfig = {}

-- Default lockstyle (used if no subjob-specific config)
DRGLockstyleConfig.default = 1

-- Lockstyle per subjob (optional)
DRGLockstyleConfig.by_subjob = {
    -- ['SAM'] = 1,  -- DRG/SAM
}

return DRGLockstyleConfig

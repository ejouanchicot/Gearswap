---============================================================================
--- RNG Lockstyle Configuration - Visual Appearance Management
---============================================================================
--- Lockstyle set for Ranger, with optional per-subjob overrides.
--- Numbers are the in-game /lockstyle set numbers.
---
--- Example:
---   RNGLockstyleConfig.default = 12
---   RNGLockstyleConfig.by_subjob = { ['DNC'] = 13 }
---
--- @file    config/rng/RNG_LOCKSTYLE.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

local RNGLockstyleConfig = {}

-- Default lockstyle (used if no subjob-specific config)
RNGLockstyleConfig.default = 1

-- Lockstyle per subjob (optional)
RNGLockstyleConfig.by_subjob = {
    -- ['WAR'] = 1,  -- RNG/WAR
}

return RNGLockstyleConfig

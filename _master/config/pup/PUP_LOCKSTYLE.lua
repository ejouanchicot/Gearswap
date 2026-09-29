---============================================================================
--- PUP Lockstyle Configuration - Visual Appearance Management
---============================================================================
--- Lockstyle set for Puppetmaster, with optional per-subjob overrides.
--- Numbers are the in-game /lockstyle set numbers.
---
--- Example:
---   PUPLockstyleConfig.default = 12
---   PUPLockstyleConfig.by_subjob = { ['DNC'] = 13 }
---
--- @file    config/pup/PUP_LOCKSTYLE.lua
--- @author  ejouanchicot
--- @version 2.0
--- @date    Created: 2026-09-29
---============================================================================

local PUPLockstyleConfig = {}

-- Default lockstyle (used if no subjob-specific config)
PUPLockstyleConfig.default = 1

-- Lockstyle per subjob (optional)
PUPLockstyleConfig.by_subjob = {
    -- ['WAR'] = 1,  -- PUP/WAR
}

return PUPLockstyleConfig

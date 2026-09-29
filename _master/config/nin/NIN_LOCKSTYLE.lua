---============================================================================
--- NIN Lockstyle Configuration - Visual Appearance Management
---============================================================================
--- Lockstyle set for Ninja, with optional per-subjob overrides.
--- Numbers are the in-game /lockstyle set numbers.
---
--- Example:
---   NINLockstyleConfig.default = 12
---   NINLockstyleConfig.by_subjob = { ['DNC'] = 13 }
---
--- @file    config/nin/NIN_LOCKSTYLE.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

local NINLockstyleConfig = {}

-- Default lockstyle (used if no subjob-specific config)
NINLockstyleConfig.default = 1

-- Lockstyle per subjob (optional)
NINLockstyleConfig.by_subjob = {
    -- ['WAR'] = 1,  -- NIN/WAR
}

return NINLockstyleConfig

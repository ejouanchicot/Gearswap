---============================================================================
--- MNK Lockstyle Configuration - Visual Appearance Management
---============================================================================
--- Lockstyle set for Monk, with optional per-subjob overrides.
--- Numbers are the in-game /lockstyle set numbers.
---
--- @file    config/mnk/MNK_LOCKSTYLE.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

local MNKLockstyleConfig = {}

-- Default lockstyle (used if no subjob-specific config)
MNKLockstyleConfig.default = 1

-- Lockstyle per subjob (optional)
MNKLockstyleConfig.by_subjob = {
    -- ['WAR'] = 1,  -- MNK/WAR
}

return MNKLockstyleConfig

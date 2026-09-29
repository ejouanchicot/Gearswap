---============================================================================
--- SCH Lockstyle Configuration - Visual Appearance Management
---============================================================================
--- Lockstyle set for Scholar, with optional per-subjob overrides.
--- Numbers are the in-game /lockstyle set numbers.
---
--- Example:
---   SCHLockstyleConfig.default = 12
---   SCHLockstyleConfig.by_subjob = { ['WHM'] = 13 }
---
--- @file    config/sch/SCH_LOCKSTYLE.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

local SCHLockstyleConfig = {}

-- Default lockstyle (used if no subjob-specific config)
SCHLockstyleConfig.default = 1

-- Lockstyle per subjob (optional)
SCHLockstyleConfig.by_subjob = {
    -- ['RDM'] = 1,  -- SCH/RDM
}

return SCHLockstyleConfig

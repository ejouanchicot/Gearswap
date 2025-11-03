---============================================================================
--- THF Lockstyle Configuration - Visual Appearance Management
---============================================================================
--- Defines lockstyle sets for Thief job with optional subjob-specific overrides.
---
--- Features:
---   • Default lockstyle (used when no subjob-specific override exists)
---   • Subjob-specific lockstyle overrides (optional)
---   • Automatic selection based on current subjob
---   • Backward compatibility with legacy code
---
--- Usage:
---   • Default lockstyle: 1 (applies to all subjobs without specific config)
---   • Override for specific subjobs in by_subjob table
---   • Lockstyle numbers correspond to /lockstyle set # in-game
---
--- Dependencies:
---   • LockstyleManager (factory that uses this configuration)
---   • DressUp addon (FFXI lockstyle support)
---
--- @file    config/thf/THF_LOCKSTYLE.lua
--- @author  Typioni
--- @version 1.0
--- @date    Created: 2025-10-06
---============================================================================

local THFLockstyleConfig = {}

-- Default lockstyle (used if no subjob-specific config)
THFLockstyleConfig.default = 1

-- Lockstyle per subjob (optional)
-- Uncomment and customize as needed
THFLockstyleConfig.by_subjob = {
    ['DNC'] = 1,  -- THF/DNC → lockstyle 1
    ['NIN'] = 1,  -- THF/NIN → lockstyle 2
    ['WAR'] = 1,  -- THF/WAR → lockstyle 3
}

return THFLockstyleConfig

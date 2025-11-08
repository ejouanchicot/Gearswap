---============================================================================
--- SAM Lockstyle Configuration
---============================================================================
--- Defines lockstyle sets for SAM by subjob.
--- @file SAM_LOCKSTYLE.lua
--- @author Morphetrix
--- @version 1.0
--- @date Created: 2025-10-21
---============================================================================

local SAMLockstyleConfig = {}

---============================================================================
--- LOCKSTYLE SETTINGS
---============================================================================

--- Default lockstyle (used if subjob not found in table)
SAMLockstyleConfig.default = 2

--- Lockstyle by subjob
SAMLockstyleConfig.by_subjob = {
    ['WAR'] = 2,  -- SAM/WAR
    ['DRG'] = 2,  -- SAM/DRG
    ['NIN'] = 2,  -- SAM/NIN
    ['DNC'] = 2,  -- SAM/DNC
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return SAMLockstyleConfig

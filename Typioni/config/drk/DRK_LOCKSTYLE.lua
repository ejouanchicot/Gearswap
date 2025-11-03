---============================================================================
--- DRK Lockstyle Configuration
---============================================================================
--- User-configurable lockstyle settings for Dark Knight job.
---
--- Features:
---   • Default lockstyle (used when no subjob-specific override exists)
---   • Subjob-specific lockstyle overrides (optional)
---   • Automatic selection based on current subjob
---
--- Usage:
---   • Edit the `default` value to set your preferred lockstyle
---   • Edit the `by_subjob` table to configure subjob-specific lockstyles
---   • Lockstyle numbers correspond to /lockstyleset 1-200 in-game
---
--- @file    config/drk/DRK_LOCKSTYLE.lua
--- @author  Typioni
--- @version 1.0.0
--- @date    Created: 2025-10-23
---============================================================================
local DRKLockstyleConfig = {}

---============================================================================
--- USER CONFIGURATION
---============================================================================

--- Default lockstyle (used if no subjob-specific lockstyle is defined)
DRKLockstyleConfig.default = 1

--- Lockstyle by subjob (OPTIONAL)
--- Configure different lockstyles per subjob here.
--- If a subjob is not in this table, the default lockstyle will be used.
DRKLockstyleConfig.by_subjob = {
    -- Examples:
    ['SAM'] = 1, -- DRK/SAM uses lockstyle 1
    ['WAR'] = 1, -- DRK/WAR uses lockstyle 1
    ['NIN'] = 2, -- DRK/NIN uses lockstyle 2
    ['DNC'] = 3  -- DRK/DNC uses lockstyle 3
}

---============================================================================
--- HELPER FUNCTION - DO NOT MODIFY
---============================================================================

--- Get lockstyle for current subjob
--- Returns subjob-specific lockstyle if configured, otherwise returns default.
---
--- @param  subjob string Current subjob code (SAM, WAR, NIN, DNC, etc.)
--- @return number Lockstyle number (1-200)
function DRKLockstyleConfig.get_style(subjob)
    -- Check if subjob-specific lockstyle exists
    if DRKLockstyleConfig.by_subjob and DRKLockstyleConfig.by_subjob[subjob] then
        return DRKLockstyleConfig.by_subjob[subjob]
    end

    -- Fallback to default
    return DRKLockstyleConfig.default
end

---============================================================================
--- BACKWARD COMPATIBILITY
---============================================================================

-- Legacy code may access .style directly instead of calling get_style()
DRKLockstyleConfig.style = DRKLockstyleConfig.default

---============================================================================
--- MODULE EXPORT
---============================================================================

return DRKLockstyleConfig

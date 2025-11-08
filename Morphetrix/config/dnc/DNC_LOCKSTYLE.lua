---============================================================================
--- DNC Lockstyle Configuration
---============================================================================
--- User-configurable lockstyle settings for Dancer job.
---
--- Features:
---   • Default lockstyle (used when no subjob-specific override exists)
---   • Subjob-specific lockstyle overrides (optional)
---   • Automatic selection based on current subjob
---   • Backward compatibility with legacy code
---
--- Usage:
---   • Edit the `default` value to set your preferred lockstyle
---   • Edit the `by_subjob` table to configure subjob-specific lockstyles
---   • Lockstyle numbers correspond to /lockstyleset 1-200 in-game
---
--- @file    config/dnc/DNC_LOCKSTYLE.lua
--- @author  Morphetrix
--- @version 1.0
--- @date    Created: 2025-10-04
---============================================================================

local DNCLockstyleConfig = {}

---============================================================================
--- USER CONFIGURATION
---============================================================================

-- Default lockstyle (used if no subjob-specific lockstyle is defined)
DNCLockstyleConfig.default = 2

-- Lockstyle by subjob (OPTIONAL)
-- If you want different lockstyles per subjob, uncomment and configure below
-- If not configured, the default lockstyle will be used
DNCLockstyleConfig.by_subjob = {
    -- Examples:
    ['NIN'] = 2,  -- DNC/NIN uses lockstyle 2
    ['SAM'] = 2,  -- DNC/SAM uses lockstyle 2
    ['WAR'] = 2,  -- DNC/WAR uses lockstyle 2
    ['THF'] = 2,  -- DNC/THF uses lockstyle 2
    ['DRG'] = 2,  -- DNC/THF uses lockstyle 2
}

---============================================================================
--- HELPER FUNCTION - DO NOT MODIFY
---============================================================================

--- Get lockstyle for current subjob
--- @param subjob string Current subjob (NIN, SAM, etc.)
--- @return number Lockstyle number
function DNCLockstyleConfig.get_style(subjob)
    -- Check if subjob-specific lockstyle exists
    if DNCLockstyleConfig.by_subjob and DNCLockstyleConfig.by_subjob[subjob] then
        return DNCLockstyleConfig.by_subjob[subjob]
    end

    -- Fallback to default
    return DNCLockstyleConfig.default
end

-- Backward compatibility (for old code using .style)
DNCLockstyleConfig.style = DNCLockstyleConfig.default

return DNCLockstyleConfig

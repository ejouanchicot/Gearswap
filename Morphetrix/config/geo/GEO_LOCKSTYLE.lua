---============================================================================
--- GEO Lockstyle Configuration
---============================================================================
--- User-configurable lockstyle settings for Geomancer job.
--- Configure different lockstyles by subjob, role, or personal preference.
---
--- @file config/geo/GEO_LOCKSTYLE.lua
--- @author Morphetrix
--- @version 1.0
--- @date Created: 2025-10-09
---============================================================================

local GEOLockstyleConfig = {}

---============================================================================
--- USER CONFIGURATION
---============================================================================

-- Default lockstyle (used if no subjob-specific lockstyle is defined)
GEOLockstyleConfig.default = 5

-- Lockstyle by subjob (OPTIONAL)
-- If you want different lockstyles per subjob, uncomment and configure below
-- If not configured, the default lockstyle will be used
GEOLockstyleConfig.by_subjob = {
    -- Examples:
    ['WHM'] = 5,  -- GEO/WHM uses lockstyle 1
    ['RDM'] = 5,  -- GEO/RDM uses lockstyle 1
    ['BLM'] = 5,  -- GEO/BLM uses lockstyle 1
    ['SCH'] = 5,  -- GEO/SCH uses lockstyle 1
}

---============================================================================
--- HELPER FUNCTION - DO NOT MODIFY
---============================================================================

--- Get lockstyle for current subjob
--- @param subjob string Current subjob (WHM, RDM, etc.)
--- @return number Lockstyle number
function GEOLockstyleConfig.get_style(subjob)
    -- Check if subjob-specific lockstyle exists
    if GEOLockstyleConfig.by_subjob and GEOLockstyleConfig.by_subjob[subjob] then
        return GEOLockstyleConfig.by_subjob[subjob]
    end

    -- Fallback to default
    return GEOLockstyleConfig.default
end

-- Backward compatibility (for old code using .style)
GEOLockstyleConfig.style = GEOLockstyleConfig.default

return GEOLockstyleConfig

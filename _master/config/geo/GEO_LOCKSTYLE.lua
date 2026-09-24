---============================================================================
--- GEO Lockstyle Configuration
---============================================================================
--- User-configurable lockstyle settings for Geomancer job.
--- Configure a default lockstyle and optional per-subjob overrides.
---
--- @file config/geo/GEO_LOCKSTYLE.lua
--- @author Tetsouo
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
-- A subjob missing from this table uses the default lockstyle
GEOLockstyleConfig.by_subjob = {
    ['WHM'] = 5,  -- GEO/WHM
    ['RDM'] = 5,  -- GEO/RDM
    ['BLM'] = 5,  -- GEO/BLM
    ['SCH'] = 5,  -- GEO/SCH
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

-- Legacy field: nothing under shared/ reads .style any more
GEOLockstyleConfig.style = GEOLockstyleConfig.default

return GEOLockstyleConfig

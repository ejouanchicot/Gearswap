---============================================================================
--- RUN Lockstyle Configuration
---============================================================================
--- User-configurable lockstyle settings for Rune Fencer job.
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
--- @file    config/run/RUN_LOCKSTYLE.lua
--- @author  Morphetrix
--- @version 1.0.0
--- @date    Created: 2025-10-03 | Updated: 2025-11-04
---============================================================================
local RUNLockstyleConfig = {}

---============================================================================
--- USER CONFIGURATION
---============================================================================

--- Default lockstyle (used if no subjob-specific lockstyle is defined)
RUNLockstyleConfig.default = 3

--- Lockstyle by subjob (OPTIONAL)
--- Configure different lockstyles per subjob here.
--- If a subjob is not in this table, the default lockstyle will be used.
RUNLockstyleConfig.by_subjob = {
    -- Examples:
    ['RUN'] = 3, -- RUN/RUN uses lockstyle 3
    ['BLU'] = 3, -- RUN/BLU uses lockstyle 3
    ['RDM'] = 3, -- RUN/RDM uses lockstyle 3
    ['WAR'] = 3, -- RUN/WAR uses lockstyle 3
    ['NIN'] = 3 -- RUN/NIN uses lockstyle 3
}

---============================================================================
--- HELPER FUNCTION - DO NOT MODIFY
---============================================================================

--- Get lockstyle for current subjob
--- Returns subjob-specific lockstyle if configured, otherwise returns default.
---
--- @param  subjob string Current subjob code (RUN, BLU, RDM, WAR, NIN, etc.)
--- @return number Lockstyle number (1-200)
function RUNLockstyleConfig.get_style(subjob)
    -- Check if subjob-specific lockstyle exists
    if RUNLockstyleConfig.by_subjob and RUNLockstyleConfig.by_subjob[subjob] then
        return RUNLockstyleConfig.by_subjob[subjob]
    end

    -- Fallback to default
    return RUNLockstyleConfig.default
end

---============================================================================
--- BACKWARD COMPATIBILITY
---============================================================================

-- Legacy code may access .style directly instead of calling get_style()
RUNLockstyleConfig.style = RUNLockstyleConfig.default

---============================================================================
--- MODULE EXPORT
---============================================================================

return RUNLockstyleConfig

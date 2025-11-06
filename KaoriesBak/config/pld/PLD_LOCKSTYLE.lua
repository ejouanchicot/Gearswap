---============================================================================
--- PLD Lockstyle Configuration
---============================================================================
--- User-configurable lockstyle settings for Paladin job.
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
--- @file    config/pld/PLD_LOCKSTYLE.lua
--- @author  Kaories
--- @version 1.0.0
--- @date    Created: 2025-10-03
---============================================================================
local PLDLockstyleConfig = {}

---============================================================================
--- USER CONFIGURATION
---============================================================================

--- Default lockstyle (used if no subjob-specific lockstyle is defined)
PLDLockstyleConfig.default = 3

--- Lockstyle by subjob (OPTIONAL)
--- Configure different lockstyles per subjob here.
--- If a subjob is not in this table, the default lockstyle will be used.
PLDLockstyleConfig.by_subjob = {
    -- Examples:
    ['RUN'] = 3, -- PLD/RUN uses lockstyle 3
    ['BLU'] = 3, -- PLD/BLU uses lockstyle 3
    ['RDM'] = 3, -- PLD/RDM uses lockstyle 3
    ['WAR'] = 3, -- PLD/WAR uses lockstyle 3
    ['NIN'] = 3 -- PLD/NIN uses lockstyle 3
}

---============================================================================
--- HELPER FUNCTION - DO NOT MODIFY
---============================================================================

--- Get lockstyle for current subjob
--- Returns subjob-specific lockstyle if configured, otherwise returns default.
---
--- @param  subjob string Current subjob code (RUN, BLU, RDM, WAR, NIN, etc.)
--- @return number Lockstyle number (1-200)
function PLDLockstyleConfig.get_style(subjob)
    -- Check if subjob-specific lockstyle exists
    if PLDLockstyleConfig.by_subjob and PLDLockstyleConfig.by_subjob[subjob] then
        return PLDLockstyleConfig.by_subjob[subjob]
    end

    -- Fallback to default
    return PLDLockstyleConfig.default
end

---============================================================================
--- BACKWARD COMPATIBILITY
---============================================================================

-- Legacy code may access .style directly instead of calling get_style()
PLDLockstyleConfig.style = PLDLockstyleConfig.default

---============================================================================
--- MODULE EXPORT
---============================================================================

return PLDLockstyleConfig

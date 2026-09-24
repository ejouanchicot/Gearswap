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
--- @file    Kaories/config/pld/PLD_LOCKSTYLE.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-10-03
---============================================================================
local PLDLockstyleConfig = {}

---============================================================================
--- USER CONFIGURATION
---============================================================================

--- Default lockstyle (used if no subjob-specific lockstyle is defined)
PLDLockstyleConfig.default = 4

--- Lockstyle by subjob (OPTIONAL)
--- Configure different lockstyles per subjob here.
--- If a subjob is not in this table, the default lockstyle will be used.
PLDLockstyleConfig.by_subjob = {
    ['RUN'] = 4, -- PLD/RUN
    ['BLU'] = 4, -- PLD/BLU
    ['RDM'] = 4, -- PLD/RDM
    ['WAR'] = 4, -- PLD/WAR
    ['NIN'] = 4 -- PLD/NIN
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

-- Legacy field: nothing under shared/ reads .style any more
PLDLockstyleConfig.style = PLDLockstyleConfig.default

---============================================================================
--- MODULE EXPORT
---============================================================================

return PLDLockstyleConfig

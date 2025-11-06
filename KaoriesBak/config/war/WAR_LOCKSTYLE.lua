---============================================================================
--- WAR Lockstyle Configuration
---============================================================================
--- User-configurable lockstyle settings for Warrior job.
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
--- @file    config/war/WAR_LOCKSTYLE.lua
--- @author  Kaories
--- @version 2.0
--- @date    Created: 2025-10-02 | Updated: 2025-10-02 - Subjob support
---============================================================================
local WARLockstyleConfig = {}

---============================================================================
--- USER CONFIGURATION
---============================================================================

--- Default lockstyle (used if no subjob-specific lockstyle is defined)
WARLockstyleConfig.default = 4

--- Lockstyle by subjob (OPTIONAL)
--- Configure different lockstyles per subjob here.
--- If a subjob is not in this table, the default lockstyle will be used.
WARLockstyleConfig.by_subjob = {
    -- Examples:
    ['SAM'] = 4, -- WAR/SAM uses lockstyle 4
    ['DRG'] = 4, -- WAR/DRG uses lockstyle 4
    ['DNC'] = 4, -- WAR/DNC uses lockstyle 4
    ['NIN'] = 4 -- WAR/NIN uses lockstyle 4
}

---============================================================================
--- HELPER FUNCTION - DO NOT MODIFY
---============================================================================

--- Get lockstyle for current subjob
--- Returns subjob-specific lockstyle if configured, otherwise returns default.
---
--- @param  subjob string Current subjob code (SAM, DRG, DNC, NIN, etc.)
--- @return number Lockstyle number (1-200)
function WARLockstyleConfig.get_style(subjob)
    -- Check if subjob-specific lockstyle exists
    if WARLockstyleConfig.by_subjob and WARLockstyleConfig.by_subjob[subjob] then
        return WARLockstyleConfig.by_subjob[subjob]
    end

    -- Fallback to default
    return WARLockstyleConfig.default
end

---============================================================================
--- BACKWARD COMPATIBILITY
---============================================================================

-- Legacy code may access .style directly instead of calling get_style()
WARLockstyleConfig.style = WARLockstyleConfig.default

---============================================================================
--- MODULE EXPORT
---============================================================================

return WARLockstyleConfig

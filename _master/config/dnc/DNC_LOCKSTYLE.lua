---============================================================================
--- DNC Lockstyle Configuration
---============================================================================
--- User-configurable lockstyle settings for Dancer job.
---
--- Features:
---   • Default lockstyle (used when no subjob-specific override exists)
---   • Subjob-specific lockstyle overrides (optional)
---   • Automatic selection based on current subjob
---   • Legacy .style field (unused)
---
--- Usage:
---   • Edit the `default` value to set your preferred lockstyle
---   • Edit the `by_subjob` table to configure subjob-specific lockstyles
---   • Lockstyle numbers correspond to /lockstyleset 1-200 in-game
---
--- @file    config/dnc/DNC_LOCKSTYLE.lua
--- @author  Tetsouo
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
-- A subjob missing from this table uses the default lockstyle
DNCLockstyleConfig.by_subjob = {
    ['NIN'] = 2,  -- DNC/NIN
    ['SAM'] = 2,  -- DNC/SAM
    ['WAR'] = 2,  -- DNC/WAR
    ['THF'] = 2,  -- DNC/THF
    ['DRG'] = 2,  -- DNC/DRG
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

-- Legacy field: nothing under shared/ reads .style any more
DNCLockstyleConfig.style = DNCLockstyleConfig.default

return DNCLockstyleConfig

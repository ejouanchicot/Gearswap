---============================================================================
--- COR Lockstyle Configuration
---============================================================================
--- User-configurable lockstyle settings for Corsair job.
--- Configure different lockstyles by subjob, role, or personal preference.
---
--- @file config/cor/COR_LOCKSTYLE.lua
--- @author Typioni
--- @version 1.0
--- @date Created: 2025-10-07
---============================================================================

local CORLockstyleConfig = {}

---============================================================================
--- USER CONFIGURATION
---============================================================================

-- Default lockstyle (used if no subjob-specific lockstyle is defined)
CORLockstyleConfig.default = 3

-- Lockstyle by subjob (OPTIONAL)
-- If you want different lockstyles per subjob, uncomment and configure below
-- If not configured, the default lockstyle will be used
CORLockstyleConfig.by_subjob = {
    -- Examples:
    ['DNC'] = 3,  -- COR/DNC uses lockstyle 1
    ['NIN'] = 3,  -- COR/NIN uses lockstyle 2
    ['WAR'] = 3,  -- COR/WAR uses lockstyle 3
    ['SAM'] = 3,  -- COR/SAM uses lockstyle 4
}

---============================================================================
--- HELPER FUNCTION - DO NOT MODIFY
---============================================================================

--- Get lockstyle for current subjob
--- @param subjob string Current subjob (DNC, NIN, etc.)
--- @return number Lockstyle number
function CORLockstyleConfig.get_style(subjob)
    -- Check if subjob-specific lockstyle exists
    if CORLockstyleConfig.by_subjob and CORLockstyleConfig.by_subjob[subjob] then
        return CORLockstyleConfig.by_subjob[subjob]
    end

    -- Fallback to default
    return CORLockstyleConfig.default
end

-- Backward compatibility (for old code using .style)
CORLockstyleConfig.style = CORLockstyleConfig.default

return CORLockstyleConfig

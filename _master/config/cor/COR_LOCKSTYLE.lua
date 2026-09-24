---============================================================================
--- COR Lockstyle Configuration
---============================================================================
--- User-configurable lockstyle settings for Corsair job.
--- Configure a default lockstyle and optional per-subjob overrides.
---
--- @file config/cor/COR_LOCKSTYLE.lua
--- @author Tetsouo
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
-- A subjob missing from this table uses the default lockstyle
CORLockstyleConfig.by_subjob = {
    ['DNC'] = 3,  -- COR/DNC
    ['NIN'] = 3,  -- COR/NIN
    ['WAR'] = 3,  -- COR/WAR
    ['SAM'] = 3,  -- COR/SAM
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

-- Legacy field: nothing under shared/ reads .style any more
CORLockstyleConfig.style = CORLockstyleConfig.default

return CORLockstyleConfig

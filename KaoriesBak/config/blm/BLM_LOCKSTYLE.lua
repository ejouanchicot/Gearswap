---============================================================================
--- BLM Lockstyle Configuration
---============================================================================
--- Defines lockstyle sets for Black Mage job per subjob.
---
--- @file config/blm/BLM_LOCKSTYLE.lua
--- @author Kaories
--- @version 1.0
--- @date Created: 2025-10-15
---============================================================================

local BLMLockstyleConfig = {}

-- Default lockstyle (used if no subjob config)
BLMLockstyleConfig.default = 5

-- Lockstyle per subjob (optional)
BLMLockstyleConfig.by_subjob = {
    ['SCH'] = 5,  -- BLM/SCH
    ['RDM'] = 5,  -- BLM/RDM
    ['WHM'] = 5,  -- BLM/WHM
}

return BLMLockstyleConfig

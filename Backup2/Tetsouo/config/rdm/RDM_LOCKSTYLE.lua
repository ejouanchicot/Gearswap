---============================================================================
--- RDM Lockstyle Configuration
---============================================================================
--- Defines lockstyle sets for Red Mage based on subjob.
---
--- @file config/rdm/RDM_LOCKSTYLE.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-12
---============================================================================

local RDMLockstyleConfig = {}

-- Default lockstyle (used if no subjob match)
RDMLockstyleConfig.default = 1

-- Lockstyle per subjob (optional - fallback to default if not specified)
RDMLockstyleConfig.by_subjob = {
    ['NIN'] = 1,  -- Dualwield melee build
    ['WHM'] = 2,  -- Support/healing build
    ['BLM'] = 3,  -- Nuking build
    ['SCH'] = 4,  -- Hybrid magic build
    ['DNC'] = 5,  -- Melee/support build
}

return RDMLockstyleConfig

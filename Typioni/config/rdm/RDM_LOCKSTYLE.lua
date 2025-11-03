---============================================================================
--- RDM Lockstyle Configuration
---============================================================================
--- Defines lockstyle sets for Red Mage based on subjob.
---
--- @file config/rdm/RDM_LOCKSTYLE.lua
--- @author Typioni
--- @version 1.0
--- @date Created: 2025-10-12
---============================================================================

local RDMLockstyleConfig = {}

-- Default lockstyle (used if no subjob match)
RDMLockstyleConfig.default = 1

-- Lockstyle per subjob (optional - fallback to default if not specified)
RDMLockstyleConfig.by_subjob = {
    ['NIN'] = 1,  -- Dualwield melee build
    ['WHM'] = 1,  -- Support/healing build
    ['BLM'] = 1,  -- Nuking build
    ['SCH'] = 1,  -- Hybrid magic build
    ['DNC'] = 1,  -- Melee/support build
}

return RDMLockstyleConfig

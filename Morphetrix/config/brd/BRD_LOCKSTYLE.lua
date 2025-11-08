---============================================================================
--- BRD Lockstyle Configuration
---============================================================================
--- Defines lockstyle sets for Bard job (cosmetic appearance).
--- Lockstyle varies by subjob for visual variety.
---
--- @file config/brd/BRD_LOCKSTYLE.lua
--- @author Morphetrix
--- @version 1.0
--- @date Created: 2025-10-13
---============================================================================

local BRDLockstyleConfig = {}

-- Default lockstyle (used if no subjob config)
BRDLockstyleConfig.default = 7

-- Lockstyle per subjob (optional customization)
BRDLockstyleConfig.by_subjob = {
    ['WHM'] = 7,  -- Bard/White Mage
    ['RDM'] = 7,  -- Bard/Red Mage
    ['NIN'] = 7,  -- Bard/Ninja
    ['DNC'] = 7,  -- Bard/Dancer
}

return BRDLockstyleConfig

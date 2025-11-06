---============================================================================
--- WHM Lockstyle Configuration - Appearance Sets
---============================================================================
--- Defines lockstyle sets for White Mage by subjob.
--- Used by LockstyleManager factory to automatically apply correct appearance.
---
--- Features:
---   • Default lockstyle (when subjob not configured)
---   • Subjob-specific lockstyles (RDM, SCH, BLM, etc.)
---   • Integration with LockstyleManager factory
---
--- Usage:
---   • Loaded automatically by WHM_LOCKSTYLE.lua module
---   • Factory pattern ensures consistency across all jobs
---   • No manual coding required in this file
---
--- @file    config/whm/WHM_LOCKSTYLE.lua
--- @author  Kaories
--- @version 1.0.0
--- @date    Created: 2025-10-21
---============================================================================

local WHMLockstyleConfig = {}

---============================================================================
--- DEFAULT LOCKSTYLE
---============================================================================

--- Default lockstyle set number (from Timara WHM: set 3)
--- Used when subjob is not defined in by_subjob table
WHMLockstyleConfig.default = 3

---============================================================================
--- SUBJOB-SPECIFIC LOCKSTYLES
---============================================================================

--- Lockstyle sets organized by subjob
--- Maps subjob code → lockstyle set number
--- Example: ['RDM'] = 3 means WHM/RDM uses lockstyle set 3
WHMLockstyleConfig.by_subjob = {
    ['RDM'] = 3,  -- Red Mage subjob (most common for WHM)
    ['SCH'] = 3,  -- Scholar subjob
    ['BLM'] = 3,  -- Black Mage subjob
    ['BLU'] = 3,  -- Blue Mage subjob (rare but possible)
    ['GEO'] = 3,  -- Geomancer subjob
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return WHMLockstyleConfig

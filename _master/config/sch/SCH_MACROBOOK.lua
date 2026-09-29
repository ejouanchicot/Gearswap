---============================================================================
--- SCH Macrobook Configuration - Macro Book & Page Assignment
---============================================================================
--- Macro book and page for Scholar, per subjob, solo and while dual-boxing
--- (by the alt's job, then this character's subjob).
---
--- Example:
---   SCHMacroConfig.solo = { ['WHM'] = { book = 20, page = 2 } }
---   SCHMacroConfig.dualbox = { ['GEO'] = { ['RDM'] = { book = 20, page = 3 } } }
---
--- @file    config/sch/SCH_MACROBOOK.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

local SCHMacroConfig = {}

-- Default macro book (used if subjob not configured)
SCHMacroConfig.default = { book = 1, page = 1 }

-- Macrobooks per subjob
SCHMacroConfig.solo = {
    -- ['RDM'] = { book = 1, page = 1 },  -- SCH/RDM
}

-- Playing SCH with an alt: ['<alt job>'] = { ['<subjob>'] = {book, page} }
SCHMacroConfig.dualbox = {}

return SCHMacroConfig

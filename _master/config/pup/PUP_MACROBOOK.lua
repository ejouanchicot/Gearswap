---============================================================================
--- PUP Macrobook Configuration - Macro Book & Page Assignment
---============================================================================
--- Macro book and page for Puppetmaster, per subjob, solo and while
--- dual-boxing (by the alt's job, then this character's subjob).
---
--- Example:
---   PUPMacroConfig.solo = { ['DNC'] = { book = 18, page = 2 } }
---   PUPMacroConfig.dualbox = { ['GEO'] = { ['WAR'] = { book = 18, page = 3 } } }
---
--- @file    config/pup/PUP_MACROBOOK.lua
--- @author  ejouanchicot
--- @version 2.0
--- @date    Created: 2026-09-29
---============================================================================

local PUPMacroConfig = {}

-- Default macro book (used if subjob not configured)
PUPMacroConfig.default = { book = 1, page = 1 }

-- Macrobooks per subjob
PUPMacroConfig.solo = {
    -- ['WAR'] = { book = 1, page = 1 },  -- PUP/WAR
}

-- Playing PUP with an alt: ['<alt job>'] = { ['<subjob>'] = {book, page} }
PUPMacroConfig.dualbox = {}

return PUPMacroConfig

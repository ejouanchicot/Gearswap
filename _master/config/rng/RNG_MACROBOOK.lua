---============================================================================
--- RNG Macrobook Configuration - Macro Book & Page Assignment
---============================================================================
--- Macro book and page for Ranger, per subjob, solo and while
--- dual-boxing (by the alt's job, then this character's subjob).
---
--- Example:
---   RNGMacroConfig.solo = { ['DNC'] = { book = 18, page = 2 } }
---   RNGMacroConfig.dualbox = { ['GEO'] = { ['WAR'] = { book = 18, page = 3 } } }
---
--- @file    config/rng/RNG_MACROBOOK.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

local RNGMacroConfig = {}

-- Default macro book (used if subjob not configured)
RNGMacroConfig.default = { book = 1, page = 1 }

-- Macrobooks per subjob
RNGMacroConfig.solo = {
    -- ['WAR'] = { book = 1, page = 1 },  -- RNG/WAR
}

-- Playing RNG with an alt: ['<alt job>'] = { ['<subjob>'] = {book, page} }
RNGMacroConfig.dualbox = {}

return RNGMacroConfig

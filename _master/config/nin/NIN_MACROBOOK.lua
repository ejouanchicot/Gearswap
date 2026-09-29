---============================================================================
--- NIN Macrobook Configuration - Macro Book & Page Assignment
---============================================================================
--- Macro book and page for Ninja, per subjob, solo and while dual-boxing
--- (by the alt's job, then this character's subjob).
---
--- Example:
---   NINMacroConfig.solo = { ['DNC'] = { book = 14, page = 2 } }
---   NINMacroConfig.dualbox = { ['GEO'] = { ['WAR'] = { book = 14, page = 3 } } }
---
--- @file    config/nin/NIN_MACROBOOK.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

local NINMacroConfig = {}

-- Default macro book (used if subjob not configured)
NINMacroConfig.default = { book = 1, page = 1 }

-- Macrobooks per subjob
NINMacroConfig.solo = {
    -- ['WAR'] = { book = 1, page = 1 },  -- NIN/WAR
}

-- Playing NIN with an alt: ['<alt job>'] = { ['<subjob>'] = {book, page} }
NINMacroConfig.dualbox = {}

return NINMacroConfig

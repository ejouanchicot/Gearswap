---============================================================================
--- DRG Macrobook Configuration - Macro Book & Page Assignment
---============================================================================
--- Macro book and page for Dragoon, per subjob, solo and while
--- dual-boxing (by the alt's job, then this character's subjob).
---
--- Example:
---   DRGMacroConfig.solo = { ['WAR'] = { book = 18, page = 2 } }
---   DRGMacroConfig.dualbox = { ['GEO'] = { ['SAM'] = { book = 18, page = 3 } } }
---
--- @file    config/drg/DRG_MACROBOOK.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

local DRGMacroConfig = {}

-- Default macro book (used if subjob not configured)
DRGMacroConfig.default = { book = 1, page = 1 }

-- Macrobooks per subjob
DRGMacroConfig.solo = {
    -- ['SAM'] = { book = 1, page = 1 },  -- DRG/SAM
}

-- Playing DRG with an alt: ['<alt job>'] = { ['<subjob>'] = {book, page} }
DRGMacroConfig.dualbox = {}

return DRGMacroConfig

---============================================================================
--- BLU Macrobook Configuration - Macro Book & Page Assignment
---============================================================================
--- Macro book and page for Blue Mage, per subjob, solo and while
--- dual-boxing (by the alt's job, then this character's subjob).
---
--- @file    config/blu/BLU_MACROBOOK.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-26
---============================================================================

local BLUMacroConfig = {}

-- Default macro book (used if subjob not configured)
BLUMacroConfig.default = { book = 1, page = 1 }

-- Macrobooks per subjob
BLUMacroConfig.solo = {
    -- ['WAR'] = { book = 1, page = 1 },  -- BLU/WAR
}

-- Playing BLU with an alt: ['<alt job>'] = { ['<subjob>'] = {book, page} }
BLUMacroConfig.dualbox = {}

return BLUMacroConfig

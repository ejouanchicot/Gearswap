---============================================================================
--- MNK Macrobook Configuration - Macro Book & Page Assignment
---============================================================================
--- Macro book and page for Monk, per subjob, solo and while
--- dual-boxing (by the alt's job, then this character's subjob).
---
--- @file    config/mnk/MNK_MACROBOOK.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

local MNKMacroConfig = {}

-- Default macro book (used if subjob not configured)
MNKMacroConfig.default = { book = 1, page = 1 }

-- Macrobooks per subjob
MNKMacroConfig.solo = {
    -- ['WAR'] = { book = 1, page = 1 },  -- MNK/WAR
}

-- Playing MNK with an alt: ['<alt job>'] = { ['<subjob>'] = {book, page} }
MNKMacroConfig.dualbox = {}

return MNKMacroConfig

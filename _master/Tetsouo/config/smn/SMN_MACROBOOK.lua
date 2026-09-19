---============================================================================
--- SMN Macrobook Configuration
---============================================================================
--- Macro book + page per subjob for Summoner.
--- Used by MacrobookManager factory.
---
--- @file config/smn/SMN_MACROBOOK.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-05-28
---============================================================================

local SMNMacroConfig = {}

--- Default macro book and page
SMNMacroConfig.default = {
    book = 1,
    page = 1
}

--- Macro book per subjob (solo play)
SMNMacroConfig.solo = {
    ['WHM'] = { book = 1, page = 1 },
    ['SCH'] = { book = 1, page = 2 },
    ['RDM'] = { book = 1, page = 3 },
    ['BLM'] = { book = 1, page = 4 },
}

--- Dual-boxing macro overrides (book/page when playing alongside a specific alt)
SMNMacroConfig.dualbox = {}

return SMNMacroConfig

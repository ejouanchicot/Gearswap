---============================================================================
--- BLM Macrobook Configuration
---============================================================================
--- Defines macro book and page settings for Black Mage job per subjob.
---
--- @file Tetsouo/config/blm/BLM_MACROBOOK.lua
--- @author Tetsouo
--- @version 2.0 - Dual-boxing support
--- @date Created: 2025-10-15 | Updated: 2025-10-22
---============================================================================

local BLMMacroConfig = {}

-- Default macro book/page (used if no subjob config)
BLMMacroConfig.default = {book = 7, page = 1}

-- Macro books per subjob (optional); unlisted subjobs use the default
BLMMacroConfig.solo = {
    ['SCH'] = {book = 9, page = 1}, -- BLM/SCH
    ['RDM'] = {book = 9, page = 1}, -- BLM/RDM
    ['WHM'] = {book = 9, page = 1} -- BLM/WHM
}

---============================================================================
--- DUAL-BOXING CONFIGURATION (Playing BLM + Alt)
--- Structure: dualbox[ALT_JOB][YOUR_SUBJOB] = {book, page}, used while the
--- alt is online on ALT_JOB; otherwise the solo table applies.
---============================================================================

BLMMacroConfig.dualbox = {
    ['GEO'] = {
        ['SCH'] = {book = 9, page = 8},
    },
    ['RDM'] = {
        ['SCH'] = {book = 9, page = 1},
    },
    ['COR'] = {
        ['SCH'] = {book = 9, page = 4}
    }
}

return BLMMacroConfig

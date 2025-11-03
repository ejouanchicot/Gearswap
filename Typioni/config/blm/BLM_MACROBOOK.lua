---============================================================================
--- BLM Macrobook Configuration
---============================================================================
--- Defines macro book and page settings for Black Mage job per subjob.
---
--- @file config/blm/BLM_MACROBOOK.lua
--- @author Typioni
--- @version 2.0 - Dual-boxing support
--- @date Created: 2025-10-15 | Updated: 2025-10-22
---============================================================================

local BLMMacroConfig = {}

-- Default macro book/page (used if no subjob config)
BLMMacroConfig.default = {book = 8, page = 1}

-- Macro books per subjob (optional)
BLMMacroConfig.solo = {
    ['SCH'] = {book = 8, page = 1}, -- BLM/SCH
    ['RDM'] = {book = 8, page = 1}, -- BLM/RDM
    ['WHM'] = {book = 8, page = 1} -- BLM/WHM
}

---============================================================================
--- DUAL-BOXING CONFIGURATION (Playing BLM + Alt)
---============================================================================

BLMMacroConfig.dualbox = {
    -- Uncomment to add dual-boxing configurations
    ['GEO'] = {
        ['SCH'] = {book = 9, page = 1},
        ['RDM'] = {book = 9, page = 1}
    },
    ['RDM'] = {
        ['SCH'] = {book = 8, page = 1},
        ['RDM'] = {book = 11, page = 1}
    },
    ['COR'] = {
        ['SCH'] = {book = 10, page = 1}
    }
}

return BLMMacroConfig

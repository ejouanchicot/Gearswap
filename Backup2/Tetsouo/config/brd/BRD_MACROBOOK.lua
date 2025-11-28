---============================================================================
--- BRD Macrobook Configuration
---============================================================================
--- Defines macrobook and page assignments for Bard job.
--- Macrobook varies by subjob for different spell/ability layouts.
---
--- @file config/brd/BRD_MACROBOOK.lua
--- @author Tetsouo
--- @version 2.0 - Dual-boxing support
--- @date Created: 2025-10-13 | Updated: 2025-10-22
---============================================================================

local BRDMacroConfig = {}

-- Default macrobook (used if no subjob config)
BRDMacroConfig.default = {book = 40, page = 1}

-- Macrobook per subjob
BRDMacroConfig.solo = {
    ['WHM'] = {book = 40, page = 1}, -- Bard/White Mage (cures + songs)
    ['RDM'] = {book = 36, page = 1}, -- Bard/Red Mage (enfeebles + songs)
    ['NIN'] = {book = 36, page = 1}, -- Bard/Ninja (utility + songs)
    ['DNC'] = {book = 36, page = 1} -- Bard/Dancer (steps + songs)
}

---============================================================================
--- DUAL-BOXING CONFIGURATION (Playing BRD + Alt)
---============================================================================

BRDMacroConfig.dualbox = {
    -- Uncomment to add dual-boxing configurations
    ['GEO'] = {
        ['SCH'] = {book = 32, page = 1},
        ['DNC'] = {book = 35, page = 1},
    },
    ['COR'] = {
        ['DNC'] = {book = 36, page = 1}
    },
    ['RDM'] = {
        ['SCH'] = {book = 31, page = 1},
        ['DNC'] = {book = 34, page = 1}
    }
}

return BRDMacroConfig

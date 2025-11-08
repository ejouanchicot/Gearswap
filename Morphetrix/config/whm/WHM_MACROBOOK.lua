---============================================================================
--- WHM Macrobook Configuration - Macro Sets
---============================================================================
--- Defines macrobook pages for White Mage by subjob.
--- Used by MacrobookManager factory to automatically load correct macros.
---
--- Features:
---   • Default macrobook/page (when subjob not configured)
---   • Subjob-specific macrobook pages (RDM, SCH, BLM, etc.)
---   • Integration with MacrobookManager factory
---
--- Usage:
---   • Loaded automatically by WHM_MACROBOOK.lua module
---   • Factory pattern ensures consistency across all jobs
---   • No manual coding required in this file
---
--- @file    config/whm/WHM_MACROBOOK.lua
--- @author  Morphetrix
--- @version 2.0 - Dual-boxing support
--- @date    Created: 2025-10-21 | Updated: 2025-10-22
---============================================================================

local WHMMacroConfig = {}

---============================================================================
--- DEFAULT MACROBOOK
---============================================================================

--- Default macrobook and page (from Timara WHM: book 11, page 1)
--- Used when subjob is not defined in macrobooks table
WHMMacroConfig.default = {
    book = 11,  -- Macrobook number
    page = 1    -- Page within macrobook
}

---============================================================================
--- SUBJOB-SPECIFIC MACROBOOKS
---============================================================================

--- Macrobook configuration organized by subjob
--- Maps subjob code → {book, page}
--- Example: ['RDM'] = {book = 11, page = 1} means WHM/RDM uses book 11 page 1
WHMMacroConfig.solo = {
    ['RDM'] = {book = 11, page = 1},  -- Red Mage subjob (most common)
    ['SCH'] = {book = 11, page = 2},  -- Scholar subjob
    ['BLM'] = {book = 11, page = 3},  -- Black Mage subjob
    ['BLU'] = {book = 11, page = 4},  -- Blue Mage subjob (rare)
    ['GEO'] = {book = 11, page = 5},  -- Geomancer subjob
}


---============================================================================
--- DUAL-BOXING CONFIGURATION (Playing WHM + Alt)
---============================================================================
--- Structure: dualbox[ALT_JOB][SUBJOB] = {book, page}
--- Example: dualbox['GEO']['SAM'] = WHM/SAM macros optimized for playing with GEO alt
---
--- Uncomment and customize sections below as needed:
---============================================================================

WHMMacroConfig.dualbox = {
    -- Uncomment to add dual-boxing configurations
    -- ['GEO'] = {
    --     ['SAM'] = { book = XX, page = 1 },
    --     ['DRG'] = { book = XX, page = 2 },
    -- },
    --
    -- ['COR'] = {
    --     ['SAM'] = { book = XX, page = 1 },
    --     ['DRG'] = { book = XX, page = 2 },
    -- },
    --
    -- ['WHM'] = {
    --     ['SAM'] = { book = XX, page = 1 },
    -- },
    --
    -- ['BRD'] = {
    --     ['SAM'] = { book = XX, page = 1 },
    -- },
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return WHMMacroConfig

---============================================================================
--- GEO Macro Book Configuration - Dual-Boxing Support
---============================================================================
--- Defines macro book settings for Geomancer job.
--- Supports per-subjob macro books with default fallback.
---
--- @file config/geo/GEO_MACROBOOK.lua
--- @author Tetsouo
--- @version 2.0 - Dual-boxing support
--- @date Created: 2025-10-09 | Updated: 2025-10-22
---============================================================================

local GEOMacroConfig = {}

---============================================================================
--- MACRO BOOK SETTINGS
---============================================================================

-- Default macro book (used if no subjob-specific config)
GEOMacroConfig.default = { book = 5, page = 1 }

-- Macro books per subjob (optional)
-- If subjob not listed, uses default
GEOMacroConfig.solo = {
    ['WHM'] = { book = 5, page = 1 },  -- GEO/WHM >> Book 1, Page 1
    ['RDM'] = { book = 5, page = 1 },  -- GEO/RDM >> Book 1, Page 2
    ['BLM'] = { book = 5, page = 1 },  -- GEO/BLM >> Book 1, Page 3
    ['SCH'] = { book = 5, page = 1 },  -- GEO/SCH >> Book 1, Page 4
}


---============================================================================
--- DUAL-BOXING CONFIGURATION (Playing GEO + Alt)
---============================================================================
--- Structure: dualbox[ALT_JOB][SUBJOB] = {book, page}
--- Example: dualbox['GEO']['SAM'] = GEO/SAM macros optimized for playing with GEO alt
---
--- Uncomment and customize sections below as needed:
---============================================================================

GEOMacroConfig.dualbox = {
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

return GEOMacroConfig

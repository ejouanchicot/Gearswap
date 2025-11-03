---============================================================================
--- SAM Macrobook Configuration
---============================================================================
--- Defines macro book and page settings for SAM by subjob.
--- @file SAM_MACROBOOK.lua
--- @author Typioni
--- @version 2.0 - Dual-boxing support
--- @date Created: 2025-10-21 | Updated: 2025-10-22
---============================================================================

local SAMMacroConfig = {}

---============================================================================
--- MACROBOOK SETTINGS
---============================================================================

--- Default macrobook (used if subjob not found in table)
SAMMacroConfig.default = {book = 2, page = 1}

--- Macrobooks by subjob
SAMMacroConfig.solo = {
    ['WAR'] = {book = 2, page = 1},  -- SAM/WAR
    ['DRG'] = {book = 2, page = 1},  -- SAM/DRG
    ['NIN'] = {book = 2, page = 1},  -- SAM/NIN
    ['DNC'] = {book = 2, page = 1},  -- SAM/DNC
}


---============================================================================
--- DUAL-BOXING CONFIGURATION (Playing SAM + Alt)
---============================================================================
--- Structure: dualbox[ALT_JOB][SUBJOB] = {book, page}
--- Example: dualbox['GEO']['SAM'] = SAM/SAM macros optimized for playing with GEO alt
---
--- Uncomment and customize sections below as needed:
---============================================================================

SAMMacroConfig.dualbox = {
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

return SAMMacroConfig

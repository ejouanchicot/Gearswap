---============================================================================
--- RUN Macro Book Configuration - Dual-Boxing Support
---============================================================================
--- User-configurable macro book and page assignments for Rune Fencer subjobs.
---
--- Features:
---   • Solo configurations: Playing RUN alone
---   • Dual-boxing configurations: Playing RUN with an alt character
---   • Subjob-specific macro book assignments
---   • Book and page customization per subjob
---   • Default fallback for unconfigured subjobs
---   • Automatic selection on subjob change
---
--- Usage:
---   • Modify the book numbers and pages below to match your FFXI macro setup
---   • Book numbers: 1-20 (FFXI macro book slots)
---   • Page numbers: 1-10 (pages within each book)
---
--- @file    config/run/RUN_MACROBOOK.lua
--- @author  Morphetrix
--- @version 2.0 - Dual-boxing support
--- @date    Created: 2025-10-03 | Updated: 2025-11-04
---============================================================================
local RUNMacroConfig = {}

---============================================================================
---============================================================================
--- SOLO CONFIGURATION (Playing RUN alone)
---============================================================================
---============================================================================

--- Default macro book (used if subjob not configured)
RUNMacroConfig.default = {book = 15, page = 1}

--- RUN macro book assignments by subjob
--- Format: ['SUBJOB'] = { book = NUMBER, page = NUMBER }
RUNMacroConfig.solo = {
    ['RUN'] = {book = 15, page = 1}, -- RUN/RUN
    ['BLU'] = {book = 18, page = 1}, -- RUN/BLU
    ['RDM'] = {book = 20, page = 1}, -- RUN/WAR
    -- Default fallback
    ['default'] = {book = 15, page = 1}
}

---============================================================================
--- DUAL-BOXING CONFIGURATION (Playing RUN + Alt)
---============================================================================
--- Structure: dualbox[ALT_JOB][SUBJOB] = {book, page}
--- Example: dualbox['GEO']['SAM'] = RUN/SAM macros optimized for playing with GEO alt
---
--- Uncomment and customize sections below as needed:
---============================================================================

RUNMacroConfig.dualbox = {
    -- Kaories playing RDM
    ['RDM'] = {
        ['RUN'] = {book = 15, page = 1}, -- RUN/RUN + RDM alt
        ['BLU'] = {book = 18, page = 1}, -- RUN/BLU + RDM alt
    },

    -- Kaories playing COR
    ['COR'] = {
        ['RUN'] = {book = 17, page = 1}, -- RUN/RUN + COR alt
        ['BLU'] = {book = 20, page = 1}, -- RUN/BLU + COR alt
    },

    -- Kaories playing GEO
    ['GEO'] = {
        ['RUN'] = {book = 16, page = 1}, -- RUN/RUN + GEO alt
        ['BLU'] = {book = 19, page = 1}, -- RUN/BLU + GEO alt
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return RUNMacroConfig

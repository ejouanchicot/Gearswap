---============================================================================
--- PLD Macro Book Configuration - Dual-Boxing Support
---============================================================================
--- User-configurable macro book and page assignments for Paladin subjobs.
---
--- Features:
---   • Solo configurations: Playing PLD alone
---   • Dual-boxing configurations: Playing PLD with an alt character
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
--- @file    config/pld/PLD_MACROBOOK.lua
--- @author  Tetsouo
--- @version 2.0 - Dual-boxing support
--- @date    Created: 2025-10-03 | Updated: 2025-10-22
---============================================================================
local PLDMacroConfig = {}

---============================================================================
---============================================================================
--- SOLO CONFIGURATION (Playing PLD alone)
---============================================================================
---============================================================================

--- Default macro book (used if subjob not configured)
PLDMacroConfig.default = {book = 15, page = 1}

--- PLD macro book assignments by subjob
--- Format: ['SUBJOB'] = { book = NUMBER, page = NUMBER }
PLDMacroConfig.solo = {
    ['RUN'] = {book = 15, page = 1}, -- PLD/RUN
    ['BLU'] = {book = 18, page = 1}, -- PLD/BLU
    ['RDM'] = {book = 20, page = 1}, -- PLD/WAR
    -- Default fallback
    ['default'] = {book = 15, page = 1}
}

---============================================================================
--- DUAL-BOXING CONFIGURATION (Playing PLD + Alt)
---============================================================================
--- Structure: dualbox[ALT_JOB][SUBJOB] = {book, page}
--- Example: dualbox['GEO']['SAM'] = PLD/SAM macros optimized for playing with GEO alt
---
--- Uncomment and customize sections below as needed:
---============================================================================

PLDMacroConfig.dualbox = {
    -- Kaories playing RDM
    ['RDM'] = {
        ['RUN'] = {book = 15, page = 1}, -- PLD/RUN + RDM alt
        ['BLU'] = {book = 18, page = 1}, -- PLD/BLU + RDM alt
    },

    -- Kaories playing COR
    ['COR'] = {
        ['RUN'] = {book = 17, page = 1}, -- PLD/RUN + COR alt
        ['BLU'] = {book = 20, page = 1}, -- PLD/BLU + COR alt
    },

    -- Kaories playing GEO
    ['GEO'] = {
        ['RUN'] = {book = 16, page = 1}, -- PLD/RUN + GEO alt
        ['BLU'] = {book = 19, page = 1}, -- PLD/BLU + GEO alt
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return PLDMacroConfig

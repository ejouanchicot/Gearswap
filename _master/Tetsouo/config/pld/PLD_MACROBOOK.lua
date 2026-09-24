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
---   • Book numbers: 1-40 (FFXI macro book slots)
---   • Page numbers: 1-10 (pages within each book)
---
--- @file    Tetsouo/config/pld/PLD_MACROBOOK.lua
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
PLDMacroConfig.default = {book = 1, page = 1}

--- PLD macro book assignments by subjob
--- Format: ['SUBJOB'] = { book = NUMBER, page = NUMBER }
PLDMacroConfig.solo = {
    ['RUN'] = {book = 1, page = 1}, -- PLD/RUN
    ['BLU'] = {book = 3, page = 1}, -- PLD/BLU
    ['RDM'] = {book = 2, page = 1}, -- PLD/RDM
    ['SCH'] = {book = 4, page = 5}, -- PLD/SCH
}

---============================================================================
--- DUAL-BOXING CONFIGURATION (Playing PLD + Alt)
---============================================================================
--- Structure: dualbox[ALT_JOB][SUBJOB] = {book, page}
--- Example: dualbox['GEO']['SAM'] = PLD/SAM macros optimized for playing with GEO alt
---
--- Used while the alt is online on ALT_JOB; otherwise the solo table applies.
---============================================================================

PLDMacroConfig.dualbox = {
    -- Kaories playing RDM
    ['RDM'] = {
        ['RUN'] = {book = 1, page = 1}, -- PLD/RUN + RDM alt
        ['RDM'] = {book = 2, page = 1}, -- PLD/RDM + RDM alt
        ['BLU'] = {book = 3, page = 1}, -- PLD/BLU + RDM alt
    },

    -- Kaories playing COR
    ['COR'] = {
        ['RUN'] = {book = 1, page = 4}, -- PLD/RUN + COR alt
        ['BLU'] = {book = 3, page = 4}, -- PLD/BLU + COR alt
    },

    -- Kaories playing GEO
    ['GEO'] = {
        ['RUN'] = {book = 1, page = 8}, -- PLD/RUN + GEO alt
        ['BLU'] = {book = 2, page = 8}, -- PLD/BLU + GEO alt
        ['SCH'] = {book = 4, page = 5}, -- PLD/SCH + GEO alt
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return PLDMacroConfig

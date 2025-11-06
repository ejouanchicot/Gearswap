---============================================================================
--- DRK Macro Book Configuration - Dual-Boxing Support
---============================================================================
--- User-configurable macro book and page assignments for Dark Knight subjobs.
---
--- Features:
---   • Solo configurations: Playing DRK alone
---   • Dual-boxing configurations: Playing DRK with an alt character
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
--- @file    config/drk/DRK_MACROBOOK.lua
--- @author  Kaories
--- @version 1.0.0
--- @date    Created: 2025-10-23
---============================================================================
local DRKMacroConfig = {}

---============================================================================
--- SOLO CONFIGURATION (Playing DRK alone)
---============================================================================

--- Default macro book (used if subjob not configured)
DRKMacroConfig.default = {book = 1, page = 1}

--- DRK macro book assignments by subjob
--- Format: ['SUBJOB'] = { book = NUMBER, page = NUMBER }
DRKMacroConfig.solo = {
    ['SAM'] = {book = 1, page = 1}, -- DRK/SAM
    ['WAR'] = {book = 1, page = 2}, -- DRK/WAR
    ['NIN'] = {book = 1, page = 3}, -- DRK/NIN
    ['DNC'] = {book = 1, page = 4}, -- DRK/DNC
    -- Default fallback
    ['default'] = {book = 1, page = 1}
}

---============================================================================
--- DUAL-BOXING CONFIGURATION (Playing DRK + Alt)
---============================================================================
--- Structure: dualbox[ALT_JOB][SUBJOB] = {book, page}
--- Example: dualbox['GEO']['SAM'] = DRK/SAM macros optimized for playing with GEO alt
---
--- Uncomment and customize sections below as needed:
---============================================================================

DRKMacroConfig.dualbox = {
    -- Alt playing RDM
    ['RDM'] = {
        ['SAM'] = {book = 2, page = 1}, -- DRK/SAM + RDM alt
        ['WAR'] = {book = 2, page = 2}, -- DRK/WAR + RDM alt
    },

    -- Alt playing COR
    ['COR'] = {
        ['SAM'] = {book = 3, page = 1}, -- DRK/SAM + COR alt
        ['WAR'] = {book = 3, page = 2}, -- DRK/WAR + COR alt
    },

    -- Alt playing GEO
    ['GEO'] = {
        ['SAM'] = {book = 4, page = 1}, -- DRK/SAM + GEO alt
        ['WAR'] = {book = 4, page = 2}, -- DRK/WAR + GEO alt
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DRKMacroConfig

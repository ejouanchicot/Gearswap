---============================================================================
--- DNC Macro Book Configuration - Dual-Boxing Support
---============================================================================
--- User-configurable macro book and page assignments for Dancer subjobs.
---
--- Features:
---   • Solo configurations: Playing DNC alone
---   • Dual-boxing configurations: Playing DNC with an alt character
---   • Subjob-specific macro book and page assignments
---   • Default fallback for unconfigured subjobs
---   • Easy customization without modifying core job files
---
--- Usage:
---   • Edit the book numbers and pages to match your in-game macro setup
---   • Use the 'default' entry as fallback for subjobs without specific config
---   • Book range: 1-20 | Page range: 1-10
---
--- @file    config/dnc/DNC_MACROBOOK.lua
--- @author  Kaories
--- @version 2.0 - Dual-boxing support
--- @date    Created: 2025-10-04 | Updated: 2025-10-22
---============================================================================

local DNCMacroConfig = {}

---============================================================================
---============================================================================
--- SOLO CONFIGURATION (Playing DNC alone)
---============================================================================
---============================================================================

-- Default macro book (used if subjob not configured)
DNCMacroConfig.default = {book = 4, page = 1}

-- DNC macro book assignments by subjob
-- Format: ['SUBJOB'] = { book = NUMBER, page = NUMBER }
DNCMacroConfig.solo = {
    ['NIN'] = {book = 4, page = 1}, -- DNC/NIN
    ['DRG'] = {book = 4, page = 1}, -- DNC/DRG
    ['SAM'] = {book = 4, page = 1}, -- DNC/SAM
    ['WAR'] = {book = 5, page = 1}, -- DNC/WAR
    ['THF'] = {book = 4, page = 1}, -- DNC/THF
    -- Default fallback
    ['default'] = {book = 4, page = 1}
}

---============================================================================
--- DUAL-BOXING CONFIGURATION (Playing DNC + Alt)
---============================================================================
--- Structure: dualbox[ALT_JOB][SUBJOB] = {book, page}
--- Example: dualbox['GEO']['SAM'] = DNC/SAM macros optimized for playing with GEO alt
---
--- Uncomment and customize sections below as needed:
---============================================================================

DNCMacroConfig.dualbox = {
    -- DNC + GEO alt
    ['GEO'] = {
        ['DRG'] = {book = 4, page = 1}, -- DNC/DRG + GEO
        ['WAR'] = {book = 4, page = 1}  -- DNC/WAR + GEO
    },
    -- DNC + COR alt
    ['COR'] = {
        ['DRG'] = {book = 6, page = 1}, -- DNC/DRG + COR
        ['WAR'] = {book = 6, page = 1}  -- DNC/WAR + COR
    },
    -- DNC + RDM alt
    ['RDM'] = {
        ['DRG'] = {book = 5, page = 1}, -- DNC/DRG + RUN
        ['WAR'] = {book = 5, page = 1}  -- DNC/WAR + RUN
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DNCMacroConfig

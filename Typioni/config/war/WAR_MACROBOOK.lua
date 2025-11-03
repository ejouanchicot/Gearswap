---============================================================================
--- WAR Macro Book Configuration - Dual-Boxing Support
---============================================================================
--- User-configurable macro book and page assignments for Warrior subjobs.
--- Supports both solo play and dual-boxing configurations.
---
--- Features:
---   • Solo configurations: Playing WAR alone
---   • Dual-boxing configurations: Playing WAR with an alt character
---   • Subjob-specific macro book and page assignments
---   • Default fallback for unconfigured subjobs
---   • Easy customization without modifying core job files
---
--- Structure:
---   • solo = { [subjob] = {book, page} }
---   • dualbox = { [alt_job] = { [subjob] = {book, page} } }
---
--- Usage:
---   • Edit the book numbers and pages to match your in-game macro setup
---   • Use the 'default' entry as fallback for subjobs without specific config
---   • Book range: 1-20 | Page range: 1-10
---
--- @file    config/war/WAR_MACROBOOK.lua
--- @author  Typioni
--- @version 2.0 - Dual-boxing support
--- @date    Created: 2025-10-02 | Updated: 2025-10-22
---============================================================================

local WARMacroConfig = {}

---============================================================================
--- SOLO CONFIGURATION (Playing WAR alone)
---============================================================================

WARMacroConfig.solo = {
    -- Primary subjobs
    ['SAM'] = { book = 22, page = 1 },  -- WAR/SAM solo
    ['DRG'] = { book = 25, page = 1 },  -- WAR/DRG solo
    ['DNC'] = { book = 28, page = 1 },  -- WAR/DNC solo

    -- Additional subjobs
    ['MNK'] = { book = 22, page = 1 },  -- WAR/MNK solo
    ['THF'] = { book = 22, page = 1 },  -- WAR/THF solo
    ['NIN'] = { book = 22, page = 1 },  -- WAR/NIN solo
    ['WHM'] = { book = 25, page = 1 },  -- WAR/WHM solo
    ['RDM'] = { book = 28, page = 1 },  -- WAR/RDM solo

    -- Default fallback
    ['default'] = { book = 22, page = 1 }
}

---============================================================================
--- DUAL-BOXING CONFIGURATION (Playing WAR + Alt)
---============================================================================
--- Structure: dualbox[ALT_JOB][SUBJOB] = {book, page}
--- Example: dualbox['GEO']['SAM'] = WAR/SAM macros optimized for playing with GEO alt
---============================================================================

WARMacroConfig.dualbox = {
    ---========================================================================
    --- WAR + RDM (Kaories Red Mage)
    ---========================================================================
    ['RDM'] = {
        ['SAM'] = { book = 22, page = 1 },  -- WAR/SAM + RDM alt
        ['DRG'] = { book = 25, page = 1 },  -- WAR/DRG + RDM alt
        ['DNC'] = { book = 28, page = 1 },  -- WAR/DNC + RDM alt
    },

    ---========================================================================
    --- WAR + GEO (Kaories Geomancer)
    ---========================================================================
    ['GEO'] = {
        ['SAM'] = { book = 23, page = 1 },  -- WAR/SAM + GEO alt (with Indi/Geo buff macros)
        ['DRG'] = { book = 26, page = 1 },  -- WAR/DRG + GEO alt
        ['DNC'] = { book = 29, page = 1 },  -- WAR/DNC + GEO alt
    },

    ---========================================================================
    --- WAR + COR (Kaories Corsair)
    ---========================================================================
    ['COR'] = {
        ['SAM'] = { book = 24, page = 1 },  -- WAR/SAM + COR alt (with roll request macros)
        ['DRG'] = { book = 27, page = 1 },  -- WAR/DRG + COR alt
        ['DNC'] = { book = 30, page = 1 },  -- WAR/DNC + COR alt
    },

    ---========================================================================
    --- Add more alt jobs as needed
    ---========================================================================
    -- ['RDM'] = {
    --     ['SAM'] = { book = 29, page = 1 },
    --     ['DRG'] = { book = 29, page = 2 },
    -- },
}

---============================================================================
--- DEFAULT FALLBACK
---============================================================================

WARMacroConfig.default = { book = 22, page = 1 }

---============================================================================
--- MODULE EXPORT
---============================================================================

return WARMacroConfig

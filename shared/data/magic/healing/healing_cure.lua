---============================================================================
--- Healing Magic Database - Cure Spells Module
---============================================================================
--- Single-target healing spells (Cure I-VI + Full Cure)
---
--- @file healing_cure.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
---
--- NOTES:
--- - Cure I-IV: Available to WHM, RDM, PLD, SCH
--- - Cure V-VI: WHM only
--- - Full Cure: WHM 1200 Job Point Gift (level 99 base)
--- - Enhanced by Afflatus Solace (WHM job trait)
--- - All cure spells use Light element
---============================================================================

local healing_cure = {}

healing_cure.spells = {
    ---========================================================================
    --- CURE I-IV (Multi-Job Access)
    ---========================================================================

    ["Cure"] = {
        description             = "Restores HP.",
        category                = "Healing",
        element                 = "Light",
        magic_type              = "White",
        tier                    = "I",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        WHM                     = 1,
        RDM                     = 3,
        PLD                     = 5,
        SCH                     = 5,
    },

    ["Cure II"] = {
        description             = "Restores HP.",
        category                = "Healing",
        element                 = "Light",
        magic_type              = "White",
        tier                    = "II",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        WHM                     = 11,
        RDM                     = 14,
        PLD                     = 17,
        SCH                     = 17,
    },

    ["Cure III"] = {
        description             = "Restores HP.",
        category                = "Healing",
        element                 = "Light",
        magic_type              = "White",
        tier                    = "III",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        WHM                     = 21,
        RDM                     = 26,
        PLD                     = 30,
        SCH                     = 30,
    },

    ["Cure IV"] = {
        description             = "Restores HP.",
        category                = "Healing",
        element                 = "Light",
        magic_type              = "White",
        tier                    = "IV",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        WHM                     = 41,
        RDM                     = 48,
        PLD                     = 55,
        SCH                     = 55,
    },

    ---========================================================================
    --- CURE V-VI (WHM Only)
    ---========================================================================

    ["Cure V"] = {
        description             = "Restores HP.",
        category                = "Healing",
        element                 = "Light",
        magic_type              = "White",
        tier                    = "V",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        WHM                     = 61,
    },

    ["Cure VI"] = {
        description             = "Restores HP.",
        category                = "Healing",
        element                 = "Light",
        magic_type              = "White",
        tier                    = "VI",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        WHM                     = 80,
    },

    ---========================================================================
    --- FULL CURE (WHM Job Point Gift)
    ---========================================================================

    ["Full Cure"] = {
        description             = "Full heal, cure ailments, costs all MP",
        category                = "Healing",
        element                 = "Light",
        magic_type              = "White",
        tier                    = nil,
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        WHM                     = 99,  -- NOT learned at level 99 - requires 1200 Job Points Gift
        notes                   = "REQUIRES: 1200 Job Points (Gift: Full Cure) - NOT learned at level 99. Consumes all MP. Afflatus Solace: Grants Stoneskin effect."
    },
}

return healing_cure

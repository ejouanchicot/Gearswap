---============================================================================
--- Elemental Magic Database - Single-Target Spells Module
---============================================================================
--- Single-target elemental spells (tier I-VI)
---
--- @file elemental_single.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @verified bg-wiki.com (2025-10-30) - ALL 36 spells individually verified
---
--- NOTES:
--- - Tier I-III: Available to BLM, SCH, RDM, GEO, DRK
--- - Tier IV: BLM, SCH (Addendum: Black), RDM, GEO
--- - Tier V: BLM, SCH (Addendum: Black), RDM (JP Gift), GEO (JP Gift)
--- - Tier VI: BLM only (Job Point Gift level 100)
--- - Six elements: Fire, Ice (Blizzard), Wind (Aero), Earth (Stone), Thunder, Water
---============================================================================

local elemental_single = {}

elemental_single.spells = {
    ---========================================================================
    --- STONE (Earth Element)
    ---========================================================================

    ["Stone"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Earth",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 1,
        SCH                     = 4,
        RDM                     = 4,
        GEO                     = 4,
        DRK                     = 5,
    },

    ["Stone II"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Earth",
        magic_type              = "Black",
        tier                    = "II",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 26,
        SCH                     = 30,
        GEO                     = 34,
        RDM                     = 35,
        DRK                     = 42,
    },

    ["Stone III"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Earth",
        magic_type              = "Black",
        tier                    = "III",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 51,
        SCH                     = 54,
        GEO                     = 58,
        RDM                     = 65,
        DRK                     = 76,
    },

    ["Stone IV"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Earth",
        magic_type              = "Black",
        tier                    = "IV",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 68,
        SCH                     = 70,  -- Requires Addendum: Black
        GEO                     = 76,
        RDM                     = 77,
        notes                   = "SCH requires Addendum: Black."
    },

    ["Stone V"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Earth",
        magic_type              = "Black",
        tier                    = "V",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 77,
        SCH                     = 79,  -- Requires Addendum: Black
        RDM                     = 100,  -- Job Point Gift
        GEO                     = 100,  -- Job Point Gift
        notes                   = "SCH requires Addendum: Black. RDM/GEO require Job Point Gift."
    },

    ["Stone VI"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Earth",
        magic_type              = "Black",
        tier                    = "VI",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 100,  -- NOT learned at level 100 - requires Job Point Gift
        notes                   = "REQUIRES: Job Point Gift (level 100) - NOT learned at level 100."
    },

    ---========================================================================
    --- WATER (Water Element)
    ---========================================================================

    ["Water"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Water",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 5,
        SCH                     = 8,
        RDM                     = 9,
        GEO                     = 9,
        DRK                     = 11,
    },

    ["Water II"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Water",
        magic_type              = "Black",
        tier                    = "II",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 30,
        SCH                     = 34,
        GEO                     = 38,
        RDM                     = 40,
        DRK                     = 48,
    },

    ["Water III"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Water",
        magic_type              = "Black",
        tier                    = "III",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 55,
        SCH                     = 57,
        GEO                     = 61,
        RDM                     = 67,
        DRK                     = 80,
    },

    ["Water IV"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Water",
        magic_type              = "Black",
        tier                    = "IV",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 70,
        SCH                     = 71,  -- Requires Addendum: Black
        GEO                     = 79,
        RDM                     = 80,
        notes                   = "SCH requires Addendum: Black."
    },

    ["Water V"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Water",
        magic_type              = "Black",
        tier                    = "V",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 80,
        SCH                     = 83,  -- Requires Addendum: Black
        RDM                     = 100,  -- Job Point Gift
        GEO                     = 100,  -- Job Point Gift
        notes                   = "SCH requires Addendum: Black. RDM/GEO require Job Point Gift."
    },

    ["Water VI"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Water",
        magic_type              = "Black",
        tier                    = "VI",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 100,  -- NOT learned at level 100 - requires Job Point Gift
        notes                   = "REQUIRES: Job Point Gift (level 100) - NOT learned at level 100."
    },

    ---========================================================================
    --- AERO (Wind Element)
    ---========================================================================

    ["Aero"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Wind",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 9,
        SCH                     = 12,
        RDM                     = 14,
        GEO                     = 14,
        DRK                     = 17,
    },

    ["Aero II"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Wind",
        magic_type              = "Black",
        tier                    = "II",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 34,
        SCH                     = 38,
        GEO                     = 42,
        RDM                     = 45,
        DRK                     = 54,
    },

    ["Aero III"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Wind",
        magic_type              = "Black",
        tier                    = "III",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 59,
        SCH                     = 60,
        GEO                     = 64,
        RDM                     = 69,
        DRK                     = 84,
    },

    ["Aero IV"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Wind",
        magic_type              = "Black",
        tier                    = "IV",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 72,
        SCH                     = 72,  -- Requires Addendum: Black
        GEO                     = 82,
        RDM                     = 83,
        notes                   = "SCH requires Addendum: Black."
    },

    ["Aero V"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Wind",
        magic_type              = "Black",
        tier                    = "V",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 83,
        SCH                     = 87,  -- Requires Addendum: Black
        RDM                     = 100,  -- Job Point Gift
        GEO                     = 100,  -- Job Point Gift
        notes                   = "SCH requires Addendum: Black. RDM/GEO require Job Point Gift."
    },

    ["Aero VI"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Wind",
        magic_type              = "Black",
        tier                    = "VI",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 100,  -- NOT learned at level 100 - requires Job Point Gift
        notes                   = "REQUIRES: Job Point Gift (level 100) - NOT learned at level 100."
    },

    ---========================================================================
    --- FIRE (Fire Element)
    ---========================================================================

    ["Fire"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Fire",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 13,
        SCH                     = 16,
        RDM                     = 19,
        GEO                     = 19,
        DRK                     = 23,
    },

    ["Fire II"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Fire",
        magic_type              = "Black",
        tier                    = "II",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 38,
        SCH                     = 42,
        GEO                     = 46,
        RDM                     = 50,
        DRK                     = 60,
    },

    ["Fire III"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Fire",
        magic_type              = "Black",
        tier                    = "III",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 62,
        SCH                     = 63,
        GEO                     = 67,
        RDM                     = 71,
        DRK                     = 88,
    },

    ["Fire IV"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Fire",
        magic_type              = "Black",
        tier                    = "IV",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 73,
        SCH                     = 73,  -- Requires Addendum: Black
        GEO                     = 85,
        RDM                     = 86,
        notes                   = "SCH requires Addendum: Black."
    },

    ["Fire V"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Fire",
        magic_type              = "Black",
        tier                    = "V",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 86,
        SCH                     = 91,  -- Requires Addendum: Black
        RDM                     = 100,  -- Job Point Gift
        GEO                     = 100,  -- Job Point Gift
        notes                   = "SCH requires Addendum: Black. RDM/GEO require Job Point Gift."
    },

    ["Fire VI"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Fire",
        magic_type              = "Black",
        tier                    = "VI",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 100,  -- NOT learned at level 100 - requires Job Point Gift
        notes                   = "REQUIRES: Job Point Gift (level 100) - NOT learned at level 100."
    },

    ---========================================================================
    --- BLIZZARD (Ice Element)
    ---========================================================================

    ["Blizzard"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Ice",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 17,
        SCH                     = 20,
        RDM                     = 24,
        GEO                     = 24,
        DRK                     = 29,
    },

    ["Blizzard II"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Ice",
        magic_type              = "Black",
        tier                    = "II",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 42,
        SCH                     = 46,
        GEO                     = 50,
        RDM                     = 55,
        DRK                     = 66,
    },

    ["Blizzard III"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Ice",
        magic_type              = "Black",
        tier                    = "III",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 64,
        SCH                     = 66,
        GEO                     = 70,
        RDM                     = 73,
        DRK                     = 92,
    },

    ["Blizzard IV"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Ice",
        magic_type              = "Black",
        tier                    = "IV",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 74,
        SCH                     = 74,  -- Requires Addendum: Black
        GEO                     = 88,
        RDM                     = 89,
        notes                   = "SCH requires Addendum: Black."
    },

    ["Blizzard V"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Ice",
        magic_type              = "Black",
        tier                    = "V",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 89,
        SCH                     = 95,  -- Requires Addendum: Black
        RDM                     = 100,  -- Job Point Gift
        GEO                     = 100,  -- Job Point Gift
        notes                   = "SCH requires Addendum: Black. RDM/GEO require Job Point Gift."
    },

    ["Blizzard VI"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Ice",
        magic_type              = "Black",
        tier                    = "VI",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 100,  -- NOT learned at level 100 - requires Job Point Gift
        notes                   = "REQUIRES: Job Point Gift (level 100) - NOT learned at level 100."
    },

    ---========================================================================
    --- THUNDER (Thunder Element)
    ---========================================================================

    ["Thunder"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Thunder",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 21,
        SCH                     = 24,
        RDM                     = 29,
        GEO                     = 29,
        DRK                     = 35,
    },

    ["Thunder II"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Thunder",
        magic_type              = "Black",
        tier                    = "II",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 46,
        SCH                     = 51,
        GEO                     = 54,
        RDM                     = 60,
        DRK                     = 72,
    },

    ["Thunder III"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Thunder",
        magic_type              = "Black",
        tier                    = "III",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 66,
        SCH                     = 69,
        GEO                     = 73,
        RDM                     = 75,
        DRK                     = 96,
    },

    ["Thunder IV"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Thunder",
        magic_type              = "Black",
        tier                    = "IV",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 75,
        SCH                     = 75,  -- Requires Addendum: Black
        GEO                     = 91,
        RDM                     = 92,
        notes                   = "SCH requires Addendum: Black."
    },

    ["Thunder V"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Thunder",
        magic_type              = "Black",
        tier                    = "V",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 92,
        SCH                     = 99,  -- Requires Addendum: Black
        RDM                     = 100,  -- Job Point Gift
        GEO                     = 100,  -- Job Point Gift
        notes                   = "SCH requires Addendum: Black. RDM/GEO require Job Point Gift."
    },

    ["Thunder VI"] = {
        description             = "Deals damage to an enemy.",
        category                = "Elemental",
        element                 = "Thunder",
        magic_type              = "Black",
        tier                    = "VI",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 100,  -- NOT learned at level 100 - requires Job Point Gift
        notes                   = "REQUIRES: Job Point Gift (level 100) - NOT learned at level 100."
    },
}

return elemental_single

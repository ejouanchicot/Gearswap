---============================================================================
--- Healing Magic Database - Raise/Reraise Spells Module
---============================================================================
--- Resurrection and reraise spells (Raise I-III, Reraise I-IV, Arise)
---
--- @file healing_raise.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30
---
--- NOTES:
--- - Raise I-III: Resurrects KO'd target (WHM, SCH, RDM, PLD)
--- - Reraise I-IV: Self-buff for auto-resurrection (WHM, SCH)
--- - Arise: Resurrects target + grants Reraise III effect (WHM only)
--- - SCH requires Addendum: White for all raise spells
--- - Reraise IV requires 100 Job Points (Gift)
--- - All spells use Light element
---============================================================================

local healing_raise = {}

healing_raise.spells = {
    ---========================================================================
    --- RAISE I-III (Resurrection - Single Target)
    ---========================================================================

    ["Raise"] = {
        description = "Revives from KO.",
        category = "Healing",
        element = "Light",
        magic_type = "White",
        tier = "I",
        type = "single",
        main_job_only = false,
        subjob_master_only = false,
        WHM = 25,
        SCH = 35, -- Requires Addendum: White
        RDM = 38,
        PLD = 50,
        notes = "SCH requires Addendum: White."
    },

    ["Raise II"] = {
        description = "Revives from KO.",
        category = "Healing",
        element = "Light",
        magic_type = "White",
        tier = "II",
        type = "single",
        main_job_only = false,
        subjob_master_only = false,
        WHM = 56,
        SCH = 70, -- Requires Addendum: White
        RDM = 95,
        notes = "SCH requires Addendum: White."
    },

    ["Raise III"] = {
        description = "Revives from KO.",
        category = "Healing",
        element = "Light",
        magic_type = "White",
        tier = "III",
        type = "single",
        main_job_only = false,
        subjob_master_only = false,
        WHM = 70,
        SCH = 92, -- Requires Addendum: White
        notes = "SCH requires Addendum: White."
    },

    ---========================================================================
    --- RERAISE I-IV (Auto-Resurrection Buff - Self)
    ---========================================================================

    ["Reraise"] = {
        description = "Grants you the effect of Raise when you are KO'd.",
        category = "Healing",
        element = "Light",
        magic_type = "White",
        tier = "I",
        type = "self",
        main_job_only = false,
        subjob_master_only = false,
        WHM = 25,
        SCH = 35, -- Requires Addendum: White
        notes = "Self-buff. SCH requires Addendum: White."
    },

    ["Reraise II"] = {
        description = "Grants you the effect of Raise II when you are KO'd.",
        category = "Healing",
        element = "Light",
        magic_type = "White",
        tier = "II",
        type = "self",
        main_job_only = false,
        subjob_master_only = false,
        WHM = 56,
        SCH = 70, -- Requires Addendum: White
        notes = "Self-buff. SCH requires Addendum: White."
    },

    ["Reraise III"] = {
        description = "Grants you the effect of Raise III when you are KO'd.",
        category = "Healing",
        element = "Light",
        magic_type = "White",
        tier = "III",
        type = "self",
        main_job_only = false,
        subjob_master_only = false,
        WHM = 70,
        SCH = 92, -- Requires Addendum: White
        notes = "Self-buff. SCH requires Addendum: White."
    },

    ["Reraise IV"] = {
        description = "Grants you the effect of Raise with a decreased weakness duration when you are KO'd.",
        category = "Healing",
        element = "Light",
        magic_type = "White",
        tier = "IV",
        type = "self",
        main_job_only = true,
        subjob_master_only = false,
        WHM = 99,  -- NOT learned at level 99 - requires 100 Job Points Gift
        notes = "REQUIRES: 100 Job Points (Gift: Reraise IV) - NOT learned at level 99. Self-buff only."
    },

    ---========================================================================
    --- ARISE (Resurrection + Reraise Combo)
    ---========================================================================

    ["Arise"] = {
        description = "Revives from KO, bestows a Reraise effect.",
        category = "Healing",
        element = "Light",
        magic_type = "White",
        tier = nil,
        type = "single",
        main_job_only = true,
        subjob_master_only = false,
        WHM = 99,
        notes = "Resurrects target with Reraise III effect. WHM only."
    },
}

return healing_raise

---============================================================================
--- Healing Magic Database - AoE Cure Spells Module
---============================================================================
--- Area-of-effect healing spells (Curaga I-V + Cura I-III)
---
--- @file healing_curaga.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30
---
--- NOTES:
--- - Curaga I-V: Party AoE (15' radius), WHM only
--- - Cura I-III: Self AoE (20' radius), WHM only
--- - Cura spells enhanced by Afflatus Misery (WHM job trait)
--- - All spells use Light element
---============================================================================

local healing_curaga = {}

healing_curaga.spells = {
    ---========================================================================
    --- CURAGA I-V (Party AoE - 15' Radius)
    ---========================================================================

    ["Curaga"] = {
        description = "Restores HP of all party members.",
        category = "Healing",
        element = "Light",
        magic_type = "White",
        tier = "I",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        WHM = 16,
        notes = "15 yalm radius. Party members only."
    },

    ["Curaga II"] = {
        description = "Restores HP of all party members.",
        category = "Healing",
        element = "Light",
        magic_type = "White",
        tier = "II",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        WHM = 31,
        notes = "15 yalm radius. Party members only."
    },

    ["Curaga III"] = {
        description = "Restores HP of all party members.",
        category = "Healing",
        element = "Light",
        magic_type = "White",
        tier = "III",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        WHM = 51,
        notes = "15 yalm radius. Party members only."
    },

    ["Curaga IV"] = {
        description = "Restores HP of all party members.",
        category = "Healing",
        element = "Light",
        magic_type = "White",
        tier = "IV",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        WHM = 71,
        notes = "15 yalm radius. Party members only."
    },

    ["Curaga V"] = {
        description = "Restores HP of all party members.",
        category = "Healing",
        element = "Light",
        magic_type = "White",
        tier = "V",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        WHM = 91,
        notes = "15 yalm radius. Party members only."
    },

    ---========================================================================
    --- CURA I-III (Self AoE - 20' Radius)
    ---========================================================================

    ["Cura"] = {
        description = "Restores HP.",
        category = "Healing",
        element = "Light",
        magic_type = "White",
        tier = "I",
        type = "self_aoe",
        main_job_only = true,
        subjob_master_only = false,
        WHM = 40,
        notes = "20 yalm radius. Casts on self. Enhanced by Afflatus Misery."
    },

    ["Cura II"] = {
        description = "Restores HP for party members within area of effect. Afflatus Misery: Raises healing potency.",
        category = "Healing",
        element = "Light",
        magic_type = "White",
        tier = "II",
        type = "self_aoe",
        main_job_only = true,
        subjob_master_only = false,
        WHM = 83,
        notes = "20 yalm radius. Casts on self. Enhanced by Afflatus Misery."
    },

    ["Cura III"] = {
        description = "Restores HP for party members within area of effect. Afflatus Misery: Raises healing potency.",
        category = "Healing",
        element = "Light",
        magic_type = "White",
        tier = "III",
        type = "self_aoe",
        main_job_only = true,
        subjob_master_only = false,
        WHM = 96,
        notes = "20 yalm radius. Casts on self. Enhanced by Afflatus Misery."
    },
}

return healing_curaga

---============================================================================
--- Elemental Magic - Helix Spells (SCH-Unique DoT Spells)
---============================================================================
--- Elemental damage-over-time spells that lower enemy stats.
--- SCH-UNIQUE - Only Scholar can cast Helix spells.
---
--- @file helix.lua
--- @author Tetsouo
--- @version 2.1 - Improved alignment - Organized by magic type
--- @date Created: 2025-10-31 | Updated: 2025-11-06 | Updated: 2025-10-31
--- @verified bg-wiki.com (2025-10-31)
---
--- NOTES:
--- - Helix spells deal elemental DoT damage affected by weather
--- - Additional effect: Lowers enemy stats based on element
--- - Tier I: Learned through normal leveling
--- - Tier II: More potent version, higher damage
--- - All Helix spells are SCH main job only
---============================================================================

local helix = {}

helix.spells = {
    -- Fire Helix
    ["Pyrohelix"] = {
        description             = "Deals fire DoT (weather+).",
        category                = "Helix",
        element                 = "Fire",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "I",
        stat_down               = "INT",
        SCH                     = 20,
        main_job_only           = true,
        notes                   = "Fire DoT. Lowers INT. Weather/day bonus. SCH-only.",
    },
    ["Pyrohelix II"] = {
        description             = "Deals fire DoT (weather+).",
        category                = "Helix",
        element                 = "Fire",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "II",
        stat_down               = "INT",
        SCH                     = 70,
        main_job_only           = true,
        notes                   = "Enhanced fire DoT. Lowers INT. Weather/day bonus. SCH-only.",
    },

    -- Ice Helix
    ["Cryohelix"] = {
        description             = "Deals ice DoT (weather+).",
        category                = "Helix",
        element                 = "Ice",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "I",
        stat_down               = "STR",
        SCH                     = 22,
        main_job_only           = true,
        notes                   = "Ice DoT. Lowers STR. Weather/day bonus. SCH-only.",
    },
    ["Cryohelix II"] = {
        description             = "Deals ice DoT (weather+).",
        category                = "Helix",
        element                 = "Ice",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "II",
        stat_down               = "STR",
        SCH                     = 72,
        main_job_only           = true,
        notes                   = "Enhanced ice DoT. Lowers STR. Weather/day bonus. SCH-only.",
    },

    -- Wind Helix
    ["Anemohelix"] = {
        description             = "Deals wind DoT (weather+).",
        category                = "Helix",
        element                 = "Wind",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "I",
        stat_down               = "VIT",
        SCH                     = 24,
        main_job_only           = true,
        notes                   = "Wind DoT. Lowers VIT. Weather/day bonus. SCH-only.",
    },
    ["Anemohelix II"] = {
        description             = "Deals wind DoT (weather+).",
        category                = "Helix",
        element                 = "Wind",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "II",
        stat_down               = "VIT",
        SCH                     = 74,
        main_job_only           = true,
        notes                   = "Enhanced wind DoT. Lowers VIT. Weather/day bonus. SCH-only.",
    },

    -- Earth Helix
    ["Geohelix"] = {
        description             = "Deals earth DoT (weather+).",
        category                = "Helix",
        element                 = "Earth",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "I",
        stat_down               = "AGI",
        SCH                     = 26,
        main_job_only           = true,
        notes                   = "Earth DoT. Lowers AGI. Weather/day bonus. SCH-only.",
    },
    ["Geohelix II"] = {
        description             = "Deals earth DoT (weather+).",
        category                = "Helix",
        element                 = "Earth",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "II",
        stat_down               = "AGI",
        SCH                     = 76,
        main_job_only           = true,
        notes                   = "Enhanced earth DoT. Lowers AGI. Weather/day bonus. SCH-only.",
    },

    -- Thunder Helix
    ["Ionohelix"] = {
        description             = "Deals thunder DoT (weather+).",
        category                = "Helix",
        element                 = "Thunder",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "I",
        stat_down               = "DEX",
        SCH                     = 28,
        main_job_only           = true,
        notes                   = "Thunder DoT. Lowers DEX. Weather/day bonus. SCH-only.",
    },
    ["Ionohelix II"] = {
        description             = "Deals thunder DoT (weather+).",
        category                = "Helix",
        element                 = "Thunder",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "II",
        stat_down               = "DEX",
        SCH                     = 78,
        main_job_only           = true,
        notes                   = "Enhanced thunder DoT. Lowers DEX. Weather/day bonus. SCH-only.",
    },

    -- Water Helix
    ["Hydrohelix"] = {
        description             = "Deals water DoT (weather+).",
        category                = "Helix",
        element                 = "Water",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "I",
        stat_down               = "MND",
        SCH                     = 30,
        main_job_only           = true,
        notes                   = "Water DoT. Lowers MND. Weather/day bonus. SCH-only.",
    },
    ["Hydrohelix II"] = {
        description             = "Deals water DoT (weather+).",
        category                = "Helix",
        element                 = "Water",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "II",
        stat_down               = "MND",
        SCH                     = 80,
        main_job_only           = true,
        notes                   = "Enhanced water DoT. Lowers MND. Weather/day bonus. SCH-only.",
    },

    -- Light Helix
    ["Luminohelix"] = {
        description             = "Deals light DoT (weather+).",
        category                = "Helix",
        element                 = "Light",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "I",
        stat_down               = "CHR",
        SCH                     = 32,
        main_job_only           = true,
        notes                   = "Light DoT. Lowers CHR. Weather/day bonus. SCH-only.",
    },
    ["Luminohelix II"] = {
        description             = "Deals light DoT (weather+).",
        category                = "Helix",
        element                 = "Light",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "II",
        stat_down               = "CHR",
        SCH                     = 82,
        main_job_only           = true,
        notes                   = "Enhanced light DoT. Lowers CHR. Weather/day bonus. SCH-only.",
    },

    -- Dark Helix
    ["Noctohelix"] = {
        description             = "Deals dark DoT (weather+).",
        category                = "Helix",
        element                 = "Dark",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "I",
        stat_down               = "CHR",
        SCH                     = 34,
        main_job_only           = true,
        notes                   = "Dark DoT. Lowers CHR. Weather/day bonus. SCH-only.",
    },
    ["Noctohelix II"] = {
        description             = "Deals dark DoT (weather+).",
        category                = "Helix",
        element                 = "Dark",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "II",
        stat_down               = "CHR",
        SCH                     = 84,
        main_job_only           = true,
        notes                   = "Enhanced dark DoT. Lowers CHR. Weather/day bonus. SCH-only.",
    },
}

return helix

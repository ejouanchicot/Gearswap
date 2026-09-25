---============================================================================
--- Elemental Magic - Helix Spells (SCH-Unique DoT Spells)
---============================================================================
--- Elemental damage-over-time spells that lower enemy stats.
--- SCH-UNIQUE - Only Scholar can cast Helix spells.
---
--- @file shared/data/magic/elemental/helix.lua
--- @author Tetsouo
--- @version 2.1 - Improved alignment - Organized by magic type
--- @date Created: 2025-10-31 | Updated: 2025-11-06
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
        SCH                     = 24,
        main_job_only           = true,
        notes                   = "Fire DoT. Day/weather bonus always applies. SCH-only.",
    },
    ["Pyrohelix II"] = {
        description             = "Deals fire DoT (weather+).",
        category                = "Helix",
        element                 = "Fire",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "II",
        SCH                     = 1200,
        main_job_only           = true,
        notes                   = "Stronger fire DoT. Day/weather bonus always applies. Requires 1200 SCH job points.",
    },

    -- Ice Helix
    ["Cryohelix"] = {
        description             = "Deals ice DoT (weather+).",
        category                = "Helix",
        element                 = "Ice",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "I",
        SCH                     = 26,
        main_job_only           = true,
        notes                   = "Ice DoT. Day/weather bonus always applies. SCH-only.",
    },
    ["Cryohelix II"] = {
        description             = "Deals ice DoT (weather+).",
        category                = "Helix",
        element                 = "Ice",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "II",
        SCH                     = 1200,
        main_job_only           = true,
        notes                   = "Stronger ice DoT. Day/weather bonus always applies. Requires 1200 SCH job points.",
    },

    -- Wind Helix
    ["Anemohelix"] = {
        description             = "Deals wind DoT (weather+).",
        category                = "Helix",
        element                 = "Wind",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "I",
        SCH                     = 22,
        main_job_only           = true,
        notes                   = "Wind DoT. Day/weather bonus always applies. SCH-only.",
    },
    ["Anemohelix II"] = {
        description             = "Deals wind DoT (weather+).",
        category                = "Helix",
        element                 = "Wind",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "II",
        SCH                     = 1200,
        main_job_only           = true,
        notes                   = "Stronger wind DoT. Day/weather bonus always applies. Requires 1200 SCH job points.",
    },

    -- Earth Helix
    ["Geohelix"] = {
        description             = "Deals earth DoT (weather+).",
        category                = "Helix",
        element                 = "Earth",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "I",
        SCH                     = 18,
        main_job_only           = true,
        notes                   = "Earth DoT. Day/weather bonus always applies. SCH-only.",
    },
    ["Geohelix II"] = {
        description             = "Deals earth DoT (weather+).",
        category                = "Helix",
        element                 = "Earth",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "II",
        SCH                     = 1200,
        main_job_only           = true,
        notes                   = "Stronger earth DoT. Day/weather bonus always applies. Requires 1200 SCH job points.",
    },

    -- Thunder Helix
    ["Ionohelix"] = {
        description             = "Deals thunder DoT (weather+).",
        category                = "Helix",
        element                 = "Thunder",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "I",
        SCH                     = 28,
        main_job_only           = true,
        notes                   = "Thunder DoT. Day/weather bonus always applies. SCH-only.",
    },
    ["Ionohelix II"] = {
        description             = "Deals thunder DoT (weather+).",
        category                = "Helix",
        element                 = "Thunder",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "II",
        SCH                     = 1200,
        main_job_only           = true,
        notes                   = "Stronger thunder DoT. Day/weather bonus always applies. Requires 1200 SCH job points.",
    },

    -- Water Helix
    ["Hydrohelix"] = {
        description             = "Deals water DoT (weather+).",
        category                = "Helix",
        element                 = "Water",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "I",
        SCH                     = 20,
        main_job_only           = true,
        notes                   = "Water DoT. Day/weather bonus always applies. SCH-only.",
    },
    ["Hydrohelix II"] = {
        description             = "Deals water DoT (weather+).",
        category                = "Helix",
        element                 = "Water",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "II",
        SCH                     = 1200,
        main_job_only           = true,
        notes                   = "Stronger water DoT. Day/weather bonus always applies. Requires 1200 SCH job points.",
    },

    -- Light Helix
    ["Luminohelix"] = {
        description             = "Deals light DoT (weather+).",
        category                = "Helix",
        element                 = "Light",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "I",
        SCH                     = 32,
        main_job_only           = true,
        notes                   = "Light DoT. Day/weather bonus always applies. SCH-only.",
    },
    ["Luminohelix II"] = {
        description             = "Deals light DoT (weather+).",
        category                = "Helix",
        element                 = "Light",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "II",
        SCH                     = 1200,
        main_job_only           = true,
        notes                   = "Stronger light DoT. Day/weather bonus always applies. Requires 1200 SCH job points.",
    },

    -- Dark Helix
    ["Noctohelix"] = {
        description             = "Deals dark DoT (weather+).",
        category                = "Helix",
        element                 = "Dark",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "I",
        SCH                     = 30,
        main_job_only           = true,
        notes                   = "Dark DoT. Day/weather bonus always applies. SCH-only.",
    },
    ["Noctohelix II"] = {
        description             = "Deals dark DoT (weather+).",
        category                = "Helix",
        element                 = "Dark",
        magic_type              = "Black",
        type                    = "single",
        tier                    = "II",
        SCH                     = 1200,
        main_job_only           = true,
        notes                   = "Stronger dark DoT. Day/weather bonus always applies. Requires 1200 SCH job points.",
    },
}

return helix

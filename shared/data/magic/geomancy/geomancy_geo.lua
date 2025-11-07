---============================================================================
--- GEOMANCY DATABASE - Geocolure Spells Module
---============================================================================
--- Luopan-based area effect spells (Geo-*) (28 total)
---
--- @file geomancy_geo.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06 | Updated: 2025-10-31
---============================================================================

local GEO_SPELLS = {}

GEO_SPELLS.spells = {

    --============================================================
    -- OFFENSIVE BUFFS (Party Support)
    --============================================================

    ["Geo-Acumen"] = {
        description             = "Boosts magic atk.",
        category                = "Geocolure",
        element                 = "Ice",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 50,
        main_job_only           = true,
        subjob_master_only      = true,
        notes                   = "Luopan field effect. Increases magic attack for party members within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-AGI"] = {
        description             = "Boosts agility.",
        category                = "Geocolure",
        element                 = "Wind",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 43,
        main_job_only           = true,
        notes                   = "Luopan field effect. Increases AGI for party members within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-Attunement"] = {
        description             = "Boosts magic acc.",
        category                = "Geocolure",
        element                 = "Light",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 20,
        main_job_only           = true,
        notes                   = "Luopan field effect. Increases magic accuracy for party members within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-Barrier"] = {
        description             = "Boosts defense.",
        category                = "Geocolure",
        element                 = "Earth",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 32,
        main_job_only           = true,
        notes                   = "Luopan field effect. Increases defense for party members within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-CHR"] = {
        description             = "Boosts charisma.",
        category                = "Geocolure",
        element                 = "Light",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 34,
        main_job_only           = true,
        notes                   = "Luopan field effect. Increases CHR for party members within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-DEX"] = {
        description             = "Boosts dexterity.",
        category                = "Geocolure",
        element                 = "Thunder",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 49,
        main_job_only           = true,
        notes                   = "Luopan field effect. Increases DEX for party members within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-Fend"] = {
        description             = "Boosts defense.",
        category                = "Geocolure",
        element                 = "Water",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 44,
        main_job_only           = true,
        notes                   = "Luopan field effect. Increases defense for party members within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-Focus"] = {
        description             = "Boosts magic acc.",
        category                = "Geocolure",
        element                 = "Dark",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 26,
        main_job_only           = true,
        notes                   = "Luopan field effect. Increases magic accuracy for party members within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-Fury"] = {
        description             = "Boosts attack.",
        category                = "Geocolure",
        element                 = "Fire",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 38,
        main_job_only           = true,
        notes                   = "Luopan field effect. Increases attack for party members within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-Haste"] = {
        description             = "Boosts attack speed.",
        category                = "Geocolure",
        element                 = "Wind",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 97,
        main_job_only           = true,
        notes                   = "Luopan field effect. Reduces melee delay for party members within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-INT"] = {
        description             = "Boosts intelligence.",
        category                = "Geocolure",
        element                 = "Ice",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 40,
        main_job_only           = true,
        notes                   = "Luopan field effect. Increases INT for party members within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-MND"] = {
        description             = "Boosts mind.",
        category                = "Geocolure",
        element                 = "Water",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 37,
        main_job_only           = true,
        notes                   = "Luopan field effect. Increases MND for party members within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-Poison"] = {
        description             = "Boosts poison dmg.",
        category                = "Geocolure",
        element                 = "Water",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 5,
        main_job_only           = true,
        notes                   = "Luopan field effect. Increases poison damage dealt by party members within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-Precision"] = {
        description             = "Boosts accuracy.",
        category                = "Geocolure",
        element                 = "Thunder",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 14,
        main_job_only           = true,
        notes                   = "Luopan field effect. Increases accuracy for party members within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-Refresh"] = {
        description             = "Restores MP.",
        category                = "Geocolure",
        element                 = "Light",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 34,
        main_job_only           = true,
        notes                   = "Luopan field effect. Restores MP over time for party members within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-Regen"] = {
        description             = "Restores HP.",
        category                = "Geocolure",
        element                 = "Light",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 19,
        main_job_only           = true,
        notes                   = "Luopan field effect. Restores HP over time for party members within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-STR"] = {
        description             = "Boosts strength.",
        category                = "Geocolure",
        element                 = "Fire",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 52,
        main_job_only           = true,
        subjob_master_only      = true,
        notes                   = "Luopan field effect. Increases STR for party members within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-VIT"] = {
        description             = "Boosts vitality.",
        category                = "Geocolure",
        element                 = "Earth",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 46,
        main_job_only           = true,
        notes                   = "Luopan field effect. Increases VIT for party members within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-Voidance"] = {
        description             = "Boosts evasion.",
        category                = "Geocolure",
        element                 = "Wind",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 8,
        main_job_only           = true,
        notes                   = "Luopan field effect. Increases evasion for party members within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    --============================================================
    -- DEBUFF FIELDS (Enemy Debuffs)
    --============================================================

    ["Geo-Fade"] = {
        description             = "Lowers attack.",
        category                = "Geocolure",
        element                 = "Fire",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 98,
        main_job_only           = true,
        notes                   = "Luopan field effect. Lowers attack for enemies within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-Frailty"] = {
        description             = "Lowers defense.",
        category                = "Geocolure",
        element                 = "Wind",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 80,
        main_job_only           = true,
        notes                   = "Luopan field effect. Lowers defense for enemies within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-Gravity"] = {
        description             = "Slows movement.",
        category                = "Geocolure",
        element                 = "Wind",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 92,
        main_job_only           = true,
        notes                   = "Luopan field effect. Reduces movement speed for enemies within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-Languor"] = {
        description             = "Slows foes.",
        category                = "Geocolure",
        element                 = "Dark",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 68,
        main_job_only           = true,
        notes                   = "Luopan field effect. Slows attack speed for enemies within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-Malaise"] = {
        description             = "Lowers magic def.",
        category                = "Geocolure",
        element                 = "Thunder",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 92,
        main_job_only           = true,
        notes                   = "Luopan field effect. Lowers magic defense for enemies within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-Paralysis"] = {
        description             = "Paralyzes foes.",
        category                = "Geocolure",
        element                 = "Ice",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 72,
        main_job_only           = true,
        notes                   = "Luopan field effect. Inflicts paralysis on enemies within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-Slip"] = {
        description             = "Lowers accuracy.",
        category                = "Geocolure",
        element                 = "Earth",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 62,
        main_job_only           = true,
        notes                   = "Luopan field effect. Lowers accuracy for enemies within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-Slow"] = {
        description             = "Slows foes.",
        category                = "Geocolure",
        element                 = "Earth",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 52,
        main_job_only           = true,
        subjob_master_only      = true,
        notes                   = "Luopan field effect. Slows attack speed for enemies within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-Torpor"] = {
        description             = "Lowers evasion.",
        category                = "Geocolure",
        element                 = "Ice",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 56,
        main_job_only           = true,
        subjob_master_only      = true,
        notes                   = "Luopan field effect. Lowers evasion for enemies within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-Vex"] = {
        description             = "Lowers magic def.",
        category                = "Geocolure",
        element                 = "Light",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 74,
        main_job_only           = true,
        notes                   = "Luopan field effect. Lowers magic defense for enemies within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

    ["Geo-Wilt"] = {
        description             = "Lowers attack.",
        category                = "Geocolure",
        element                 = "Water",
        magic_type              = "Geomancy",
        type                    = "aoe",
        GEO                     = 86,
        main_job_only           = true,
        notes                   = "Luopan field effect. Lowers attack for enemies within Luopan range. Duration: Luopan HP. GEO-only (main job).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return GEO_SPELLS

---============================================================================
--- GEOMANCY DATABASE - Indicolure Spells Module
---============================================================================
--- Self-centered aura spells (Indi-*) affecting nearby party members (30 total)
---
--- @file geomancy_indi.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-31 | Updated: 2025-10-31
---============================================================================

local INDI_SPELLS = {}

INDI_SPELLS.spells = {

    --============================================================
    -- OFFENSIVE BUFFS (Party Support)
    --============================================================

    ["Indi-Acumen"] = {
        description = "Boosts magic atk.",
        category = "Indicolure",
        element = "Ice",
        magic_type = "Geomancy",
        type = "self",
        GEO = 46,
        notes = "Self-centered aura. Increases magic attack for party members within range. Duration: Geomancy skill. GEO-only (subjob OK).",
    },

    ["Indi-AGI"] = {
        description = "Boosts agility.",
        category = "Indicolure",
        element = "Wind",
        magic_type = "Geomancy",
        type = "self",
        GEO = 39,
        notes = "Self-centered aura. Increases AGI for party members within range. Duration: Geomancy skill. GEO-only (subjob OK).",
    },

    ["Indi-Attunement"] = {
        description = "Boosts magic acc.",
        category = "Indicolure",
        element = "Light",
        magic_type = "Geomancy",
        type = "self",
        GEO = 16,
        notes = "Self-centered aura. Increases magic accuracy for party members within range. Duration: Geomancy skill. GEO-only (subjob OK).",
    },

    ["Indi-Barrier"] = {
        description = "Boosts defense.",
        category = "Indicolure",
        element = "Earth",
        magic_type = "Geomancy",
        type = "self",
        GEO = 28,
        notes = "Self-centered aura. Increases defense for party members within range. Duration: Geomancy skill. GEO-only (subjob OK).",
    },

    ["Indi-CHR"] = {
        description = "Boosts charisma.",
        category = "Indicolure",
        element = "Light",
        magic_type = "Geomancy",
        type = "self",
        GEO = 30,
        notes = "Self-centered aura. Increases CHR for party members within range. Duration: Geomancy skill. GEO-only (subjob OK).",
    },

    ["Indi-DEX"] = {
        description = "Boosts dexterity.",
        category = "Indicolure",
        element = "Thunder",
        magic_type = "Geomancy",
        type = "self",
        GEO = 45,
        notes = "Self-centered aura. Increases DEX for party members within range. Duration: Geomancy skill. GEO-only (subjob OK).",
    },

    ["Indi-Fend"] = {
        description = "Boosts defense.",
        category = "Indicolure",
        element = "Water",
        magic_type = "Geomancy",
        type = "self",
        GEO = 40,
        notes = "Self-centered aura. Increases defense for party members within range. Duration: Geomancy skill. GEO-only (subjob OK).",
    },

    ["Indi-Focus"] = {
        description = "Boosts magic acc.",
        category = "Indicolure",
        element = "Dark",
        magic_type = "Geomancy",
        type = "self",
        GEO = 22,
        notes = "Self-centered aura. Increases magic accuracy for party members within range. Duration: Geomancy skill. GEO-only (subjob OK).",
    },

    ["Indi-Fury"] = {
        description = "Boosts attack.",
        category = "Indicolure",
        element = "Fire",
        magic_type = "Geomancy",
        type = "self",
        GEO = 34,
        notes = "Self-centered aura. Increases attack for party members within range. Duration: Geomancy skill. GEO-only (subjob OK).",
    },

    ["Indi-Haste"] = {
        description = "Boosts attack speed.",
        category = "Indicolure",
        element = "Wind",
        magic_type = "Geomancy",
        type = "self",
        GEO = 93,
        main_job_only = true,
        notes = "Self-centered aura. Reduces melee delay for party members within range. Duration: Geomancy skill. GEO-only (main job only).",
    },

    ["Indi-INT"] = {
        description = "Boosts intelligence.",
        category = "Indicolure",
        element = "Ice",
        magic_type = "Geomancy",
        type = "self",
        GEO = 36,
        notes = "Self-centered aura. Increases INT for party members within range. Duration: Geomancy skill. GEO-only (subjob OK).",
    },

    ["Indi-MND"] = {
        description = "Boosts mind.",
        category = "Indicolure",
        element = "Water",
        magic_type = "Geomancy",
        type = "self",
        GEO = 33,
        notes = "Self-centered aura. Increases MND for party members within range. Duration: Geomancy skill. GEO-only (subjob OK).",
    },

    ["Indi-Poison"] = {
        description = "Boosts poison dmg.",
        category = "Indicolure",
        element = "Water",
        magic_type = "Geomancy",
        type = "self",
        GEO = 1,
        notes = "Self-centered aura. Increases poison damage dealt by party members within range. Duration: Geomancy skill. GEO-only (subjob OK).",
    },

    ["Indi-Precision"] = {
        description = "Boosts accuracy.",
        category = "Indicolure",
        element = "Thunder",
        magic_type = "Geomancy",
        type = "self",
        GEO = 10,
        notes = "Self-centered aura. Increases accuracy for party members within range. Duration: Geomancy skill. GEO-only (subjob OK).",
    },

    ["Indi-Refresh"] = {
        description = "Restores MP.",
        category = "Indicolure",
        element = "Light",
        magic_type = "Geomancy",
        type = "self",
        GEO = 30,
        notes = "Self-centered aura. Restores MP over time for party members within range. Duration: Geomancy skill. GEO-only (subjob OK).",
    },

    ["Indi-Regen"] = {
        description = "Restores HP.",
        category = "Indicolure",
        element = "Light",
        magic_type = "Geomancy",
        type = "self",
        GEO = 15,
        notes = "Self-centered aura. Restores HP over time for party members within range. Duration: Geomancy skill. GEO-only (subjob OK).",
    },

    ["Indi-STR"] = {
        description = "Boosts strength.",
        category = "Indicolure",
        element = "Fire",
        magic_type = "Geomancy",
        type = "self",
        GEO = 48,
        notes = "Self-centered aura. Increases STR for party members within range. Duration: Geomancy skill. GEO-only (subjob OK).",
    },

    ["Indi-VIT"] = {
        description = "Boosts vitality.",
        category = "Indicolure",
        element = "Earth",
        magic_type = "Geomancy",
        type = "self",
        GEO = 42,
        notes = "Self-centered aura. Increases VIT for party members within range. Duration: Geomancy skill. GEO-only (subjob OK).",
    },

    ["Indi-Voidance"] = {
        description = "Boosts evasion.",
        category = "Indicolure",
        element = "Wind",
        magic_type = "Geomancy",
        type = "self",
        GEO = 4,
        notes = "Self-centered aura. Increases evasion for party members within range. Duration: Geomancy skill. GEO-only (subjob OK).",
    },

    --============================================================
    -- DEBUFF AURAS (Enemy Debuffs - Subjob Accessible)
    --============================================================

    ["Indi-Slow"] = {
        description = "Slows nearby foes.",
        category = "Indicolure",
        element = "Earth",
        magic_type = "Geomancy",
        type = "self",
        GEO = 48,
        notes = "Self-centered aura. Slows attack speed for enemies within range. Duration: Geomancy skill. GEO-only (subjob OK).",
    },

    --============================================================
    -- DEBUFF AURAS (Enemy Debuffs - Subjob Master Required)
    --============================================================

    ["Indi-Slip"] = {
        description = "Lowers accuracy.",
        category = "Indicolure",
        element = "Earth",
        magic_type = "Geomancy",
        type = "self",
        GEO = 58,
        subjob_master_only = true,
        notes = "Self-centered aura. Lowers accuracy for enemies within range. Duration: Geomancy skill. GEO-only (subjob master OK).",
    },

    ["Indi-Torpor"] = {
        description = "Lowers evasion.",
        category = "Indicolure",
        element = "Ice",
        magic_type = "Geomancy",
        type = "self",
        GEO = 52,
        subjob_master_only = true,
        notes = "Self-centered aura. Lowers evasion for enemies within range. Duration: Geomancy skill. GEO-only (subjob master OK).",
    },

    --============================================================
    -- DEBUFF AURAS (Enemy Debuffs - Main Job Only)
    --============================================================

    ["Indi-Fade"] = {
        description = "Lowers attack.",
        category = "Indicolure",
        element = "Fire",
        magic_type = "Geomancy",
        type = "self",
        GEO = 94,
        main_job_only = true,
        notes = "Self-centered aura. Lowers attack for enemies within range. Duration: Geomancy skill. GEO-only (main job only).",
    },

    ["Indi-Frailty"] = {
        description = "Lowers defense.",
        category = "Indicolure",
        element = "Wind",
        magic_type = "Geomancy",
        type = "self",
        GEO = 76,
        main_job_only = true,
        notes = "Self-centered aura. Lowers defense for enemies within range. Duration: Geomancy skill. GEO-only (main job only).",
    },

    ["Indi-Gravity"] = {
        description = "Slows movement.",
        category = "Indicolure",
        element = "Wind",
        magic_type = "Geomancy",
        type = "self",
        GEO = 88,
        main_job_only = true,
        notes = "Self-centered aura. Reduces movement speed for enemies within range. Duration: Geomancy skill. GEO-only (main job only).",
    },

    ["Indi-Languor"] = {
        description = "Slows foes.",
        category = "Indicolure",
        element = "Dark",
        magic_type = "Geomancy",
        type = "self",
        GEO = 64,
        main_job_only = true,
        notes = "Self-centered aura. Slows attack speed for enemies within range. Duration: Geomancy skill. GEO-only (main job only).",
    },

    ["Indi-Malaise"] = {
        description = "Lowers magic def.",
        category = "Indicolure",
        element = "Thunder",
        magic_type = "Geomancy",
        type = "self",
        GEO = 88,
        main_job_only = true,
        notes = "Self-centered aura. Lowers magic defense for enemies within range. Duration: Geomancy skill. GEO-only (main job only).",
    },

    ["Indi-Paralysis"] = {
        description = "Paralyzes foes.",
        category = "Indicolure",
        element = "Ice",
        magic_type = "Geomancy",
        type = "self",
        GEO = 68,
        main_job_only = true,
        notes = "Self-centered aura. Inflicts paralysis on enemies within range. Duration: Geomancy skill. GEO-only (main job only).",
    },

    ["Indi-Vex"] = {
        description = "Lowers magic def.",
        category = "Indicolure",
        element = "Light",
        magic_type = "Geomancy",
        type = "self",
        GEO = 70,
        main_job_only = true,
        notes = "Self-centered aura. Lowers magic defense for enemies within range. Duration: Geomancy skill. GEO-only (main job only).",
    },

    ["Indi-Wilt"] = {
        description = "Lowers attack.",
        category = "Indicolure",
        element = "Water",
        magic_type = "Geomancy",
        type = "self",
        GEO = 82,
        main_job_only = true,
        notes = "Self-centered aura. Lowers attack for enemies within range. Duration: Geomancy skill. GEO-only (main job only).",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return INDI_SPELLS

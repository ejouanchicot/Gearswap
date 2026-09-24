---============================================================================
--- ENFEEBLING MAGIC DATABASE - DoT Spells Module
---============================================================================
--- Damage over Time enfeebling spells (10 total)
---
--- Contents:
---   - Dia family (4): Dia I/II/III, Diaga (Defense down + Light DoT)
---   - Bio family (3): Bio I/II/III (Attack down + Dark DoT)
---   - Poison family (3): Poison I/II, Poisonga (Water DoT)
---
--- @file shared/data/magic/enfeebling/enfeebling_dots.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
---============================================================================

local ENFEEBLING_DOTS = {}

ENFEEBLING_DOTS.spells = {

    ---========================================================================
    --- DIA FAMILY - Light Element (Defense Down + DoT)
    ---========================================================================
    --- Enfeebling Type: POTENCY (Enfeebling Potency pure)

    ["Dia"] = {
        description             = "Light DoT + def down.",
        element                 = "Light",
        tier                    = "I",
        category                = "Enfeebling",
        magic_type              = "White",
        type                    = "single",
        enfeebling_type         = "potency",
        RDM                     = 1,
        WHM                     = 3,
        notes                   = "Light DoT (1/tick, ticks every 3s) + defense down (-10%). RDM/WHM.",
    },

    ["Dia II"] = {
        description             = "Light DoT + def down.",
        element                 = "Light",
        tier                    = "II",
        category                = "Enfeebling",
        magic_type              = "White",
        type                    = "single",
        enfeebling_type         = "potency",
        RDM                     = 31,
        WHM                     = 36,
        notes                   = "Enhanced light DoT (2/tick, ticks every 3s) + defense down (-15%). RDM/WHM.",
    },

    ["Dia III"] = {
        description             = "Light DoT + def down.",
        element                 = "Light",
        tier                    = "III",
        category                = "Enfeebling",
        magic_type              = "White",
        type                    = "single",
        enfeebling_type         = "potency",
        RDM                     = 75,
        notes                   = "Maximum light DoT (3/tick, ticks every 3s; +1/tick per Enfeebling magic effect+ gear) + defense down (-20%). RDM-only.",
    },

    ["Diaga"] = {
        description             = "Light DoT + def down (AOE).",
        element                 = "Light",
        tier                    = "I",
        category                = "Enfeebling",
        magic_type              = "White",
        type                    = "aoe",
        enfeebling_type         = "potency",
        RDM                     = 15,
        WHM                     = 18,
        notes                   = "AOE light DoT (1/tick, ticks every 3s) + defense down (-10%). RDM/WHM.",
    },

    ---========================================================================
    --- BIO FAMILY - Dark Element (Attack Down + DoT)
    ---========================================================================
    --- Enfeebling Type: POTENCY

    ["Bio"] = {
        description             = "Dark DoT + atk down.",
        element                 = "Dark",
        tier                    = "I",
        category                = "Dark",
        magic_type              = "Dark",
        type                    = "single",
        enfeebling_type         = "potency",
        BLM                     = 10,
        DRK                     = 15,
        RDM                     = 10,
        notes                   = "Bio effect (attack down -10%, static) + darkness DoT (scales with Dark Magic skill, caps at 3/tick). Ticks every 3 seconds. Duration: 60s. BLM/DRK/RDM.",
    },

    ["Bio II"] = {
        description             = "Dark DoT + atk down.",
        element                 = "Dark",
        tier                    = "II",
        category                = "Dark",
        magic_type              = "Dark",
        type                    = "single",
        enfeebling_type         = "potency",
        BLM                     = 35,
        DRK                     = 40,
        RDM                     = 36,
        notes                   = "Stronger Bio effect (attack down -15%, static) + darkness DoT (5-8/tick by Dark Magic skill). Ticks every 3 seconds. Duration: 120s. BLM/DRK/RDM.",
    },

    ["Bio III"] = {
        description             = "Dark DoT + atk down.",
        element                 = "Dark",
        tier                    = "III",
        category                = "Dark",
        magic_type              = "Dark",
        type                    = "single",
        enfeebling_type         = "potency",
        RDM                     = 75,
        notes                   = "Bio effect (attack down -20%, static) + darkness DoT (scales with Dark Magic skill, caps at 17/tick). Ticks every 3 seconds. RDM-only.",
    },

    ---========================================================================
    --- POISON FAMILY - Water Element (DoT)
    ---========================================================================
    --- Enfeebling Type: MACC (Poison I) / SKILL_POTENCY (Poison II)

    ["Poison"] = {
        description             = "Water DoT.",
        element                 = "Water",
        tier                    = "I",
        category                = "Enfeebling",
        magic_type              = "Black",
        type                    = "single",
        enfeebling_type         = "macc",
        BLM                     = 3,
        DRK                     = 6,
        RDM                     = 5,
        notes                   = "Water DoT (ticks every 3s). Success rate: Magic Accuracy. BLM/DRK/RDM.",
    },

    ["Poison II"] = {
        description             = "Water DoT.",
        element                 = "Water",
        tier                    = "II",
        category                = "Enfeebling",
        magic_type              = "Black",
        type                    = "single",
        enfeebling_type         = "skill_potency",
        BLM                     = 43,
        DRK                     = 46,
        RDM                     = 46,
        notes                   = "Enhanced water DoT (ticks every 3s). Potency: Enfeebling Magic skill. BLM/DRK/RDM.",
    },

    ["Poisonga"] = {
        description             = "Water DoT (AOE).",
        element                 = "Water",
        tier                    = "I",
        category                = "Enfeebling",
        magic_type              = "Black",
        type                    = "aoe",
        enfeebling_type         = "macc",
        BLM                     = 24,
        DRK                     = 26,
        notes                   = "AOE water DoT (ticks every 3s). Success rate: Magic Accuracy. BLM/DRK.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return ENFEEBLING_DOTS

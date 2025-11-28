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
--- @file enfeebling_dots.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06 | Updated: 2025-10-31
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
        notes                   = "Light DoT (ticks every 3s) + defense down. Potency: Enfeebling Magic skill. RDM/WHM.",
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
        notes                   = "Enhanced light DoT (ticks every 3s) + defense down. Potency: Enfeebling Magic skill. RDM/WHM.",
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
        notes                   = "Maximum light DoT (ticks every 3s) + defense down. Potency: Enfeebling Magic skill. RDM-only.",
    },

    ["Diaga"] = {
        description             = "Light DoT (AOE).",
        element                 = "Light",
        tier                    = "I",
        category                = "Enfeebling",
        magic_type              = "White",
        type                    = "aoe",
        enfeebling_type         = "potency",
        RDM                     = 15,
        WHM                     = 18,
        notes                   = "AOE light DoT (ticks every 3s). No defense down effect. Potency: Enfeebling Magic skill. RDM/WHM.",
    },

    ---========================================================================
    --- BIO FAMILY - Dark Element (Attack Down + DoT)
    ---========================================================================
    --- Enfeebling Type: POTENCY

    ["Bio"] = {
        description             = "Dark DoT + atk down.",
        element                 = "Dark",
        tier                    = "I",
        category                = "Enfeebling",
        magic_type              = "Dark",
        type                    = "single",
        enfeebling_type         = "potency",
        BLM                     = 10,
        DRK                     = 15,
        RDM                     = 10,
        notes                   = "Dark DoT (ticks every 3s) + attack down. Potency: Enfeebling Magic skill. BLM/DRK/RDM.",
    },

    ["Bio II"] = {
        description             = "Dark DoT + atk down.",
        element                 = "Dark",
        tier                    = "II",
        category                = "Enfeebling",
        magic_type              = "Dark",
        type                    = "single",
        enfeebling_type         = "potency",
        BLM                     = 35,
        DRK                     = 40,
        RDM                     = 36,
        notes                   = "Enhanced dark DoT (ticks every 3s) + attack down. Potency: Enfeebling Magic skill. BLM/DRK/RDM.",
    },

    ["Bio III"] = {
        description             = "Dark DoT + atk down.",
        element                 = "Dark",
        tier                    = "III",
        category                = "Enfeebling",
        magic_type              = "Dark",
        type                    = "single",
        enfeebling_type         = "potency",
        RDM                     = 75,
        notes                   = "Maximum dark DoT (ticks every 3s) + attack down. Potency: Enfeebling Magic skill. RDM-only.",
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

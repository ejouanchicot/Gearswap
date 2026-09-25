---============================================================================
--- BLUE MAGIC DATABASE - Magical Light Spells
---============================================================================
--- Light-element magical damage Blue Magic spells
---
--- @file shared/data/magic/blu/magical/blu_magical_light.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06
---============================================================================

local BLU_MAGICAL_LIGHT = {}

BLU_MAGICAL_LIGHT.spells = {

    ["1000 Needles"] = {
        description             = "Deals 1000 dmg split among targets (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = "Beast Killer",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 62,
        mp_cost                 = 350,
        notes                   = "Light-based magical fixed damage (AoE). MP: 350. Level: 62. Trait: Beast Killer. Damage is divided equally among targets; cannot be partially resisted; Magic Burst raises accuracy only. Recast: 120s. BLU only.",
    },

    ["Magic Hammer"] = {
        description             = "Deals dmg + MP drain.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = "Magic Attack Bonus",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 74,
        mp_cost                 = 40,
        notes                   = "Light-based magical damage + MP drain equal to damage dealt. MP: 40. Level: 74. Trait: Magic Attack Bonus. Affected by Magic Attack Bonus. Ineffective against undead. Recast: 180s. Single target. BLU only.",
    },

    ["Retinal Glare"] = {
        description             = "Deals light dmg + flash.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = "Conserve MP",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 26,
        notes                   = "Light-based magical damage + Flash (conal AoE). MP: 26. Level: 99. Trait: Conserve MP. Additional effect: Flash (15s). Recast: 45s. BLU only.",
    },

    ["Diffusion Ray"] = {
        description             = "Deals light dmg (conal AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = "Store TP",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 238,
        notes                   = "Light-based magical damage (conal AoE). MP: 238. Level: 99. Trait: Store TP. Recast: 45s. BLU only.",
    },

    ["Rail Cannon"] = {
        description             = "Deals light dmg.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = "Magic Burst Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 200,
        notes                   = "Light-based magical damage. MP: 200. Level: 99. Trait: Magic Burst Bonus. Recast: 180s. Single target. BLU only.",
    },

    ["Uproot"] = {
        description             = "Deals light dmg + erases caster debuffs (unbridled, AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = true,
        BLU                     = 99,
        mp_cost                 = 88,
        notes                   = "Light-based magical damage (unbridled, AoE). MP: 88. Level: 99. Trait: None. Requires: Unbridled Learning. Also removes all debuffs from the caster. Recast: 30s. BLU only.",
    },

    ["Blinding Fulgor"] = {
        description             = "Deals light dmg + flash (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = "Magic Evasion Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 116,
        notes                   = "Light-based magical damage + Flash (AoE). MP: 116. Level: 99. Trait: Magic Evasion Bonus. Recast: 60s. Range: ~10'. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_MAGICAL_LIGHT

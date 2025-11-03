---============================================================================
--- BLUE MAGIC DATABASE - Magical Light Spells
---============================================================================
--- Light-element magical damage Blue Magic spells
---
--- @file blu_magical_light.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-01 | Updated: 2025-11-01
---============================================================================

local BLU_MAGICAL_LIGHT = {}

BLU_MAGICAL_LIGHT.spells = {

    ["1000 Needles"] = {
        description = "Deals fixed 1000 dmg.",
        category = "Magical",
        magic_type = "Blue",
        element = "Light",
        trait = "Beast Killer",
        trait_points = 4,
        unbridled = false,
        BLU = 62,
        mp_cost = 114,
        notes = "Light-based magical damage (fixed 1000 HP). MP: 114. Level: 62. Trait: Beast Killer (4 pts). Damage: Always 1000 (not affected by MAB). Single target. BLU only.",
    },

    ["Magic Hammer"] = {
        description = "Deals dmg + MP drain.",
        category = "Magical",
        magic_type = "Blue",
        element = "Light",
        trait = "Magic Attack Bonus",
        trait_points = 4,
        unbridled = false,
        BLU = 74,
        mp_cost = 40,
        notes = "Light-based magical damage + MP drain. MP: 40. Level: 74. Trait: Magic Attack Bonus (4 pts). Drains enemy MP. Single target. BLU only.",
    },

    ["Retinal Glare"] = {
        description = "Deals light dmg + flash.",
        category = "Magical",
        magic_type = "Blue",
        element = "Light",
        trait = "Conserve MP",
        trait_points = 8,
        unbridled = false,
        BLU = 99,
        mp_cost = 113,
        notes = "Light-based magical damage + Flash. MP: 113. Level: 99. Trait: Conserve MP (8 pts). Additional effect: Flash (accuracy down). Single target. BLU only.",
    },

    ["Diffusion Ray"] = {
        description = "Deals light dmg (AoE).",
        category = "Magical",
        magic_type = "Blue",
        element = "Light",
        trait = "Store TP",
        trait_points = 8,
        unbridled = false,
        BLU = 99,
        mp_cost = 182,
        notes = "Light-based magical damage (AoE). MP: 182. Level: 99. Trait: Store TP (8 pts). AoE range. BLU only.",
    },

    ["Rail Cannon"] = {
        description = "Deals light dmg.",
        category = "Magical",
        magic_type = "Blue",
        element = "Light",
        trait = "Magic Burst Bonus",
        trait_points = 8,
        unbridled = false,
        BLU = 99,
        mp_cost = 195,
        notes = "Light-based magical damage. MP: 195. Level: 99. Trait: Magic Burst Bonus (8 pts). High damage single target. BLU only.",
    },

    ["Uproot"] = {
        description = "Deals light dmg (unbridled, AoE).",
        category = "Magical",
        magic_type = "Blue",
        element = "Light",
        trait = nil,
        trait_points = 0,
        unbridled = true,
        BLU = 99,
        mp_cost = 218,
        notes = "Light-based magical damage (unbridled, AoE). MP: 218. Level: 99. Trait: None (0 pts). Requires: Unbridled Learning/Wisdom. AoE range. BLU only.",
    },

    ["Blinding Fulgor"] = {
        description = "Deals light dmg + blind.",
        category = "Magical",
        magic_type = "Blue",
        element = "Light",
        trait = "Magic Evasion Bonus",
        trait_points = 8,
        unbridled = false,
        BLU = 99,
        mp_cost = 195,
        notes = "Light-based magical damage + Blind. MP: 195. Level: 99. Trait: Magic Evasion Bonus (8 pts). AoE range. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_MAGICAL_LIGHT

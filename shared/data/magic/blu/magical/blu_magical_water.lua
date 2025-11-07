---============================================================================
--- BLUE MAGIC DATABASE - Magical Water Spells
---============================================================================
--- Water-element magical damage Blue Magic spells
---
--- @file blu_magical_water.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06 | Updated: 2025-11-01
---============================================================================

local BLU_MAGICAL_WATER = {}

BLU_MAGICAL_WATER.spells = {

    ["Cursed Sphere"] = {
        description             = "Deals water dmg + curse.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = "Magic Attack Bonus",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 18,
        mp_cost                 = 46,
        notes                   = "Water-based magical damage + Curse. MP: 46. Level: 18. Trait: Magic Attack Bonus (4 pts). Single target. BLU only.",
    },

    ["Maelstrom"] = {
        description             = "Deals water dmg + STR down.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = "Clear Mind",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 61,
        mp_cost                 = 133,
        notes                   = "Water-based magical damage + STR Down. MP: 133. Level: 61. Trait: Clear Mind (4 pts). Single target. BLU only.",
    },

    ["Corrosive Ooze"] = {
        description             = "Deals water dmg + defense down.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = "Clear Mind",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 66,
        mp_cost                 = 84,
        notes                   = "Water-based magical damage + Defense Down. MP: 84. Level: 66. Trait: Clear Mind (4 pts). Single target. BLU only.",
    },

    ["Regurgitation"] = {
        description             = "Deals water dmg + bind.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = "Resist Gravity",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 69,
        mp_cost                 = 99,
        notes                   = "Water-based magical damage + Bind. MP: 99. Level: 69. Trait: Resist Gravity (4 pts). Single target. BLU only.",
    },

    ["Acrid Stream"] = {
        description             = "Deals water dmg + magic defense down.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = "Double / Triple Attack",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 77,
        mp_cost                 = 104,
        notes                   = "Water-based magical damage + Magic Defense Down. MP: 104. Level: 77. Trait: Double/Triple Attack (4 pts). Single target. BLU only.",
    },

    ["Water Bomb"] = {
        description             = "Deals water dmg (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = "Conserve MP",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 92,
        mp_cost                 = 175,
        notes                   = "Water-based magical damage (AoE). MP: 175. Level: 92. Trait: Conserve MP (4 pts). AoE range. BLU only.",
    },

    ["Rending Deluge"] = {
        description             = "Deals water dmg.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = "Magic Defense Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 177,
        notes                   = "Water-based magical damage. MP: 177. Level: 99. Trait: Magic Defense Bonus (8 pts). Single target. BLU only.",
    },

    ["Foul Waters"] = {
        description             = "Deals water dmg + drown.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = "Resist Silence",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 195,
        notes                   = "Water-based magical damage + Drown. MP: 195. Level: 99. Trait: Resist Silence (8 pts). Additional effect: Drown (DoT). Single target. BLU only.",
    },

    ["Nectarous Deluge"] = {
        description             = "Deals water dmg (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = "Beast Killer",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 195,
        notes                   = "Water-based magical damage (AoE). MP: 195. Level: 99. Trait: Beast Killer (8 pts). AoE range. BLU only.",
    },

    ["Scouring Spate"] = {
        description             = "Deals water dmg + dispel.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = "Magic Defense Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 195,
        notes                   = "Water-based magical damage + Dispel. MP: 195. Level: 99. Trait: Magic Defense Bonus (8 pts). Dispels beneficial effects. AoE range. BLU only.",
    },

    ["Cesspool"] = {
        description             = "Deals water dmg (unbridled, AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = true,
        BLU                     = 99,
        mp_cost                 = 212,
        notes                   = "Water-based magical damage (unbridled, AoE). MP: 212. Level: 99. Trait: None (0 pts). Requires: Unbridled Learning/Wisdom. AoE range. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_MAGICAL_WATER

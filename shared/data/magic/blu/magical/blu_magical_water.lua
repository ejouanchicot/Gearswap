---============================================================================
--- BLUE MAGIC DATABASE - Magical Water Spells
---============================================================================
--- Water-element magical damage Blue Magic spells
---
--- @file shared/data/magic/blu/magical/blu_magical_water.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06
---============================================================================

local BLU_MAGICAL_WATER = {}

BLU_MAGICAL_WATER.spells = {

    ["Cursed Sphere"] = {
        description             = "Deals water dmg (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = "Magic Attack Bonus",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 18,
        mp_cost                 = 36,
        notes                   = "Water-based magical damage (AoE, centered on target). MP: 36. Level: 18. Trait: Magic Attack Bonus. BLU only.",
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
        mp_cost                 = 162,
        notes                   = "Water-based magical damage + STR Down (AoE). MP: 162. Level: 61. Trait: Clear Mind. Additional effect: STR -20 (60s). Recast: 39s. BLU only.",
    },

    ["Corrosive Ooze"] = {
        description             = "Deals water dmg + attack/defense down.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = "Clear Mind",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 66,
        mp_cost                 = 55,
        notes                   = "Water-based magical damage + Attack Down + Defense Down (AoE). MP: 55. Level: 66. Trait: Clear Mind. Additional effect: Attack -5% and Defense -5% (60-90s), do not always land. Almost no enmity. Recast: 30s. BLU only.",
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
        mp_cost                 = 69,
        notes                   = "Water-based magical damage + Bind. MP: 69. Level: 69. Trait: Resist Gravity. Bind applied after damage. Almost no enmity. +25% damage from behind the target. Range: ~21'. Single target. BLU only.",
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
        mp_cost                 = 89,
        notes                   = "Water-based magical damage + Magic Defense Down (conal AoE). MP: 89. Level: 77. Trait: Double/Triple Attack. Additional effect: Magic Defense -10 (120s), does not overwrite itself. Recast: 23s. BLU only.",
    },

    ["Water Bomb"] = {
        description             = "Deals water dmg + silence (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = "Conserve MP",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 92,
        mp_cost                 = 67,
        notes                   = "Water-based magical damage + Silence (AoE). MP: 67. Level: 92. Trait: Conserve MP. Additional effect: Silence (60-90s). Range: ~16'. BLU only.",
    },

    ["Rending Deluge"] = {
        description             = "Deals water dmg + dispel (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = "Magic Defense Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 118,
        notes                   = "Water-based magical damage + Dispel (AoE). MP: 118. Level: 99. Trait: Magic Defense Bonus. Dispel removes one effect and cannot miss. Recast: 35s. BLU only.",
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
        mp_cost                 = 76,
        notes                   = "Water-based magical damage + Drown (conal AoE). MP: 76. Level: 99. Trait: Resist Silence. Additional effect: Drown (31 HP/tick, -65 STR, 3min). Recast: 60s. BLU only.",
    },

    ["Nectarous Deluge"] = {
        description             = "Deals water dmg + poison (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = "Beast Killer",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 97,
        notes                   = "Water-based magical damage + Poison (AoE). MP: 97. Level: 99. Trait: Beast Killer. Additional effect: Poison 80 HP/tick (~30s). Recast: 45s. BLU only.",
    },

    ["Scouring Spate"] = {
        description             = "Deals water dmg + attack down (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = "Magic Defense Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 116,
        notes                   = "Water-based magical damage + Attack Down (AoE). MP: 116. Level: 99. Trait: Magic Defense Bonus. Additional effect: Attack -20% (~3min). Recast: 60s. Range: ~10'. BLU only.",
    },

    ["Cesspool"] = {
        description             = "Deals water dmg + plague (unbridled, AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = true,
        BLU                     = 99,
        mp_cost                 = 166,
        notes                   = "Water-based magical damage + Plague (unbridled, AoE). MP: 166. Level: 99. Trait: None. Requires: Unbridled Learning/Wisdom. Additional effect: Plague (-5 MP/tick, -100 TP/tick, 60s). Recast: 30s. Range: 10'. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_MAGICAL_WATER

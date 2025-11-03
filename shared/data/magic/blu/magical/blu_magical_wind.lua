---============================================================================
--- BLUE MAGIC DATABASE - Magical Wind Spells
---============================================================================
--- Wind-element magical damage Blue Magic spells
---
--- @file blu_magical_wind.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-01 | Updated: 2025-11-01
---============================================================================

local BLU_MAGICAL_WIND = {}

BLU_MAGICAL_WIND.spells = {

    ["Mysterious Light"] = {
        description = "Deals wind dmg + weight.",
        category = "Magical",
        magic_type = "Blue",
        element = "Wind",
        trait = "Max MP Boost",
        trait_points = 4,
        unbridled = false,
        BLU = 40,
        mp_cost = 88,
        notes = "Wind-based magical damage + Weight. MP: 88. Level: 40. Trait: Max MP Boost (4 pts). Additional effect: Weight (movement down). Single target. BLU only.",
    },

    ["Voracious Trunk"] = {
        description = "Deals wind dmg + HP drain.",
        category = "Magical",
        magic_type = "Blue",
        element = "Wind",
        trait = "Auto Refresh",
        trait_points = 3,
        unbridled = false,
        BLU = 64,
        mp_cost = 99,
        notes = "Wind-based magical damage + HP drain. MP: 99. Level: 64. Trait: Auto Refresh (3 pts). Drains HP from enemy. Single target. BLU only.",
    },

    ["Leafstorm"] = {
        description = "Deals wind dmg (AoE).",
        category = "Magical",
        magic_type = "Blue",
        element = "Wind",
        trait = "Magic Burst Bonus",
        trait_points = 6,
        unbridled = false,
        BLU = 77,
        mp_cost = 120,
        notes = "Wind-based magical damage (AoE). MP: 120. Level: 77. Trait: Magic Burst Bonus (6 pts). AoE range. BLU only.",
    },

    ["Tem. Upheaval"] = {
        description = "Deals wind dmg.",
        category = "Magical",
        magic_type = "Blue",
        element = "Wind",
        trait = "Evasion Bonus",
        trait_points = 8,
        unbridled = false,
        BLU = 99,
        mp_cost = 138,
        notes = "Wind-based magical damage. MP: 138. Level: 99. Trait: Evasion Bonus (8 pts). Single target. BLU only.",
    },

    ["Droning Whirlwind"] = {
        description = "Deals wind dmg (unbridled, AoE).",
        category = "Magical",
        magic_type = "Blue",
        element = "Wind",
        trait = nil,
        trait_points = 0,
        unbridled = true,
        BLU = 99,
        mp_cost = 195,
        notes = "Wind-based magical damage (unbridled, AoE). MP: 195. Level: 99. Trait: None (0 pts). Requires: Unbridled Learning/Wisdom. AoE range. BLU only.",
    },

    ["Subduction"] = {
        description = "Deals wind dmg.",
        category = "Magical",
        magic_type = "Blue",
        element = "Wind",
        trait = "Magic Attack Bonus",
        trait_points = 8,
        unbridled = false,
        BLU = 99,
        mp_cost = 162,
        notes = "Wind-based magical damage. MP: 162. Level: 99. Trait: Magic Attack Bonus (8 pts). Single target. BLU only.",
    },

    ["Molting Plumage"] = {
        description = "Deals wind dmg + evasion down.",
        category = "Magical",
        magic_type = "Blue",
        element = "Wind",
        trait = "Dual Wield",
        trait_points = 8,
        unbridled = false,
        BLU = 99,
        mp_cost = 195,
        notes = "Wind-based magical damage + Evasion Down. MP: 195. Level: 99. Trait: Dual Wield (8 pts). AoE range. BLU only.",
    },

    ["Silent Storm"] = {
        description = "Deals wind dmg + silence.",
        category = "Magical",
        magic_type = "Blue",
        element = "Wind",
        trait = "Evasion Bonus",
        trait_points = 8,
        unbridled = false,
        BLU = 99,
        mp_cost = 195,
        notes = "Wind-based magical damage + Silence. MP: 195. Level: 99. Trait: Evasion Bonus (8 pts). AoE range. BLU only.",
    },

    ["Tearing Gust"] = {
        description = "Deals wind dmg (unbridled, AoE).",
        category = "Magical",
        magic_type = "Blue",
        element = "Wind",
        trait = nil,
        trait_points = 0,
        unbridled = true,
        BLU = 99,
        mp_cost = 212,
        notes = "Wind-based magical damage (unbridled, AoE). MP: 212. Level: 99. Trait: None (0 pts). Requires: Unbridled Learning/Wisdom. AoE range. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_MAGICAL_WIND

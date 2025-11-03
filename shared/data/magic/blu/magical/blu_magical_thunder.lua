---============================================================================
--- BLUE MAGIC DATABASE - Magical Thunder Spells
---============================================================================
--- Thunder-element magical damage Blue Magic spells
---
--- @file blu_magical_thunder.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-01 | Updated: 2025-11-01
---============================================================================

local BLU_MAGICAL_THUNDER = {}

BLU_MAGICAL_THUNDER.spells = {

    ["Blitzstrahl"] = {
        description = "Deals thunder dmg + stun.",
        category = "Magical",
        magic_type = "Blue",
        element = "Thunder",
        trait = nil,
        trait_points = 0,
        unbridled = false,
        BLU = 44,
        mp_cost = 95,
        notes = "Thunder-based magical damage + Stun. MP: 95. Level: 44. Trait: None (0 pts). Single target. BLU only.",
    },

    ["Mind Blast"] = {
        description = "Deals thunder dmg + paralysis.",
        category = "Magical",
        magic_type = "Blue",
        element = "Thunder",
        trait = "Clear Mind",
        trait_points = 4,
        unbridled = false,
        BLU = 73,
        mp_cost = 82,
        notes = "Thunder-based magical damage + Paralysis. MP: 82. Level: 73. Trait: Clear Mind (4 pts). Single target. BLU only.",
    },

    ["Charged Whisker"] = {
        description = "Deals thunder dmg.",
        category = "Magical",
        magic_type = "Blue",
        element = "Thunder",
        trait = "Gilfinder / Treasure Hunter",
        trait_points = 6,
        unbridled = false,
        BLU = 88,
        mp_cost = 104,
        notes = "Thunder-based magical damage. MP: 104. Level: 88. Trait: Gilfinder/Treasure Hunter (6 pts). Single target. BLU only.",
    },

    ["Thunderbolt"] = {
        description = "Deals thunder dmg (unbridled, AoE).",
        category = "Magical",
        magic_type = "Blue",
        element = "Thunder",
        trait = nil,
        trait_points = 0,
        unbridled = true,
        BLU = 95,
        mp_cost = 197,
        notes = "Thunder-based magical damage (unbridled, AoE). MP: 197. Level: 95. Trait: None (0 pts). Requires: Unbridled Learning/Wisdom. AoE range. BLU only.",
    },

    ["Crashing Thunder"] = {
        description = "Deals thunder dmg (unbridled, AoE).",
        category = "Magical",
        magic_type = "Blue",
        element = "Thunder",
        trait = nil,
        trait_points = 0,
        unbridled = true,
        BLU = 99,
        mp_cost = 212,
        notes = "Thunder-based magical damage (unbridled, AoE). MP: 212. Level: 99. Trait: None (0 pts). Requires: Unbridled Learning/Wisdom. AoE range. BLU only.",
    },

    ["Anvil Lightning"] = {
        description = "Deals thunder dmg (AoE).",
        category = "Magical",
        magic_type = "Blue",
        element = "Thunder",
        trait = "Accuracy Bonus",
        trait_points = 8,
        unbridled = false,
        BLU = 99,
        mp_cost = 195,
        notes = "Thunder-based magical damage (AoE). MP: 195. Level: 99. Trait: Accuracy Bonus (8 pts). AoE range. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_MAGICAL_THUNDER

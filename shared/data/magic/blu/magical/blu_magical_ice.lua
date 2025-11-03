---============================================================================
--- BLUE MAGIC DATABASE - Magical Ice Spells
---============================================================================
--- Ice-element magical damage Blue Magic spells
---
--- @file blu_magical_ice.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-01 | Updated: 2025-11-01
---============================================================================

local BLU_MAGICAL_ICE = {}

BLU_MAGICAL_ICE.spells = {

    ["Ice Break"] = {
        description = "Deals ice dmg + paralyze.",
        category = "Magical",
        magic_type = "Blue",
        element = "Ice",
        trait = "Magic Defense Bonus",
        trait_points = 4,
        unbridled = false,
        BLU = 50,
        mp_cost = 142,
        notes = "Ice-based magical damage + Paralysis. MP: 142. Level: 50. Trait: Magic Defense Bonus (4 pts). Single target. BLU only.",
    },

    ["Polar Roar"] = {
        description = "Deals ice dmg (unbridled, AoE).",
        category = "Magical",
        magic_type = "Blue",
        element = "Ice",
        trait = nil,
        trait_points = 0,
        unbridled = true,
        BLU = 99,
        mp_cost = 212,
        notes = "Ice-based magical damage (unbridled, AoE). MP: 212. Level: 99. Trait: None (0 pts). Requires: Unbridled Learning/Wisdom. AoE range. BLU only.",
    },

    ["Spectral Floe"] = {
        description = "Deals ice dmg (AoE).",
        category = "Magical",
        magic_type = "Blue",
        element = "Ice",
        trait = "Magic Attack Bonus",
        trait_points = 8,
        unbridled = false,
        BLU = 99,
        mp_cost = 195,
        notes = "Ice-based magical damage (AoE). MP: 195. Level: 99. Trait: Magic Attack Bonus (8 pts). AoE range. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_MAGICAL_ICE

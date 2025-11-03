---============================================================================
--- BLUE MAGIC DATABASE - Magical Fire Spells
---============================================================================
--- Fire-element magical damage Blue Magic spells
---
--- @file blu_magical_fire.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-01 | Updated: 2025-11-01
---============================================================================

local BLU_MAGICAL_FIRE = {}

BLU_MAGICAL_FIRE.spells = {

    ["Blastbomb"] = {
        description = "Deals fire dmg.",
        category = "Magical",
        magic_type = "Blue",
        element = "Fire",
        trait = nil,
        trait_points = 0,
        unbridled = false,
        BLU = 18,
        mp_cost = 46,
        notes = "Fire-based magical damage. MP: 46. Level: 18. Trait: None (0 pts). Single target. BLU only.",
    },

    ["Bomb Toss"] = {
        description = "Deals fire dmg (AoE).",
        category = "Magical",
        magic_type = "Blue",
        element = "Fire",
        trait = nil,
        trait_points = 0,
        unbridled = false,
        BLU = 28,
        mp_cost = 72,
        notes = "Fire-based magical damage (AoE). MP: 72. Level: 28. Trait: None (0 pts). AoE range. BLU only.",
    },

    ["Self-Destruct"] = {
        description = "Deals fire dmg (sacrifices caster).",
        category = "Magical",
        magic_type = "Blue",
        element = "Fire",
        trait = "Auto Refresh",
        trait_points = 2,
        unbridled = false,
        BLU = 50,
        mp_cost = 1,
        notes = "Fire-based magical damage (ultimate). MP: 1. Level: 50. Trait: Auto Refresh (2 pts). Damage = current HP, caster KO'd. AoE range. BLU only.",
    },

    ["Firespit"] = {
        description = "Deals fire dmg.",
        category = "Magical",
        magic_type = "Blue",
        element = "Fire",
        trait = "Magic Attack Bonus",
        trait_points = 4,
        unbridled = false,
        BLU = 68,
        mp_cost = 91,
        notes = "Fire-based magical damage. MP: 91. Level: 68. Trait: Magic Attack Bonus (4 pts). Single target. BLU only.",
    },

    ["Blazing Bound"] = {
        description = "Deals fire dmg + burn.",
        category = "Magical",
        magic_type = "Blue",
        element = "Fire",
        trait = "Dual Wield",
        trait_points = 4,
        unbridled = false,
        BLU = 80,
        mp_cost = 83,
        notes = "Fire-based magical damage + Burn. MP: 83. Level: 80. Trait: Dual Wield (4 pts). Additional effect: Burn (DoT). Single target. BLU only.",
    },

    ["Thermal Pulse"] = {
        description = "Deals fire dmg (AoE).",
        category = "Magical",
        magic_type = "Blue",
        element = "Fire",
        trait = "Attack Bonus",
        trait_points = 4,
        unbridled = false,
        BLU = 86,
        mp_cost = 180,
        notes = "Fire-based magical damage (AoE). MP: 180. Level: 86. Trait: Attack Bonus (4 pts). AoE range. BLU only.",
    },

    ["Gates of Hades"] = {
        description = "Deals fire dmg (unbridled, AoE).",
        category = "Magical",
        magic_type = "Blue",
        element = "Fire",
        trait = nil,
        trait_points = 0,
        unbridled = true,
        BLU = 97,
        mp_cost = 212,
        notes = "Fire-based magical damage (unbridled, AoE). MP: 212. Level: 97. Trait: None (0 pts). Requires: Unbridled Learning/Wisdom. AoE range. BLU only.",
    },

    ["Searing Tempest"] = {
        description = "Deals fire dmg (AoE).",
        category = "Magical",
        magic_type = "Blue",
        element = "Fire",
        trait = "Attack Bonus",
        trait_points = 8,
        unbridled = false,
        BLU = 99,
        mp_cost = 195,
        notes = "Fire-based magical damage (AoE). MP: 195. Level: 99. Trait: Attack Bonus (8 pts). AoE range. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_MAGICAL_FIRE

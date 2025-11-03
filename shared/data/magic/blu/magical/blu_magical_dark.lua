---============================================================================
--- BLUE MAGIC DATABASE - Magical Dark Spells
---============================================================================
--- Dark-element magical damage Blue Magic spells
---
--- @file blu_magical_dark.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-01 | Updated: 2025-11-01
---============================================================================

local BLU_MAGICAL_DARK = {}

BLU_MAGICAL_DARK.spells = {

    ["Blood Drain"] = {
        description = "Steals HP from enemy.",
        category = "Magical",
        magic_type = "Blue",
        element = "Dark",
        trait = nil,
        trait_points = 0,
        unbridled = false,
        BLU = 20,
        mp_cost = 10,
        notes = "Dark-based magical HP drain. MP: 10. Level: 20. Trait: None (0 pts). Absorbs HP from target. Ineffective against undead. Single target. BLU only.",
    },

    ["Death Ray"] = {
        description = "Deals dark dmg.",
        category = "Magical",
        magic_type = "Blue",
        element = "Dark",
        trait = nil,
        trait_points = 0,
        unbridled = false,
        BLU = 34,
        mp_cost = 49,
        notes = "Dark-based magical damage. MP: 49. Level: 34. Trait: None (0 pts). Recast: 30s. Single target. BLU only.",
    },

    ["Digest"] = {
        description = "Steals HP from enemy.",
        category = "Magical",
        magic_type = "Blue",
        element = "Dark",
        trait = nil,
        trait_points = 0,
        unbridled = false,
        BLU = 36,
        mp_cost = 20,
        notes = "Dark-based magical HP drain. MP: 20. Level: 36. Trait: None (0 pts). HP drained = Blue Magic Skill × 0.55. Ineffective against undead. Recast: 90s. Single target. BLU only.",
    },

    ["MP Drainkiss"] = {
        description = "Steals MP from enemy.",
        category = "Magical",
        magic_type = "Blue",
        element = "Dark",
        trait = nil,
        trait_points = 0,
        unbridled = false,
        BLU = 42,
        mp_cost = 20,
        notes = "Dark-based magical MP drain. MP: 20. Level: 42. Trait: None (0 pts). Drains enemy MP (soft cap: 165 MP). Ineffective against undead. Recast: 90s. Single target. BLU only.",
    },

    ["Blood Saber"] = {
        description = "Steals HP (AoE).",
        category = "Magical",
        magic_type = "Blue",
        element = "Dark",
        trait = nil,
        trait_points = 0,
        unbridled = false,
        BLU = 48,
        mp_cost = 48,
        notes = "Dark-based magical HP drain (AoE). MP: 48. Level: 48. Trait: None (0 pts). HP recovered = (Blue Magic Skill × 0.11) × 3.5. Ineffective against undead. Recast: 90s. AoE range. BLU only.",
    },

    ["Eyes On Me"] = {
        description = "Deals dark dmg.",
        category = "Magical",
        magic_type = "Blue",
        element = "Dark",
        trait = "Magic Attack Bonus",
        trait_points = 4,
        unbridled = false,
        BLU = 61,
        mp_cost = 112,
        notes = "Dark-based magical damage. MP: 112. Level: 61. Trait: Magic Attack Bonus (4 pts). Recast: 29.25s. Single target. BLU only.",
    },

    ["Osmosis"] = {
        description = "Steals one buff + drain.",
        category = "Magical",
        magic_type = "Blue",
        element = "Dark",
        trait = "Magic Defense Bonus",
        trait_points = 4,
        unbridled = false,
        BLU = 84,
        mp_cost = 47,
        notes = "Dark-based magical drain + buff steal. MP: 47. Level: 84. Trait: Magic Defense Bonus (4 pts). Steals one beneficial status effect from target (cannot miss). Damage = (Blue Magic Skill × 0.11) × 7. Recast: 120s. Single target. BLU only.",
    },

    ["Evryone. Grudge"] = {
        description = "Deals dark dmg (MND/INT).",
        category = "Magical",
        magic_type = "Blue",
        element = "Dark",
        trait = "Gilfinder / Treasure Hunter",
        trait_points = 6,
        unbridled = false,
        BLU = 90,
        mp_cost = 185,
        notes = "Dark-based magical damage. MP: 185. Level: 90. Trait: Gilfinder/Treasure Hunter (6 pts). Damage scales with MND (40%) and INT (2.0 per dINT). Recast: 70s. Single target. BLU only.",
    },

    ["Dark Orb"] = {
        description = "Deals dark dmg.",
        category = "Magical",
        magic_type = "Blue",
        element = "Dark",
        trait = "Counter",
        trait_points = 4,
        unbridled = false,
        BLU = 93,
        mp_cost = 124,
        notes = "Dark-based magical damage. MP: 124. Level: 93. Trait: Counter (4 pts). Damage scales with INT (40% + 2.0 per dINT). Recast: 72s. Single target. BLU only.",
    },

    ["Atra. Libations"] = {
        description = "Steals HP (AoE).",
        category = "Magical",
        magic_type = "Blue",
        element = "Dark",
        trait = "Defense Bonus",
        trait_points = 8,
        unbridled = false,
        BLU = 99,
        mp_cost = 164,
        notes = "Dark-based magical HP drain (AoE). MP: 164. Level: 99. Trait: Defense Bonus (8 pts). HP absorbed = (Blue Magic Skill × 0.11) × 9. Ineffective against undead. Recast: 180s. AoE range. BLU only.",
    },

    ["Tenebral Crush"] = {
        description = "Deals dark dmg + defense down.",
        category = "Magical",
        magic_type = "Blue",
        element = "Dark",
        trait = "Magic Accuracy Bonus",
        trait_points = 8,
        unbridled = false,
        BLU = 99,
        mp_cost = 116,
        notes = "Dark-based magical damage + Defense Down. MP: 116. Level: 99. Trait: Magic Accuracy Bonus (8 pts). Additional effect: -20% defense (180s duration, 90s on NMs). Recast: 60s. AoE range (~10'). BLU only.",
    },

    ["Palling Salvo"] = {
        description = "Deals dark dmg + bio.",
        category = "Magical",
        magic_type = "Blue",
        element = "Dark",
        trait = "Tenacity",
        trait_points = 8,
        unbridled = false,
        BLU = 99,
        mp_cost = 175,
        notes = "Dark-based magical damage + Bio. MP: 175. Level: 99. Trait: Tenacity (8 pts). Additional effect: Bio (-15 HP/tick, -10% attack, 60-90s duration). Recast: 45s. AoE range. BLU only.",
    },

    ["Cruel Joke"] = {
        description = "Inflicts doom (unbridled, AoE).",
        category = "Magical",
        magic_type = "Blue",
        element = "Dark",
        trait = nil,
        trait_points = 0,
        unbridled = true,
        BLU = 99,
        mp_cost = 187,
        notes = "Dark-based magical doom (unbridled, AoE). MP: 187. Level: 99. Trait: None (0 pts). Requires: Unbridled Learning/Wisdom. Inflicts Doom (60s duration, KO after expiration). Doom removed if caster moves >10' away. Does not affect NMs. Recast: 30s. AoE range. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_MAGICAL_DARK


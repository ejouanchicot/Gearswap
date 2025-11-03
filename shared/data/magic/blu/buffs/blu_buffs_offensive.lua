---============================================================================
--- BLUE MAGIC DATABASE - Offensive Buffs
---============================================================================
--- Attack, Magic Attack, Haste, and Critical Hit Blue Magic buffs
---
--- @file blu_buffs_offensive.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-01 | Updated: 2025-11-01
---============================================================================

local BLU_BUFFS_OFFENSIVE = {}

BLU_BUFFS_OFFENSIVE.spells = {

    --============================================================
    -- LEVEL 48
    --============================================================

    ["Refueling"] = {
        description = "Grants haste.",
        category = "Buff",
        magic_type = "Blue",
        element = "Wind",
        trait = nil,
        trait_points = 0,
        property = nil,
        unbridled = false,
        BLU = 48,
        mp_cost = 82,
        notes = "Haste buff (self only). MP: 82. Level: 48. Trait: None (0 pts). Effect: Haste +10%. Duration: 3min. Recast: 120s. BLU only.",
    },

    --============================================================
    -- LEVEL 62
    --============================================================

    ["Memento Mori"] = {
        description = "Grants magic attack.",
        category = "Buff",
        magic_type = "Blue",
        element = "Ice",
        trait = "Magic Attack Bonus",
        trait_points = 4,
        property = nil,
        unbridled = false,
        BLU = 62,
        mp_cost = 33,
        notes = "Magic Attack buff (self only). MP: 33. Level: 62. Trait: Magic Attack Bonus (4 pts). Effect: Magic Attack +20. Additional effect: Max MP down. Duration: 3min. Recast: 90s. BLU only.",
    },

    --============================================================
    -- LEVEL 68
    --============================================================

    ["Warm-Up"] = {
        description = "Grants accuracy + evasion.",
        category = "Buff",
        magic_type = "Blue",
        element = "Earth",
        trait = "Clear Mind",
        trait_points = 4,
        property = nil,
        unbridled = false,
        BLU = 68,
        mp_cost = 59,
        notes = "Accuracy/Evasion buff (self only). MP: 59. Level: 68. Trait: Clear Mind (4 pts). Effect: Accuracy +10, Evasion +10. Duration: 3min. Recast: 120s. BLU only.",
    },

    --============================================================
    -- LEVEL 70
    --============================================================

    ["Amplification"] = {
        description = "Grants magic attack.",
        category = "Buff",
        magic_type = "Blue",
        element = "Water",
        trait = nil,
        trait_points = 0,
        property = nil,
        unbridled = false,
        BLU = 70,
        mp_cost = 30,
        notes = "Magic Attack buff (self only). MP: 30. Level: 70. Trait: None (0 pts). Effect: Magic Attack +15%, Magic Accuracy +15. Duration: 90s. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 71
    --============================================================

    ["Triumphant Roar"] = {
        description = "Grants attack + accuracy.",
        category = "Buff",
        magic_type = "Blue",
        element = "Fire",
        trait = nil,
        trait_points = 0,
        property = nil,
        unbridled = false,
        BLU = 71,
        mp_cost = 30,
        notes = "Attack/Accuracy buff (self only). MP: 30. Level: 71. Trait: None (0 pts). Effect: Attack +15%, Accuracy +15. Duration: 90s. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 74
    --============================================================

    ["Reactor Cool"] = {
        description = "Grants magic attack.",
        category = "Buff",
        magic_type = "Blue",
        element = "Ice",
        trait = "Magic Attack Bonus",
        trait_points = 4,
        property = nil,
        unbridled = false,
        BLU = 74,
        mp_cost = 30,
        notes = "Magic Attack buff (self only). MP: 30. Level: 74. Trait: Magic Attack Bonus (4 pts). Effect: Magic Attack +25. Duration: 3min. Recast: 90s. BLU only.",
    },

    --============================================================
    -- LEVEL 75
    --============================================================

    ["Plasma Charge"] = {
        description = "Grants enspell (thunder).",
        category = "Buff",
        magic_type = "Blue",
        element = "Thunder",
        trait = "Auto Refresh",
        trait_points = 4,
        property = nil,
        unbridled = false,
        BLU = 75,
        mp_cost = 41,
        notes = "Enspell buff (self only). MP: 41. Level: 75. Trait: Auto Refresh (4 pts). Effect: Enspell - Thunder (adds lightning damage to attacks). Duration: 3min. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 79
    --============================================================

    ["Animating Wail"] = {
        description = "Grants haste.",
        category = "Buff",
        magic_type = "Blue",
        element = "Wind",
        trait = "Dual Wield",
        trait_points = 4,
        property = nil,
        unbridled = false,
        BLU = 79,
        mp_cost = 52,
        notes = "Haste buff (self only). MP: 52. Level: 79. Trait: Dual Wield (4 pts). Effect: Haste +10%. Duration: 3min. Recast: 120s. BLU only.",
    },

    --============================================================
    -- LEVEL 85
    --============================================================

    ["Fantod"] = {
        description = "Grants critical hit rate.",
        category = "Buff",
        magic_type = "Blue",
        element = "Fire",
        trait = "Store TP",
        trait_points = 4,
        property = nil,
        unbridled = false,
        BLU = 85,
        mp_cost = 48,
        notes = "Critical Hit buff (self only). MP: 48. Level: 85. Trait: Store TP (4 pts). Effect: Critical Hit Rate +25%. Duration: 90s. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 99
    --============================================================

    ["Nature's Meditation"] = {
        description = "Grants TP regen + attack.",
        category = "Buff",
        magic_type = "Blue",
        element = "Fire",
        trait = "Accuracy Bonus",
        trait_points = 8,
        property = nil,
        unbridled = false,
        BLU = 99,
        mp_cost = 62,
        notes = "TP Regen/Attack buff (self only). MP: 62. Level: 99. Trait: Accuracy Bonus (8 pts). Effect: Regain +10/tick, Attack +10%. Duration: 3min. Recast: 120s. BLU only.",
    },

    ["Erratic Flutter"] = {
        description = "Grants haste (tier II).",
        category = "Buff",
        magic_type = "Blue",
        element = "Wind",
        trait = "Fast Cast",
        trait_points = 8,
        property = nil,
        unbridled = false,
        BLU = 99,
        mp_cost = 92,
        notes = "Haste buff tier II (self only). MP: 92. Level: 99. Trait: Fast Cast (8 pts). Effect: Haste II +29.98% (307/1024). Duration: 5min. Recast: 45s. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_BUFFS_OFFENSIVE

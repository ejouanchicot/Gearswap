---============================================================================
--- BLUE MAGIC DATABASE - Stat Debuffs
---============================================================================
--- Attack, Defense, Magic Attack, and Stat reduction Blue Magic debuffs
---
--- @file blu_debuffs_stats.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06 | Updated: 2025-11-01
---============================================================================

local BLU_DEBUFFS_STATS = {}

BLU_DEBUFFS_STATS.spells = {

    --============================================================
    -- LEVEL 32
    --============================================================

    ["Sound Blast"] = {
        description             = "Inflicts INT down.",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Fire",
        trait                   = "Magic Attack Bonus",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 32,
        mp_cost                 = 26,
        notes                   = "INT down (AoE). MP: 26. Level: 32. Trait: Magic Attack Bonus (4 pts). Effect: INT -10%. Duration: 3min. AoE range. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 42
    --============================================================

    ["Venom Shell"] = {
        description             = "Inflicts poison (AoE).",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = "Clear Mind",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 42,
        mp_cost                 = 32,
        notes                   = "Poison status (AoE). MP: 32. Level: 42. Trait: Clear Mind (4 pts). Effect: Poison (5 HP/tick, 90s duration). AoE range. Recast: 30s. BLU only.",
    },

    --============================================================
    -- LEVEL 44
    --============================================================

    ["Stinking Gas"] = {
        description             = "Inflicts VIT down.",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Auto Refresh",
        trait_points            = 1,
        property                = nil,
        unbridled               = false,
        BLU                     = 44,
        mp_cost                 = 37,
        notes                   = "VIT down (AoE). MP: 37. Level: 44. Trait: Auto Refresh (1 pt). Effect: VIT -10%. Duration: 3min. AoE range. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 46
    --============================================================

    ["Awful Eye"] = {
        description             = "Inflicts STR down.",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = "Clear Mind",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 46,
        mp_cost                 = 34,
        notes                   = "STR down. MP: 34. Level: 46. Trait: Clear Mind (4 pts). Effect: STR -10%. Duration: 3min. Single target. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 50
    --============================================================

    ["Frightful Roar"] = {
        description             = "Inflicts defense down.",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Auto Refresh",
        trait_points            = 2,
        property                = nil,
        unbridled               = false,
        BLU                     = 50,
        mp_cost                 = 32,
        notes                   = "Defense down (AoE). MP: 32. Level: 50. Trait: Auto Refresh (2 pts). Effect: Defense -25%. Duration: 3min. AoE range. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 52
    --============================================================

    ["Cold Wave"] = {
        description             = "Inflicts INT down (AoE).",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Ice",
        trait                   = "Auto Refresh",
        trait_points            = 1,
        property                = nil,
        unbridled               = false,
        BLU                     = 52,
        mp_cost                 = 37,
        notes                   = "INT down (AoE). MP: 37. Level: 52. Trait: Auto Refresh (1 pt). Effect: INT -10%. Duration: 3min. AoE range. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 58
    --============================================================

    ["Light of Penance"] = {
        description             = "Inflicts flash + defense down.",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = "Auto Refresh",
        trait_points            = 2,
        property                = nil,
        unbridled               = false,
        BLU                     = 58,
        mp_cost                 = 36,
        notes                   = "Flash + Defense down (AoE). MP: 36. Level: 58. Trait: Auto Refresh (2 pts). Effect: Accuracy -20 (flash), Defense -25%. Duration: 3min. AoE range. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 64
    --============================================================

    ["Feather Tickle"] = {
        description             = "Inflicts critical hit rate down.",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Clear Mind",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 64,
        mp_cost                 = 32,
        notes                   = "Critical Hit Rate down. MP: 32. Level: 64. Trait: Clear Mind (4 pts). Effect: Critical Hit Rate -25%. Duration: 3min. Single target. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 66
    --============================================================

    ["Sandspray"] = {
        description             = "Inflicts accuracy down.",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = "Clear Mind",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 66,
        mp_cost                 = 37,
        notes                   = "Accuracy down (AoE). MP: 37. Level: 66. Trait: Clear Mind (4 pts). Effect: Accuracy -40. Duration: 3min. AoE range. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 67
    --============================================================

    ["Enervation"] = {
        description             = "Inflicts magic attack down.",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = "Counter",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 67,
        mp_cost                 = 36,
        notes                   = "Magic Attack down. MP: 36. Level: 67. Trait: Counter (4 pts). Effect: Magic Attack -20%. Duration: 3min. Single target. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 71
    --============================================================

    ["Lowing"] = {
        description             = "Inflicts attack down.",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Fire",
        trait                   = "Clear Mind",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 71,
        mp_cost                 = 38,
        notes                   = "Attack down (AoE). MP: 38. Level: 71. Trait: Clear Mind (4 pts). Effect: Attack -25%. Duration: 3min. AoE range. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 78
    --============================================================

    ["Cimicine Discharge"] = {
        description             = "Inflicts magic evasion down.",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Earth",
        trait                   = "Magic Burst Bonus",
        trait_points            = 6,
        property                = nil,
        unbridled               = false,
        BLU                     = 78,
        mp_cost                 = 45,
        notes                   = "Magic Evasion down (AoE). MP: 45. Level: 78. Trait: Magic Burst Bonus (6 pts). Effect: Magic Evasion -50. Duration: 3min. AoE range. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 80
    --============================================================

    ["Demoralizing Roar"] = {
        description             = "Inflicts attack down (AoE).",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = "Double / Triple Attack",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 80,
        mp_cost                 = 42,
        notes                   = "Attack down (AoE). MP: 42. Level: 80. Trait: Double/Triple Attack (4 pts). Effect: Attack -30%. Duration: 3min. AoE range. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 90
    --============================================================

    ["Reaving Wind"] = {
        description             = "Inflicts defense down + dispel.",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Magic Burst Bonus",
        trait_points            = 6,
        property                = nil,
        unbridled               = false,
        BLU                     = 90,
        mp_cost                 = 49,
        notes                   = "Defense down + Dispel (AoE). MP: 49. Level: 90. Trait: Magic Burst Bonus (6 pts). Effect: Defense -30% + Dispels beneficial effects. Duration: 3min. AoE range. Recast: 60s. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_DEBUFFS_STATS

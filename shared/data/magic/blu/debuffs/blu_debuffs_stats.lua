---============================================================================
--- BLUE MAGIC DATABASE - Stat Debuffs
---============================================================================
--- Attack, Defense, Magic Attack, and Stat reduction Blue Magic debuffs
---
--- @file shared/data/magic/blu/debuffs/blu_debuffs_stats.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06
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
        mp_cost                 = 25,
        notes                   = "INT down (AoE, centered on caster). MP: 25. Level: 32. Trait: Magic Attack Bonus. Duration: 30s. Recast: 30s. Range: 6'. BLU only.",
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
        mp_cost                 = 86,
        notes                   = "Poison status (AoE). MP: 86. Level: 42. Trait: Clear Mind. Effect: Poison 6 HP/tick. Duration: 45s. Recast: 45s. BLU only.",
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
        notes                   = "VIT down (AoE, centered on caster). MP: 37. Level: 44. Trait: Auto Refresh. Duration: 60s. Recast: 60s. Range: 6'. BLU only.",
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
        mp_cost                 = 32,
        notes                   = "STR down (AoE conal). MP: 32. Level: 46. Trait: Clear Mind. Stats: MND +1. Effect: STR -30, decays over time. Duration: 30s. Recast: 60s. BLU only.",
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
        notes                   = "Defense down (AoE around the caster). MP: 32. Level: 50. Trait: Auto Refresh. Stats: AGI +2. Effect: Defense -10% (26/256). Duration: 3min. Recast: 20s. BLU only.",
    },

    --============================================================
    -- LEVEL 52
    --============================================================

    ["Cold Wave"] = {
        description             = "Inflicts AGI down + Frost DoT (AoE).",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Ice",
        trait                   = "Auto Refresh",
        trait_points            = 1,
        property                = nil,
        unbridled               = false,
        BLU                     = 52,
        mp_cost                 = 37,
        notes                   = "AGI down + Frost (AoE). MP: 37. Level: 52. Trait: Auto Refresh. Effect: AGI -(level/2), cap -49, decays; Frost DoT; no initial damage. Duration: 30s. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 58
    --============================================================

    ["Light of Penance"] = {
        description             = "Reduces TP + blind + bind.",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = "Auto Refresh",
        trait_points            = 2,
        property                = nil,
        unbridled               = false,
        BLU                     = 58,
        mp_cost                 = 53,
        notes                   = "TP reduction + Blind + Bind (single target, gaze). MP: 53. Level: 58. Trait: Auto Refresh. Stats: CHR +1, HP +15. Effect: TP -100, Blind (-100 accuracy), Bind. Duration: 30s. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 64
    --============================================================

    ["Feather Tickle"] = {
        description             = "Reduces enemy TP.",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Clear Mind",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 64,
        mp_cost                 = 48,
        notes                   = "TP reduction (single target). MP: 48. Level: 64. Trait: Clear Mind. Stats: AGI +1. Effect: Reduces TP by a random 0-1500. Recast: 90s. BLU only.",
    },

    --============================================================
    -- LEVEL 66
    --============================================================

    ["Sandspray"] = {
        description             = "Inflicts blind (conal).",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = "Clear Mind",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 66,
        mp_cost                 = 43,
        notes                   = "Blind (AoE conal). MP: 43. Level: 66. Trait: Clear Mind. Stats: VIT +1. Effect: Accuracy -25; overwritten by Blind, Blind II and Kurayami. Recast: 60-120s. BLU only.",
    },

    --============================================================
    -- LEVEL 67
    --============================================================

    ["Enervation"] = {
        description             = "Inflicts defense + magic defense down (AoE).",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = "Counter",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 67,
        mp_cost                 = 48,
        notes                   = "Defense + Magic Defense down (AoE). MP: 48. Level: 67. Trait: Counter. Stats: HP -5, MP +5. Effect: Defense -10% (26/256), Magic Defense Bonus -8. Duration: 30s. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 71
    --============================================================

    ["Lowing"] = {
        description             = "Inflicts plague (AoE).",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Fire",
        trait                   = "Clear Mind",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 71,
        mp_cost                 = 66,
        notes                   = "Plague (AoE). MP: 66. Level: 71. Trait: Clear Mind. Stats: HP -5. Effect: Plague (-50 TP/tick, -3 MP/tick). Duration: 40-60s. Recast: 120s. BLU only.",
    },

    --============================================================
    -- LEVEL 78
    --============================================================

    ["Cimicine Discharge"] = {
        description             = "Inflicts slow (AoE).",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Earth",
        trait                   = "Magic Burst Bonus",
        trait_points            = 6,
        property                = nil,
        unbridled               = false,
        BLU                     = 78,
        mp_cost                 = 32,
        notes                   = "Slow (AoE). MP: 32. Level: 78. Trait: Magic Burst Bonus. Stats: DEX +1, AGI +2. Effect: Slow (19.5%). Duration: 90s. Recast: 20s. BLU only.",
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
        mp_cost                 = 46,
        notes                   = "Attack down (AoE). MP: 46. Level: 80. Trait: Double Attack / Triple Attack. Stats: STR -2, VIT +3. Effect: Attack -20%. Duration: 30s. Recast: 20s. BLU only.",
    },

    --============================================================
    -- LEVEL 90
    --============================================================

    ["Reaving Wind"] = {
        description             = "Reduces enemy TP (AoE).",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Magic Burst Bonus",
        trait_points            = 6,
        property                = nil,
        unbridled               = false,
        BLU                     = 90,
        mp_cost                 = 84,
        notes                   = "TP reduction (AoE). MP: 84. Level: 90. Trait: Magic Burst Bonus. Stats: STR +2, AGI +2. Effect: TP -1000 (-750 vs Amorphs, -1250 vs Aquans). Recast: 90s. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_DEBUFFS_STATS

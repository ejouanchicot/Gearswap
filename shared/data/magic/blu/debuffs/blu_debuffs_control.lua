---============================================================================
--- BLUE MAGIC DATABASE - Control Debuffs
---============================================================================
--- Sleep, Stun, Slow, Terror, Silence, Blind, Doom, and Dispel Blue Magic debuffs
---
--- @file shared/data/magic/blu/debuffs/blu_debuffs_control.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06
---============================================================================

local BLU_DEBUFFS_CONTROL = {}

BLU_DEBUFFS_CONTROL.spells = {

    --============================================================
    -- LEVEL 16
    --============================================================

    ["Sheep Song"] = {
        description             = "Inflicts sleep (AoE).",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = "Auto Regen",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 16,
        mp_cost                 = 22,
        notes                   = "Sleep (AoE around the caster). MP: 22. Level: 16. Trait: Auto Regen. Stats: CHR +1, HP +5. Effect: Sleep (40-60s). Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 24
    --============================================================

    ["Soporific"] = {
        description             = "Inflicts sleep (AoE).",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = "Clear Mind",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 24,
        mp_cost                 = 38,
        notes                   = "Sleep (AoE around the caster). MP: 38. Level: 24. Trait: Clear Mind. Stats: HP -5, MP +5. Effect: Sleep (90s). Recast: 90s. BLU only.",
    },

    --============================================================
    -- LEVEL 32
    --============================================================

    ["Chaotic Eye"] = {
        description             = "Inflicts silence.",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Conserve MP",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 32,
        mp_cost                 = 13,
        notes                   = "Silence (single target, gaze). MP: 13. Level: 32. Trait: Conserve MP. Stats: AGI +1. Effect: Silence (5-120s); the enemy must be facing you; overwritten by Silence. Recast: 10s. BLU only.",
    },

    --============================================================
    -- LEVEL 38
    --============================================================

    ["Blank Gaze"] = {
        description             = "Dispels beneficial effects.",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 38,
        mp_cost                 = 25,
        notes                   = "Dispel (single target, gaze). MP: 25. Level: 38. Trait: None. Effect: Removes 1 beneficial magic effect; the enemy must be facing you. Recast: 10s. BLU only.",
    },

    --============================================================
    -- LEVEL 46
    --============================================================

    ["Geist Wall"] = {
        description             = "Dispels beneficial effects.",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 46,
        mp_cost                 = 35,
        notes                   = "Dispel (AoE around the caster). MP: 35. Level: 46. Trait: None. Effect: Removes 1 beneficial magic effect from enemies in range. Recast: 30s. BLU only.",
    },

    --============================================================
    -- LEVEL 48
    --============================================================

    ["Jettatura"] = {
        description             = "Inflicts terror.",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 48,
        mp_cost                 = 37,
        notes                   = "Terror (AoE conal, gaze). MP: 37. Level: 48. Trait: None. Stats: MP +15. Effect: Terror (~2s); enmity is gained even if it does not land. Recast: 120s. BLU only.",
    },

    --============================================================
    -- LEVEL 52
    --============================================================

    ["Filamented Hold"] = {
        description             = "Inflicts slow (conal).",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Earth",
        trait                   = "Clear Mind",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 52,
        mp_cost                 = 38,
        notes                   = "Slow status (AoE conal). MP: 38. Level: 52. Trait: Clear Mind. Effect: Slow (~25%). Duration: 90s. Recast: 20s. BLU only.",
    },

    --============================================================
    -- LEVEL 64
    --============================================================

    ["Yawn"] = {
        description             = "Inflicts sleep (AoE, gaze).",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = "Resist Sleep",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 64,
        mp_cost                 = 55,
        notes                   = "Sleep (AoE, gaze). MP: 55. Level: 64. Trait: Resist Sleep. Stats: CHR +1, HP +5. Effect: Sleep (70-90s); the enemy must be facing you. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 65
    --============================================================

    ["Infrasonics"] = {
        description             = "Inflicts evasion down.",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Ice",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 65,
        mp_cost                 = 42,
        notes                   = "Evasion down (AoE conal). MP: 42. Level: 65. Trait: None. Effect: Evasion -20. Duration: 60s. Recast: 120s. BLU only.",
    },

    --============================================================
    -- LEVEL 73
    --============================================================

    ["Temporal Shift"] = {
        description             = "Inflicts stun (AoE).",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Thunder",
        trait                   = "Attack Bonus",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 73,
        mp_cost                 = 48,
        notes                   = "Stun (AoE centered on the caster). MP: 48. Level: 73. Trait: Attack Bonus. Effect: Stun. Recast: 120s. BLU only.",
    },

    --============================================================
    -- LEVEL 74
    --============================================================

    ["Actinic Burst"] = {
        description             = "Inflicts flash (AoE).",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = "Auto Refresh",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 74,
        mp_cost                 = 24,
        notes                   = "Flash (AoE). MP: 24. Level: 74. Trait: Auto Refresh. Stats: CHR +2, HP +20. Effect: Flash (greatly lowers accuracy for a brief time). Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 84
    --============================================================

    ["Auroral Drape"] = {
        description             = "Inflicts silence + blind (AoE).",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Fast Cast",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 84,
        mp_cost                 = 51,
        notes                   = "Silence + Blind (AoE). MP: 51. Level: 84. Trait: Fast Cast. Effect: Silence, Blind (-60 accuracy). Duration: 40-60s. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 87
    --============================================================

    ["Dream Flower"] = {
        description             = "Inflicts sleep (AoE).",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = "Magic Attack Bonus",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 87,
        mp_cost                 = 68,
        notes                   = "Sleep (AoE around the caster). MP: 68. Level: 87. Trait: Magic Attack Bonus. Stats: HP +5, MP +5, CHR +2. Effect: Sleep (90s). Recast: 45s. BLU only.",
    },

    --============================================================
    -- LEVEL 91
    --============================================================

    ["Mortal Ray"] = {
        description             = "Inflicts doom.",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = "Dual Wield",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 91,
        mp_cost                 = 267,
        notes                   = "Doom (single target, gaze). MP: 267. Level: 91. Trait: Dual Wield. Stats: STR +2, MND +2. Effect: Doom (KO after 63s; wears off beyond 10' from the target); very low accuracy. Recast: 150s. BLU only.",
    },

    --============================================================
    -- LEVEL 96
    --============================================================

    ["Absolute Terror"] = {
        description             = "Inflicts terror (unbridled).",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = true,
        BLU                     = 96,
        mp_cost                 = 29,
        notes                   = "Terror (single target, unbridled). MP: 29. Level: 96. Trait: None. Effect: Terror; success rate and duration improve with Blue Magic Skill and Magic Accuracy. Recast: 30s. Requires: Unbridled Learning. BLU only.",
    },

    --============================================================
    -- LEVEL 99
    --============================================================

    ["Blistering Roar"] = {
        description             = "Inflicts terror (AoE, unbridled).",
        category                = "Debuff",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = true,
        BLU                     = 99,
        mp_cost                 = 43,
        notes                   = "Terror (AoE, unbridled). MP: 43. Level: 99. Trait: None. Effect: Terror. Recast: 120s. Requires: Unbridled Learning. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_DEBUFFS_CONTROL

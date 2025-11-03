---============================================================================
--- BLUE MAGIC DATABASE - Control Debuffs
---============================================================================
--- Sleep, Stun, Bind, Terror, Silence, Doom, and Dispel Blue Magic debuffs
---
--- @file blu_debuffs_control.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-01 | Updated: 2025-11-01
---============================================================================

local BLU_DEBUFFS_CONTROL = {}

BLU_DEBUFFS_CONTROL.spells = {

    --============================================================
    -- LEVEL 16
    --============================================================

    ["Sheep Song"] = {
        description = "Inflicts sleep (AoE).",
        category = "Debuff",
        magic_type = "Blue",
        element = "Light",
        trait = "Auto Regen",
        trait_points = 4,
        property = nil,
        unbridled = false,
        BLU = 16,
        mp_cost = 33,
        notes = "Sleep status (AoE). MP: 33. Level: 16. Trait: Auto Regen (4 pts). Effect: Sleep (90s duration). Range: 10 yalms. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 24
    --============================================================

    ["Soporific"] = {
        description = "Inflicts sleep (conal).",
        category = "Debuff",
        magic_type = "Blue",
        element = "Dark",
        trait = "Clear Mind",
        trait_points = 4,
        property = nil,
        unbridled = false,
        BLU = 24,
        mp_cost = 38,
        notes = "Sleep status (AoE conal). MP: 38. Level: 24. Trait: Clear Mind (4 pts). Effect: Sleep (90s duration). Fan-shaped area. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 32
    --============================================================

    ["Chaotic Eye"] = {
        description = "Inflicts silence.",
        category = "Debuff",
        magic_type = "Blue",
        element = "Wind",
        trait = "Conserve MP",
        trait_points = 4,
        property = nil,
        unbridled = false,
        BLU = 32,
        mp_cost = 25,
        notes = "Silence status. MP: 25. Level: 32. Trait: Conserve MP (4 pts). Effect: Silence (prevents spellcasting, 60s duration). Single target. Recast: 30s. BLU only.",
    },

    --============================================================
    -- LEVEL 38
    --============================================================

    ["Blank Gaze"] = {
        description = "Dispels beneficial effects.",
        category = "Debuff",
        magic_type = "Blue",
        element = "Light",
        trait = nil,
        trait_points = 0,
        property = nil,
        unbridled = false,
        BLU = 38,
        mp_cost = 25,
        notes = "Dispel (removes buffs). MP: 25. Level: 38. Trait: None (0 pts). Effect: Dispels 1 beneficial effect from enemy. Single target. Recast: 30s. BLU only.",
    },

    --============================================================
    -- LEVEL 46
    --============================================================

    ["Geist Wall"] = {
        description = "Dispels beneficial effects.",
        category = "Debuff",
        magic_type = "Blue",
        element = "Dark",
        trait = nil,
        trait_points = 0,
        property = nil,
        unbridled = false,
        BLU = 46,
        mp_cost = 35,
        notes = "Dispel (removes buffs, AoE). MP: 35. Level: 46. Trait: None (0 pts). Effect: Dispels 1 beneficial effect from enemies. AoE range. Recast: 30s. BLU only.",
    },

    --============================================================
    -- LEVEL 48
    --============================================================

    ["Jettatura"] = {
        description = "Inflicts terror.",
        category = "Debuff",
        magic_type = "Blue",
        element = "Dark",
        trait = nil,
        trait_points = 0,
        property = nil,
        unbridled = false,
        BLU = 48,
        mp_cost = 37,
        notes = "Terror status. MP: 37. Level: 48. Trait: None (0 pts). Effect: Terror (prevents action, 15s duration). Single target. Recast: 30s. BLU only.",
    },

    --============================================================
    -- LEVEL 52
    --============================================================

    ["Filamented Hold"] = {
        description = "Inflicts bind.",
        category = "Debuff",
        magic_type = "Blue",
        element = "Earth",
        trait = "Clear Mind",
        trait_points = 4,
        property = nil,
        unbridled = false,
        BLU = 52,
        mp_cost = 32,
        notes = "Bind status. MP: 32. Level: 52. Trait: Clear Mind (4 pts). Effect: Bind (prevents movement, 60s duration). Single target. Recast: 30s. BLU only.",
    },

    --============================================================
    -- LEVEL 64
    --============================================================

    ["Yawn"] = {
        description = "Inflicts sleep (conal).",
        category = "Debuff",
        magic_type = "Blue",
        element = "Light",
        trait = "Resist Sleep",
        trait_points = 4,
        property = nil,
        unbridled = false,
        BLU = 64,
        mp_cost = 55,
        notes = "Sleep status (AoE conal). MP: 55. Level: 64. Trait: Resist Sleep (4 pts). Effect: Sleep (90s duration). Fan-shaped area. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 65
    --============================================================

    ["Infrasonics"] = {
        description = "Inflicts evasion down.",
        category = "Debuff",
        magic_type = "Blue",
        element = "Ice",
        trait = nil,
        trait_points = 0,
        property = nil,
        unbridled = false,
        BLU = 65,
        mp_cost = 42,
        notes = "Evasion down (AoE). MP: 42. Level: 65. Trait: None (0 pts). Effect: Evasion -40. Duration: 3min. AoE range. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 73
    --============================================================

    ["Temporal Shift"] = {
        description = "Inflicts slow + gravity.",
        category = "Debuff",
        magic_type = "Blue",
        element = "Thunder",
        trait = "Attack Bonus",
        trait_points = 4,
        property = nil,
        unbridled = false,
        BLU = 73,
        mp_cost = 48,
        notes = "Slow + Gravity status. MP: 48. Level: 73. Trait: Attack Bonus (4 pts). Effect: Slow (haste down) + Gravity (movement speed down). Duration: 3min. Single target. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 74
    --============================================================

    ["Actinic Burst"] = {
        description = "Inflicts stun + blind.",
        category = "Debuff",
        magic_type = "Blue",
        element = "Light",
        trait = "Auto Refresh",
        trait_points = 4,
        property = nil,
        unbridled = false,
        BLU = 74,
        mp_cost = 33,
        notes = "Stun + Blind status (AoE). MP: 33. Level: 74. Trait: Auto Refresh (4 pts). Effect: Stun (interrupts action) + Blind (accuracy down, 3min). AoE range. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 87
    --============================================================

    ["Dream Flower"] = {
        description = "Inflicts sleep (AoE).",
        category = "Debuff",
        magic_type = "Blue",
        element = "Light",
        trait = "Magic Attack Bonus",
        trait_points = 4,
        property = nil,
        unbridled = false,
        BLU = 87,
        mp_cost = 44,
        notes = "Sleep status (AoE). MP: 44. Level: 87. Trait: Magic Attack Bonus (4 pts). Effect: Sleep (90s duration). AoE range. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 91
    --============================================================

    ["Mortal Ray"] = {
        description = "Inflicts doom.",
        category = "Debuff",
        magic_type = "Blue",
        element = "Dark",
        trait = "Dual Wield",
        trait_points = 4,
        property = nil,
        unbridled = false,
        BLU = 91,
        mp_cost = 101,
        notes = "Doom status. MP: 101. Level: 91. Trait: Dual Wield (4 pts). Effect: Doom (KO after countdown, 60s). Single target. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 96
    --============================================================

    ["Absolute Terror"] = {
        description = "Inflicts terror (AoE, unbridled).",
        category = "Debuff",
        magic_type = "Blue",
        element = "Dark",
        trait = nil,
        trait_points = 0,
        property = nil,
        unbridled = true,
        BLU = 96,
        mp_cost = 73,
        notes = "Terror status (AoE, unbridled). MP: 73. Level: 96. Trait: None (0 pts). Effect: Terror (prevents action, 20s duration). AoE range. Recast: 60s. Requires: Unbridled Learning/Wisdom. BLU only.",
    },

    --============================================================
    -- LEVEL 99
    --============================================================

    ["Blistering Roar"] = {
        description = "Inflicts attack/defense down (unbridled).",
        category = "Debuff",
        magic_type = "Blue",
        element = "Dark",
        trait = nil,
        trait_points = 0,
        property = nil,
        unbridled = true,
        BLU = 99,
        mp_cost = 89,
        notes = "Multi-debuff (AoE, unbridled). MP: 89. Level: 99. Trait: None (0 pts). Effect: Attack -50%, Defense -50%. Duration: 3min. AoE range. Recast: 60s. Requires: Unbridled Learning/Wisdom. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_DEBUFFS_CONTROL

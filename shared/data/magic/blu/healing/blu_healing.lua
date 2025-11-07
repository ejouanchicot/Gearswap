---============================================================================
--- BLUE MAGIC DATABASE - Healing Spells
---============================================================================
--- Healing and status removal Blue Magic spells
---
--- @file blu_healing.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06 | Updated: 2025-11-01
---============================================================================

local BLU_HEALING = {}

BLU_HEALING.spells = {

    --============================================================
    -- LEVEL 1
    --============================================================

    ["Pollen"] = {
        description             = "Restores HP (self).",
        category                = "Healing",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = "Resist Sleep",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 1,
        mp_cost                 = 5,
        notes                   = "HP restoration (self only). MP: 5. Level: 1. Trait: Resist Sleep (4 pts). Healing: ~36 HP (soft cap, scales with MND). Stats: CHR +1, HP +5. Recast: 5s. BLU only.",
    },

    --============================================================
    -- LEVEL 16
    --============================================================

    ["Healing Breeze"] = {
        description             = "Restores HP (AoE).",
        category                = "Healing",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Auto Regen",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 16,
        mp_cost                 = 55,
        notes                   = "HP restoration (party AoE). MP: 55. Level: 16. Trait: Auto Regen (4 pts). Healing: ~180 HP (soft cap, scales with MND/VIT). Range: 10 yalms. Recast: 15s. BLU only.",
    },

    --============================================================
    -- LEVEL 30
    --============================================================

    ["Wild Carrot"] = {
        description             = "Restores HP.",
        category                = "Healing",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = "Resist Sleep",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 30,
        mp_cost                 = 37,
        notes                   = "HP restoration (single target). MP: 37. Level: 30. Trait: Resist Sleep (4 pts). Healing: ~180 HP (soft cap, scales with MND/VIT/Healing Magic Skill). Range: 20 yalms. Recast: 6s. BLU only.",
    },

    --============================================================
    -- LEVEL 58
    --============================================================

    ["Magic Fruit"] = {
        description             = "Restores HP (Cure IV tier).",
        category                = "Healing",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = "Resist Sleep",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 58,
        mp_cost                 = 72,
        notes                   = "HP restoration (single target). MP: 72. Level: 58. Trait: Resist Sleep (4 pts). Healing: ~550 HP (soft cap 550, hard cap 610, Cure IV equivalent, scales with MND/VIT/Healing Magic Skill). Range: 20 yalms. Recast: 6s. BLU only.",
    },

    --============================================================
    -- LEVEL 75
    --============================================================

    ["Exuviation"] = {
        description             = "Restores HP + erase.",
        category                = "Healing",
        magic_type              = "Blue",
        element                 = "Fire",
        trait                   = "Resist Sleep",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 75,
        mp_cost                 = 40,
        notes                   = "HP restoration + status removal (self only). MP: 40. Level: 75. Trait: Resist Sleep (4 pts). Effect: Restores HP + removes 1 detrimental magic effect (Erase equivalent). Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 76
    --============================================================

    ["Plenilune Embrace"] = {
        description             = "Restores HP + buffs (moon-based).",
        category                = "Healing",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 76,
        mp_cost                 = 106,
        notes                   = "HP restoration + ATK/MAB buffs (single target). MP: 106. Level: 76. Trait: None (0 pts). Healing: ~650 HP (soft cap 650, hard cap 710, Cure IV-V equivalent). Buffs: ATK +10-15%, MAB +1-15% (moon phase dependent). Cast: 4s. Recast: 10s. Range: 20 yalms. BLU only.",
    },

    --============================================================
    -- LEVEL 78
    --============================================================

    ["Regeneration"] = {
        description             = "Grants regen (self).",
        category                = "Healing",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 78,
        mp_cost                 = 36,
        notes                   = "HP regeneration over time (self only). MP: 36. Level: 78. Trait: None (0 pts). Regen: 25 HP/tick for 30 ticks (750 HP total over 90s). Duration: 90s. Stacks with other regen effects. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 94
    --============================================================

    ["White Wind"] = {
        description             = "Restores HP (AoE, max HP-based).",
        category                = "Healing",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Auto Regen",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 94,
        mp_cost                 = 145,
        notes                   = "HP restoration (party AoE). MP: 145. Level: 94. Trait: Auto Regen (4 pts). Healing: floor(MaxHP/7) × 2 (scales with caster's max HP, not current HP). Enhanced by Cure Potency. Range: 10 yalms. Cast: 7s. Recast: 20s. BLU only.",
    },

    --============================================================
    -- LEVEL 99
    --============================================================

    ["Restoral"] = {
        description             = "Restores HP (self, high potency).",
        category                = "Healing",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = "Max HP Boost",
        trait_points            = 8,
        property                = nil,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 127,
        notes                   = "HP restoration (self only, high potency). MP: 127. Level: 99. Trait: Max HP Boost (8 pts). Healing: ~640 HP base (soft cap 1040 HP, scales with Blue Magic Skill/MND/VIT). Recast: 10s. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_HEALING

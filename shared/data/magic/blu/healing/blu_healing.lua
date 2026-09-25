---============================================================================
--- BLUE MAGIC DATABASE - Healing Spells
---============================================================================
--- Healing and status removal Blue Magic spells
---
--- @file shared/data/magic/blu/healing/blu_healing.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06
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
        notes                   = "HP restoration (self only). Level: 1. Trait: Resist Sleep. Healing: soft cap 36 HP, MND heavily influential. Stats: CHR +1, HP +5. Recast: 5s. BLU only.",
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
        notes                   = "HP restoration (party AoE). MP: 55. Level: 16. Trait: Auto Regen. Healing: soft cap 180 HP, MND primary, VIT secondary. Enhanced by Cure Potency. Range: 10'. Recast: 15s. BLU only.",
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
        notes                   = "HP restoration (single target). MP: 37. Level: 30. Trait: Resist Sleep. Healing: soft cap 180 HP, scales with MND/VIT/Healing Magic Skill. Not affected by day/weather. Range: 20'. Recast: 6s. BLU only.",
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
        notes                   = "HP restoration (single target). MP: 72. Level: 58. Trait: Resist Sleep. Healing: soft cap 550, hard cap 610 (roughly Cure IV), scales with MND/VIT/Healing Magic Skill. Not affected by day/weather. Range: 20'. Recast: 6s. BLU only.",
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
        notes                   = "HP restoration + status removal (self only). MP: 40. Level: 75. Trait: Resist Sleep. Effect: Restores HP (soft cap 85 HP) + removes 1 detrimental effect that Erase can remove. Recast: 60s. BLU only.",
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
        notes                   = "HP restoration + Attack/Magic Attack boost (single target). MP: 106. Level: 76. Trait: None. Healing: soft cap 650, hard cap 710 (between Cure IV and Cure V). Buffs: Attack ~1-15% and Magic Attack ~1-15, inverted by moon phase. Duration: 90s. Range: 20'. BLU only.",
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
        notes                   = "HP regeneration over time (self only). MP: 36. Level: 78. Trait: None. Regen: 25 HP/tick for 30 ticks (750 HP total). Duration: 90s. Stacks with Mighty Guard regen. Recast: 60s. BLU only.",
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
        notes                   = "HP restoration (party AoE). MP: 145. Level: 94. Trait: Auto Regen. Healing: floor(MaxHP/7) x 2 (max HP, not current HP). Enhanced by Cure Potency, obis and weather; not affected by Healing Magic Skill or MND. Range: ~10'. BLU only.",
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
        notes                   = "HP restoration (self only, roughly Cure VI). MP: 127. Level: 99. Trait: Max HP Boost. Healing: base 640, soft cap 1040 HP; Blue Magic Skill replaces Healing Magic Skill (2 skill = 1 HP). Affected by day/weather. Recast: 10s. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_HEALING

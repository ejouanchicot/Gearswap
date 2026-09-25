---============================================================================
--- BLUE MAGIC DATABASE - Breath Spells
---============================================================================
--- Breath-type Blue Magic spells (HP-based damage, AoE conal)
---
--- @file shared/data/magic/blu/breath/blu_breath.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06
---============================================================================

local BLU_BREATH = {}

BLU_BREATH.spells = {

    --============================================================
    -- LEVEL 22
    --============================================================

    ["Poison Breath"] = {
        description             = "Deals water dmg + poison.",
        category                = "Breath",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = "Clear Mind",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 22,
        mp_cost                 = 22,
        notes                   = "Water breath damage (AoE conal). MP: 22. Level: 22. Trait: Clear Mind. Additional effect: Poison (4 dmg/tick, 30s). Damage: (Current HP)/10 + (Level)/1.25. Recast: 60s. Fan-shaped area. BLU only.",
    },

    --============================================================
    -- LEVEL 46
    --============================================================

    ["Magnetite Cloud"] = {
        description             = "Deals earth dmg + gravity.",
        category                = "Breath",
        magic_type              = "Blue",
        element                 = "Earth",
        trait                   = "Magic Defense Bonus",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 46,
        mp_cost                 = 86,
        notes                   = "Earth breath damage (AoE conal). MP: 86. Level: 46. Trait: Magic Defense Bonus. Additional effect: Gravity (-26% movement speed, 30-120s). Damage: (HP/6) × (Level/1.875). Recast: 29.25s. Fan-shaped area. BLU only.",
    },

    --============================================================
    -- LEVEL 54
    --============================================================

    ["Hecatomb Wave"] = {
        description             = "Deals wind dmg + blind.",
        category                = "Breath",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Max MP Boost",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 54,
        mp_cost                 = 116,
        notes                   = "Wind breath damage (AoE conal). MP: 116. Level: 54. Trait: Max MP Boost. Stats: AGI +1. Additional effect: Blindness. Damage: (Current HP)/4 + (Level)/1.5. Bonus: +25% damage vs Dragons. Recast: 33.75s. BLU only.",
    },

    ["Radiant Breath"] = {
        description             = "Deals light dmg + slow + silence.",
        category                = "Breath",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 54,
        mp_cost                 = 116,
        notes                   = "Light breath damage (AoE conal). MP: 116. Level: 54. Trait: None. Stats: CHR +1, HP +5. Additional effect: Slow + Silence (90s). Damage: (Current HP)/5 + (Level)/0.75. Bonus: +25% damage vs Demons. Recast: 33.75s. BLU only.",
    },

    --============================================================
    -- LEVEL 58
    --============================================================

    ["Flying Hip Press"] = {
        description             = "Deals wind dmg (AoE).",
        category                = "Breath",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Max HP Boost",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 58,
        mp_cost                 = 125,
        notes                   = "Wind breath damage (AoE around the caster, not conal). MP: 125. Level: 58. Trait: Max HP Boost. Stats: AGI +1. Damage: (Current HP)/3. Recast: 34.5s. BLU only.",
    },

    --============================================================
    -- LEVEL 61
    --============================================================

    ["Bad Breath"] = {
        description             = "Deals earth dmg + 7 ailments.",
        category                = "Breath",
        magic_type              = "Blue",
        element                 = "Earth",
        trait                   = "Fast Cast",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 61,
        mp_cost                 = 212,
        notes                   = "Earth breath damage (AoE conal). MP: 212. Level: 61. Trait: Fast Cast. Stats: INT +2, MND +2. Damage: (Current HP)/8 + (Level)/3. Additional effect: Slow, Poison, Silence, Paralyze, Gravity, Bind and Blind (shared timer, usually under 1min). Recast: 120s. BLU only.",
    },

    --============================================================
    -- LEVEL 66
    --============================================================

    ["Frost Breath"] = {
        description             = "Deals ice dmg + paralyze.",
        category                = "Breath",
        magic_type              = "Blue",
        element                 = "Ice",
        trait                   = "Conserve MP",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 66,
        mp_cost                 = 136,
        notes                   = "Ice breath damage (AoE conal). MP: 136. Level: 66. Trait: Conserve MP. Stats: INT -2. Damage: (Current HP)/3 + (Level)/0.625. Additional effect: Paralyze (12.5% potency, 3min). Bonus: +25% damage vs Vermin, -25% vs Beasts. Recast: 43s. BLU only.",
    },

    --============================================================
    -- LEVEL 71
    --============================================================

    ["Heat Breath"] = {
        description             = "Deals fire dmg.",
        category                = "Breath",
        magic_type              = "Blue",
        element                 = "Fire",
        trait                   = "Magic Attack Bonus",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 71,
        mp_cost                 = 169,
        notes                   = "Fire breath damage (AoE conal). MP: 169. Level: 71. Trait: Magic Attack Bonus. Stats: STR +3. Damage: (Current HP)/2 (not affected by Magic Attack Bonus, increased by Convergence). Recast: 49s. BLU only.",
    },

    --============================================================
    -- LEVEL 96
    --============================================================

    ["Vapor Spray"] = {
        description             = "Deals water dmg.",
        category                = "Breath",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = "Max MP Boost",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 96,
        mp_cost                 = 172,
        notes                   = "Water breath damage (AoE conal). MP: 172. Level: 96. Trait: Max MP Boost. Stats: HP +15, VIT +4. Recast: 56s. Fan-shaped area. BLU only.",
    },

    --============================================================
    -- LEVEL 97
    --============================================================

    ["Thunder Breath"] = {
        description             = "Deals thunder dmg.",
        category                = "Breath",
        magic_type              = "Blue",
        element                 = "Thunder",
        trait                   = "Max HP Boost",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 97,
        mp_cost                 = 193,
        notes                   = "Thunder breath damage (AoE conal). MP: 193. Level: 97. Trait: Max HP Boost. Stats: STR +2, DEX +2. Recast: 112s. BLU only.",
    },

    --============================================================
    -- LEVEL 99
    --============================================================

    ["Wind Breath"] = {
        description             = "Deals wind dmg.",
        category                = "Breath",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Fast Cast",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 26,
        notes                   = "Wind breath damage (AoE conal). MP: 26. Level: 99. Trait: Fast Cast. Stats: STR +2, AGI +2. Recast: 29.5s. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_BREATH

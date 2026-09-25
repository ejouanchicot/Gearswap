---============================================================================
--- BLUE MAGIC DATABASE - Magical Thunder Spells
---============================================================================
--- Thunder-element magical damage Blue Magic spells
---
--- @file shared/data/magic/blu/magical/blu_magical_thunder.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06
---============================================================================

local BLU_MAGICAL_THUNDER = {}

BLU_MAGICAL_THUNDER.spells = {

    ["Blitzstrahl"] = {
        description             = "Deals thunder dmg + stun.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Thunder",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = false,
        BLU                     = 44,
        mp_cost                 = 70,
        notes                   = "Thunder-based magical damage + Stun. MP: 70. Level: 44. Trait: None. Recast: 29.25s. Single target. BLU only.",
    },

    ["Mind Blast"] = {
        description             = "Deals thunder dmg + paralysis.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Thunder",
        trait                   = "Clear Mind",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 73,
        mp_cost                 = 82,
        notes                   = "Thunder-based magical damage + Paralysis. MP: 82. Level: 73. Trait: Clear Mind. Additional effect: Paralyze 20% (1.5min). Recast: 30s. Single target. BLU only.",
    },

    ["Charged Whisker"] = {
        description             = "Deals thunder dmg (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Thunder",
        trait                   = "Gilfinder / Treasure Hunter",
        trait_points            = 6,
        unbridled               = false,
        BLU                     = 88,
        mp_cost                 = 183,
        notes                   = "Thunder-based magical damage (AoE). MP: 183. Level: 88. Trait: Gilfinder/Treasure Hunter. BLU only.",
    },

    ["Thunderbolt"] = {
        description             = "Deals thunder dmg + stun (unbridled, AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Thunder",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = true,
        BLU                     = 95,
        mp_cost                 = 138,
        notes                   = "Thunder-based magical damage + Stun (unbridled, AoE). MP: 138. Level: 95. Trait: None. Requires: Unbridled Learning. Recast: 30s. Range: ~12'. BLU only.",
    },

    ["Crashing Thunder"] = {
        description             = "Deals thunder dmg (unbridled, AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Thunder",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = true,
        BLU                     = 99,
        mp_cost                 = 172,
        notes                   = "Thunder-based magical damage (unbridled, AoE). MP: 172. Level: 99. Trait: None. Requires: Unbridled Learning. Recast: 30s. BLU only.",
    },

    ["Anvil Lightning"] = {
        description             = "Deals thunder dmg + stun (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Thunder",
        trait                   = "Accuracy Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 116,
        notes                   = "Thunder-based magical damage + Stun (AoE). MP: 116. Level: 99. Trait: Accuracy Bonus. Recast: 60s. Range: ~10'. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_MAGICAL_THUNDER

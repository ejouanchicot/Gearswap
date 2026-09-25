---============================================================================
--- BLUE MAGIC DATABASE - Magical Wind Spells
---============================================================================
--- Wind-element magical damage Blue Magic spells
---
--- @file shared/data/magic/blu/magical/blu_magical_wind.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06
---============================================================================

local BLU_MAGICAL_WIND = {}

BLU_MAGICAL_WIND.spells = {

    ["Mysterious Light"] = {
        description             = "Deals wind dmg + weight.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Max MP Boost",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 40,
        mp_cost                 = 73,
        notes                   = "Wind-based magical damage + Weight (AoE). MP: 73. Level: 40. Trait: Max MP Boost. Additional effect: Weight, about -26% movement speed (30-120s). Recast: 24.5s. Range: 6'. BLU only.",
    },

    ["Voracious Trunk"] = {
        description             = "Steals one beneficial effect.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Auto Refresh",
        trait_points            = 3,
        unbridled               = false,
        BLU                     = 64,
        mp_cost                 = 72,
        notes                   = "Steals one beneficial effect from an enemy; the stolen effect keeps its remaining duration. MP: 72. Level: 64. Trait: Auto Refresh (3 pts). Single target. BLU only.",
    },

    ["Leafstorm"] = {
        description             = "Deals wind dmg (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Magic Burst Bonus",
        trait_points            = 6,
        unbridled               = false,
        BLU                     = 77,
        mp_cost                 = 132,
        notes                   = "Wind-based magical damage (AoE, 6' radius from caster). MP: 132. Level: 77. Trait: Magic Burst Bonus. Casting range ~11'. BLU only.",
    },

    ["Tem. Upheaval"] = {
        description             = "Deals wind dmg (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Evasion Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 133,
        notes                   = "Wind-based magical damage (AoE). MP: 133. Level: 99. Trait: Evasion Bonus. Recast: 12s. Range: 13'. BLU only.",
    },

    ["Droning Whirlwind"] = {
        description             = "Deals wind dmg + dispel (unbridled, AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = true,
        BLU                     = 99,
        mp_cost                 = 224,
        notes                   = "Wind-based magical damage + Dispel (unbridled, AoE). MP: 224. Level: 99. Trait: None. Requires: Unbridled Learning. Range: ~10'. BLU only.",
    },

    ["Subduction"] = {
        description             = "Deals wind dmg + weight (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Magic Attack Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 27,
        notes                   = "Wind-based magical damage + Weight (AoE, centered on caster). MP: 27. Level: 99. Trait: Magic Attack Bonus. Additional effect: Weight, about -76% movement speed (90s). Recast: 5s. BLU only.",
    },

    ["Molting Plumage"] = {
        description             = "Deals wind dmg (conal AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Dual Wield",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 146,
        notes                   = "Wind-based magical damage (conal AoE). MP: 146. Level: 99. Trait: Dual Wield. Recast: 25s. BLU only.",
    },

    ["Silent Storm"] = {
        description             = "Deals wind dmg + silence.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Evasion Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 116,
        notes                   = "Wind-based magical damage + Silence (AoE). MP: 116. Level: 99. Trait: Evasion Bonus. Additional effect: Silence (up to ~5min). Recast: 60s. Range: ~10'. BLU only.",
    },

    ["Tearing Gust"] = {
        description             = "Deals wind dmg + magic defense down (unbridled, AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = true,
        BLU                     = 99,
        mp_cost                 = 202,
        notes                   = "Wind-based magical damage + Magic Defense Down (unbridled, AoE). MP: 202. Level: 99. Trait: None. Requires: Unbridled Learning/Wisdom. Additional effect: around -30 Magic Defense (60s). Recast: 30s. Range: 10'. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_MAGICAL_WIND

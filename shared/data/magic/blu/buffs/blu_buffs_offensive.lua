---============================================================================
--- BLUE MAGIC DATABASE - Offensive Buffs
---============================================================================
--- Attack, Magic Attack, Haste, and Critical Hit Blue Magic buffs
---
--- @file shared/data/magic/blu/buffs/blu_buffs_offensive.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06
---============================================================================

local BLU_BUFFS_OFFENSIVE = {}

BLU_BUFFS_OFFENSIVE.spells = {

    --============================================================
    -- LEVEL 48
    --============================================================

    ["Refueling"] = {
        description             = "Grants haste.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 48,
        mp_cost                 = 29,
        notes                   = "Haste buff (self only). MP: 29. Level: 48. Trait: None. Stats: AGI +2. Effect: Haste 10%; overwritten by any other haste or slow. Duration: 5min. Recast: 30s. BLU only.",
    },

    --============================================================
    -- LEVEL 62
    --============================================================

    ["Memento Mori"] = {
        description             = "Grants magic attack.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Ice",
        trait                   = "Magic Attack Bonus",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 62,
        mp_cost                 = 46,
        notes                   = "Magic Attack buff (self only). MP: 46. Level: 62. Trait: Magic Attack Bonus. Stats: INT +1. Effect: Magic Attack Bonus +20. Duration: 60s. Recast: 120s. BLU only.",
    },

    --============================================================
    -- LEVEL 68
    --============================================================

    ["Warm-Up"] = {
        description             = "Grants accuracy + evasion.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Earth",
        trait                   = "Clear Mind",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 68,
        mp_cost                 = 59,
        notes                   = "Accuracy/Evasion buff (self only). MP: 59. Level: 68. Trait: Clear Mind. Effect: Accuracy +10, Evasion +10. Duration: 3min. Recast: 120s. BLU only.",
    },

    --============================================================
    -- LEVEL 70
    --============================================================

    ["Amplification"] = {
        description             = "Enhances magic attack + magic defense.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 70,
        mp_cost                 = 48,
        notes                   = "Magic Attack/Magic Defense buff (self only). MP: 48. Level: 70. Trait: None. Stats: HP -5, MP +5. Effect: About +10 Magic Attack Bonus and +10 Magic Defense Bonus. Duration: 90s. Recast: 120s. BLU only.",
    },

    --============================================================
    -- LEVEL 71
    --============================================================

    ["Triumphant Roar"] = {
        description             = "Enhances attack.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Fire",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 71,
        mp_cost                 = 24,
        notes                   = "Attack buff (self only). MP: 24. Level: 71. Trait: None. Stats: STR +3. Effect: Attack +15% (38/256); overwritten by Nat. Meditation. Duration: 60s. Recast: 90s. BLU only.",
    },

    --============================================================
    -- LEVEL 74
    --============================================================

    ["Reactor Cool"] = {
        description             = "Enhances defense + Ice Spikes.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Ice",
        trait                   = "Magic Attack Bonus",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 74,
        mp_cost                 = 28,
        notes                   = "Defense + Ice Spikes (self only). MP: 28. Level: 74. Trait: Magic Attack Bonus. Effect: Defense +12%, Ice Spikes. Duration: 3min. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 75
    --============================================================

    ["Plasma Charge"] = {
        description             = "Grants Shock Spikes.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Thunder",
        trait                   = "Auto Refresh",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 75,
        mp_cost                 = 24,
        notes                   = "Shock Spikes (self only). MP: 24. Level: 75. Trait: Auto Refresh. Effect: Shock Spikes. Duration: over 12min. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 79
    --============================================================

    ["Animating Wail"] = {
        description             = "Grants haste.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Dual Wield",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 79,
        mp_cost                 = 53,
        notes                   = "Haste buff (self only). MP: 53. Level: 79. Trait: Dual Wield. Stats: HP +20. Effect: Haste 15%. Duration: 5min. Recast: 45s. BLU only.",
    },

    --============================================================
    -- LEVEL 85
    --============================================================

    ["Fantod"] = {
        description             = "Enhances attack + magic attack (next attack).",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Fire",
        trait                   = "Store TP",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 85,
        mp_cost                 = 12,
        notes                   = "Boost-type buff (self only). MP: 12. Level: 85. Trait: Store TP. Stats: HP -10, DEX +2, AGI +2. Effect: Attack +2.7% to +29.7% and Magic Attack +2 to +20 by number of casts (caps at 10); next attack only, not breath damage. Duration: 3min or next attack. Recast: 10s. BLU only.",
    },

    --============================================================
    -- LEVEL 99
    --============================================================

    ["Nat. Meditation"] = {
        description             = "Enhances attack.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Fire",
        trait                   = "Accuracy Bonus",
        trait_points            = 8,
        property                = nil,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 38,
        notes                   = "Attack buff (self only). MP: 38. Level: 99. Trait: Accuracy Bonus. Stats: DEX +6. Effect: Attack +20% (52/256); overwrites the attack boosts of Plenilune Embrace, Triumphant Roar and Carcharian Verve. Duration: 90s. Recast: 60s. BLU only.",
    },

    ["Erratic Flutter"] = {
        description             = "Grants haste (tier II).",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Fast Cast",
        trait_points            = 8,
        property                = nil,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 92,
        notes                   = "Haste buff tier II (self only). MP: 92. Level: 99. Trait: Fast Cast. Effect: Haste II +29.98% (307/1024). Duration: 5min. Recast: 45s. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_BUFFS_OFFENSIVE

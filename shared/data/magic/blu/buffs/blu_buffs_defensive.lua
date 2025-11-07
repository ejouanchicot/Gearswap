---============================================================================
--- BLUE MAGIC DATABASE - Defensive Buffs
---============================================================================
--- Defense, Evasion, Stoneskin, Shadows, and Protection Blue Magic buffs
---
--- @file blu_buffs_defensive.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06 | Updated: 2025-11-01
---============================================================================

local BLU_BUFFS_DEFENSIVE = {}

BLU_BUFFS_DEFENSIVE.spells = {

    --============================================================
    -- LEVEL 8
    --============================================================

    ["Cocoon"] = {
        description             = "Grants defense boost.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Earth",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 8,
        mp_cost                 = 10,
        notes                   = "Defense buff (self only). MP: 10. Level: 8. Trait: None (0 pts). Effect: Defense +50%. Duration: 90s. Recast: 60s. BLU only.",
    },

    ["Metallic Body"] = {
        description             = "Grants stoneskin.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Earth",
        trait                   = "Max MP Boost",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 8,
        mp_cost                 = 19,
        notes                   = "Stoneskin buff (self only). MP: 19. Level: 8. Trait: Max MP Boost (4 pts). Effect: Stoneskin (Blue Magic Skill × 0.375 + 12.5 HP, max 200 HP @ 500 skill). Duration: 5min. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 56
    --============================================================

    ["Feather Barrier"] = {
        description             = "Grants evasion boost.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Resist Gravity",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 56,
        mp_cost                 = 32,
        notes                   = "Evasion buff (self only). MP: 32. Level: 56. Trait: Resist Gravity (4 pts). Effect: Evasion +25. Duration: 3min. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 65
    --============================================================

    ["Zephyr Mantle"] = {
        description             = "Grants evasion boost.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Conserve MP",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 65,
        mp_cost                 = 31,
        notes                   = "Evasion buff (self only). MP: 31. Level: 65. Trait: Conserve MP (4 pts). Effect: Evasion +40. Duration: 3min. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 67
    --============================================================

    ["Diamondhide"] = {
        description             = "Grants stoneskin.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Earth",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 67,
        mp_cost                 = 66,
        notes                   = "Stoneskin buff (self only). MP: 66. Level: 67. Trait: None (0 pts). Effect: Stoneskin (VIT-based, ~500 HP absorption). Duration: 5min. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 72
    --============================================================

    ["Saline Coat"] = {
        description             = "Grants defense + debuff resist.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = "Defense Bonus",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 72,
        mp_cost                 = 45,
        notes                   = "Defense/Resist buff (self only). MP: 45. Level: 72. Trait: Defense Bonus (4 pts). Effect: Defense +33%, Debuff resistance +50. Duration: 3min. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 79
    --============================================================

    ["Battery Charge"] = {
        description             = "Grants refresh.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 79,
        mp_cost                 = 25,
        notes                   = "Refresh buff (self only). MP: 25. Level: 79. Trait: None (0 pts). Effect: Refresh +4 MP/tick. Duration: 90s. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 82
    --============================================================

    ["Magic Barrier"] = {
        description             = "Grants magic defense boost.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = "Max MP Boost",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 82,
        mp_cost                 = 32,
        notes                   = "Magic Defense buff (self only). MP: 32. Level: 82. Trait: Max MP Boost (4 pts). Effect: Magic Defense Bonus +20. Duration: 3min. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 84
    --============================================================

    ["Auroral Drape"] = {
        description             = "Grants status ailment resist.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Fast Cast",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 84,
        mp_cost                 = 41,
        notes                   = "Status Resist buff (self only). MP: 41. Level: 84. Trait: Fast Cast (4 pts). Effect: Resist Sleep/Poison/Paralyze/Blind/Silence/Slow/Curse/Doom/Stun. Duration: 3min. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 88
    --============================================================

    ["Occultation"] = {
        description             = "Grants shadow images.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Evasion Bonus",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 88,
        mp_cost                 = 138,
        notes                   = "Shadow buff (self only). MP: 138. Level: 88. Trait: Evasion Bonus (4 pts). Effect: Shadows (floor(Blue Magic Skill / 50), max 12 shadows @ 600 skill). Duration: 5min. Recast: 90s. BLU only.",
    },

    --============================================================
    -- LEVEL 89
    --============================================================

    ["Winds of Promy."] = {
        description             = "Grants regen + refresh + haste.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = "Auto Refresh",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 89,
        mp_cost                 = 66,
        notes                   = "Multi-buff (self only). MP: 66. Level: 89. Trait: Auto Refresh (4 pts). Effect: Regen +20 HP/tick, Refresh +3 MP/tick, Haste +10%. Duration: 3min. Recast: 120s. BLU only.",
    },

    --============================================================
    -- LEVEL 91
    --============================================================

    ["Barrier Tusk"] = {
        description             = "Grants damage reduction.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Earth",
        trait                   = "Max HP Boost",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 91,
        mp_cost                 = 41,
        notes                   = "Phalanx-type buff (self only). MP: 41. Level: 91. Trait: Max HP Boost (4 pts). Effect: Damage taken -15% (bypasses 50% reduction cap, overwritten by Phalanx). Duration: 3min. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 95
    --============================================================

    ["Harden Shell"] = {
        description             = "Grants stoneskin (high potency).",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Earth",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = true,
        BLU                     = 95,
        mp_cost                 = 84,
        notes                   = "Stoneskin buff (self only, unbridled). MP: 84. Level: 95. Trait: None (0 pts). Effect: Stoneskin (~600-700 HP absorption, VIT-based). Duration: 5min. Recast: 60s. Requires: Unbridled Learning/Wisdom. BLU only.",
    },

    --============================================================
    -- LEVEL 98
    --============================================================

    ["O. Counterstance"] = {
        description             = "Grants counter + defense.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Fire",
        trait                   = "Counter",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 98,
        mp_cost                 = 37,
        notes                   = "Counter/Defense buff (self only). MP: 37. Level: 98. Trait: Counter (4 pts). Effect: Counter +50%, Defense +15%. Duration: 3min. Recast: 60s. BLU only.",
    },

    ["Pyric Bulwark"] = {
        description             = "Grants magic shield.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Ice",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = true,
        BLU                     = 98,
        mp_cost                 = 96,
        notes                   = "Magic Shield buff (self only, unbridled). MP: 96. Level: 98. Trait: None (0 pts). Effect: Magic Damage Reduction -50%. Duration: 3min. Recast: 60s. Requires: Unbridled Learning/Wisdom. BLU only.",
    },

    --============================================================
    -- LEVEL 99
    --============================================================

    ["Carcharian Verve"] = {
        description             = "Grants stoneskin + regen.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = true,
        BLU                     = 99,
        mp_cost                 = 96,
        notes                   = "Stoneskin/Regen buff (self only, unbridled). MP: 96. Level: 99. Trait: None (0 pts). Effect: Stoneskin (~800 HP absorption) + Regen +25 HP/tick. Duration: 5min. Recast: 60s. Requires: Unbridled Learning/Wisdom. BLU only.",
    },

    ["Mighty Guard"] = {
        description             = "Grants haste + def + regen.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = true,
        BLU                     = 99,
        mp_cost                 = 299,
        notes                   = "Multi-buff (self only, unbridled). MP: 299. Level: 99. Trait: None (0 pts). Effect: Haste +15%, Defense +25%, Magic Defense +15, Regen +30 HP/tick. Duration: 3min (extendable to 5min+ with merits/gear). Recast: 30s. Requires: Unbridled Learning/Wisdom. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_BUFFS_DEFENSIVE

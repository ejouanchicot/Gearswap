---============================================================================
--- BLUE MAGIC DATABASE - Defensive Buffs
---============================================================================
--- Defense, Evasion, Stoneskin, Shadows, and Protection Blue Magic buffs
---
--- @file shared/data/magic/blu/buffs/blu_buffs_defensive.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06
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
        notes                   = "Defense buff (self only). MP: 10. Level: 8. Trait: None. Effect: Defense +50%. Duration: 90s. Recast: 60s. BLU only.",
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
        notes                   = "Stoneskin buff (self only). MP: 19. Level: 8. Trait: Max MP Boost. Effect: Stoneskin (Blue Magic Skill × 0.375 + 12.5 HP, max 200 HP @ 500 skill). Duration: 5min. Recast: 60s. BLU only.",
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
        mp_cost                 = 29,
        notes                   = "Evasion buff (self only). MP: 29. Level: 56. Trait: Resist Gravity. Effect: Evasion +25. Duration: 30s. Recast: 120s. BLU only.",
    },

    --============================================================
    -- LEVEL 65
    --============================================================

    ["Zephyr Mantle"] = {
        description             = "Grants shadow images.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Wind",
        trait                   = "Conserve MP",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 65,
        mp_cost                 = 31,
        notes                   = "Shadow buff (self only). MP: 31. Level: 65. Trait: Conserve MP. Effect: 4 shadow images; overwritten by Utsusemi/Blink. Duration: 5min. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 67
    --============================================================

    ["Diamondhide"] = {
        description             = "Grants stoneskin (party AoE).",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Earth",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 67,
        mp_cost                 = 99,
        notes                   = "Stoneskin (party members in area of effect). MP: 99. Level: 67. Trait: None. Stats: VIT +1. Effect: Stoneskin = (Blue Magic Skill/3) x 2, caps at 500 skill; not affected by Stoneskin gear; overwritten by Stoneskin, Earthen Ward and Rampart. Duration: 15min. Recast: 90s. BLU only.",
    },

    --============================================================
    -- LEVEL 72
    --============================================================

    ["Saline Coat"] = {
        description             = "Enhances magic defense.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = "Defense Bonus",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 72,
        mp_cost                 = 66,
        notes                   = "Magic Defense buff (self only). MP: 66. Level: 72. Trait: Defense Bonus. Stats: MP +10, VIT +2, AGI +2. Effect: Magic Defense Bonus +50 at cast, decaying to +8. Duration: 3min (wears off about 1min early). Recast: 60s. BLU only.",
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
        mp_cost                 = 50,
        notes                   = "Refresh buff (self only). MP: 50. Level: 79. Trait: None. Stats: MP +10, MND +1. Effect: Refresh 3 MP/tick (300 MP total); overwrites and is overwritten by Refresh/Refresh II. Duration: 5min. Recast: 75s. BLU only.",
    },

    --============================================================
    -- LEVEL 82
    --============================================================

    ["Magic Barrier"] = {
        description             = "Grants a magic damage shield.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Dark",
        trait                   = "Max MP Boost",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 82,
        mp_cost                 = 29,
        notes                   = "Magic Shield (self only). MP: 29. Level: 82. Trait: Max MP Boost. Stats: MP +7, INT +2. Effect: Absorbs magic damage equal to Blue Magic Skill; overwritten by Stoneskin effects and Rampart. Duration: 5min. Recast: 60s. BLU only.",
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
        notes                   = "Shadow buff (self only). MP: 138. Level: 88. Trait: Evasion Bonus. Effect: Blink shadows = floor(Blue Magic Skill / 50) (12 at 600 skill); removed by AoE TP moves. Duration: 5min. Recast: 90s. BLU only.",
    },

    --============================================================
    -- LEVEL 89
    --============================================================

    ["Winds of Promy."] = {
        description             = "Removes one detrimental effect (party AoE).",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Light",
        trait                   = "Auto Refresh",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 89,
        mp_cost                 = 36,
        notes                   = "Erase effect (party AoE). MP: 36. Level: 89. Trait: Auto Refresh. Effect: Removes one effect Erase can remove. Recast: 20s. BLU only.",
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
        notes                   = "Damage reduction buff (self only). MP: 41. Level: 91. Trait: Max HP Boost. Stats: HP +15, MP -15, VIT +3. Effect: Damage taken -15%, applied after -% damage taken gear (bypasses the 50% cap); overwritten by Phalanx, not affected by Phalanx+ gear. Duration: 3min. Recast: 60s. BLU only.",
    },

    --============================================================
    -- LEVEL 95
    --============================================================

    ["Harden Shell"] = {
        description             = "Enhances defense.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Earth",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = true,
        BLU                     = 95,
        mp_cost                 = 20,
        notes                   = "Defense buff (self only, unbridled). MP: 20. Level: 95. Trait: None. Effect: Defense +100%. Duration: 90s. Recast: 25s. Requires: Unbridled Learning/Wisdom. BLU only.",
    },

    --============================================================
    -- LEVEL 98
    --============================================================

    ["O. Counterstance"] = {
        description             = "Enhances counter.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Fire",
        trait                   = "Counter",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 98,
        mp_cost                 = 18,
        notes                   = "Counter buff (self only). MP: 18. Level: 98. Trait: Counter. Stats: HP +10, STR +3, VIT +3, DEX -2, AGI -2. Effect: About +10% counter rate and +50% counter damage. Duration: 3min. Recast: 120s. BLU only.",
    },

    ["Pyric Bulwark"] = {
        description             = "Grants physical immunity.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Ice",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = true,
        BLU                     = 98,
        mp_cost                 = 50,
        notes                   = "Physical immunity (self only, unbridled). MP: 50. Level: 98. Trait: None. Effect: Physical Immunity for a single attack. Duration: 5min or one attack. Recast: 30s. Requires: Unbridled Learning. BLU only.",
    },

    --============================================================
    -- LEVEL 99
    --============================================================

    ["Carcharian Verve"] = {
        description             = "Enhances attack + magic attack; grants Aquaveil.",
        category                = "Buff",
        magic_type              = "Blue",
        element                 = "Water",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = true,
        BLU                     = 99,
        mp_cost                 = 65,
        notes                   = "Attack/Magic Attack buff + Aquaveil (self only, unbridled). MP: 65. Level: 99. Trait: None. Effect: Attack +20% and Magic Attack Bonus +20 (1min); Aquaveil preventing 10 interruptions (15min). Requires: Unbridled Learning. BLU only.",
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
        notes                   = "Multi-buff (self only, unbridled). MP: 299. Level: 99. Trait: None. Effect: Haste +15% (unverified), Defense +25%, Magic Defense Bonus +15, Regen +30 HP/tick. Duration: 3min (3min36s with Job Points; not affected by Enhancing Magic duration gear). Recast: 30s. Requires: Unbridled Learning/Wisdom. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_BUFFS_DEFENSIVE

---============================================================================
--- BLUE MAGIC DATABASE - Magical Fire Spells
---============================================================================
--- Fire-element magical damage Blue Magic spells
---
--- @file shared/data/magic/blu/magical/blu_magical_fire.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06
---============================================================================

local BLU_MAGICAL_FIRE = {}

BLU_MAGICAL_FIRE.spells = {

    ["Blastbomb"] = {
        description             = "Deals fire dmg + bind (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Fire",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = false,
        BLU                     = 18,
        mp_cost                 = 36,
        notes                   = "Fire-based magical damage + Bind (AoE, centered on target). MP: 36. Level: 18. Trait: None. Bypasses shadows. Bind applied after damage. Recast: 15s. BLU only.",
    },

    ["Bomb Toss"] = {
        description             = "Deals fire dmg (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Fire",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = false,
        BLU                     = 28,
        mp_cost                 = 42,
        notes                   = "Fire-based magical damage (AoE). MP: 42. Level: 28. Trait: None. BLU only.",
    },

    ["Self-Destruct"] = {
        description             = "Sacrifices HP to deal fire dmg (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Fire",
        trait                   = "Auto Refresh",
        trait_points            = 2,
        unbridled               = false,
        BLU                     = 50,
        mp_cost                 = 100,
        notes                   = "Fire-based magical damage (AoE). MP: 100. Level: 50. Trait: Auto Refresh. Damage limited to the caster's current HP; caster drops to 1 HP and gets Weakness (5min). Recast: 21s. BLU only.",
    },

    ["Firespit"] = {
        description             = "Deals fire dmg.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Fire",
        trait                   = "Conserve MP",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 68,
        mp_cost                 = 121,
        notes                   = "Fire-based magical damage. MP: 121. Level: 68. Trait: Conserve MP. Single target. BLU only.",
    },

    ["Blazing Bound"] = {
        description             = "Deals fire dmg.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Fire",
        trait                   = "Dual Wield",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 80,
        mp_cost                 = 113,
        notes                   = "Fire-based magical damage. MP: 113. Level: 80. Trait: Dual Wield. Uses Magic Defense Bonus instead of Magic Attack Bonus (MAB has no effect). No Burn effect. Single target. BLU only.",
    },

    ["Thermal Pulse"] = {
        description             = "Deals fire dmg + blind (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Fire",
        trait                   = "Attack Bonus",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 86,
        mp_cost                 = 151,
        notes                   = "Fire-based magical damage + Blind (AoE). MP: 151. Level: 86. Trait: Attack Bonus. Additional effect: Blind -25 accuracy (30-60s). Range: ~12.5'. BLU only.",
    },

    ["Gates of Hades"] = {
        description             = "Deals fire dmg + burn (unbridled, AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Fire",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = true,
        BLU                     = 97,
        mp_cost                 = 156,
        notes                   = "Fire-based magical damage + Burn (unbridled, AoE). MP: 156. Level: 97. Trait: None. Requires: Unbridled Learning. Additional effect: Burn (22 HP/tick, -47 INT, 90s). Recast: 30s. BLU only.",
    },

    ["Searing Tempest"] = {
        description             = "Deals fire dmg + burn (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Fire",
        trait                   = "Attack Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 116,
        notes                   = "Fire-based magical damage + Burn (AoE). MP: 116. Level: 99. Trait: Attack Bonus. Additional effect: Burn (30 HP/tick, -63 INT). Recast: 60s. Range: ~10'. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_MAGICAL_FIRE

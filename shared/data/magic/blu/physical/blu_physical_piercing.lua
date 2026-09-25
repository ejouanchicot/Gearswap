---============================================================================
--- BLUE MAGIC DATABASE - Physical Piercing Spells
---============================================================================
--- Piercing physical damage Blue Magic spells
---
--- @file shared/data/magic/blu/physical/blu_physical_piercing.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06
---============================================================================

local BLU_PHYSICAL_PIERCING = {}

BLU_PHYSICAL_PIERCING.spells = {

    ["Wild Oats"] = {
        description             = "Deals piercing dmg + VIT down.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Piercing",
        trait                   = "Beast Killer",
        trait_points            = 4,
        property                = "Transfixion",
        unbridled               = false,
        BLU                     = 4,
        notes                   = "Physical piercing damage. Additional effect: VIT Down (decays over time); duration varies with TP. Level: 4. Trait: Beast Killer (4 pts). Skillchain: Transfixion. BLU only.",
    },

    ["Screwdriver"] = {
        description             = "Deals piercing dmg (crit rate varies with TP).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Piercing",
        trait                   = "Evasion Bonus",
        trait_points            = 4,
        property                = "Transfixion / Scission",
        unbridled               = false,
        BLU                     = 26,
        notes                   = "Physical piercing damage. Critical hit chance varies with TP. Level: 26. Trait: Evasion Bonus (4 pts). Skillchain: Transfixion/Scission. BLU only.",
    },

    ["Disseverment"] = {
        description             = "Deals piercing dmg (5-hit) + poison.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Piercing",
        trait                   = "Accuracy Bonus",
        trait_points            = 4,
        property                = "Distortion",
        unbridled               = false,
        BLU                     = 72,
        notes                   = "Physical piercing damage, 5 hits. Additional effect: Poison (3 min). Accuracy varies with TP. Level: 72. Trait: Accuracy Bonus (4 pts). Skillchain: Distortion. BLU only.",
    },

    ["Sub-zero Smash"] = {
        description             = "Deals piercing dmg (conal AoE) + paralysis.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Piercing",
        trait                   = "Fast Cast",
        trait_points            = 4,
        property                = "Fragmentation",
        unbridled               = false,
        BLU                     = 72,
        notes                   = "Physical piercing damage (conal AoE). Additional effect: Paralysis (10%, 3 min). Damage varies with TP. Level: 72. Trait: Fast Cast (4 pts). Skillchain: Fragmentation. BLU only.",
    },

    ["Final Sting"] = {
        description             = "Deals piercing dmg based on HP; HP drops to 1.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Piercing",
        trait                   = "Zanshin",
        trait_points            = 4,
        property                = "Fusion",
        unbridled               = false,
        BLU                     = 81,
        notes                   = "Physical piercing damage proportional to the caster's HP; reduces HP to 1 after use (no HP lost if it misses). Ignores Utsusemi. Damage varies with TP. Level: 81. Trait: Zanshin (4 pts). Skillchain: Fusion. BLU only.",
    },

    ["Benthic Typhoon"] = {
        description             = "Deals piercing dmg (conal AoE) + defense/magic defense down.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Piercing",
        trait                   = "Skillchain Bonus",
        trait_points            = 6,
        property                = "Gravitation / Transfixion",
        unbridled               = false,
        BLU                     = 83,
        notes                   = "Physical piercing damage (conal AoE). Additional effect: Defense Down -10% and Magic Defense Down -10 (60 s). Damage varies with TP. Level: 83. Trait: Skillchain Bonus (6 pts). Skillchain: Gravitation/Transfixion. BLU only.",
    },

    ["Quad. Continuum"] = {
        description             = "Deals piercing dmg (4-hit).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Piercing",
        trait                   = "Dual Wield",
        trait_points            = 4,
        property                = "Distortion / Scission",
        unbridled               = false,
        BLU                     = 85,
        notes                   = "Physical piercing damage, 4 hits. Damage varies with TP. Level: 85. Trait: Dual Wield (4 pts). Skillchain: Distortion/Scission. BLU only.",
    },

    ["Amorphic Spikes"] = {
        description             = "Deals piercing dmg (5-hit).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Piercing",
        trait                   = "Gilfinder / Treasure Hunter",
        trait_points            = 6,
        property                = "Gravitation / Transfixion",
        unbridled               = false,
        BLU                     = 98,
        notes                   = "Physical piercing damage, 5 hits. Damage varies with TP. Level: 98. Trait: Gilfinder/Treasure Hunter (6 pts). Skillchain: Gravitation/Transfixion. BLU only.",
    },

    ["Glutinous Dart"] = {
        description             = "Deals piercing dmg.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Piercing",
        trait                   = "Max HP Boost",
        trait_points            = 4,
        property                = "Fragmentation",
        unbridled               = false,
        BLU                     = 99,
        notes                   = "Physical piercing damage. Damage varies with TP. Level: 99. Trait: Max HP Boost (4 pts). Skillchain: Fragmentation. BLU only.",
    },

    ["Sinker Drill"] = {
        description             = "Deals piercing dmg (5-hit).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Piercing",
        trait                   = "Critical Attack Bonus",
        trait_points            = 8,
        property                = "Gravitation / Reverberation",
        unbridled               = false,
        BLU                     = 99,
        notes                   = "Physical piercing damage, 5 hits. Damage varies with TP. Level: 99. Trait: Critical Attack Bonus (8 pts). Skillchain: Gravitation/Reverberation. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_PHYSICAL_PIERCING

---============================================================================
--- BLUE MAGIC DATABASE - Physical Piercing Spells
---============================================================================
--- Piercing physical damage Blue Magic spells
---
--- @file blu_physical_piercing.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06 | Updated: 2025-11-01
---============================================================================

local BLU_PHYSICAL_PIERCING = {}

BLU_PHYSICAL_PIERCING.spells = {

    ["Wild Oats"] = {
        description             = "Deals piercing dmg.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Piercing",
        trait                   = "Beast Killer",
        trait_points            = 4,
        property                = "Transfixion",
        unbridled               = false,
        BLU                     = 4,
        notes                   = "Physical piercing damage. Level: 4. Trait: Beast Killer (4 pts). Skillchain: Transfixion. Uses TP. BLU only.",
    },

    ["Screwdriver"] = {
        description             = "Deals piercing dmg.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Piercing",
        trait                   = "Evasion Bonus",
        trait_points            = 4,
        property                = "Transfixion / Scission",
        unbridled               = false,
        BLU                     = 26,
        notes                   = "Physical piercing damage. Level: 26. Trait: Evasion Bonus (4 pts). Skillchain: Transfixion/Scission. Uses TP. BLU only.",
    },

    ["Disseverment"] = {
        description             = "Deals piercing dmg.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Piercing",
        trait                   = "Accuracy Bonus",
        trait_points            = 4,
        property                = "Distortion",
        unbridled               = false,
        BLU                     = 72,
        notes                   = "Physical piercing damage. Level: 72. Trait: Accuracy Bonus (4 pts). Skillchain: Distortion. Uses TP. BLU only.",
    },

    ["Sub-zero Smash"] = {
        description             = "Deals piercing ice dmg.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Piercing",
        trait                   = "Fast Cast",
        trait_points            = 4,
        property                = "Fragmentation",
        unbridled               = false,
        BLU                     = 72,
        notes                   = "Physical piercing ice damage. Level: 72. Trait: Fast Cast (4 pts). Skillchain: Fragmentation. Uses TP. BLU only.",
    },

    ["Final Sting"] = {
        description             = "Deals piercing dmg (sacrifices caster).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Piercing",
        trait                   = "Zanshin",
        trait_points            = 4,
        property                = "Fusion",
        unbridled               = false,
        BLU                     = 81,
        notes                   = "Physical piercing damage (ultimate). Level: 81. Trait: Zanshin (4 pts). Skillchain: Fusion. Deals damage = current HP, caster KO'd. Uses TP. BLU only.",
    },

    ["Benthic Typhoon"] = {
        description             = "Deals piercing dmg.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Piercing",
        trait                   = "Skillchain Bonus",
        trait_points            = 4,
        property                = "Gravitation / Transfixion",
        unbridled               = false,
        BLU                     = 83,
        notes                   = "Physical piercing damage. Level: 83. Trait: Skillchain Bonus (4 pts). Skillchain: Gravitation/Transfixion. Uses TP. BLU only.",
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
        notes                   = "Physical piercing damage (4-fold). Level: 85. Trait: Dual Wield (4 pts). Skillchain: Distortion/Scission. 4-hit attack. Uses TP. BLU only.",
    },

    ["Amorphic Spikes"] = {
        description             = "Deals piercing dmg.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Piercing",
        trait                   = "Gilfinder / Treasure Hunter",
        trait_points            = 6,
        property                = "Gravitation / Transfixion",
        unbridled               = false,
        BLU                     = 98,
        notes                   = "Physical piercing damage. Level: 98. Trait: Gilfinder/Treasure Hunter (6 pts). Skillchain: Gravitation/Transfixion. Uses TP. BLU only.",
    },

    ["Glutinous Dart"] = {
        description             = "Deals piercing dmg + slow.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Piercing",
        trait                   = "Max HP Boost",
        trait_points            = 4,
        property                = "Fragmentation",
        unbridled               = false,
        BLU                     = 99,
        notes                   = "Physical piercing damage + Slow effect. Level: 99. Trait: Max HP Boost (4 pts). Skillchain: Fragmentation. Uses TP. BLU only.",
    },

    ["Sinker Drill"] = {
        description             = "Deals piercing dmg (critical bonus).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Piercing",
        trait                   = "Critical Attack Bonus",
        trait_points            = 8,
        property                = "Gravitation / Reverberation",
        unbridled               = false,
        BLU                     = 99,
        notes                   = "Physical piercing damage (critical focus). Level: 99. Trait: Critical Attack Bonus (8 pts). Skillchain: Gravitation/Reverberation. High critical hit rate. Uses TP. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_PHYSICAL_PIERCING

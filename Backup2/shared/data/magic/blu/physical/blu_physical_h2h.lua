---============================================================================
--- BLUE MAGIC DATABASE - Physical H2H Spells
---============================================================================
--- Hand-to-Hand physical damage Blue Magic spells
---
--- @file blu_physical_h2h.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06 | Updated: 2025-11-01
---============================================================================

local BLU_PHYSICAL_H2H = {}

BLU_PHYSICAL_H2H.spells = {

    ["Terror Touch"] = {
        description             = "Deals H2H dmg + terror.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "H2H",
        trait                   = "Defense Bonus",
        trait_points            = 4,
        property                = "Compression / Reverberation",
        unbridled               = false,
        BLU                     = 40,
        notes                   = "Physical H2H damage + Terror effect. Level: 40. Trait: Defense Bonus (4 pts). Skillchain: Compression/Reverberation. Uses TP. BLU only.",
    },

    ["Sickle Slash"] = {
        description             = "Deals H2H dmg.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "H2H",
        trait                   = "Store TP",
        trait_points            = 4,
        property                = "Compression",
        unbridled               = false,
        BLU                     = 48,
        notes                   = "Physical H2H damage. Level: 48. Trait: Store TP (4 pts). Skillchain: Compression. Uses TP. BLU only.",
    },

    ["Dimensional Death"] = {
        description             = "Deals H2H dmg (ignores Utsusemi).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "H2H",
        trait                   = "Accuracy Bonus",
        trait_points            = 4,
        property                = "Impaction",
        unbridled               = false,
        BLU                     = 60,
        notes                   = "Physical H2H damage (ignores shadows). Level: 60. Trait: Accuracy Bonus (4 pts). Skillchain: Impaction. Bypasses Utsusemi/Blink. Uses TP. BLU only.",
    },

    ["Hydro Shot"] = {
        description             = "Deals H2H water dmg.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "H2H",
        trait                   = "Rapid Shot",
        trait_points            = 4,
        property                = "Reverberation",
        unbridled               = false,
        BLU                     = 63,
        notes                   = "Physical H2H water damage. Level: 63. Trait: Rapid Shot (4 pts). Skillchain: Reverberation. Uses TP. BLU only.",
    },

    ["Tail Slap"] = {
        description             = "Deals H2H dmg.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "H2H",
        trait                   = "Store TP",
        trait_points            = 4,
        property                = "Reverberation",
        unbridled               = false,
        BLU                     = 69,
        notes                   = "Physical H2H damage. Level: 69. Trait: Store TP (4 pts). Skillchain: Reverberation. Uses TP. BLU only.",
    },

    ["Hysteric Barrage"] = {
        description             = "Deals H2H dmg (multi-hit).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "H2H",
        trait                   = "Evasion Bonus",
        trait_points            = 4,
        property                = "Detonation",
        unbridled               = false,
        BLU                     = 69,
        notes                   = "Physical H2H damage (multi-hit). Level: 69. Trait: Evasion Bonus (4 pts). Skillchain: Detonation. Uses TP. BLU only.",
    },

    ["Asuran Claws"] = {
        description             = "Deals H2H dmg (6-hit).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "H2H",
        trait                   = "Counter",
        trait_points            = 4,
        property                = "Liquefaction / Impaction",
        unbridled               = false,
        BLU                     = 70,
        notes                   = "Physical H2H damage (6-fold attack). Level: 70. Trait: Counter (4 pts). Skillchain: Liquefaction/Impaction. 6-hit attack. Uses TP. BLU only.",
    },

    ["Cannonball"] = {
        description             = "Deals H2H dmg (high potency).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "H2H",
        trait                   = nil,
        trait_points            = 0,
        property                = "Fusion",
        unbridled               = false,
        BLU                     = 70,
        notes                   = "Physical H2H damage (high potency). Level: 70. Trait: None (0 pts). Skillchain: Fusion. High damage single hit. Uses TP. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_PHYSICAL_H2H

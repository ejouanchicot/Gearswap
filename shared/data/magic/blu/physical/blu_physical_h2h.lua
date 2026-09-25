---============================================================================
--- BLUE MAGIC DATABASE - Physical H2H Spells
---============================================================================
--- Hand-to-Hand physical damage Blue Magic spells
---
--- @file shared/data/magic/blu/physical/blu_physical_h2h.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06
---============================================================================

local BLU_PHYSICAL_H2H = {}

BLU_PHYSICAL_H2H.spells = {

    ["Terror Touch"] = {
        description             = "Deals H2H dmg + attack down.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "H2H",
        trait                   = "Defense Bonus",
        trait_points            = 4,
        property                = "Compression / Reverberation",
        unbridled               = false,
        BLU                     = 40,
        notes                   = "Physical H2H damage. Additional effect: Attack Down (15%, 60 s). Accuracy varies with TP. Level: 40. Trait: Defense Bonus (4 pts). Skillchain: Compression/Reverberation. BLU only.",
    },

    ["Sickle Slash"] = {
        description             = "Deals H2H dmg (crit rate varies with TP).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "H2H",
        trait                   = "Store TP",
        trait_points            = 4,
        property                = "Compression",
        unbridled               = false,
        BLU                     = 48,
        notes                   = "Physical H2H damage. Critical hit chance varies with TP. Level: 48. Trait: Store TP (4 pts). Skillchain: Compression. BLU only.",
    },

    ["Dimensional Death"] = {
        description             = "Deals H2H dmg.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "H2H",
        trait                   = "Accuracy Bonus",
        trait_points            = 4,
        property                = "Impaction",
        unbridled               = false,
        BLU                     = 60,
        notes                   = "Physical H2H damage. Damage varies with TP. Level: 60. Trait: Accuracy Bonus (4 pts). Skillchain: Impaction. BLU only.",
    },

    ["Hydro Shot"] = {
        description             = "Deals H2H dmg + enmity down.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "H2H",
        trait                   = "Rapid Shot",
        trait_points            = 4,
        property                = "Reverberation",
        unbridled               = false,
        BLU                     = 63,
        notes                   = "Physical H2H damage. Additional effect: Enmity Down; chance varies with TP. Level: 63. Trait: Rapid Shot (4 pts). Skillchain: Reverberation. BLU only.",
    },

    ["Tail Slap"] = {
        description             = "Deals H2H dmg (conal AoE) + stun.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "H2H",
        trait                   = "Store TP",
        trait_points            = 4,
        property                = "Reverberation",
        unbridled               = false,
        BLU                     = 69,
        notes                   = "Physical H2H damage (conal AoE). Additional effect: Stun. Damage varies with TP. Level: 69. Trait: Store TP (4 pts). Skillchain: Reverberation. BLU only.",
    },

    ["Hysteric Barrage"] = {
        description             = "Deals H2H dmg (5-hit).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "H2H",
        trait                   = "Evasion Bonus",
        trait_points            = 4,
        property                = "Detonation",
        unbridled               = false,
        BLU                     = 69,
        notes                   = "Physical H2H damage, 5 hits. Damage varies with TP. Level: 69. Trait: Evasion Bonus (4 pts). Skillchain: Detonation. BLU only.",
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
        notes                   = "Physical H2H damage, 6 hits. Accuracy varies with TP. Level: 70. Trait: Counter (4 pts). Skillchain: Liquefaction/Impaction. BLU only.",
    },

    ["Cannonball"] = {
        description             = "Deals H2H dmg (uses caster defense).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "H2H",
        trait                   = nil,
        trait_points            = 0,
        property                = "Fusion",
        unbridled               = false,
        BLU                     = 70,
        notes                   = "Physical H2H damage; uses the caster's defense as a modifier of its attack. Damage varies with TP. Level: 70. Trait: None. Skillchain: Fusion. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_PHYSICAL_H2H

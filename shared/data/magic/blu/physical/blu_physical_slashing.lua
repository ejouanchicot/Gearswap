---============================================================================
--- BLUE MAGIC DATABASE - Physical Slashing Spells
---============================================================================
--- Slashing physical damage Blue Magic spells
---
--- @file shared/data/magic/blu/physical/blu_physical_slashing.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06
---============================================================================

local BLU_PHYSICAL_SLASHING = {}

BLU_PHYSICAL_SLASHING.spells = {

    ["Foot Kick"] = {
        description             = "Deals slashing dmg (crit rate varies with TP).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Slashing",
        trait                   = "Lizard Killer",
        trait_points            = 4,
        property                = "Detonation",
        unbridled               = false,
        BLU                     = 1,
        notes                   = "Physical slashing damage. Critical hit chance varies with TP. Level: 1. Trait: Lizard Killer (4 pts). Skillchain: Detonation. BLU only.",
    },

    ["Battle Dance"] = {
        description             = "Deals slashing dmg (AoE) + DEX down.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Slashing",
        trait                   = "Attack Bonus",
        trait_points            = 4,
        property                = "Impaction",
        unbridled               = false,
        BLU                     = 12,
        notes                   = "Physical slashing damage (AoE, centered on the caster). Additional effect: DEX Down; duration varies with TP. Removes shadows (Utsusemi/Blink) and Third Eye. Level: 12. Trait: Attack Bonus (4 pts). Skillchain: Impaction. BLU only.",
    },

    ["Claw Cyclone"] = {
        description             = "Deals slashing dmg (conal AoE, 2-hit).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Slashing",
        trait                   = "Lizard Killer",
        trait_points            = 4,
        property                = "Scission",
        unbridled               = false,
        BLU                     = 20,
        notes                   = "Physical slashing damage (conal AoE), 2 hits. Damage varies with TP. Level: 20. Trait: Lizard Killer (4 pts). Skillchain: Scission. BLU only.",
    },

    ["Smite of Rage"] = {
        description             = "Deals slashing dmg.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Slashing",
        trait                   = "Undead Killer",
        trait_points            = 4,
        property                = "Detonation",
        unbridled               = false,
        BLU                     = 34,
        notes                   = "Physical slashing damage. Damage varies with TP. Level: 34. Trait: Undead Killer (4 pts). Skillchain: Detonation. BLU only.",
    },

    ["Mandibular Bite"] = {
        description             = "Deals slashing dmg.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Slashing",
        trait                   = "Plantoid Killer",
        trait_points            = 4,
        property                = "Induration",
        unbridled               = false,
        BLU                     = 44,
        notes                   = "Physical slashing damage. Damage varies with TP. Level: 44. Trait: Plantoid Killer (4 pts). Skillchain: Induration. BLU only.",
    },

    ["Spiral Spin"] = {
        description             = "Deals slashing dmg + accuracy down.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Slashing",
        trait                   = "Plantoid Killer",
        trait_points            = 4,
        property                = "Transfixion",
        unbridled               = false,
        BLU                     = 60,
        notes                   = "Physical slashing damage. Single target. Additional effect: Accuracy Down (-15, 45-60 s); chance varies with TP. Ignores shadows. Level: 60. Trait: Plantoid Killer (4 pts). Skillchain: Transfixion. BLU only.",
    },

    ["Death Scissors"] = {
        description             = "Deals slashing dmg.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Slashing",
        trait                   = "Attack Bonus",
        trait_points            = 4,
        property                = "Compression / Reverberation",
        unbridled               = false,
        BLU                     = 60,
        notes                   = "Physical slashing damage. Damage varies with TP. Level: 60. Trait: Attack Bonus (4 pts). Skillchain: Compression/Reverberation. BLU only.",
    },

    ["Seedspray"] = {
        description             = "Deals slashing dmg x3 + defense down.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Slashing",
        trait                   = "Beast Killer",
        trait_points            = 4,
        property                = "Induration / Detonation",
        unbridled               = false,
        BLU                     = 61,
        notes                   = "Physical slashing damage, 3 hits, single target. Additional effect: Defense Down (-8%, chance varies with TP). Level: 61. Trait: Beast Killer (4 pts). Skillchain: Induration/Detonation. BLU only.",
    },

    ["Spinal Cleave"] = {
        description             = "Deals slashing dmg.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Slashing",
        trait                   = "Attack Bonus",
        trait_points            = 4,
        property                = "Scission / Detonation",
        unbridled               = false,
        BLU                     = 63,
        notes                   = "Physical slashing damage. Accuracy varies with TP. Level: 63. Trait: Attack Bonus (4 pts). Skillchain: Scission/Detonation. BLU only.",
    },

    ["Vertical Cleave"] = {
        description             = "Deals slashing dmg (ignores Utsusemi).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Slashing",
        trait                   = "Defense Bonus",
        trait_points            = 4,
        property                = "Gravitation",
        unbridled               = false,
        BLU                     = 75,
        notes                   = "Physical slashing damage. Ignores Utsusemi shadows. Damage varies with TP. Level: 75. Trait: Defense Bonus (4 pts). Skillchain: Gravitation. BLU only.",
    },

    ["Vanity Dive"] = {
        description             = "Deals slashing dmg.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Slashing",
        trait                   = "Accuracy Bonus",
        trait_points            = 4,
        property                = "Scission",
        unbridled               = false,
        BLU                     = 82,
        notes                   = "Physical slashing damage. Damage varies with TP. Level: 82. Trait: Accuracy Bonus (4 pts). Skillchain: Scission. BLU only.",
    },

    ["Whirl of Rage"] = {
        description             = "Deals slashing dmg (AoE) + stun.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Slashing",
        trait                   = "Zanshin",
        trait_points            = 4,
        property                = "Scission / Detonation",
        unbridled               = false,
        BLU                     = 83,
        notes                   = "Physical slashing damage (AoE). Additional effect: Stun. Damage varies with TP. Level: 83. Trait: Zanshin (4 pts). Skillchain: Scission/Detonation. BLU only.",
    },

    ["Empty Thrash"] = {
        description             = "Deals slashing dmg (conal AoE).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Slashing",
        trait                   = "Double / Triple Attack",
        trait_points            = 4,
        property                = "Compression / Scission",
        unbridled               = false,
        BLU                     = 87,
        notes                   = "Physical slashing damage (conal AoE). Accuracy varies with TP. Level: 87. Trait: Double/Triple Attack (4 pts). Skillchain: Compression/Scission. BLU only.",
    },

    ["Delta Thrust"] = {
        description             = "Deals slashing dmg (3-hit) + plague.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Slashing",
        trait                   = "Dual Wield",
        trait_points            = 4,
        property                = "Liquefaction / Detonation",
        unbridled               = false,
        BLU                     = 89,
        notes                   = "Physical slashing damage, 3 hits. Additional effect: Plague (-6 MP/tick, -100 TP/tick, 40-60 s). Level: 89. Trait: Dual Wield (4 pts). Skillchain: Liquefaction/Detonation. BLU only.",
    },

    ["Sudden Lunge"] = {
        description             = "Deals slashing dmg + stun.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Slashing",
        trait                   = "Store TP",
        trait_points            = 4,
        property                = "Detonation",
        unbridled               = false,
        BLU                     = 95,
        notes                   = "Physical slashing damage + Stun. Damage varies with TP. Level: 95. Trait: Store TP (4 pts). Skillchain: Detonation. BLU only.",
    },

    ["Quadrastrike"] = {
        description             = "Deals slashing dmg (4-hit, crit rate varies with TP).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Slashing",
        trait                   = "Skillchain Bonus",
        trait_points            = 6,
        property                = "Liquefaction / Scission",
        unbridled               = false,
        BLU                     = 96,
        notes                   = "Physical slashing damage, 4 hits. Critical hit chance varies with TP (no crit without Chain Affinity or Efflux). Level: 96. Trait: Skillchain Bonus (6 pts). Skillchain: Liquefaction/Scission. BLU only.",
    },

    ["Barbed Crescent"] = {
        description             = "Deals slashing dmg + accuracy down.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Slashing",
        trait                   = "Dual Wield",
        trait_points            = 4,
        property                = "Distortion / Liquefaction",
        unbridled               = false,
        BLU                     = 99,
        notes                   = "Physical slashing damage. Additional effect: Accuracy Down (~-30, 120 s). Damage varies with TP. Level: 99. Trait: Dual Wield (4 pts). Skillchain: Distortion/Liquefaction. BLU only.",
    },

    ["Bloodrake"] = {
        description             = "Deals slashing dmg (3-hit) + HP drain (unbridled).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Slashing",
        trait                   = nil,
        trait_points            = 0,
        property                = "Dark / Distortion",
        unbridled               = true,
        BLU                     = 99,
        notes                   = "Physical slashing damage, 3 hits, single target. Additional effect: HP Drain (100% of damage; no drain from undead). Damage varies with TP. Level: 99. Trait: None. Skillchain: Darkness/Distortion. Requires: Unbridled Learning/Wisdom. BLU only.",
    },

    ["Paralyzing Triad"] = {
        description             = "Deals slashing dmg + paralysis (3-hit).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Slashing",
        trait                   = "Skillchain Bonus",
        trait_points            = 8,
        property                = "Gravitation",
        unbridled               = false,
        BLU                     = 99,
        notes                   = "Physical slashing damage, 3 hits. Additional effect: Paralysis (20%, 60 s). Damage varies with TP. Level: 99. Trait: Skillchain Bonus (8 pts). Skillchain: Gravitation. BLU only.",
    },

    ["Saurian Slide"] = {
        description             = "Deals slashing dmg + attack down.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Slashing",
        trait                   = "Inquartata",
        trait_points            = 8,
        property                = "Fragmentation / Distortion",
        unbridled               = false,
        BLU                     = 99,
        notes                   = "Physical slashing damage. Additional effect: Attack Down (-25%, ~60 s). Damage varies with TP. Level: 99. Trait: Inquartata (8 pts). Skillchain: Fragmentation/Distortion. BLU only.",
    },

    ["Thrashing Assault"] = {
        description             = "Deals slashing dmg (5-hit).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Slashing",
        trait                   = "Double / Triple Attack",
        trait_points            = 8,
        property                = "Fusion / Impaction",
        unbridled               = false,
        BLU                     = 99,
        notes                   = "Physical slashing damage, 5 hits. Damage varies with TP. Level: 99. Trait: Double/Triple Attack (8 pts). Skillchain: Fusion/Impaction. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_PHYSICAL_SLASHING

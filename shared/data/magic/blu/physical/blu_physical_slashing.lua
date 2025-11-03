---============================================================================
--- BLUE MAGIC DATABASE - Physical Slashing Spells
---============================================================================
--- Slashing physical damage Blue Magic spells
---
--- @file blu_physical_slashing.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-01 | Updated: 2025-11-01
---============================================================================

local BLU_PHYSICAL_SLASHING = {}

BLU_PHYSICAL_SLASHING.spells = {

    ["Foot Kick"] = {
        description = "Deals slashing dmg.",
        category = "Physical",
        magic_type = "Blue",
        damage_type = "Slashing",
        trait = "Lizard Killer",
        trait_points = 4,
        property = "Detonation",
        unbridled = false,
        BLU = 1,
        notes = "Physical slashing damage. Level: 1. Trait: Lizard Killer (4 pts). Skillchain: Detonation. Uses TP. BLU only.",
    },

    ["Battle Dance"] = {
        description = "Deals slashing dmg (AoE).",
        category = "Physical",
        magic_type = "Blue",
        damage_type = "Slashing",
        trait = "Attack Bonus",
        trait_points = 4,
        property = "Impaction",
        unbridled = false,
        BLU = 12,
        notes = "Physical slashing damage (AoE). Level: 12. Trait: Attack Bonus (4 pts). Skillchain: Impaction. AoE range. Uses TP. BLU only.",
    },

    ["Claw Cyclone"] = {
        description = "Deals slashing dmg (AoE).",
        category = "Physical",
        magic_type = "Blue",
        damage_type = "Slashing",
        trait = "Lizard Killer",
        trait_points = 4,
        property = "Scission",
        unbridled = false,
        BLU = 20,
        notes = "Physical slashing damage (AoE). Level: 20. Trait: Lizard Killer (4 pts). Skillchain: Scission. AoE range. Uses TP. BLU only.",
    },

    ["Smite of Rage"] = {
        description = "Deals slashing dmg.",
        category = "Physical",
        magic_type = "Blue",
        damage_type = "Slashing",
        trait = "Undead Killer",
        trait_points = 4,
        property = "Detonation",
        unbridled = false,
        BLU = 34,
        notes = "Physical slashing damage. Level: 34. Trait: Undead Killer (4 pts). Skillchain: Detonation. Uses TP. BLU only.",
    },

    ["Mandibular Bite"] = {
        description = "Deals slashing dmg + defense down.",
        category = "Physical",
        magic_type = "Blue",
        damage_type = "Slashing",
        trait = "Plantoid Killer",
        trait_points = 4,
        property = "Induration",
        unbridled = false,
        BLU = 44,
        notes = "Physical slashing damage + Defense Down. Level: 44. Trait: Plantoid Killer (4 pts). Skillchain: Induration. Uses TP. BLU only.",
    },

    ["Spiral Spin"] = {
        description = "Deals slashing dmg (AoE).",
        category = "Physical",
        magic_type = "Blue",
        damage_type = "Slashing",
        trait = "Plantoid Killer",
        trait_points = 4,
        property = "Transfixion",
        unbridled = false,
        BLU = 60,
        notes = "Physical slashing damage (AoE). Level: 60. Trait: Plantoid Killer (4 pts). Skillchain: Transfixion. AoE range. Uses TP. BLU only.",
    },

    ["Death Scissors"] = {
        description = "Deals slashing dmg + accuracy down.",
        category = "Physical",
        magic_type = "Blue",
        damage_type = "Slashing",
        trait = "Attack Bonus",
        trait_points = 4,
        property = "Compression / Reverberation",
        unbridled = false,
        BLU = 60,
        notes = "Physical slashing damage + Accuracy Down. Level: 60. Trait: Attack Bonus (4 pts). Skillchain: Compression/Reverberation. Uses TP. BLU only.",
    },

    ["Seedspray"] = {
        description = "Deals slashing dmg (AoE).",
        category = "Physical",
        magic_type = "Blue",
        damage_type = "Slashing",
        trait = "Beast Killer",
        trait_points = 4,
        property = "Induration / Detonation",
        unbridled = false,
        BLU = 61,
        notes = "Physical slashing damage (AoE). Level: 61. Trait: Beast Killer (4 pts). Skillchain: Induration/Detonation. AoE range. Uses TP. BLU only.",
    },

    ["Spinal Cleave"] = {
        description = "Deals slashing dmg + paralysis.",
        category = "Physical",
        magic_type = "Blue",
        damage_type = "Slashing",
        trait = "Attack Bonus",
        trait_points = 4,
        property = "Scission / Detonation",
        unbridled = false,
        BLU = 63,
        notes = "Physical slashing damage + Paralysis. Level: 63. Trait: Attack Bonus (4 pts). Skillchain: Scission/Detonation. Uses TP. BLU only.",
    },

    ["Vertical Cleave"] = {
        description = "Deals slashing dmg (high potency).",
        category = "Physical",
        magic_type = "Blue",
        damage_type = "Slashing",
        trait = "Defense Bonus",
        trait_points = 4,
        property = "Gravitation",
        unbridled = false,
        BLU = 75,
        notes = "Physical slashing damage (high potency). Level: 75. Trait: Defense Bonus (4 pts). Skillchain: Gravitation. Uses TP. BLU only.",
    },

    ["Vanity Dive"] = {
        description = "Deals slashing dmg.",
        category = "Physical",
        magic_type = "Blue",
        damage_type = "Slashing",
        trait = "Accuracy Bonus",
        trait_points = 4,
        property = "Scission",
        unbridled = false,
        BLU = 82,
        notes = "Physical slashing damage. Level: 82. Trait: Accuracy Bonus (4 pts). Skillchain: Scission. Uses TP. BLU only.",
    },

    ["Whirl of Rage"] = {
        description = "Deals slashing dmg (AoE).",
        category = "Physical",
        magic_type = "Blue",
        damage_type = "Slashing",
        trait = "Zanshin",
        trait_points = 4,
        property = "Scission / Detonation",
        unbridled = false,
        BLU = 83,
        notes = "Physical slashing damage (AoE). Level: 83. Trait: Zanshin (4 pts). Skillchain: Scission/Detonation. AoE range. Uses TP. BLU only.",
    },

    ["Empty Thrash"] = {
        description = "Deals slashing dmg (3-hit).",
        category = "Physical",
        magic_type = "Blue",
        damage_type = "Slashing",
        trait = "Double / Triple Attack",
        trait_points = 4,
        property = "Compression / Scission",
        unbridled = false,
        BLU = 87,
        notes = "Physical slashing damage (3-fold). Level: 87. Trait: Double/Triple Attack (4 pts). Skillchain: Compression/Scission. 3-hit attack. Uses TP. BLU only.",
    },

    ["Delta Thrust"] = {
        description = "Deals slashing dmg.",
        category = "Physical",
        magic_type = "Blue",
        damage_type = "Slashing",
        trait = "Dual Wield",
        trait_points = 4,
        property = "Liquefaction / Detonation",
        unbridled = false,
        BLU = 89,
        notes = "Physical slashing damage. Level: 89. Trait: Dual Wield (4 pts). Skillchain: Liquefaction/Detonation. Uses TP. BLU only.",
    },

    ["Sudden Lunge"] = {
        description = "Deals slashing dmg + stun.",
        category = "Physical",
        magic_type = "Blue",
        damage_type = "Slashing",
        trait = "Store TP",
        trait_points = 4,
        property = "Detonation",
        unbridled = false,
        BLU = 95,
        notes = "Physical slashing damage + Stun. Level: 95. Trait: Store TP (4 pts). Skillchain: Detonation. Uses TP. BLU only.",
    },

    ["Quadrastrike"] = {
        description = "Deals slashing dmg (4-hit).",
        category = "Physical",
        magic_type = "Blue",
        damage_type = "Slashing",
        trait = "Skillchain Bonus",
        trait_points = 6,
        property = "Liquefaction / Scission",
        unbridled = false,
        BLU = 96,
        notes = "Physical slashing damage (4-fold). Level: 96. Trait: Skillchain Bonus (6 pts). Skillchain: Liquefaction/Scission. 4-hit attack. Uses TP. BLU only.",
    },

    ["Barbed Crescent"] = {
        description = "Deals slashing dmg + poison.",
        category = "Physical",
        magic_type = "Blue",
        damage_type = "Slashing",
        trait = "Dual Wield",
        trait_points = 4,
        property = "Distortion / Liquefaction",
        unbridled = false,
        BLU = 99,
        notes = "Physical slashing damage + Poison. Level: 99. Trait: Dual Wield (4 pts). Skillchain: Distortion/Liquefaction. Uses TP. BLU only.",
    },

    ["Bloodrake"] = {
        description = "Deals slashing dmg (unbridled, AoE).",
        category = "Physical",
        magic_type = "Blue",
        damage_type = "Slashing",
        trait = nil,
        trait_points = 0,
        property = "Dark / Distortion",
        unbridled = true,
        BLU = 99,
        notes = "Physical slashing damage (unbridled, AoE). Level: 99. Trait: None (0 pts). Skillchain: Dark/Distortion. Requires: Unbridled Learning/Wisdom. AoE range. Uses TP. BLU only.",
    },

    ["Paralyzing Triad"] = {
        description = "Deals slashing dmg + paralysis (3-hit).",
        category = "Physical",
        magic_type = "Blue",
        damage_type = "Slashing",
        trait = "Skillchain Bonus",
        trait_points = 8,
        property = "Gravitation",
        unbridled = false,
        BLU = 99,
        notes = "Physical slashing damage + Paralysis (3-fold). Level: 99. Trait: Skillchain Bonus (8 pts). Skillchain: Gravitation. 3-hit attack. Uses TP. BLU only.",
    },

    ["Saurian Slide"] = {
        description = "Deals slashing dmg.",
        category = "Physical",
        magic_type = "Blue",
        damage_type = "Slashing",
        trait = "Inquartata",
        trait_points = 8,
        property = "Fragmentation / Distortion",
        unbridled = false,
        BLU = 99,
        notes = "Physical slashing damage. Level: 99. Trait: Inquartata (8 pts). Skillchain: Fragmentation/Distortion. Uses TP. BLU only.",
    },

    ["Thrashing Assault"] = {
        description = "Deals slashing dmg (multi-hit).",
        category = "Physical",
        magic_type = "Blue",
        damage_type = "Slashing",
        trait = "Double / Triple Attack",
        trait_points = 8,
        property = "Fusion / Impaction",
        unbridled = false,
        BLU = 99,
        notes = "Physical slashing damage (multi-hit). Level: 99. Trait: Double/Triple Attack (8 pts). Skillchain: Fusion/Impaction. Uses TP. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_PHYSICAL_SLASHING

---============================================================================
--- BLUE MAGIC DATABASE - Physical Blunt Spells
---============================================================================
--- Blunt physical damage Blue Magic spells
---
--- @file blu_physical_blunt.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06 | Updated: 2025-11-01
---============================================================================

local BLU_PHYSICAL_BLUNT = {}

BLU_PHYSICAL_BLUNT.spells = {

    ["Sprout Smack"] = {
        description             = "Deals blunt dmg.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = "Beast Killer",
        trait_points            = 4,
        property                = "Reverberation",
        unbridled               = false,
        BLU                     = 4,
        notes                   = "Physical blunt damage. Level: 4. Trait: Beast Killer (4 pts). Skillchain: Reverberation. Uses TP. BLU only.",
    },

    ["Power Attack"] = {
        description             = "Deals blunt dmg.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = "Plantoid Killer",
        trait_points            = 4,
        property                = "Reverberation",
        unbridled               = false,
        BLU                     = 4,
        notes                   = "Physical blunt damage. Level: 4. Trait: Plantoid Killer (4 pts). Skillchain: Reverberation. Uses TP. BLU only.",
    },

    ["Head Butt"] = {
        description             = "Deals blunt dmg + stun.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = nil,
        trait_points            = 0,
        property                = "Impaction",
        unbridled               = false,
        BLU                     = 12,
        notes                   = "Physical blunt damage + Stun. Level: 12. Trait: None (0 pts). Skillchain: Impaction. Uses TP. BLU only.",
    },

    ["Helldive"] = {
        description             = "Deals blunt dmg.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = nil,
        trait_points            = 0,
        property                = "Transfixion",
        unbridled               = false,
        BLU                     = 16,
        notes                   = "Physical blunt damage. Level: 16. Trait: None (0 pts). Skillchain: Transfixion. Uses TP. BLU only.",
    },

    ["Bludgeon"] = {
        description             = "Deals blunt dmg.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = "Undead Killer",
        trait_points            = 4,
        property                = "Liquefaction",
        unbridled               = false,
        BLU                     = 18,
        notes                   = "Physical blunt damage. Level: 18. Trait: Undead Killer (4 pts). Skillchain: Liquefaction. Uses TP. BLU only.",
    },

    ["Grand Slam"] = {
        description             = "Deals blunt dmg (high potency).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = "Defense Bonus",
        trait_points            = 4,
        property                = "Induration",
        unbridled               = false,
        BLU                     = 30,
        notes                   = "Physical blunt damage (high potency). Level: 30. Trait: Defense Bonus (4 pts). Skillchain: Induration. Uses TP. BLU only.",
    },

    ["Jet Stream"] = {
        description             = "Deals blunt dmg (AoE).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = "Rapid Shot",
        trait_points            = 4,
        property                = "Impaction",
        unbridled               = false,
        BLU                     = 38,
        notes                   = "Physical blunt damage (AoE). Level: 38. Trait: Rapid Shot (4 pts). Skillchain: Impaction. AoE range. Uses TP. BLU only.",
    },

    ["Uppercut"] = {
        description             = "Deals blunt dmg.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = "Attack Bonus",
        trait_points            = 4,
        property                = "Liquefaction",
        unbridled               = false,
        BLU                     = 38,
        notes                   = "Physical blunt damage. Level: 38. Trait: Attack Bonus (4 pts). Skillchain: Liquefaction. Uses TP. BLU only.",
    },

    ["Body Slam"] = {
        description             = "Deals blunt dmg + bind.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = "Max HP Boost",
        trait_points            = 4,
        property                = "Impaction",
        unbridled               = false,
        BLU                     = 62,
        notes                   = "Physical blunt damage + Bind. Level: 62. Trait: Max HP Boost (4 pts). Skillchain: Impaction. Uses TP. BLU only.",
    },

    ["Frypan"] = {
        description             = "Deals blunt fire dmg + stun.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = "Max HP Boost",
        trait_points            = 4,
        property                = "Impaction",
        unbridled               = false,
        BLU                     = 63,
        notes                   = "Physical blunt fire damage + Stun. Level: 63. Trait: Max HP Boost (4 pts). Skillchain: Impaction. Uses TP. BLU only.",
    },

    ["Frenetic Rip"] = {
        description             = "Deals blunt dmg (multi-hit).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = "Accuracy Bonus",
        trait_points            = 4,
        property                = "Induration",
        unbridled               = false,
        BLU                     = 63,
        notes                   = "Physical blunt damage (multi-hit). Level: 63. Trait: Accuracy Bonus (4 pts). Skillchain: Induration. Uses TP. BLU only.",
    },

    ["Ram Charge"] = {
        description             = "Deals blunt dmg + knockback.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = "Lizard Killer",
        trait_points            = 4,
        property                = "Fragmentation",
        unbridled               = false,
        BLU                     = 73,
        notes                   = "Physical blunt damage + Knockback. Level: 73. Trait: Lizard Killer (4 pts). Skillchain: Fragmentation. Uses TP. BLU only.",
    },

    ["Goblin Rush"] = {
        description             = "Deals blunt dmg (5-hit).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = "Skillchain Bonus",
        trait_points            = 6,
        property                = "Fusion / Impaction",
        unbridled               = false,
        BLU                     = 81,
        notes                   = "Physical blunt damage (5-fold). Level: 81. Trait: Skillchain Bonus (6 pts). Skillchain: Fusion/Impaction. 5-hit attack. Uses TP. BLU only.",
    },

    ["Heavy Strike"] = {
        description             = "Deals blunt dmg.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = "Double / Triple Attack",
        trait_points            = 4,
        property                = "Fragmentation / Transfixion",
        unbridled               = false,
        BLU                     = 92,
        notes                   = "Physical blunt damage. Level: 92. Trait: Double/Triple Attack (4 pts). Skillchain: Fragmentation/Transfixion. Uses TP. BLU only.",
    },

    ["Tourbillion"] = {
        description             = "Deals blunt dmg (unbridled).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = nil,
        trait_points            = 0,
        property                = "Light / Fragmentation",
        unbridled               = true,
        BLU                     = 97,
        notes                   = "Physical blunt damage (unbridled). Level: 97. Trait: None (0 pts). Skillchain: Light/Fragmentation. Requires: Unbridled Learning/Wisdom. Uses TP. BLU only.",
    },

    ["Bilgestorm"] = {
        description             = "Deals blunt dmg (unbridled, AoE).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = nil,
        trait_points            = 0,
        property                = "Dark / Gravitation",
        unbridled               = true,
        BLU                     = 99,
        notes                   = "Physical blunt damage (unbridled, AoE). Level: 99. Trait: None (0 pts). Skillchain: Dark/Gravitation. Requires: Unbridled Learning/Wisdom. Uses TP. BLU only.",
    },

    ["Sweeping Gouge"] = {
        description             = "Deals blunt dmg (AoE).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = "Lizard Killer",
        trait_points            = 8,
        property                = "Question",
        unbridled               = false,
        BLU                     = 99,
        notes                   = "Physical blunt damage (AoE). Level: 99. Trait: Lizard Killer (8 pts). Skillchain: Question. AoE range. Uses TP. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_PHYSICAL_BLUNT

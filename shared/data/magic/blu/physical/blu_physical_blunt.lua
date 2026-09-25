---============================================================================
--- BLUE MAGIC DATABASE - Physical Blunt Spells
---============================================================================
--- Blunt physical damage Blue Magic spells
---
--- @file shared/data/magic/blu/physical/blu_physical_blunt.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06
---============================================================================

local BLU_PHYSICAL_BLUNT = {}

BLU_PHYSICAL_BLUNT.spells = {

    ["Sprout Smack"] = {
        description             = "Deals blunt dmg + slow.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = "Beast Killer",
        trait_points            = 4,
        property                = "Reverberation",
        unbridled               = false,
        BLU                     = 4,
        notes                   = "Physical blunt damage. Additional effect: Slow (15%); duration varies with TP. Level: 4. Trait: Beast Killer (4 pts). Skillchain: Reverberation. BLU only.",
    },

    ["Power Attack"] = {
        description             = "Deals slashing dmg (crit rate varies with TP).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Slashing",
        trait                   = "Plantoid Killer",
        trait_points            = 4,
        property                = "Reverberation",
        unbridled               = false,
        BLU                     = 4,
        notes                   = "Physical slashing damage. Critical hit chance varies with TP. Level: 4. Trait: Plantoid Killer (4 pts). Skillchain: Reverberation. BLU only.",
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
        notes                   = "Physical blunt damage + Stun. Damage varies with TP. Level: 12. Trait: None. Skillchain: Impaction. BLU only.",
    },

    ["Helldive"] = {
        description             = "Deals slashing dmg + knockback.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Slashing",
        trait                   = nil,
        trait_points            = 0,
        property                = "Transfixion",
        unbridled               = false,
        BLU                     = 16,
        notes                   = "Physical slashing damage + Knockback. Damage varies with TP. Level: 16. Trait: None. Skillchain: Transfixion. BLU only.",
    },

    ["Bludgeon"] = {
        description             = "Deals blunt dmg (3-hit).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = "Undead Killer",
        trait_points            = 4,
        property                = "Liquefaction",
        unbridled               = false,
        BLU                     = 18,
        notes                   = "Physical blunt damage, 3 hits. Accuracy varies with TP. Level: 18. Trait: Undead Killer (4 pts). Skillchain: Liquefaction. BLU only.",
    },

    ["Grand Slam"] = {
        description             = "Deals blunt dmg (AoE).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = "Defense Bonus",
        trait_points            = 4,
        property                = "Induration",
        unbridled               = false,
        BLU                     = 30,
        notes                   = "Physical blunt damage (AoE, centered on the caster). Damage varies with TP. Level: 30. Trait: Defense Bonus (4 pts). Skillchain: Induration. BLU only.",
    },

    ["Jet Stream"] = {
        description             = "Deals blunt dmg (3-hit).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = "Rapid Shot",
        trait_points            = 4,
        property                = "Impaction",
        unbridled               = false,
        BLU                     = 38,
        notes                   = "Physical blunt damage, 3 hits. Single target. Accuracy varies with TP. Level: 38. Trait: Rapid Shot (4 pts). Skillchain: Impaction. BLU only.",
    },

    ["Uppercut"] = {
        description             = "Deals blunt dmg.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = "Attack Bonus",
        trait_points            = 4,
        property                = "Liquefaction / Impaction",
        unbridled               = false,
        BLU                     = 38,
        notes                   = "Physical blunt damage. Damage varies with TP. Level: 38. Trait: Attack Bonus (4 pts). Skillchain: Liquefaction/Impaction. BLU only.",
    },

    ["Body Slam"] = {
        description             = "Deals blunt dmg (AoE).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = "Max HP Boost",
        trait_points            = 4,
        property                = "Impaction",
        unbridled               = false,
        BLU                     = 62,
        notes                   = "Physical blunt damage (AoE). Damage varies with TP. Level: 62. Trait: Max HP Boost (4 pts). Skillchain: Impaction. BLU only.",
    },

    ["Frypan"] = {
        description             = "Deals blunt dmg (AoE) + stun.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = "Max HP Boost",
        trait_points            = 4,
        property                = "Impaction",
        unbridled               = false,
        BLU                     = 63,
        notes                   = "Physical blunt damage (AoE). Additional effect: Stun. Accuracy varies with TP. Level: 63. Trait: Max HP Boost (4 pts). Skillchain: Impaction. BLU only.",
    },

    ["Frenetic Rip"] = {
        description             = "Deals blunt dmg (3-hit).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = "Accuracy Bonus",
        trait_points            = 4,
        property                = "Induration",
        unbridled               = false,
        BLU                     = 63,
        notes                   = "Physical blunt damage, 3 hits. Damage varies with TP. Level: 63. Trait: Accuracy Bonus (4 pts). Skillchain: Induration. BLU only.",
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
        notes                   = "Physical blunt damage + Knockback. Damage varies with TP. Level: 73. Trait: Lizard Killer (4 pts). Skillchain: Fragmentation. BLU only.",
    },

    ["Goblin Rush"] = {
        description             = "Deals blunt dmg (3-hit).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = "Skillchain Bonus",
        trait_points            = 6,
        property                = "Fusion / Impaction",
        unbridled               = false,
        BLU                     = 81,
        notes                   = "Physical blunt damage, 3 hits. Accuracy varies with TP. Level: 81. Trait: Skillchain Bonus (6 pts). Skillchain: Fusion/Impaction. BLU only.",
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
        notes                   = "Physical blunt damage. Automatic critical hit; large accuracy penalty. Damage varies with TP. Level: 92. Trait: Double/Triple Attack (4 pts). Skillchain: Fragmentation/Transfixion. BLU only.",
    },

    ["Tourbillion"] = {
        description             = "Deals blunt dmg (AoE) + defense down (unbridled).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = nil,
        trait_points            = 0,
        property                = "Light / Fragmentation",
        unbridled               = true,
        BLU                     = 97,
        notes                   = "Physical blunt damage (AoE). Additional effect: Defense Down (~33%, 60-120 s; duration varies with TP). Level: 97. Trait: None. Skillchain: Light/Fragmentation. Requires: Unbridled Learning/Wisdom. BLU only.",
    },

    ["Bilgestorm"] = {
        description             = "Deals blunt dmg (AoE) + attack/accuracy/defense down (unbridled).",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = nil,
        trait_points            = 0,
        property                = "Dark / Gravitation",
        unbridled               = true,
        BLU                     = 99,
        notes                   = "Physical blunt damage (AoE). Additional effect: Defense Down -25%, Attack Down -25%, Accuracy Down -10 (each resisted independently). Level: 99. Trait: None. Skillchain: Darkness/Gravitation. Requires: Unbridled Learning/Wisdom. BLU only.",
    },

    ["Sweeping Gouge"] = {
        description             = "Deals blunt dmg (2-hit) + defense down.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Blunt",
        trait                   = "Lizard Killer",
        trait_points            = 8,
        property                = "Question",
        unbridled               = false,
        BLU                     = 99,
        notes                   = "Physical blunt damage, 2 hits, single target. Additional effect: Defense Down (~16%, 90 s; duration varies with TP). Level: 99. Trait: Lizard Killer (8 pts). Skillchain: unknown. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_PHYSICAL_BLUNT

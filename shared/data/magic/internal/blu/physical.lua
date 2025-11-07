---============================================================================
--- BLU Physical Spells - Physical Damage BLU Spells
---============================================================================
--- @file internal/blu/physical.lua
--- @author Tetsouo
---============================================================================
local physical_spells = {}

physical_spells.spells = {

    ---========================================================================
    --- LEVEL 1 SPELLS
    ---========================================================================

    ["Foot Kick"] = {
        damage_type             = "Slashing",
        trait                   = "Lizard Killer",
        trait_points            = 4,
        property                = "Detonation",
        unbridled               = false,
        BLU                     = 1
    },

    ---========================================================================
    --- LEVEL 4 SPELLS
    ---========================================================================

    ["Sprout Smack"] = {
        damage_type             = "Blunt",
        trait                   = "Beast Killer",
        trait_points            = 4,
        property                = "Reverberation",
        unbridled               = false,
        BLU                     = 4
    },
    ["Wild Oats"] = {
        damage_type             = "Piercing",
        trait                   = "Beast Killer",
        trait_points            = 4,
        property                = "Transfixion",
        unbridled               = false,
        BLU                     = 4
    },
    ["Power Attack"] = {
        damage_type             = "Blunt",
        trait                   = "Plantoid Killer",
        trait_points            = 4,
        property                = "Reverberation",
        unbridled               = false,
        BLU                     = 4
    },

    ---========================================================================
    --- LEVEL 8 SPELLS
    ---========================================================================

    ["Queasyshroom"] = {
        damage_type             = "Ranged",
        trait                   = nil,
        trait_points            = 0,
        property                = "Compression",
        unbridled               = false,
        BLU                     = 8
    },

    ---========================================================================
    --- LEVEL 12 SPELLS
    ---========================================================================

    ["Battle Dance"] = {
        damage_type             = "Slashing",
        trait                   = "Attack Bonus",
        trait_points            = 4,
        property                = "Impaction",
        unbridled               = false,
        BLU                     = 12
    },
    ["Feather Storm"] = {
        damage_type             = "Ranged",
        trait                   = "Rapid Shot",
        trait_points            = 4,
        property                = "Transfixion",
        unbridled               = false,
        BLU                     = 12
    },
    ["Head Butt"] = {
        damage_type             = "Blunt",
        trait                   = nil,
        trait_points            = 0,
        property                = "Impaction",
        unbridled               = false,
        BLU                     = 12
    },

    ---========================================================================
    --- LEVEL 16 SPELLS
    ---========================================================================

    ["Helldive"] = {
        damage_type             = "Blunt",
        trait                   = nil,
        trait_points            = 0,
        property                = "Transfixion",
        unbridled               = false,
        BLU                     = 16
    },

    ---========================================================================
    --- LEVEL 18 SPELLS
    ---========================================================================

    ["Bludgeon"] = {
        damage_type             = "Blunt",
        trait                   = "Undead Killer",
        trait_points            = 4,
        property                = "Liquefaction",
        unbridled               = false,
        BLU                     = 18
    },

    ---========================================================================
    --- LEVEL 20 SPELLS
    ---========================================================================

    ["Claw Cyclone"] = {
        damage_type             = "Slashing",
        trait                   = "Lizard Killer",
        trait_points            = 4,
        property                = "Scission",
        unbridled               = false,
        BLU                     = 20
    },

    ---========================================================================
    --- LEVEL 26 SPELLS
    ---========================================================================

    ["Screwdriver"] = {
        damage_type             = "Piercing",
        trait                   = "Evasion Bonus",
        trait_points            = 4,
        property                = "Transfixion / Scission",
        unbridled               = false,
        BLU                     = 26
    },

    ---========================================================================
    --- LEVEL 30 SPELLS
    ---========================================================================

    ["Grand Slam"] = {
        damage_type             = "Blunt",
        trait                   = "Defense Bonus",
        trait_points            = 4,
        property                = "Induration",
        unbridled               = false,
        BLU                     = 30
    },

    ---========================================================================
    --- LEVEL 34 SPELLS
    ---========================================================================

    ["Smite of Rage"] = {
        damage_type             = "Slashing",
        trait                   = "Undead Killer",
        trait_points            = 4,
        property                = "Detonation",
        unbridled               = false,
        BLU                     = 34
    },

    ---========================================================================
    --- LEVEL 36 SPELLS
    ---========================================================================

    ["Pinecone Bomb"] = {
        damage_type             = "Ranged",
        trait                   = nil,
        trait_points            = 0,
        property                = "Liquefaction",
        unbridled               = false,
        BLU                     = 36
    },

    ---========================================================================
    --- LEVEL 38 SPELLS
    ---========================================================================

    ["Jet Stream"] = {
        damage_type             = "Blunt",
        trait                   = "Rapid Shot",
        trait_points            = 4,
        property                = "Impaction",
        unbridled               = false,
        BLU                     = 38
    },
    ["Uppercut"] = {
        damage_type             = "Blunt",
        trait                   = "Attack Bonus",
        trait_points            = 4,
        property                = "Liquefaction",
        unbridled               = false,
        BLU                     = 38
    },

    ---========================================================================
    --- LEVEL 40 SPELLS
    ---========================================================================

    ["Terror Touch"] = {
        damage_type             = "H2H",
        trait                   = "Defense Bonus",
        trait_points            = 4,
        property                = "Compression / Reverberation",
        unbridled               = false,
        BLU                     = 40
    },

    ---========================================================================
    --- LEVEL 44 SPELLS
    ---========================================================================

    ["Mandibular Bite"] = {
        damage_type             = "Slashing",
        trait                   = "Plantoid Killer",
        trait_points            = 4,
        property                = "Induration",
        unbridled               = false,
        BLU                     = 44
    },

    ---========================================================================
    --- LEVEL 48 SPELLS
    ---========================================================================

    ["Sickle Slash"] = {
        damage_type             = "H2H",
        trait                   = "Store TP",
        trait_points            = 4,
        property                = "Compression",
        unbridled               = false,
        BLU                     = 48
    },

    ---========================================================================
    --- LEVEL 60 SPELLS
    ---========================================================================

    ["Dimensional Death"] = {
        damage_type             = "H2H",
        trait                   = "Accuracy Bonus",
        trait_points            = 4,
        property                = "Impaction",
        unbridled               = false,
        BLU                     = 60
    },
    ["Spiral Spin"] = {
        damage_type             = "Slashing",
        trait                   = "Plantoid Killer",
        trait_points            = 4,
        property                = "Transfixion",
        unbridled               = false,
        BLU                     = 60
    },
    ["Death Scissors"] = {
        damage_type             = "Slashing",
        trait                   = "Attack Bonus",
        trait_points            = 4,
        property                = "Compression / Reverberation",
        unbridled               = false,
        BLU                     = 60
    },

    ---========================================================================
    --- LEVEL 61 SPELLS
    ---========================================================================

    ["Seedspray"] = {
        damage_type             = "Slashing",
        trait                   = "Beast Killer",
        trait_points            = 4,
        property                = "Induration / Detonation",
        unbridled               = false,
        BLU                     = 61
    },

    ---========================================================================
    --- LEVEL 62 SPELLS
    ---========================================================================

    ["Body Slam"] = {
        damage_type             = "Blunt",
        trait                   = "Max HP Boost",
        trait_points            = 4,
        property                = "Impaction",
        unbridled               = false,
        BLU                     = 62
    },

    ---========================================================================
    --- LEVEL 63 SPELLS
    ---========================================================================

    ["Hydro Shot"] = {
        damage_type             = "H2H",
        trait                   = "Rapid Shot",
        trait_points            = 4,
        property                = "Reverberation",
        unbridled               = false,
        BLU                     = 63
    },
    ["Frypan"] = {
        damage_type             = "Blunt",
        trait                   = "Max HP Boost",
        trait_points            = 4,
        property                = "Impaction",
        unbridled               = false,
        BLU                     = 63
    },
    ["Frenetic Rip"] = {
        damage_type             = "Blunt",
        trait                   = "Accuracy Bonus",
        trait_points            = 4,
        property                = "Induration",
        unbridled               = false,
        BLU                     = 63
    },
    ["Spinal Cleave"] = {
        damage_type             = "Slashing",
        trait                   = "Attack Bonus",
        trait_points            = 4,
        property                = "Scission / Detonation",
        unbridled               = false,
        BLU                     = 63
    },

    ---========================================================================
    --- LEVEL 69 SPELLS
    ---========================================================================

    ["Tail Slap"] = {
        damage_type             = "H2H",
        trait                   = "Store TP",
        trait_points            = 4,
        property                = "Reverberation",
        unbridled               = false,
        BLU                     = 69
    },
    ["Hysteric Barrage"] = {
        damage_type             = "H2H",
        trait                   = "Evasion Bonus",
        trait_points            = 4,
        property                = "Detonation",
        unbridled               = false,
        BLU                     = 69
    },

    ---========================================================================
    --- LEVEL 70 SPELLS
    ---========================================================================

    ["Asuran Claws"] = {
        damage_type             = "H2H",
        trait                   = "Counter",
        trait_points            = 4,
        property                = "Liquefaction / Impaction",
        unbridled               = false,
        BLU                     = 70
    },
    ["Cannonball"] = {
        damage_type             = "H2H",
        trait                   = nil,
        trait_points            = 0,
        property                = "Fusion",
        unbridled               = false,
        BLU                     = 70
    },

    ---========================================================================
    --- LEVEL 72 SPELLS
    ---========================================================================

    ["Disseverment"] = {
        damage_type             = "Piercing",
        trait                   = "Accuracy Bonus",
        trait_points            = 4,
        property                = "Distortion",
        unbridled               = false,
        BLU                     = 72
    },
    ["Sub-zero Smash"] = {
        damage_type             = "Piercing",
        trait                   = "Fast Cast",
        trait_points            = 4,
        property                = "Fragmentation",
        unbridled               = false,
        BLU                     = 72
    },

    ---========================================================================
    --- LEVEL 73 SPELLS
    ---========================================================================

    ["Ram Charge"] = {
        damage_type             = "Blunt",
        trait                   = "Lizard Killer",
        trait_points            = 4,
        property                = "Fragmentation",
        unbridled               = false,
        BLU                     = 73
    },

    ---========================================================================
    --- LEVEL 75 SPELLS
    ---========================================================================

    ["Vertical Cleave"] = {
        damage_type             = "Slashing",
        trait                   = "Defense Bonus",
        trait_points            = 4,
        property                = "Gravitation",
        unbridled               = false,
        BLU                     = 75
    },

    ---========================================================================
    --- LEVEL 81 SPELLS
    ---========================================================================

    ["Final Sting"] = {
        damage_type             = "Piercing",
        trait                   = "Zanshin",
        trait_points            = 4,
        property                = "Fusion",
        unbridled               = false,
        BLU                     = 81
    },
    ["Goblin Rush"] = {
        damage_type             = "Blunt",
        trait                   = "Skillchain Bonus",
        trait_points            = 6,
        property                = "Fusion / Impaction",
        unbridled               = false,
        BLU                     = 81
    },

    ---========================================================================
    --- LEVEL 82 SPELLS
    ---========================================================================

    ["Vanity Dive"] = {
        damage_type             = "Slashing",
        trait                   = "Accuracy Bonus",
        trait_points            = 4,
        property                = "Scission",
        unbridled               = false,
        BLU                     = 82
    },

    ---========================================================================
    --- LEVEL 83 SPELLS
    ---========================================================================

    ["Whirl of Rage"] = {
        damage_type             = "Slashing",
        trait                   = "Zanshin",
        trait_points            = 4,
        property                = "Scission / Detonation",
        unbridled               = false,
        BLU                     = 83
    },
    ["Benthic Typhoon"] = {
        damage_type             = "Piercing",
        trait                   = "Skillchain Bonus",
        trait_points            = 4,
        property                = "Gravitation / Transfixion",
        unbridled               = false,
        BLU                     = 83
    },

    ---========================================================================
    --- LEVEL 85 SPELLS
    ---========================================================================

    ["Quad. Continuum"] = {
        damage_type             = "Piercing",
        trait                   = "Dual Wield",
        trait_points            = 4,
        property                = "Distortion / Scission",
        unbridled               = false,
        BLU                     = 85
    },

    ---========================================================================
    --- LEVEL 87 SPELLS
    ---========================================================================

    ["Empty Thrash"] = {
        damage_type             = "Slashing",
        trait                   = "Double / Triple Attack",
        trait_points            = 4,
        property                = "Compression / Scission",
        unbridled               = false,
        BLU                     = 87
    },

    ---========================================================================
    --- LEVEL 89 SPELLS
    ---========================================================================

    ["Delta Thrust"] = {
        damage_type             = "Slashing",
        trait                   = "Dual Wield",
        trait_points            = 4,
        property                = "Liquefaction / Detonation",
        unbridled               = false,
        BLU                     = 89
    },

    ---========================================================================
    --- LEVEL 92 SPELLS
    ---========================================================================

    ["Heavy Strike"] = {
        damage_type             = "Blunt",
        trait                   = "Double / Triple Attack",
        trait_points            = 4,
        property                = "Fragmentation / Transfixion",
        unbridled               = false,
        BLU                     = 92
    },

    ---========================================================================
    --- LEVEL 95 SPELLS
    ---========================================================================

    ["Sudden Lunge"] = {
        damage_type             = "Slashing",
        trait                   = "Store TP",
        trait_points            = 4,
        property                = "Detonation",
        unbridled               = false,
        BLU                     = 95
    },

    ---========================================================================
    --- LEVEL 96 SPELLS
    ---========================================================================

    ["Quadrastrike"] = {
        damage_type             = "Slashing",
        trait                   = "Skillchain Bonus",
        trait_points            = 6,
        property                = "Liquefaction / Scission",
        unbridled               = false,
        BLU                     = 96
    },

    ---========================================================================
    --- LEVEL 97 SPELLS
    ---========================================================================

    ["Tourbillion"] = {
        damage_type             = "Blunt",
        trait                   = nil,
        trait_points            = 0,
        property                = "Light / Fragmentation",
        unbridled               = true,
        BLU                     = 97
    },

    ---========================================================================
    --- LEVEL 98 SPELLS
    ---========================================================================

    ["Amorphic Spikes"] = {
        damage_type             = "Piercing",
        trait                   = "Gilfinder / Treasure Hunter",
        trait_points            = 6,
        property                = "Gravitation / Transfixion",
        unbridled               = false,
        BLU                     = 98
    },

    ---========================================================================
    --- LEVEL 99 SPELLS
    ---========================================================================

    ["Barbed Crescent"] = {
        damage_type             = "Slashing",
        trait                   = "Dual Wield",
        trait_points            = 4,
        property                = "Distortion / Liquefaction",
        unbridled               = false,
        BLU                     = 99
    },
    ["Bilgestorm"] = {
        damage_type             = "Blunt",
        trait                   = nil,
        trait_points            = 0,
        property                = "Dark / Gravitation",
        unbridled               = true,
        BLU                     = 99
    },
    ["Bloodrake"] = {
        damage_type             = "Slashing",
        trait                   = nil,
        trait_points            = 0,
        property                = "Dark / Distortion",
        unbridled               = true,
        BLU                     = 99
    },
    ["Glutinous Dart"] = {
        damage_type             = "Piercing",
        trait                   = "Max HP Boost",
        trait_points            = 4,
        property                = "Fragmentation",
        unbridled               = false,
        BLU                     = 99
    },
    ["Paralyzing Triad"] = {
        damage_type             = "Slashing",
        trait                   = "Skillchain Bonus",
        trait_points            = 8,
        property                = "Gravitation",
        unbridled               = false,
        BLU                     = 99
    },
    ["Sweeping Gouge"] = {
        damage_type             = "Blunt",
        trait                   = "Lizard Killer",
        trait_points            = 8,
        property                = "Question",
        unbridled               = false,
        BLU                     = 99
    },
    ["Saurian Slide"] = {
        damage_type             = "Slashing",
        trait                   = "Inquartata",
        trait_points            = 8,
        property                = "Fragmentation / Distortion",
        unbridled               = false,
        BLU                     = 99
    },
    ["Thrashing Assault"] = {
        damage_type             = "Slashing",
        trait                   = "Double / Triple Attack",
        trait_points            = 8,
        property                = "Fusion / Impaction",
        unbridled               = false,
        BLU                     = 99
    },
    ["Sinker Drill"] = {
        damage_type             = "Piercing",
        trait                   = "Critical Attack Bonus",
        trait_points            = 8,
        property                = "Gravitation / Reverberation",
        unbridled               = false,
        BLU                     = 99
    }
}

return physical_spells

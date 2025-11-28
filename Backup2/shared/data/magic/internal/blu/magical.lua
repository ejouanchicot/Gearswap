---============================================================================
--- BLU Magical Spells - Magical Damage BLU Spells
---============================================================================
--- @file internal/blu/magical.lua
--- @author Tetsouo
---============================================================================
local magical_spells = {}

magical_spells.spells = {

    ---========================================================================
    --- LEVEL 1 SPELLS
    ---========================================================================

    ["Sandspin"] = {
        element                 = "Earth",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = false,
        BLU                     = 1
    },

    ---========================================================================
    --- LEVEL 18 SPELLS
    ---========================================================================

    ["Cursed Sphere"] = {
        element                 = "Water",
        trait                   = "Magic Attack Bonus",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 18
    },
    ["Blastbomb"] = {
        element                 = "Fire",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = false,
        BLU                     = 18
    },

    ---========================================================================
    --- LEVEL 20 SPELLS
    ---========================================================================

    ["Blood Drain"] = {
        element                 = "Dark",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = false,
        BLU                     = 20
    },

    ---========================================================================
    --- LEVEL 28 SPELLS
    ---========================================================================

    ["Bomb Toss"] = {
        element                 = "Fire",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = false,
        BLU                     = 28
    },

    ---========================================================================
    --- LEVEL 34 SPELLS
    ---========================================================================

    ["Death Ray"] = {
        element                 = "Dark",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = false,
        BLU                     = 34
    },

    ---========================================================================
    --- LEVEL 36 SPELLS
    ---========================================================================

    ["Digest"] = {
        element                 = "Dark",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = false,
        BLU                     = 36
    },

    ---========================================================================
    --- LEVEL 40 SPELLS
    ---========================================================================

    ["Mysterious Light"] = {
        element                 = "Wind",
        trait                   = "Max MP Boost",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 40
    },

    ---========================================================================
    --- LEVEL 42 SPELLS
    ---========================================================================

    ["MP Drainkiss"] = {
        element                 = "Dark",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = false,
        BLU                     = 42
    },

    ---========================================================================
    --- LEVEL 44 SPELLS
    ---========================================================================

    ["Blitzstrahl"] = {
        element                 = "Thunder",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = false,
        BLU                     = 44
    },

    ---========================================================================
    --- LEVEL 48 SPELLS
    ---========================================================================

    ["Blood Saber"] = {
        element                 = "Dark",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = false,
        BLU                     = 48
    },

    ---========================================================================
    --- LEVEL 50 SPELLS
    ---========================================================================

    ["Ice Break"] = {
        element                 = "Ice",
        trait                   = "Magic Defense Bonus",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 50
    },
    ["Self-Destruct"] = {
        element                 = "Fire",
        trait                   = "Auto Refresh",
        trait_points            = 2,
        unbridled               = false,
        BLU                     = 50
    },

    ---========================================================================
    --- LEVEL 61 SPELLS
    ---========================================================================

    ["Eyes On Me"] = {
        element                 = "Dark",
        trait                   = "Magic Attack Bonus",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 61
    },
    ["Maelstrom"] = {
        element                 = "Water",
        trait                   = "Clear Mind",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 61
    },

    ---========================================================================
    --- LEVEL 62 SPELLS
    ---========================================================================

    ["1000 Needles"] = {
        element                 = "Light",
        trait                   = "Beast Killer",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 62
    },

    ---========================================================================
    --- LEVEL 64 SPELLS
    ---========================================================================

    ["Voracious Trunk"] = {
        element                 = "Wind",
        trait                   = "Auto Refresh",
        trait_points            = 3,
        unbridled               = false,
        BLU                     = 64
    },

    ---========================================================================
    --- LEVEL 66 SPELLS
    ---========================================================================

    ["Corrosive Ooze"] = {
        element                 = "Water",
        trait                   = "Clear Mind",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 66
    },

    ---========================================================================
    --- LEVEL 68 SPELLS
    ---========================================================================

    ["Firespit"] = {
        element                 = "Fire",
        trait                   = "Magic Attack Bonus",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 68
    },

    ---========================================================================
    --- LEVEL 69 SPELLS
    ---========================================================================

    ["Regurgitation"] = {
        element                 = "Water",
        trait                   = "Resist Gravity",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 69
    },

    ---========================================================================
    --- LEVEL 73 SPELLS
    ---========================================================================

    ["Mind Blast"] = {
        element                 = "Thunder",
        trait                   = "Clear Mind",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 73
    },

    ---========================================================================
    --- LEVEL 74 SPELLS
    ---========================================================================

    ["Magic Hammer"] = {
        element                 = "Light",
        trait                   = "Magic Attack Bonus",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 74
    },

    ---========================================================================
    --- LEVEL 77 SPELLS
    ---========================================================================

    ["Acrid Stream"] = {
        element                 = "Water",
        trait                   = "Double / Triple Attack",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 77
    },
    ["Leafstorm"] = {
        element                 = "Wind",
        trait                   = "Magic Burst Bonus",
        trait_points            = 6,
        unbridled               = false,
        BLU                     = 77
    },

    ---========================================================================
    --- LEVEL 80 SPELLS
    ---========================================================================

    ["Blazing Bound"] = {
        element                 = "Fire",
        trait                   = "Dual Wield",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 80
    },

    ---========================================================================
    --- LEVEL 84 SPELLS
    ---========================================================================

    ["Osmosis"] = {
        element                 = "Dark",
        trait                   = "Magic Defense Bonus",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 84
    },

    ---========================================================================
    --- LEVEL 86 SPELLS
    ---========================================================================

    ["Thermal Pulse"] = {
        element                 = "Fire",
        trait                   = "Attack Bonus",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 86
    },

    ---========================================================================
    --- LEVEL 88 SPELLS
    ---========================================================================

    ["Charged Whisker"] = {
        element                 = "Thunder",
        trait                   = "Gilfinder / Treasure Hunter",
        trait_points            = 6,
        unbridled               = false,
        BLU                     = 88
    },

    ---========================================================================
    --- LEVEL 90 SPELLS
    ---========================================================================

    ["Evryone. Grudge"] = {
        element                 = "Dark",
        trait                   = "Gilfinder / Treasure Hunter",
        trait_points            = 6,
        unbridled               = false,
        BLU                     = 90
    },

    ---========================================================================
    --- LEVEL 92 SPELLS
    ---========================================================================

    ["Water Bomb"] = {
        element                 = "Water",
        trait                   = "Conserve MP",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 92
    },

    ---========================================================================
    --- LEVEL 93 SPELLS
    ---========================================================================

    ["Dark Orb"] = {
        element                 = "Dark",
        trait                   = "Counter",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 93
    },

    ---========================================================================
    --- LEVEL 95 SPELLS
    ---========================================================================

    ["Thunderbolt"] = {
        element                 = "Thunder",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = true,
        BLU                     = 95
    },

    ---========================================================================
    --- LEVEL 97 SPELLS
    ---========================================================================

    ["Gates of Hades"] = {
        element                 = "Fire",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = true,
        BLU                     = 97
    },

    ---========================================================================
    --- LEVEL 99 SPELLS
    ---========================================================================

    ["Tem. Upheaval"] = {
        element                 = "Wind",
        trait                   = "Evasion Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99
    },
    ["Embalming Earth"] = {
        element                 = "Earth",
        trait                   = "Attack Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99
    },
    ["Rending Deluge"] = {
        element                 = "Water",
        trait                   = "Magic Defense Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99
    },
    ["Foul Waters"] = {
        element                 = "Water",
        trait                   = "Resist Silence",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99
    },
    ["Retinal Glare"] = {
        element                 = "Light",
        trait                   = "Conserve MP",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99
    },
    ["Droning Whirlwind"] = {
        element                 = "Wind",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = true,
        BLU                     = 99
    },
    ["Subduction"] = {
        element                 = "Wind",
        trait                   = "Magic Attack Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99
    },
    ["Diffusion Ray"] = {
        element                 = "Light",
        trait                   = "Store TP",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99
    },
    ["Rail Cannon"] = {
        element                 = "Light",
        trait                   = "Magic Burst Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99
    },
    ["Uproot"] = {
        element                 = "Light",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = true,
        BLU                     = 99
    },
    ["Crashing Thunder"] = {
        element                 = "Thunder",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = true,
        BLU                     = 99
    },
    ["Polar Roar"] = {
        element                 = "Ice",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = true,
        BLU                     = 99
    },
    ["Molting Plumage"] = {
        element                 = "Wind",
        trait                   = "Dual Wield",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99
    },
    ["Nectarous Deluge"] = {
        element                 = "Water",
        trait                   = "Beast Killer",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99
    },
    ["Atra. Libations"] = {
        element                 = "Dark",
        trait                   = "Defense Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99
    },
    ["Searing Tempest"] = {
        element                 = "Fire",
        trait                   = "Attack Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99
    },
    ["Blinding Fulgor"] = {
        element                 = "Light",
        trait                   = "Magic Evasion Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99
    },
    ["Spectral Floe"] = {
        element                 = "Ice",
        trait                   = "Magic Attack Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99
    },
    ["Scouring Spate"] = {
        element                 = "Water",
        trait                   = "Magic Defense Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99
    },
    ["Anvil Lightning"] = {
        element                 = "Thunder",
        trait                   = "Accuracy Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99
    },
    ["Silent Storm"] = {
        element                 = "Wind",
        trait                   = "Evasion Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99
    },
    ["Entomb"] = {
        element                 = "Earth",
        trait                   = "Defense Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99
    },
    ["Tenebral Crush"] = {
        element                 = "Dark",
        trait                   = "Magic Accuracy Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99
    },
    ["Palling Salvo"] = {
        element                 = "Dark",
        trait                   = "Tenacity",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99
    },
    ["Cruel Joke"] = {
        element                 = "Dark",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = true,
        BLU                     = 99
    },
    ["Cesspool"] = {
        element                 = "Water",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = true,
        BLU                     = 99
    },
    ["Tearing Gust"] = {
        element                 = "Wind",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = true,
        BLU                     = 99
    }
}

return magical_spells

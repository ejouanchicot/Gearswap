---============================================================================
--- BLU Buff Spells - Self-buff BLU Spells
---============================================================================
--- @file internal/blu/buff.lua
--- @author Tetsouo
---============================================================================
local buff_spells = {}

buff_spells.spells = {

    ---========================================================================
    --- LEVEL 8 SPELLS
    ---========================================================================

    ["Cocoon"] = {
        element                 = "Earth",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 8
    },
    ["Metallic Body"] = {
        element                 = "Earth",
        trait                   = "Max MP Boost",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 8
    },

    ---========================================================================
    --- LEVEL 48 SPELLS
    ---========================================================================

    ["Refueling"] = {
        element                 = "Wind",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 48
    },

    ---========================================================================
    --- LEVEL 56 SPELLS
    ---========================================================================

    ["Feather Barrier"] = {
        element                 = "Wind",
        trait                   = "Resist Gravity",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 56
    },

    ---========================================================================
    --- LEVEL 62 SPELLS
    ---========================================================================

    ["Memento Mori"] = {
        element                 = "Ice",
        trait                   = "Magic Attack Bonus",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 62
    },

    ---========================================================================
    --- LEVEL 65 SPELLS
    ---========================================================================

    ["Zephyr Mantle"] = {
        element                 = "Wind",
        trait                   = "Conserve MP",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 65
    },

    ---========================================================================
    --- LEVEL 67 SPELLS
    ---========================================================================

    ["Diamondhide"] = {
        element                 = "Earth",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 67
    },

    ---========================================================================
    --- LEVEL 68 SPELLS
    ---========================================================================

    ["Warm-Up"] = {
        element                 = "Earth",
        trait                   = "Clear Mind",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 68
    },

    ---========================================================================
    --- LEVEL 70 SPELLS
    ---========================================================================

    ["Amplification"] = {
        element                 = "Water",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 70
    },

    ---========================================================================
    --- LEVEL 71 SPELLS
    ---========================================================================

    ["Triumphant Roar"] = {
        element                 = "Fire",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 71
    },

    ---========================================================================
    --- LEVEL 72 SPELLS
    ---========================================================================

    ["Saline Coat"] = {
        element                 = "Light",
        trait                   = "Defense Bonus",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 72
    },

    ---========================================================================
    --- LEVEL 74 SPELLS
    ---========================================================================

    ["Reactor Cool"] = {
        element                 = "Ice",
        trait                   = "Magic Attack Bonus",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 74
    },

    ---========================================================================
    --- LEVEL 75 SPELLS
    ---========================================================================

    ["Plasma Charge"] = {
        element                 = "Thunder",
        trait                   = "Auto Refresh",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 75
    },

    ---========================================================================
    --- LEVEL 79 SPELLS
    ---========================================================================

    ["Animating Wail"] = {
        element                 = "Wind",
        trait                   = "Dual Wield",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 79
    },
    ["Battery Charge"] = {
        element                 = "Light",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 79
    },

    ---========================================================================
    --- LEVEL 82 SPELLS
    ---========================================================================

    ["Magic Barrier"] = {
        element                 = "Dark",
        trait                   = "Max MP Boost",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 82
    },

    ---========================================================================
    --- LEVEL 84 SPELLS
    ---========================================================================

    ["Auroral Drape"] = {
        element                 = "Wind",
        trait                   = "Fast Cast",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 84
    },

    ---========================================================================
    --- LEVEL 85 SPELLS
    ---========================================================================

    ["Fantod"] = {
        element                 = "Fire",
        trait                   = "Store TP",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 85
    },

    ---========================================================================
    --- LEVEL 88 SPELLS
    ---========================================================================

    ["Occultation"] = {
        element                 = "Wind",
        trait                   = "Evasion Bonus",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 88
    },

    ---========================================================================
    --- LEVEL 89 SPELLS
    ---========================================================================

    ["Winds of Promy."] = {
        element                 = "Light",
        trait                   = "Auto Refresh",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 89
    },

    ---========================================================================
    --- LEVEL 91 SPELLS
    ---========================================================================

    ["Barrier Tusk"] = {
        element                 = "Earth",
        trait                   = "Max HP Boost",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 91
    },

    ---========================================================================
    --- LEVEL 95 SPELLS
    ---========================================================================

    ["Harden Shell"] = {
        element                 = "Earth",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = true,
        BLU                     = 95
    },

    ---========================================================================
    --- LEVEL 98 SPELLS
    ---========================================================================

    ["O. Counterstance"] = {
        element                 = "Fire",
        trait                   = "Counter",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 98
    },
    ["Pyric Bulwark"] = {
        element                 = "Ice",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = true,
        BLU                     = 98
    },

    ---========================================================================
    --- LEVEL 99 SPELLS
    ---========================================================================

    ["Nature's Meditation"] = {
        element                 = "Fire",
        trait                   = "Accuracy Bonus",
        trait_points            = 8,
        property                = nil,
        unbridled               = false,
        BLU                     = 99
    },
    ["Carcharian Verve"] = {
        element                 = "Water",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = true,
        BLU                     = 99
    },
    ["Erratic Flutter"] = {
        element                 = "Wind",
        trait                   = "Fast Cast",
        trait_points            = 8,
        property                = nil,
        unbridled               = false,
        BLU                     = 99
    },
    ["Mighty Guard"] = {
        element                 = "Light",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = true,
        BLU                     = 99
    }
}

return buff_spells

---============================================================================
--- BLU Debuff Spells - Enemy Debuff BLU Spells
---============================================================================
--- @file internal/blu/debuff.lua
--- @author Tetsouo
---============================================================================
local debuff_spells = {}

debuff_spells.spells = {

    ---========================================================================
    --- LEVEL 16 SPELLS
    ---========================================================================

    ["Sheep Song"] = {
        element                 = "Light",
        trait                   = "Auto Regen",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 16
    },

    ---========================================================================
    --- LEVEL 24 SPELLS
    ---========================================================================

    ["Soporific"] = {
        element                 = "Dark",
        trait                   = "Clear Mind",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 24
    },

    ---========================================================================
    --- LEVEL 32 SPELLS
    ---========================================================================

    ["Chaotic Eye"] = {
        element                 = "Wind",
        trait                   = "Conserve MP",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 32
    },
    ["Sound Blast"] = {
        element                 = "Fire",
        trait                   = "Magic Attack Bonus",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 32
    },

    ---========================================================================
    --- LEVEL 38 SPELLS
    ---========================================================================

    ["Blank Gaze"] = {
        element                 = "Light",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 38
    },

    ---========================================================================
    --- LEVEL 42 SPELLS
    ---========================================================================

    ["Venom Shell"] = {
        element                 = "Water",
        trait                   = "Clear Mind",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 42
    },

    ---========================================================================
    --- LEVEL 44 SPELLS
    ---========================================================================

    ["Stinking Gas"] = {
        element                 = "Wind",
        trait                   = "Auto Refresh",
        trait_points            = 1,
        property                = nil,
        unbridled               = false,
        BLU                     = 44
    },

    ---========================================================================
    --- LEVEL 46 SPELLS
    ---========================================================================

    ["Awful Eye"] = {
        element                 = "Water",
        trait                   = "Clear Mind",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 46
    },
    ["Geist Wall"] = {
        element                 = "Dark",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 46
    },

    ---========================================================================
    --- LEVEL 48 SPELLS
    ---========================================================================

    ["Jettatura"] = {
        element                 = "Dark",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 48
    },

    ---========================================================================
    --- LEVEL 50 SPELLS
    ---========================================================================

    ["Frightful Roar"] = {
        element                 = "Wind",
        trait                   = "Auto Refresh",
        trait_points            = 2,
        property                = nil,
        unbridled               = false,
        BLU                     = 50
    },

    ---========================================================================
    --- LEVEL 52 SPELLS
    ---========================================================================

    ["Cold Wave"] = {
        element                 = "Ice",
        trait                   = "Auto Refresh",
        trait_points            = 1,
        property                = nil,
        unbridled               = false,
        BLU                     = 52
    },
    ["Filamented Hold"] = {
        element                 = "Earth",
        trait                   = "Clear Mind",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 52
    },

    ---========================================================================
    --- LEVEL 58 SPELLS
    ---========================================================================

    ["Light of Penance"] = {
        element                 = "Light",
        trait                   = "Auto Refresh",
        trait_points            = 2,
        property                = nil,
        unbridled               = false,
        BLU                     = 58
    },

    ---========================================================================
    --- LEVEL 64 SPELLS
    ---========================================================================

    ["Feather Tickle"] = {
        element                 = "Wind",
        trait                   = "Clear Mind",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 64
    },
    ["Yawn"] = {
        element                 = "Light",
        trait                   = "Resist Sleep",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 64
    },

    ---========================================================================
    --- LEVEL 65 SPELLS
    ---========================================================================

    ["Infrasonics"] = {
        element                 = "Ice",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 65
    },

    ---========================================================================
    --- LEVEL 66 SPELLS
    ---========================================================================

    ["Sandspray"] = {
        element                 = "Dark",
        trait                   = "Clear Mind",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 66
    },

    ---========================================================================
    --- LEVEL 67 SPELLS
    ---========================================================================

    ["Enervation"] = {
        element                 = "Dark",
        trait                   = "Counter",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 67
    },

    ---========================================================================
    --- LEVEL 71 SPELLS
    ---========================================================================

    ["Lowing"] = {
        element                 = "Fire",
        trait                   = "Clear Mind",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 71
    },

    ---========================================================================
    --- LEVEL 73 SPELLS
    ---========================================================================

    ["Temporal Shift"] = {
        element                 = "Thunder",
        trait                   = "Attack Bonus",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 73
    },

    ---========================================================================
    --- LEVEL 74 SPELLS
    ---========================================================================

    ["Actinic Burst"] = {
        element                 = "Light",
        trait                   = "Auto Refresh",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 74
    },

    ---========================================================================
    --- LEVEL 78 SPELLS
    ---========================================================================

    ["Cimicine Discharge"] = {
        element                 = "Earth",
        trait                   = "Magic Burst Bonus",
        trait_points            = 6,
        property                = nil,
        unbridled               = false,
        BLU                     = 78
    },

    ---========================================================================
    --- LEVEL 80 SPELLS
    ---========================================================================

    ["Demoralizing Roar"] = {
        element                 = "Water",
        trait                   = "Double / Triple Attack",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 80
    },

    ---========================================================================
    --- LEVEL 87 SPELLS
    ---========================================================================

    ["Dream Flower"] = {
        element                 = "Light",
        trait                   = "Magic Attack Bonus",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 87
    },

    ---========================================================================
    --- LEVEL 90 SPELLS
    ---========================================================================

    ["Reaving Wind"] = {
        element                 = "Wind",
        trait                   = "Magic Burst Bonus",
        trait_points            = 6,
        property                = nil,
        unbridled               = false,
        BLU                     = 90
    },

    ---========================================================================
    --- LEVEL 91 SPELLS
    ---========================================================================

    ["Mortal Ray"] = {
        element                 = "Dark",
        trait                   = "Dual Wield",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 91
    },

    ---========================================================================
    --- LEVEL 96 SPELLS
    ---========================================================================

    ["Absolute Terror"] = {
        element                 = "Dark",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = true,
        BLU                     = 96
    },

    ---========================================================================
    --- LEVEL 99 SPELLS
    ---========================================================================

    ["Blistering Roar"] = {
        element                 = "Dark",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = true,
        BLU                     = 99
    }
}

return debuff_spells

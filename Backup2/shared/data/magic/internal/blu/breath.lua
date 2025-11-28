---============================================================================
--- BLU Breath Spells - Breath-type BLU Spells
---============================================================================
--- @file internal/blu/breath.lua
--- @author Tetsouo
---============================================================================
local breath_spells = {}

breath_spells.spells = {

    ---========================================================================
    --- LEVEL 22 SPELLS
    ---========================================================================

    ["Poison Breath"] = {
        element                 = "Water",
        trait                   = "Clear Mind",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 22
    },

    ---========================================================================
    --- LEVEL 46 SPELLS
    ---========================================================================

    ["Magnetite Cloud"] = {
        element                 = "Earth",
        trait                   = "Magic Defense Bonus",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 46
    },

    ---========================================================================
    --- LEVEL 54 SPELLS
    ---========================================================================

    ["Hecatomb Wave"] = {
        element                 = "Wind",
        trait                   = "Max MP Boost",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 54
    },
    ["Radiant Breath"] = {
        element                 = "Light",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 54
    },

    ---========================================================================
    --- LEVEL 58 SPELLS
    ---========================================================================

    ["Flying Hip Press"] = {
        element                 = "Wind",
        trait                   = "Max HP Boost",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 58
    },

    ---========================================================================
    --- LEVEL 61 SPELLS
    ---========================================================================

    ["Bad Breath"] = {
        element                 = "Earth",
        trait                   = "Fast Cast",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 61
    },

    ---========================================================================
    --- LEVEL 66 SPELLS
    ---========================================================================

    ["Frost Breath"] = {
        element                 = "Ice",
        trait                   = "Conserve MP",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 66
    },

    ---========================================================================
    --- LEVEL 71 SPELLS
    ---========================================================================

    ["Heat Breath"] = {
        element                 = "Fire",
        trait                   = "Magic Attack Bonus",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 71
    },

    ---========================================================================
    --- LEVEL 96 SPELLS
    ---========================================================================

    ["Vapor Spray"] = {
        element                 = "Water",
        trait                   = "Max MP Boost",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 96
    },

    ---========================================================================
    --- LEVEL 97 SPELLS
    ---========================================================================

    ["Thunder Breath"] = {
        element                 = "Thunder",
        trait                   = "Max HP Boost",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 97
    },

    ---========================================================================
    --- LEVEL 99 SPELLS
    ---========================================================================

    ["Wind Breath"] = {
        element                 = "Wind",
        trait                   = "Fast Cast",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 99
    }
}

return breath_spells

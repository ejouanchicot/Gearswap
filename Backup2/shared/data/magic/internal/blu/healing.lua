---============================================================================
--- BLU Healing Spells - Healing-type BLU Spells
---============================================================================
--- @file internal/blu/healing.lua
--- @author Tetsouo
---============================================================================
local healing_spells = {}

healing_spells.spells = {

    ---========================================================================
    --- LEVEL 1 SPELLS
    ---========================================================================

    ["Pollen"] = {
        element                 = "Light",
        trait                   = "Resist Sleep",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 1
    },

    ---========================================================================
    --- LEVEL 16 SPELLS
    ---========================================================================

    ["Healing Breeze"] = {
        element                 = "Wind",
        trait                   = "Auto Regen",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 16
    },

    ---========================================================================
    --- LEVEL 30 SPELLS
    ---========================================================================

    ["Wild Carrot"] = {
        element                 = "Light",
        trait                   = "Resist Sleep",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 30
    },

    ---========================================================================
    --- LEVEL 58 SPELLS
    ---========================================================================

    ["Magic Fruit"] = {
        element                 = "Light",
        trait                   = "Resist Sleep",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 58
    },

    ---========================================================================
    --- LEVEL 75 SPELLS
    ---========================================================================

    ["Exuviation"] = {
        element                 = "Fire",
        trait                   = "Resist Sleep",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 75
    },

    ---========================================================================
    --- LEVEL 76 SPELLS
    ---========================================================================

    ["Plenilune Embrace"] = {
        element                 = "Light",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 76
    },

    ---========================================================================
    --- LEVEL 78 SPELLS
    ---========================================================================

    ["Regeneration"] = {
        element                 = "Light",
        trait                   = nil,
        trait_points            = 0,
        property                = nil,
        unbridled               = false,
        BLU                     = 78
    },

    ---========================================================================
    --- LEVEL 94 SPELLS
    ---========================================================================

    ["White Wind"] = {
        element                 = "Wind",
        trait                   = "Auto Regen",
        trait_points            = 4,
        property                = nil,
        unbridled               = false,
        BLU                     = 94
    },

    ---========================================================================
    --- LEVEL 99 SPELLS
    ---========================================================================

    ["Restoral"] = {
        element                 = "Light",
        trait                   = "Max HP Boost",
        trait_points            = 8,
        property                = nil,
        unbridled               = false,
        BLU                     = 99
    }
}

return healing_spells

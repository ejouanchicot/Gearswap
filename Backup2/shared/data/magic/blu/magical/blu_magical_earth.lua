---============================================================================
--- BLUE MAGIC DATABASE - Magical Earth Spells
---============================================================================
--- Earth-element magical damage Blue Magic spells
---
--- @file blu_magical_earth.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06 | Updated: 2025-11-01
---============================================================================

local BLU_MAGICAL_EARTH = {}

BLU_MAGICAL_EARTH.spells = {

    ["Sandspin"] = {
        description             = "Deals earth dmg + accuracy down.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Earth",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = false,
        BLU                     = 1,
        mp_cost                 = 8,
        notes                   = "Earth-based magical damage + Accuracy Down. MP: 8. Level: 1. Trait: None (0 pts). Single target. BLU only.",
    },

    ["Embalming Earth"] = {
        description             = "Deals earth dmg + slow.",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Earth",
        trait                   = "Attack Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 177,
        notes                   = "Earth-based magical damage + Slow. MP: 177. Level: 99. Trait: Attack Bonus (8 pts). Single target. BLU only.",
    },

    ["Entomb"] = {
        description             = "Deals earth dmg (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Earth",
        trait                   = "Defense Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 195,
        notes                   = "Earth-based magical damage (AoE). MP: 195. Level: 99. Trait: Defense Bonus (8 pts). AoE range. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_MAGICAL_EARTH

---============================================================================
--- BLUE MAGIC DATABASE - Magical Earth Spells
---============================================================================
--- Earth-element magical damage Blue Magic spells
---
--- @file shared/data/magic/blu/magical/blu_magical_earth.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06
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
        mp_cost                 = 10,
        notes                   = "Earth-based magical damage + Accuracy Down. MP: 10. Level: 1. Trait: None. Additional effect: Accuracy -25 (3min). Recast: 9.75s. Single target. BLU only.",
    },

    ["Embalming Earth"] = {
        description             = "Deals earth dmg + slow (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Earth",
        trait                   = "Attack Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 57,
        notes                   = "Earth-based magical damage + Slow (AoE). MP: 57. Level: 99. Trait: Attack Bonus. Additional effect: Slow -25% (3min). Recast: 24s. Range: 13'. BLU only.",
    },

    ["Entomb"] = {
        description             = "Deals earth dmg + petrification (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Earth",
        trait                   = "Defense Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 116,
        notes                   = "Earth-based magical damage + Petrification (AoE). MP: 116. Level: 99. Trait: Defense Bonus. Additional effect: Petrification (~60s, applied after damage). Recast: 60s. Range: ~10'. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_MAGICAL_EARTH

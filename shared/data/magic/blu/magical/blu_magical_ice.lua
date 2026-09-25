---============================================================================
--- BLUE MAGIC DATABASE - Magical Ice Spells
---============================================================================
--- Ice-element magical damage Blue Magic spells
---
--- @file shared/data/magic/blu/magical/blu_magical_ice.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06
---============================================================================

local BLU_MAGICAL_ICE = {}

BLU_MAGICAL_ICE.spells = {

    ["Ice Break"] = {
        description             = "Deals ice dmg + bind (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Ice",
        trait                   = "Magic Defense Bonus",
        trait_points            = 4,
        unbridled               = false,
        BLU                     = 50,
        mp_cost                 = 142,
        notes                   = "Ice-based magical damage + Bind (AoE). MP: 142. Level: 50. Trait: Magic Defense Bonus. Recast: 33.75s. BLU only.",
    },

    ["Polar Roar"] = {
        description             = "Deals ice dmg + bind (unbridled, AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Ice",
        trait                   = nil,
        trait_points            = 0,
        unbridled               = true,
        BLU                     = 99,
        mp_cost                 = 126,
        notes                   = "Ice-based magical damage + Bind (unbridled, AoE). MP: 126. Level: 99. Trait: None. Requires: Unbridled Learning. Recast: 30s. Range: 10'. BLU only.",
    },

    ["Spectral Floe"] = {
        description             = "Deals ice dmg + terror (AoE).",
        category                = "Magical",
        magic_type              = "Blue",
        element                 = "Ice",
        trait                   = "Magic Attack Bonus",
        trait_points            = 8,
        unbridled               = false,
        BLU                     = 99,
        mp_cost                 = 116,
        notes                   = "Ice-based magical damage + Terror (AoE). MP: 116. Level: 99. Trait: Magic Attack Bonus. Recast: 60s. Range: ~10'. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_MAGICAL_ICE

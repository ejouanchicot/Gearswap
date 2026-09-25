---============================================================================
--- BLUE MAGIC DATABASE - Physical Ranged Spells
---============================================================================
--- Ranged physical damage Blue Magic spells
---
--- @file shared/data/magic/blu/physical/blu_physical_ranged.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-11-01 | Updated: 2025-11-06
---============================================================================

local BLU_PHYSICAL_RANGED = {}

BLU_PHYSICAL_RANGED.spells = {

    --============================================================
    -- LEVEL 8
    --============================================================

    ["Queasyshroom"] = {
        description             = "Deals piercing dmg + poison.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Piercing",
        trait                   = nil,
        trait_points            = 0,
        property                = "Compression",
        unbridled               = false,
        BLU                     = 8,
        notes                   = "Physical piercing damage + Poison (3 HP/tick, 1.5-3 min; duration varies with TP). Removes all shadows on the target, hit or miss. Single target. Level: 8. Trait: None. Skillchain: Compression. BLU only.",
    },

    --============================================================
    -- LEVEL 12
    --============================================================

    ["Feather Storm"] = {
        description             = "Deals piercing dmg + poison.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Piercing",
        trait                   = "Rapid Shot",
        trait_points            = 4,
        property                = "Transfixion",
        unbridled               = false,
        BLU                     = 12,
        notes                   = "Physical piercing damage. Single target. Additional effect: Poison; chance varies with TP. Level: 12. Trait: Rapid Shot (4 pts). Skillchain: Transfixion. BLU only.",
    },

    --============================================================
    -- LEVEL 36
    --============================================================

    ["Pinecone Bomb"] = {
        description             = "Deals ranged dmg + sleep.",
        category                = "Physical",
        magic_type              = "Blue",
        damage_type             = "Ranged",
        trait                   = nil,
        trait_points            = 0,
        property                = "Liquefaction",
        unbridled               = false,
        BLU                     = 36,
        notes                   = "Physical ranged (piercing) damage. Additional effect: Sleep (10-60 s; duration varies with TP). Single target. Level: 36. Trait: None. Skillchain: Liquefaction. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_PHYSICAL_RANGED

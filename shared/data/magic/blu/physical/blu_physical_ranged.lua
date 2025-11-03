---============================================================================
--- BLUE MAGIC DATABASE - Physical Ranged Spells
---============================================================================
--- Ranged physical damage Blue Magic spells
---
--- @file blu_physical_ranged.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-01 | Updated: 2025-11-01
---============================================================================

local BLU_PHYSICAL_RANGED = {}

BLU_PHYSICAL_RANGED.spells = {

    --============================================================
    -- LEVEL 8
    --============================================================

    ["Queasyshroom"] = {
        description = "Deals ranged dmg + poison.",
        category = "Physical",
        magic_type = "Blue",
        damage_type = "Ranged",
        trait = nil,
        trait_points = 0,
        property = "Compression",
        unbridled = false,
        BLU = 8,
        notes = "Physical ranged damage + Poison. Level: 8. Trait: None (0 pts). Skillchain: Compression. Single target. Uses TP. BLU only.",
    },

    --============================================================
    -- LEVEL 12
    --============================================================

    ["Feather Storm"] = {
        description = "Deals ranged dmg (AoE).",
        category = "Physical",
        magic_type = "Blue",
        damage_type = "Ranged",
        trait = "Rapid Shot",
        trait_points = 4,
        property = "Transfixion",
        unbridled = false,
        BLU = 12,
        notes = "Physical ranged damage (AoE). Level: 12. Trait: Rapid Shot (4 pts). Skillchain: Transfixion. AoE range. Uses TP. BLU only.",
    },

    --============================================================
    -- LEVEL 36
    --============================================================

    ["Pinecone Bomb"] = {
        description = "Deals ranged dmg.",
        category = "Physical",
        magic_type = "Blue",
        damage_type = "Ranged",
        trait = nil,
        trait_points = 0,
        property = "Liquefaction",
        unbridled = false,
        BLU = 36,
        notes = "Physical ranged damage. Level: 36. Trait: None (0 pts). Skillchain: Liquefaction. Single target. Uses TP. BLU only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_PHYSICAL_RANGED

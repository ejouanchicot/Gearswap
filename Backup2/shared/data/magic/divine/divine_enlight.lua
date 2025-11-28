---============================================================================
--- Divine Magic Database - Enlight Spells Module
---============================================================================
--- Light-based weapon enhancement spells (Enlight I-II)
---
--- @file divine_enlight.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06 | Updated: 2025-10-31
--- @verified bg-wiki.com (2025-10-31)
---============================================================================

local divine_enlight = {}

divine_enlight.spells = {
    ["Enlight"] = {
        description             = "Adds light dmg to attacks.",
        category                = "Divine",
        element                 = "Light",
        magic_type              = "White",
        tier                    = "I",
        type                    = "self",
        main_job_only           = true,
        subjob_master_only      = false,
        PLD                     = 85,
        notes                   = "Weapon enhancement. Adds light damage to physical attacks. PLD-only.",
    },

    ["Enlight II"] = {
        description             = "Adds light dmg to attacks; Acc/Atk+.",
        category                = "Divine",
        element                 = "Light",
        magic_type              = "White",
        tier                    = "II",
        type                    = "self",
        main_job_only           = true,
        subjob_master_only      = false,
        PLD                     = "JP",
        notes                   = "Enhanced weapon enchantment. Adds light damage to attacks; boosts accuracy and attack. Requires 100 JP Gift (PLD). Scales with Divine Magic skill.",
    },
}

return divine_enlight

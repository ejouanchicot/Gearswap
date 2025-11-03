---============================================================================
--- Divine Magic Database - Banish Spells Module
---============================================================================
--- Light-based Divine Magic (Banish I–IV, Banishga I–II)
---
--- @file divine_banish.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30 | Updated: 2025-10-31
--- @verified bg-wiki.com (2025-10-31)
---============================================================================

local divine_banish = {}

divine_banish.spells = {
    ---========================================================================
    --- BANISH (Single-Target)
    ---========================================================================

    ["Banish"] = {
        description = "Deals light dmg (vs undead).",
        category = "Divine",
        element = "Light",
        magic_type = "White",
        tier = "I",
        type = "single",
        main_job_only = false,
        subjob_master_only = false,
        WHM = 5,
        PLD = 7,
        notes = "Single-target light damage. Effective against undead. WHM/PLD.",
    },

    ["Banish II"] = {
        description = "Deals light dmg (vs undead).",
        category = "Divine",
        element = "Light",
        magic_type = "White",
        tier = "II",
        type = "single",
        main_job_only = false,
        subjob_master_only = false,
        WHM = 30,
        PLD = 34,
        notes = "Single-target light damage. Effective against undead. WHM/PLD.",
    },

    ["Banish III"] = {
        description = "Deals light dmg (vs undead).",
        category = "Divine",
        element = "Light",
        magic_type = "White",
        tier = "III",
        type = "single",
        main_job_only = true,
        subjob_master_only = false,
        WHM = 65,
        notes = "Single-target light damage. Effective against undead. WHM-only.",
    },

    -- NOTE: Banish IV is not available in the game (not implemented by SE)
    --[[ ["Banish IV"] = {
        description = "Deals light dmg (vs undead).",
        category = "Divine",
        element = "Light",
        magic_type = "White",
        tier = "IV",
        type = "single",
        main_job_only = true,
        subjob_master_only = false,
        WHM = 99,
    }, ]]

    ---========================================================================
    --- BANISHGA (AOE)
    ---========================================================================

    ["Banishga"] = {
        description = "Deals light dmg (vs undead).",
        category = "Divine",
        element = "Light",
        magic_type = "White",
        tier = "I",
        type = "aoe",
        main_job_only = false,
        subjob_master_only = false,
        WHM = 15,
        PLD = 30,
        notes = "AOE light damage (~10y range). Effective against undead. WHM/PLD.",
    },

    ["Banishga II"] = {
        description = "Deals light dmg (vs undead).",
        category = "Divine",
        element = "Light",
        magic_type = "White",
        tier = "II",
        type = "aoe",
        main_job_only = true,
        subjob_master_only = false,
        WHM = 40,
        notes = "AOE light damage (~10y range). Effective against undead. WHM-only.",
    },
}

return divine_banish

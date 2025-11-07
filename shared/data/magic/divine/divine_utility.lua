---============================================================================
--- Divine Magic Database - Utility Spells Module
---============================================================================
--- Utility Divine Magic spells (Holy I-II, Flash, Repose)
---
--- @file divine_utility.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06 | Updated: 2025-10-31
--- @verified bg-wiki.com (2025-10-31)
---============================================================================

local divine_utility = {}

divine_utility.spells = {
    ---========================================================================
    --- HOLY (Light Nuke)
    ---========================================================================

    ["Holy"] = {
        description             = "Deals light dmg (vs undead).",
        category                = "Divine",
        element                 = "Light",
        magic_type              = "White",
        tier                    = "I",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        WHM                     = 50,
        PLD                     = 55,
        notes                   = "High-power light nuke. Effective against undead. WHM/PLD.",
    },

    ["Holy II"] = {
        description             = "Deals light dmg; Solace: potency+ from HP healed.",
        category                = "Divine",
        element                 = "Light",
        magic_type              = "White",
        tier                    = "II",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        WHM                     = 95,
        PLD                     = 99,
        notes                   = "High-tier light nuke. Effective against undead. Afflatus Solace: Raises potency based on HP restored. WHM/PLD.",
    },

    ---========================================================================
    --- FLASH (Enmity + Blind)
    ---========================================================================

    ["Flash"] = {
        description             = "Blinds target; Acc-; high enmity.",
        category                = "Divine",
        element                 = "Light",
        magic_type              = "White",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        PLD                     = 37,
        WHM                     = 45,
        RUN                     = 45,
        notes                   = "No damage. Blind effect (-300 accuracy). Generates high enmity (tanking tool). PLD/WHM/RUN.",
    },

    ---========================================================================
    --- REPOSE (Sleep)
    ---========================================================================

    ["Repose"] = {
        description             = "Puts target to sleep.",
        category                = "Divine",
        element                 = "Light",
        magic_type              = "White",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        WHM                     = 48,
        notes                   = "Divine Magic sleep spell (light-based, distinct from Enfeebling Magic sleep). WHM-only.",
    },
}

return divine_utility

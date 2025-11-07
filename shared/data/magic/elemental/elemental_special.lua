---============================================================================
--- Elemental Magic Database - Special Spells Module
---============================================================================
--- Special elemental spells (Comet, Meteor, Impact)
---
--- @file elemental_special.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06 | Updated: 2025-10-31
--- @verified bg-wiki.com (2025-10-31)
---
--- NOTES:
--- - Comet: BLM-only, Dark element, cumulative magic (level 94)
--- - Meteor: BLM-only, Fire element, requires Elemental Seal (level 99)
--- - Impact: Multi-job (BLM/WHM/RDM/SCH/DRK/SMN/GEO), requires Twilight/Crepuscular Cloak (level 90)
---============================================================================

local elemental_special = {}

elemental_special.spells = {
    ["Comet"] = {
        description             = "Deals dark dmg (single, stacks).",
        category                = "Elemental",
        element                 = "Dark",
        magic_type              = "Black",
        tier                    = nil,
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 94,
        notes                   = "Cumulative magic: potency increases with successive casts. BLM-only.",
    },

    ["Meteor"] = {
        description             = "Deals fire dmg (AOE).",
        category                = "Elemental",
        element                 = "Fire",
        magic_type              = "Black",
        tier                    = nil,
        type                    = "aoe",
        main_job_only           = true,
        subjob_master_only      = false,
        BLM                     = 99,
        notes                   = "Requires Elemental Seal. BLM-only merit spell.",
    },

    ["Impact"] = {
        description             = "Deals dark dmg (DoT), lowers all stats.",
        category                = "Elemental",
        element                 = "Dark",
        magic_type              = "Black",
        tier                    = nil,
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 90,
        WHM                     = 90,
        RDM                     = 90,
        SCH                     = 90,
        DRK                     = 90,
        SMN                     = 90,
        GEO                     = 90,
        notes                   = "Requires Twilight/Crepuscular Cloak. Inflicts DoT and lowers all stats, DEF & MDEF.",
    },
}

return elemental_special

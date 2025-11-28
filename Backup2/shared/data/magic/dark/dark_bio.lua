---============================================================================
--- DARK MAGIC DATABASE - Bio Spells Module
---============================================================================
--- Damage-over-time (DoT) bio spells (3 total)
--- Data source: bg-wiki.com (official FFXI documentation)
---
--- Contents:
---   - Bio (Lv10-15) - Disease + Darkness DoT
---   - Bio II (Lv35-40) - Enhanced Disease + Darkness DoT
---   - Bio III (Lv75 SCH) - Maximum Disease + Darkness DoT
---
--- Notes:
---   - All Bio spells inflict Disease status (Attack down, Regen down)
---   - Bio III is SCH-exclusive
---   - Duration and potency scale with Dark Magic skill
---   - DoT damage ticks every 3 seconds
---
--- @file dark_bio.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Bio
--- @source https://www.bg-wiki.com/ffxi/Bio_II
--- @source https://www.bg-wiki.com/ffxi/Bio_III
---============================================================================

local DARK_BIO = {}

DARK_BIO.spells = {

    ["Bio"] = {
        description             = "Weakens attacks, drains HP.",
        category                = "Dark",
        element                 = "Dark",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 10,
        DRK                     = 15,
        RDM                     = 10,
        notes                   = "Inflicts Disease (Attack down, Regen down) + darkness DoT. Ticks every 3 seconds. Duration/potency scale with Dark Magic skill. BLM/DRK/RDM.",
    },

    ["Bio II"] = {
        description             = "Weakens attacks, drains HP.",
        category                = "Dark",
        element                 = "Dark",
        magic_type              = "Black",
        tier                    = "II",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 35,
        DRK                     = 40,
        RDM                     = 36,
        notes                   = "Enhanced Disease (Attack down, Regen down) + darkness DoT. Ticks every 3 seconds. Duration/potency scale with Dark Magic skill. BLM/DRK/RDM.",
    },

    ["Bio III"] = {
        description             = "Weakens attacks, drains HP.",
        category                = "Dark",
        element                 = "Dark",
        magic_type              = "Black",
        tier                    = "III",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        SCH                     = 75,
        notes                   = "Maximum Disease (Attack down, Regen down) + darkness DoT. Ticks every 3 seconds. Duration/potency scale with Dark Magic skill. SCH-only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DARK_BIO

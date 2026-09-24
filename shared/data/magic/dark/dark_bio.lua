---============================================================================
--- DARK MAGIC DATABASE - Bio Spells Module
---============================================================================
--- Damage-over-time (DoT) bio spells (3 total)
--- Data source: bg-wiki.com (official FFXI documentation)
---
--- Contents:
---   - Bio (Lv10-15) - Attack down + Darkness DoT
---   - Bio II (Lv35-40) - Stronger attack down + Darkness DoT
---   - Bio III (RDM Lv75) - Strongest attack down + Darkness DoT
---
--- Notes:
---   - All Bio spells inflict the Bio status (attack down + DoT)
---   - Bio III is RDM-exclusive
---   - Duration and potency scale with Dark Magic skill
---   - DoT damage ticks every 3 seconds
---
--- @file shared/data/magic/dark/dark_bio.lua
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
        notes                   = "Bio effect (attack down -10%, static) + darkness DoT (scales with Dark Magic skill, caps at 3/tick). Ticks every 3 seconds. Duration: 60s. BLM/DRK/RDM.",
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
        notes                   = "Stronger Bio effect (attack down -15%, static) + darkness DoT (5-8/tick by Dark Magic skill). Ticks every 3 seconds. Duration: 120s. BLM/DRK/RDM.",
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
        RDM                     = 75,
        notes                   = "Bio effect (attack down -20%, static) + darkness DoT (scales with Dark Magic skill, caps at 17/tick). Ticks every 3 seconds. RDM-only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DARK_BIO

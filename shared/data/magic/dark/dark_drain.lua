---============================================================================
--- DARK MAGIC DATABASE - Drain & Aspir Spells Module
---============================================================================
--- HP/MP drain spells (6 total)
--- Data source: bg-wiki.com (official FFXI documentation)
---
--- Contents:
---   ASPIR SERIES (MP drain):
---   - Aspir (Lv20-36) - Drains MP from target
---   - Aspir II (Lv78-97) - Enhanced MP drain
---   - Aspir III (Lv99 JP) - Maximum MP drain
---
---   DRAIN SERIES (HP drain):
---   - Drain (Lv10-21) - Drains HP from target
---   - Drain II (Lv62 DRK) - Enhanced HP drain
---   - Drain III (Lv99 JP DRK) - Maximum HP drain
---
--- Notes:
---   - Drain II/III are DRK main job only
---   - Aspir III is BLM/GEO Job Points ability
---   - Drain III is DRK Job Points ability
---
--- @file dark_drain.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Aspir
--- @source https://www.bg-wiki.com/ffxi/Drain
---============================================================================

local DARK_DRAIN = {}

DARK_DRAIN.spells = {

    ---========================================================================
    --- ASPIR SERIES (MP Drain)
    ---========================================================================

    ["Aspir"] = {
        description             = "Absorbs MP (no undead).",
        category                = "Dark",
        element                 = "Dark",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 25,
        DRK                     = 20,
        GEO                     = 30,
        SCH                     = 36,
        notes                   = "MP drain. BLM/DRK/GEO/SCH. Ineffective vs undead.",
    },

    ["Aspir II"] = {
        description             = "Absorbs MP (no undead).",
        category                = "Dark",
        element                 = "Dark",
        magic_type              = "Black",
        tier                    = "II",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 83,
        DRK                     = 78,
        GEO                     = 90,
        SCH                     = 97,
        notes                   = "Enhanced MP drain. BLM/DRK/GEO/SCH. Ineffective vs undead.",
    },

    ["Aspir III"] = {
        description             = "Absorbs MP (no undead).",
        category                = "Dark",
        element                 = "Dark",
        magic_type              = "Black",
        tier                    = "III",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = "JP",
        GEO                     = "JP",
        notes                   = "Maximum MP drain. Requires Job Points (BLM/GEO). Ineffective vs undead.",
    },

    ---========================================================================
    --- DRAIN SERIES (HP Drain)
    ---========================================================================

    ["Drain"] = {
        description             = "Absorbs HP (no undead).",
        category                = "Dark",
        element                 = "Dark",
        magic_type              = "Black",
        tier                    = "I",
        type                    = "single",
        main_job_only           = false,
        subjob_master_only      = false,
        BLM                     = 12,
        DRK                     = 10,
        GEO                     = 15,
        SCH                     = 21,
        notes                   = "HP drain. BLM/DRK/GEO/SCH. Ineffective vs undead.",
    },

    ["Drain II"] = {
        description             = "Absorbs HP; Max HP+ (no undead).",
        category                = "Dark",
        element                 = "Dark",
        magic_type              = "Black",
        tier                    = "II",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        DRK                     = 62,
        notes                   = "Enhanced HP drain; may raise max HP. DRK-only. Ineffective vs undead.",
    },

    ["Drain III"] = {
        description             = "Absorbs HP; Max HP+ (no undead).",
        category                = "Dark",
        element                 = "Dark",
        magic_type              = "Black",
        tier                    = "III",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        DRK                     = "JP",
        notes                   = "Maximum HP drain; may raise max HP. Requires Job Points (DRK). Ineffective vs undead.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DARK_DRAIN

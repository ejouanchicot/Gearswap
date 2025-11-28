---============================================================================
--- DARK MAGIC DATABASE - Absorb Spells Module
---============================================================================
--- DRK-exclusive stat absorption spells (10 total)
--- Data source: bg-wiki.com (official FFXI documentation)
---
--- Contents:
---   - Absorb-ACC (Lv61) - Absorbs accuracy
---   - Absorb-AGI (Lv37) - Absorbs agility
---   - Absorb-Attri (Lv91) - Steals beneficial status effects (NOT attributes!)
---   - Absorb-CHR (Lv33) - Absorbs charisma
---   - Absorb-DEX (Lv41) - Absorbs dexterity
---   - Absorb-INT (Lv39) - Absorbs intelligence
---   - Absorb-MND (Lv31) - Absorbs mind
---   - Absorb-STR (Lv43) - Absorbs strength
---   - Absorb-TP (Lv45) - Absorbs TP
---   - Absorb-VIT (Lv35) - Absorbs vitality
---
--- Notes:
---   - All Absorb spells are DRK main job only
---   - All are Darkness element
---   - Duration varies with Dark Magic skill
---
--- @file dark_absorb.lua
--- @author Tetsouo
--- @version 2.0 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Category:Dark_Magic
---============================================================================

local DARK_ABSORB = {}

DARK_ABSORB.spells = {

    ["Absorb-ACC"] = {
        description             = "Steals Accuracy.",
        category                = "Dark",
        element                 = "Dark",
        magic_type              = "Black",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        DRK                     = 61,
        notes                   = "Lowers target's accuracy, raises caster's accuracy. Duration scales with Dark Magic skill. DRK-only.",
    },

    ["Absorb-AGI"] = {
        description             = "Steals Agility.",
        category                = "Dark",
        element                 = "Dark",
        magic_type              = "Black",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        DRK                     = 37,
        notes                   = "Lowers target's AGI, raises caster's AGI. Duration scales with Dark Magic skill. DRK-only.",
    },

    ["Absorb-Attri"] = {
        description             = "Steals beneficial status effects.",
        category                = "Dark",
        element                 = "Dark",
        magic_type              = "Black",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        DRK                     = 91,
        notes                   = "Steals beneficial buffs from target (NOT attributes/stats). Duration scales with Dark Magic skill. DRK-only.",
    },

    ["Absorb-CHR"] = {
        description             = "Steals Charisma.",
        category                = "Dark",
        element                 = "Dark",
        magic_type              = "Black",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        DRK                     = 33,
        notes                   = "Lowers target's CHR, raises caster's CHR. Duration scales with Dark Magic skill. DRK-only.",
    },

    ["Absorb-DEX"] = {
        description             = "Steals Dexterity.",
        category                = "Dark",
        element                 = "Dark",
        magic_type              = "Black",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        DRK                     = 41,
        notes                   = "Lowers target's DEX, raises caster's DEX. Duration scales with Dark Magic skill. DRK-only.",
    },

    ["Absorb-INT"] = {
        description             = "Steals Intelligence.",
        category                = "Dark",
        element                 = "Dark",
        magic_type              = "Black",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        DRK                     = 39,
        notes                   = "Lowers target's INT, raises caster's INT. Duration scales with Dark Magic skill. DRK-only.",
    },

    ["Absorb-MND"] = {
        description             = "Steals Mind.",
        category                = "Dark",
        element                 = "Dark",
        magic_type              = "Black",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        DRK                     = 31,
        notes                   = "Lowers target's MND, raises caster's MND. Duration scales with Dark Magic skill. DRK-only.",
    },

    ["Absorb-STR"] = {
        description             = "Steals Strength.",
        category                = "Dark",
        element                 = "Dark",
        magic_type              = "Black",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        DRK                     = 43,
        notes                   = "Lowers target's STR, raises caster's STR. Duration scales with Dark Magic skill. DRK-only.",
    },

    ["Absorb-TP"] = {
        description             = "Steals TP.",
        category                = "Dark",
        element                 = "Dark",
        magic_type              = "Black",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        DRK                     = 45,
        notes                   = "Drains TP from target, adds to caster's TP. Amount scales with Dark Magic skill. DRK-only.",
    },

    ["Absorb-VIT"] = {
        description             = "Steals Vitality.",
        category                = "Dark",
        element                 = "Dark",
        magic_type              = "Black",
        type                    = "single",
        main_job_only           = true,
        subjob_master_only      = false,
        DRK                     = 35,
        notes                   = "Lowers target's VIT, raises caster's VIT. Duration scales with Dark Magic skill. DRK-only.",
    },

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DARK_ABSORB

---============================================================================
--- SCH White Grimoire - Sub-Job Accessible Module
---============================================================================
--- Scholar White Grimoire (Light Arts) stratagems accessible as subjob (5 total)
---
--- Contents:
---   - Penury (Lv10) - Next white magic -50% MP
---   - Addendum: White (Lv10) - Access additional white magic
---   - Celerity (Lv25) - Next white magic -50% cast time
---   - Accession (Lv40) - Next heal/enhancing → party AoE
---   - Rapture (Lv55 - Master Job Only) - Next white magic +potency
---
--- @file sch_white_grimoire_subjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Scholar
--- @source https://www.bg-wiki.com/ffxi/Stratagems
---============================================================================

local SCH_WHITE_GRIMOIRE_SUBJOB = {}

SCH_WHITE_GRIMOIRE_SUBJOB.abilities = {
    ['Penury'] = {
        description             = 'Next white magic -50% MP',
        level                   = 10,
        recast                  = 0,  -- Charge system
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Addendum: White'] = {
        description             = 'Access additional white magic',
        level                   = 10,
        recast                  = 0,  -- Charge system
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Celerity'] = {
        description             = 'Next white magic -50% cast time',
        level                   = 25,
        recast                  = 0,  -- Charge system
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Accession'] = {
        description             = 'Next heal/enhancing → party AoE',
        level                   = 40,
        recast                  = 0,  -- Charge system
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Rapture'] = {
        description             = 'Next white magic +potency',
        level                   = 55,
        recast                  = 0,  -- Charge system
        main_job_only           = false,  -- Master Job Only for subjob access
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return SCH_WHITE_GRIMOIRE_SUBJOB

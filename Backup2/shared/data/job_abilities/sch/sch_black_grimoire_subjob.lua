---============================================================================
--- SCH Black Grimoire - Sub-Job Accessible Module
---============================================================================
--- Scholar Black Grimoire (Dark Arts) stratagems accessible as subjob (5 total)
---
--- Contents:
---   - Parsimony (Lv10) - Next black magic -50% MP
---   - Alacrity (Lv25) - Next black magic -50% cast time
---   - Addendum: Black (Lv30) - Access additional black magic
---   - Manifestation (Lv40) - Next enfeebling >> AoE
---   - Ebullience (Lv55 - Master Job Only) - Next black magic +potency
---
--- @file sch_black_grimoire_subjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Scholar
--- @source https://www.bg-wiki.com/ffxi/Stratagems
---============================================================================

local SCH_BLACK_GRIMOIRE_SUBJOB = {}

SCH_BLACK_GRIMOIRE_SUBJOB.abilities = {
    ['Parsimony'] = {
        description             = 'Next black magic -50% MP',
        level                   = 10,
        recast                  = 0,  -- Charge system
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Alacrity'] = {
        description             = 'Next black magic -50% cast time',
        level                   = 25,
        recast                  = 0,  -- Charge system
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Addendum: Black'] = {
        description             = 'Access additional black magic',
        level                   = 30,
        recast                  = 0,  -- Charge system
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Manifestation'] = {
        description             = 'Next enfeebling >> AoE',
        level                   = 40,
        recast                  = 0,  -- Charge system
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Ebullience'] = {
        description             = 'Next black magic +potency',
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

return SCH_BLACK_GRIMOIRE_SUBJOB

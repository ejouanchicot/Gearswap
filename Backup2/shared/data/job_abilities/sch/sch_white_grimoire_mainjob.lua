---============================================================================
--- SCH White Grimoire - Main Job Only Module
---============================================================================
--- Scholar White Grimoire (Light Arts) stratagems restricted to main job (3 total)
---
--- Contents:
---   - Altruism (Lv75 Merit) - Next white magic +accuracy
---   - Tranquility (Lv75 Merit) - Next white magic -enmity
---   - Perpetuance (Lv87) - Next enhancing +duration
---
--- @file sch_white_grimoire_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Scholar
--- @source https://www.bg-wiki.com/ffxi/Stratagems
---============================================================================

local SCH_WHITE_GRIMOIRE_MAINJOB = {}

SCH_WHITE_GRIMOIRE_MAINJOB.abilities = {
    ['Altruism'] = {
        description             = 'Next white magic +accuracy',
        level                   = 75,
        recast                  = 0,  -- Charge system
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Tranquility'] = {
        description             = 'Next white magic -enmity',
        level                   = 75,
        recast                  = 0,  -- Charge system
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Perpetuance'] = {
        description             = 'Next enhancing +duration',
        level                   = 87,
        recast                  = 0,  -- Charge system
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return SCH_WHITE_GRIMOIRE_MAINJOB

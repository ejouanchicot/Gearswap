---============================================================================
--- SCH Black Grimoire - Main Job Only Module
---============================================================================
--- Scholar Black Grimoire (Dark Arts) stratagems restricted to main job (3 total)
---
--- Contents:
---   - Focalization (Lv75 Merit) - Next black magic +accuracy
---   - Equanimity (Lv75 Merit) - Next black magic -enmity
---   - Immanence (Lv87) - Next elemental can skillchain (not MB)
---
--- @file sch_black_grimoire_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Scholar
--- @source https://www.bg-wiki.com/ffxi/Stratagems
---============================================================================

local SCH_BLACK_GRIMOIRE_MAINJOB = {}

SCH_BLACK_GRIMOIRE_MAINJOB.abilities = {
    ['Focalization'] = {
        description             = 'Next black magic +accuracy',
        level                   = 75,
        recast                  = 0,  -- Charge system
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Equanimity'] = {
        description             = 'Next black magic -enmity',
        level                   = 75,
        recast                  = 0,  -- Charge system
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Immanence'] = {
        description             = 'Next elemental can skillchain (not MB)',
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

return SCH_BLACK_GRIMOIRE_MAINJOB

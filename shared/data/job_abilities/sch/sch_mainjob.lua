---============================================================================
--- SCH Job Abilities - Main Job Only Module
---============================================================================
--- Scholar abilities restricted to main job (3 total)
---
--- Contents:
---   - Modus Veritas (Lv65) - Helix DoT x2, duration -50%
---   - Enlightenment (Lv75 Merit) - Both Arts active, both Addenda
---   - Libra (Lv76) - Examine target enmity levels
---
--- @file sch_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Scholar
---============================================================================

local SCH_MAINJOB = {}

SCH_MAINJOB.abilities = {
    ['Modus Veritas'] = {
        description             = 'Helix DoT x2, duration -50%',
        level                   = 65,
        recast                  = 180,  -- 3min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Enlightenment'] = {
        description             = 'Both Arts active, both Addenda',
        level                   = 75,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 1,
        volatile_enmity         = 80
    },
    ['Libra'] = {
        description             = 'Examine target enmity levels',
        level                   = 76,
        recast                  = 60,  -- 1min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return SCH_MAINJOB

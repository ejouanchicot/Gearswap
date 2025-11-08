---============================================================================
--- SCH Job Abilities - Sub-Job Accessible Module
---============================================================================
--- Scholar abilities accessible as subjob (3 total)
---
--- Contents:
---   - Light Arts (Lv10) - White magic optimized, -10% cost/time
---   - Dark Arts (Lv10) - Black magic optimized, -10% cost/time
---   - Sublimation (Lv35) - Convert HP >> MP over time
---
--- @file sch_subjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Scholar
---============================================================================

local SCH_SUBJOB = {}

SCH_SUBJOB.abilities = {
    ['Light Arts'] = {
        description             = 'White magic optimized, -10% cost/time',
        level                   = 10,
        recast                  = 60,  -- 1min
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Dark Arts'] = {
        description             = 'Black magic optimized, -10% cost/time',
        level                   = 10,
        recast                  = 60,  -- 1min
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Sublimation'] = {
        description             = 'Convert HP >> MP over time',
        level                   = 35,
        recast                  = 30,  -- 30s
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return SCH_SUBJOB

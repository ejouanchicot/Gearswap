---============================================================================
--- DNC Job Abilities - Steps (Sub-Job Accessible)
---============================================================================
--- Dancer steps accessible as subjob (3 steps, Lv20-40)
---
--- @file dnc_steps_subjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Dancer
---============================================================================

local DNC_STEPS_SUBJOB = {}

DNC_STEPS_SUBJOB.abilities = {
    ['Quickstep'] = {
        description             = "Evasion down. Grants FM if successful",
        level                   = 20,
        recast                  = 5,
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Box Step'] = {
        description             = "Defense down. Grants FM if successful",
        level                   = 30,
        recast                  = 5,
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Stutter Step'] = {
        description             = "Magic Evasion down. Grants FM if successful",
        level                   = 40,
        recast                  = 5,
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DNC_STEPS_SUBJOB

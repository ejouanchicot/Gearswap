---============================================================================
--- DNC Job Abilities - Steps (Main Job Only)
---============================================================================
--- Dancer steps restricted to main job (1 step, Lv83)
---
--- @file dnc_steps_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Dancer
---============================================================================

local DNC_STEPS_MAINJOB = {}

DNC_STEPS_MAINJOB.abilities = {
    ['Feather Step'] = {
        description             = "Crit Evasion down. Grants FM if successful",
        level                   = 83,
        recast                  = 5,
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DNC_STEPS_MAINJOB

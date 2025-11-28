---============================================================================
--- DNC Job Abilities - Flourishes III (Main Job Only)
---============================================================================
--- Dancer flourishes tier III - Advanced finishing move consumers (3 total)
--- All main job only (Lv80-93)
---
--- @file dnc_flourishes3_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Dancer
---============================================================================

local DNC_FLOURISHES3_MAINJOB = {}

DNC_FLOURISHES3_MAINJOB.abilities = {
    ['Climactic Flourish'] = {
        description             = "Forces critical hits. Requires 1 FM",
        level                   = 80,
        recast                  = 60,
        fm_cost                 = 1,
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Striking Flourish'] = {
        description             = "Forces Double Attack. Requires 2 FM",
        level                   = 89,
        recast                  = 60,
        fm_cost                 = 2,
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Ternary Flourish'] = {
        description             = "Forces Triple Attack. Requires 3 FM",
        level                   = 93,
        recast                  = 60,
        fm_cost                 = 3,
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DNC_FLOURISHES3_MAINJOB

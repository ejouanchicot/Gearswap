---============================================================================
--- DNC Job Abilities - Flourishes I (Sub-Job Accessible)
---============================================================================
--- Dancer flourishes tier I - Basic finishing move consumers (3 total)
--- All accessible as subjob (Lv20-45)
---
--- @file dnc_flourishes1_subjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Dancer
---============================================================================

local DNC_FLOURISHES1_SUBJOB = {}

DNC_FLOURISHES1_SUBJOB.abilities = {
    ['Animated Flourish'] = {
        description             = "Provoke. Requires 1 FM",
        level                   = 20,
        recast                  = 30,
        fm_cost                 = 1,
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Desperate Flourish'] = {
        description             = "Slow. Requires 1 FM",
        level                   = 30,
        recast                  = 30,
        fm_cost                 = 1,
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Violent Flourish'] = {
        description             = "Stun. Requires 1 FM",
        level                   = 45,
        recast                  = 30,
        fm_cost                 = 1,
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DNC_FLOURISHES1_SUBJOB

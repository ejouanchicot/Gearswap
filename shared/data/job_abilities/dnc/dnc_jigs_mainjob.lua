---============================================================================
--- DNC Job Abilities - Jigs (Main Job Only)
---============================================================================
--- Dancer jigs restricted to main job (2 jigs, Lv55-70)
---
--- @file dnc_jigs_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Dancer
---============================================================================

local DNC_JIGS_MAINJOB = {}

DNC_JIGS_MAINJOB.abilities = {
    ['Chocobo Jig'] = {
        description             = "Movement speed +20%",
        level                   = 55,
        recast                  = 60,
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Chocobo Jig II'] = {
        description             = "Movement speed +20% (AoE)",
        level                   = 70,
        recast                  = 60,
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DNC_JIGS_MAINJOB

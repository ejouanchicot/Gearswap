---============================================================================
--- DNC Job Abilities - Waltzes (Main Job Only)
---============================================================================
--- Dancer waltzes restricted to main job (3 waltzes, Lv70-87)
---
--- @file dnc_waltzes_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Dancer
---============================================================================

local DNC_WALTZES_MAINJOB = {}

DNC_WALTZES_MAINJOB.abilities = {
    ['Curing Waltz IV'] = {
        description             = "Restores HP",
        level                   = 70,
        recast                  = 10,
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Divine Waltz II'] = {
        description             = "Restores HP (AoE)",
        level                   = 78,
        recast                  = 15,
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Curing Waltz V'] = {
        description             = "Restores HP",
        level                   = 87,
        recast                  = 13,
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DNC_WALTZES_MAINJOB

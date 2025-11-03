---============================================================================
--- DNC Job Abilities - Flourishes II (Main Job Only)
---============================================================================
--- Dancer flourishes tier II - Main job only (1 flourish, Lv60)
---
--- @file dnc_flourishes2_mainjob.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30
--- @source https://www.bg-wiki.com/ffxi/Dancer
---============================================================================

local DNC_FLOURISHES2_MAINJOB = {}

DNC_FLOURISHES2_MAINJOB.abilities = {
    ['Wild Flourish'] = {
        description = "Readies target for skillchain. Requires 2 FM",
        level = 60,
        recast = 30,
        fm_cost = 2,
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DNC_FLOURISHES2_MAINJOB

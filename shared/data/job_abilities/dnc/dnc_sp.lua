---============================================================================
--- DNC Job Abilities - SP Abilities Module
---============================================================================
--- Dancer special abilities (2 SP total)
---
--- Contents:
---   - Trance (SP1, Lv1) - Steps/Dances TP cost 0
---   - Grand Pas (SP2, Lv96) - Flourishes without FM cost
---
--- @file dnc_sp.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30
--- @source https://www.bg-wiki.com/ffxi/Dancer
---============================================================================

local DNC_SP = {}

DNC_SP.abilities = {
    ['Trance'] = {
        description = "Dances and steps TP cost 0 (60s)",
        level = 1,
        recast = 3600,  -- 1 hour (SP1)
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Grand Pas'] = {
        description = "Flourishes without FM cost (30s or 3 uses)",
        level = 96,
        recast = 3600,  -- 1 hour (SP2)
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DNC_SP

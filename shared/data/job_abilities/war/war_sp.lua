---============================================================================
--- WAR Job Abilities - SP Abilities Module
---============================================================================
--- Warrior special abilities (2 SP total)
---
--- Contents:
---   - Mighty Strikes (SP1, Lv1) - All attacks critical (45s)
---   - Brazen Rush (SP2, Lv96) - Double attack 100% (30s)
---
--- @file war_sp.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Warrior
--- @source https://www.bg-wiki.com/ffxi/Mighty_Strikes
--- @source https://www.bg-wiki.com/ffxi/Brazen_Rush
---============================================================================

local WAR_SP = {}

WAR_SP.abilities = {
    ['Mighty Strikes'] = {
        description = "All attacks critical (45s)",
        level = 1,
        recast = 3600,  -- 1 hour (SP1)
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Brazen Rush'] = {
        description = "Double attack 100% (30s)",
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

return WAR_SP

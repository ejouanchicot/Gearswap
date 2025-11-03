---============================================================================
--- THF Job Abilities - SP Abilities Module
---============================================================================
--- Thief special abilities (2 SP total)
---
--- Contents:
---   - Perfect Dodge (SP1, Lv1) - Dodge all melee attacks (30s)
---   - Larceny (SP2, Lv96) - Steal buff from enemy (1hr)
---
--- @file thf_sp.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Thief
--- @source https://www.bg-wiki.com/ffxi/Perfect_Dodge
--- @source https://www.bg-wiki.com/ffxi/Larceny
---============================================================================

local THF_SP = {}

THF_SP.abilities = {
    ['Perfect Dodge'] = {
        description = "Dodge all melee attacks (30s)",
        level = 1,
        recast = 3600,  -- 1 hour (SP1)
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Larceny'] = {
        description = "Steal buff from enemy",
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

return THF_SP

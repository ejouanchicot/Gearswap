---============================================================================
--- RNG Job Abilities - SP Abilities Module
---============================================================================
--- Ranger special abilities (2 SP total)
---
--- Contents:
---   - Eagle Eye Shot (SP1, Lv1) - Powerful accurate shot x5 damage
---   - Overkill (SP2, Lv96) - Ranged speed +50%, Double/Triple Shot 100%
---
--- @file rng_sp.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Ranger
--- @source https://www.bg-wiki.com/ffxi/Eagle_Eye_Shot
--- @source https://www.bg-wiki.com/ffxi/Overkill
---============================================================================

local RNG_SP = {}

RNG_SP.abilities = {
    ['Eagle Eye Shot'] = {
        description             = "Powerful accurate shot x5 damage",
        level                   = 1,
        recast                  = 3600,  -- 1hr (SP1)
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Overkill'] = {
        description             = "Ranged speed +50%, Double/Triple Shot 100%",
        level                   = 96,
        recast                  = 3600,  -- 1hr (SP2)
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return RNG_SP

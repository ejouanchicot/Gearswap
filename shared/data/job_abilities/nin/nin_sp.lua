---============================================================================
--- NIN Job Abilities - SP Abilities Module
---============================================================================
--- Ninja special abilities (2 SP total)
---
--- Contents:
---   - Mijin Gakure (SP1, Lv1) - Sacrifice self, damage enemy
---   - Mikage (SP2, Lv96) - Multi-attack based on Utsusemi shadows (45s)
---
--- @file nin_sp.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Ninja
--- @source https://www.bg-wiki.com/ffxi/Mijin_Gakure
--- @source https://www.bg-wiki.com/ffxi/Mikage
---============================================================================

local NIN_SP = {}

NIN_SP.abilities = {
    ['Mijin Gakure'] = {
        description             = "Sacrifice self, damage enemy (~50% HP)",
        level                   = 1,
        recast                  = 3600,  -- 1hr (SP1)
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Mikage'] = {
        description             = "Multi-attack based on Utsusemi shadows (45s)",
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

return NIN_SP

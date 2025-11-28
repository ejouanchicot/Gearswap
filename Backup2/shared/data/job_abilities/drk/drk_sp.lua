---============================================================================
--- DRK Job Abilities - SP Abilities Module
---============================================================================
--- Dark Knight special abilities (2 SP total)
---
--- Contents:
---   - Blood Weapon (SP1, Lv1) - Drain HP with melee attacks
---   - Soul Enslavement (SP2, Lv96) - Absorb TP with melee attacks
---
--- @file drk_sp.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Dark_Knight
--- @source https://www.bg-wiki.com/ffxi/Blood_Weapon
--- @source https://www.bg-wiki.com/ffxi/Soul_Enslavement
---============================================================================

local DRK_SP = {}

DRK_SP.abilities = {
    ['Blood Weapon'] = {
        description             = "Drain HP with melee attacks",
        level                   = 1,
        recast                  = 3600,  -- 1hr (SP1)
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Soul Enslavement'] = {
        description             = "Absorb TP with melee attacks",
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

return DRK_SP

---============================================================================
--- WHM Job Abilities - SP Abilities Module
---============================================================================
--- White Mage special abilities (2 SP total)
---
--- Contents:
---   - Benediction (SP1, Lv1) - Restore party HP, remove status (instant)
---   - Asylum (SP2, Lv96) - Party debuff/dispel immunity
---
--- @file whm_sp.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/White_Mage
--- @source https://www.bg-wiki.com/ffxi/Benediction
--- @source https://www.bg-wiki.com/ffxi/Asylum
---============================================================================

local WHM_SP = {}

WHM_SP.abilities = {
    ['Benediction'] = {
        description             = "Restore party HP, remove status",
        level                   = 1,
        recast                  = 3600,  -- 1hr (SP1)
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Asylum'] = {
        description             = "Party debuff/dispel immunity",
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

return WHM_SP

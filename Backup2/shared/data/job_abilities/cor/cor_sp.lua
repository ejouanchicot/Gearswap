---============================================================================
--- COR Job Abilities - SP Abilities Module
---============================================================================
--- Corsair special abilities (2 SP total)
---
--- Contents:
---   - Wild Card (SP1, Lv1) - Random party ability reset (1-6)
---   - Cutting Cards (SP2, Lv96) - Reduce party SP recast (5-50%)
---
--- @file cor_sp.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Corsair
--- @source https://www.bg-wiki.com/ffxi/Wild_Card
--- @source https://www.bg-wiki.com/ffxi/Cutting_Cards
---============================================================================

local COR_SP = {}

COR_SP.abilities = {
    ['Wild Card'] = {
        description             = "Random party ability reset (1-6)",
        level                   = 1,
        recast                  = 3600,  -- 1hr (SP1)
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Cutting Cards'] = {
        description             = "Party SP recast -5-50%",
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

return COR_SP

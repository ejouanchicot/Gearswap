---============================================================================
--- SCH Job Abilities - SP Abilities Module
---============================================================================
--- Scholar special abilities (2 SP total)
---
--- Contents:
---   - Tabula Rasa (SP1, Lv1) - All Arts/Stratagems no recast (3min)
---   - Caper Emissarius (SP2, Lv96) - Transfer all enmity to party member
---
--- @file sch_sp.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Scholar
--- @source https://www.bg-wiki.com/ffxi/Tabula_Rasa
--- @source https://www.bg-wiki.com/ffxi/Caper_Emissarius
---============================================================================

local SCH_SP = {}

SCH_SP.abilities = {
    ['Tabula Rasa'] = {
        description             = "All Arts/Stratagems no recast (3min)",
        level                   = 1,
        recast                  = 3600,  -- 1hr (SP1)
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Caper Emissarius'] = {
        description             = "Transfer all enmity to party member",
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

return SCH_SP

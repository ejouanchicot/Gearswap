---============================================================================
--- SAM Job Abilities - SP Abilities Module
---============================================================================
--- Samurai special abilities (2 SP total)
---
--- Contents:
---   - Meikyo Shisui (SP1, Lv1) - WS TP cost reduced (30s)
---   - Yaegasumi (SP2, Lv96) - Evade special attacks (45s)
---
--- @file sam_sp.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @updated 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Samurai
--- @source https://www.bg-wiki.com/ffxi/Meikyo_Shisui
--- @source https://www.bg-wiki.com/ffxi/Yaegasumi
---============================================================================

local SAM_SP = {}

SAM_SP.abilities = {
    ['Meikyo Shisui'] = {
        description             = "WS TP cost → 1000 (30s)",
        level                   = 1,
        recast                  = 3600,  -- 1hr (SP1)
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Yaegasumi'] = {
        description             = "Evade special attacks, WS damage+ (45s)",
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

return SAM_SP

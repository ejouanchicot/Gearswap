---============================================================================
--- DRG Job Abilities - SP Abilities Module
---============================================================================
--- Dragoon special abilities (2 SP total)
---
--- Contents:
---   - Spirit Surge (SP1, Lv1) - Adds wyvern's strength to your own
---   - Fly High (SP2, Lv96) - Reset Jump timers, 10s recast
---
--- @file drg_sp.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Dragoon
--- @source https://www.bg-wiki.com/ffxi/Spirit_Surge
--- @source https://www.bg-wiki.com/ffxi/Fly_High
---============================================================================

local DRG_SP = {}

DRG_SP.abilities = {
    ['Spirit Surge'] = {
        description             = "Adds wyvern's strength to your own",
        level                   = 1,
        recast                  = 3600,  -- 1hr (SP1)
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Fly High'] = {
        description             = "Reset Jump timers, 10s recast",
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

return DRG_SP

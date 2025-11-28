---============================================================================
--- DNC Job Abilities - Main Job Only Module
---============================================================================
--- Dancer abilities restricted to main job (4 standard abilities)
---
--- Contents:
---   - Saber Dance (Lv75) - Double Attack boost, blocks Waltzes
---   - Fan Dance (Lv75) - Physical damage -90%, blocks Sambas
---   - No Foot Rise (Lv75) - Instant finishing moves
---   - Presto (Lv77) - Next Step enhanced +Daze
---
--- @file dnc_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Dancer
---============================================================================

local DNC_MAINJOB = {}

DNC_MAINJOB.abilities = {
    ['Saber Dance'] = {
        description             = "Double Attack+ but disables Waltzes",
        level                   = 75,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Fan Dance'] = {
        description             = "PDT- Enmity+ but disables Sambas",
        level                   = 75,
        recast                  = 180,  -- 3min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['No Foot Rise'] = {
        description             = "Instantly grants FM (1 per merit)",
        level                   = 75,
        recast                  = 180,  -- 3min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Presto'] = {
        description             = "Enhances next Step and grants +FM",
        level                   = 77,
        recast                  = 15,  -- 15s
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DNC_MAINJOB

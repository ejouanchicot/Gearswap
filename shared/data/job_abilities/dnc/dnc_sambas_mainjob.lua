---============================================================================
--- DNC Job Abilities - Sambas (Main Job Only)
---============================================================================
--- Dancer sambas restricted to main job (2 sambas, Lv60-65)
---
--- @file shared/data/job_abilities/dnc/dnc_sambas_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Dancer
---============================================================================

local DNC_SAMBAS_MAINJOB = {}

DNC_SAMBAS_MAINJOB.abilities = {
    ['Aspir Samba II'] = {
        description             = "Attackers drain MP from target (enhanced)",
        level                   = 60,
        recast                  = 60,
        main_job_only           = true,
        cumulative_enmity       = 1,
        volatile_enmity         = 300
    },
    ['Drain Samba III'] = {
        description             = "Attackers drain HP from target (superior)",
        level                   = 65,
        recast                  = 60,
        main_job_only           = true,
        cumulative_enmity       = 1,
        volatile_enmity         = 300
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DNC_SAMBAS_MAINJOB

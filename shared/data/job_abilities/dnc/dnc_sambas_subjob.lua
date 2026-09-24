---============================================================================
--- DNC Job Abilities - Sambas (Sub-Job Accessible)
---============================================================================
--- Dancer sambas accessible as subjob (4 sambas, Lv5-45)
---
--- @file shared/data/job_abilities/dnc/dnc_sambas_subjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Dancer
---============================================================================

local DNC_SAMBAS_SUBJOB = {}

DNC_SAMBAS_SUBJOB.abilities = {
    ['Drain Samba'] = {
        description             = "Attackers drain HP from target",
        level                   = 5,
        recast                  = 60,
        main_job_only           = false,
        cumulative_enmity       = 1,
        volatile_enmity         = 300
    },
    ['Aspir Samba'] = {
        description             = "Attackers drain MP from target",
        level                   = 25,
        recast                  = 60,
        main_job_only           = false,
        cumulative_enmity       = 1,
        volatile_enmity         = 300
    },
    ['Drain Samba II'] = {
        description             = "Attackers drain HP from target (enhanced)",
        level                   = 35,
        recast                  = 60,
        main_job_only           = false,
        cumulative_enmity       = 1,
        volatile_enmity         = 300
    },
    ['Haste Samba'] = {
        description             = "Attackers gain Haste from target",
        level                   = 45,
        recast                  = 60,
        main_job_only           = false,
        cumulative_enmity       = 1,
        volatile_enmity         = 300
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DNC_SAMBAS_SUBJOB

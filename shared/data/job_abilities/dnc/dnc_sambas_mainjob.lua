---============================================================================
--- DNC Job Abilities - Sambas (Main Job Only)
---============================================================================
--- Dancer sambas restricted to main job (2 sambas, Lv60-65)
---
--- @file dnc_sambas_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Dancer
---============================================================================

local DNC_SAMBAS_MAINJOB = {}

DNC_SAMBAS_MAINJOB.abilities = {
    ['Aspir Samba II'] = {
        description             = "Party drains MP from target (enhanced)",
        level                   = 60,
        recast                  = 60,
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Drain Samba III'] = {
        description             = "Party drains HP from target (superior)",
        level                   = 65,
        recast                  = 60,
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DNC_SAMBAS_MAINJOB

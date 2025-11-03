---============================================================================
--- DNC Job Abilities - Sambas (Sub-Job Accessible)
---============================================================================
--- Dancer sambas accessible as subjob (4 sambas, Lv5-45)
---
--- @file dnc_sambas_subjob.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30
--- @source https://www.bg-wiki.com/ffxi/Dancer
---============================================================================

local DNC_SAMBAS_SUBJOB = {}

DNC_SAMBAS_SUBJOB.abilities = {
    ['Drain Samba'] = {
        description = "Party drains HP from target",
        level = 5,
        recast = 60,
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Aspir Samba'] = {
        description = "Party drains MP from target",
        level = 25,
        recast = 60,
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Drain Samba II'] = {
        description = "Party drains HP from target (enhanced)",
        level = 35,
        recast = 60,
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Haste Samba'] = {
        description = "Party gains Haste from target",
        level = 45,
        recast = 60,
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DNC_SAMBAS_SUBJOB

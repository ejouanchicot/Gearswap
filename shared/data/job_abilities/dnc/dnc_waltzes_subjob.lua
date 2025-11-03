---============================================================================
--- DNC Job Abilities - Waltzes (Sub-Job Accessible)
---============================================================================
--- Dancer waltzes accessible as subjob (5 waltzes, Lv15-45)
---
--- @file dnc_waltzes_subjob.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30
--- @source https://www.bg-wiki.com/ffxi/Dancer
---============================================================================

local DNC_WALTZES_SUBJOB = {}

DNC_WALTZES_SUBJOB.abilities = {
    ['Curing Waltz'] = {
        description = "Restores HP",
        level = 15,
        recast = 6,
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Divine Waltz'] = {
        description = "Restores HP (AoE)",
        level = 25,
        recast = 15,
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Curing Waltz II'] = {
        description = "Restores HP",
        level = 30,
        recast = 6,
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Healing Waltz'] = {
        description = "Removes one status ailment",
        level = 35,
        recast = 6,
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Curing Waltz III'] = {
        description = "Restores HP",
        level = 45,
        recast = 8,
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DNC_WALTZES_SUBJOB

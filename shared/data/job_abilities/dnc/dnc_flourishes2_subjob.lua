---============================================================================
--- DNC Job Abilities - Flourishes II (Sub-Job Accessible)
---============================================================================
--- Dancer flourishes tier II - Accessible as subjob (2 flourishes, Lv40-50)
---
--- @file dnc_flourishes2_subjob.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30
--- @source https://www.bg-wiki.com/ffxi/Dancer
---============================================================================

local DNC_FLOURISHES2_SUBJOB = {}

DNC_FLOURISHES2_SUBJOB.abilities = {
    ['Reverse Flourish'] = {
        description = "Converts FM to TP. Requires 1 FM",
        level = 40,
        recast = 60,
        fm_cost = 1,  -- Consumes all finishing moves
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Building Flourish'] = {
        description = "Next WS potency+. Requires 1 FM",
        level = 50,
        recast = 60,
        fm_cost = 1,
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DNC_FLOURISHES2_SUBJOB

---============================================================================
--- DNC Job Abilities - Sub-Job Accessible Module
---============================================================================
--- Dancer abilities accessible as subjob (1 ability, requires Master Level)
---
--- Contents:
---   - Contradance (Lv50) - Next Waltz doubled
---
--- @file dnc_subjob.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30
--- @source https://www.bg-wiki.com/ffxi/Dancer
---============================================================================

local DNC_SUBJOB = {}

DNC_SUBJOB.abilities = {
    ['Contradance'] = {
        description = "Doubles next Waltz potency",
        level = 50,
        recast = 300,  -- 5 minutes
        main_job_only = false,  -- Accessible as subjob (Lv50)
        cumulative_enmity = 0,
        volatile_enmity = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DNC_SUBJOB

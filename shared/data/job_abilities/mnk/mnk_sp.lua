---============================================================================
--- MNK Job Abilities - SP Abilities Module
---============================================================================
--- Monk special abilities (2 SP total)
---
--- Contents:
---   - Hundred Fists (SP1, Lv1) - Attack speed +75% (45s)
---   - Inner Strength (SP2, Lv96) - Max HP x2, Counter/Guard 100% (30s)
---
--- @file mnk_sp.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Monk
--- @source https://www.bg-wiki.com/ffxi/Hundred_Fists
--- @source https://www.bg-wiki.com/ffxi/Inner_Strength
---============================================================================

local MNK_SP = {}

MNK_SP.abilities = {
    ['Hundred Fists'] = {
        description = "Attack speed +75% (45s)",
        level = 1,
        recast = 3600,  -- 1 hour (SP1)
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Inner Strength'] = {
        description = "Max HP x2, Counter/Guard 100% (30s)",
        level = 96,
        recast = 3600,  -- 1 hour (SP2)
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return MNK_SP

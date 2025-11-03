---============================================================================
--- RUN Job Abilities - SP Abilities Module
---============================================================================
--- Rune Fencer special abilities (2 SP total)
---
--- Contents:
---   - Elemental Sforzo (SP1, Lv1) - Immune to all magic attacks (30s)
---   - Odyllic Subterfuge (SP2, Lv96) - Enemy MACC -40 (30s)
---
--- @file run_sp.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Rune_Fencer
--- @source https://www.bg-wiki.com/ffxi/Elemental_Sforzo
--- @source https://www.bg-wiki.com/ffxi/Odyllic_Subterfuge
---============================================================================

local RUN_SP = {}

RUN_SP.abilities = {
    ['Elemental Sforzo'] = {
        description = "Immune to all magic attacks (30s)",
        level = 1,
        recast = 3600,  -- 1 hour (SP1)
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Odyllic Subterfuge'] = {
        description = "Enemy MACC -40 (30s)",
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

return RUN_SP

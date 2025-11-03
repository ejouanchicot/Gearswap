---============================================================================
--- BRD Job Abilities - SP Abilities Module
---============================================================================
--- Bard special abilities (2 SP total)
---
--- Contents:
---   - Soul Voice (SP1, Lv1) - Enhances song effects (3min)
---   - Clarion Call (SP2, Lv96) - +1 song slot for party (3min)
---
--- @file brd_sp.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30
--- @source https://www.bg-wiki.com/ffxi/Bard
--- @source https://www.bg-wiki.com/ffxi/Soul_Voice
--- @source https://www.bg-wiki.com/ffxi/Clarion_Call
---============================================================================

local BRD_SP = {}

BRD_SP.abilities = {
    ['Soul Voice'] = {
        description = "Song effects x2 (3min)",
        level = 1,
        recast = 3600,  -- 1 hour (SP1)
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Clarion Call'] = {
        description = "+1 song slot for party (3min)",
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

return BRD_SP

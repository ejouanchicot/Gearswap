---============================================================================
--- BRD Job Abilities - Sub-Job Accessible Module
---============================================================================
--- Bard abilities accessible as subjob (1 ability)
---
--- Contents:
---   - Pianissimo (Lv20) - Next song affects single target only
---
--- @file brd_subjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Bard
--- @source https://www.bg-wiki.com/ffxi/Pianissimo
---============================================================================

local BRD_SUBJOB = {}

BRD_SUBJOB.abilities = {
    ['Pianissimo'] = {
        description             = "Next song affects single target",
        level                   = 20,
        recast                  = 5,  -- 5s
        main_job_only           = false,  -- Accessible as subjob
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BRD_SUBJOB

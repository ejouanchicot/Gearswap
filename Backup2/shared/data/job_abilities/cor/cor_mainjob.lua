---============================================================================
--- COR Job Abilities - Main Job Only Module
---============================================================================
--- Corsair abilities restricted to main job (4 standard abilities)
---
--- Contents:
---   - Snake Eye (Merit, Lv75) - Force roll = 1, auto-11 chance
---   - Fold (Merit, Lv75) - Remove longest roll/bust
---   - Triple Shot (Lv87) - 40% triple shot for ranged attacks
---   - Crooked Cards (Lv95) - Next roll +20% effect
---
--- @file cor_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Corsair
--- @source https://www.bg-wiki.com/ffxi/Snake_Eye
--- @source https://www.bg-wiki.com/ffxi/Fold
--- @source https://www.bg-wiki.com/ffxi/Triple_Shot
--- @source https://www.bg-wiki.com/ffxi/Crooked_Cards
---============================================================================

local COR_MAINJOB = {}

COR_MAINJOB.abilities = {
    ['Snake Eye'] = {
        description             = "Force roll = 1, auto-11 chance",
        level                   = 75,  -- Merit ability
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Fold'] = {
        description             = "Remove longest roll/bust",
        level                   = 75,  -- Merit ability
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Triple Shot'] = {
        description             = "40% triple shot",
        level                   = 87,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Crooked Cards'] = {
        description             = "Next roll +20% (bust penalty +20%)",
        level                   = 95,
        recast                  = 600,  -- 10min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return COR_MAINJOB

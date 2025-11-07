---============================================================================
--- BRD Job Abilities - Main Job Only Module
---============================================================================
--- Bard abilities restricted to main job (4 standard abilities)
---
--- Contents:
---   - Nightingale (Merit, Lv75) - Song cast/recast -50% (1min)
---   - Troubadour (Merit, Lv75) - Song duration x2, cast time +50% (1min)
---   - Tenuto (Lv83) - Next self song no overwrite (1min)
---   - Marcato (Lv95) - Next song effect x1.5 (1min)
---
--- @file brd_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Bard
--- @source https://www.bg-wiki.com/ffxi/Nightingale
--- @source https://www.bg-wiki.com/ffxi/Troubadour
--- @source https://www.bg-wiki.com/ffxi/Tenuto
--- @source https://www.bg-wiki.com/ffxi/Marcato
---============================================================================

local BRD_MAINJOB = {}

BRD_MAINJOB.abilities = {
    ['Nightingale'] = {
        description             = "Song cast/recast -50%",
        level                   = 75,  -- Merit ability
        recast                  = 600,  -- 10min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Troubadour'] = {
        description             = "Song duration x2",
        level                   = 75,  -- Merit ability
        recast                  = 600,  -- 10min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Tenuto'] = {
        description             = "Next self song no overwrite (5 max)",
        level                   = 83,
        recast                  = 5,  -- 5s
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Marcato'] = {
        description             = "Next song effect x1.5",
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

return BRD_MAINJOB

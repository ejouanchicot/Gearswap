---============================================================================
--- MNK Job Abilities - Main Job Only Module
---============================================================================
--- Monk abilities restricted to main job (5 total)
---
--- Contents:
---   - Footwork (Lv65) - Kick attack enhancement
---   - Mantra (Lv75 Merit) - Party max HP boost
---   - Formless Strikes (Lv75 Merit) - Bypass immunities
---   - Perfect Counter (Lv79) - Counter rate 100%
---   - Impetus (Lv88) - Attack boost per hit
---
--- @file mnk_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Monk
---============================================================================

local MNK_MAINJOB = {}

MNK_MAINJOB.abilities = {
    ['Footwork'] = {
        description             = 'Kick attack rate/damage +20%',
        level                   = 65,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Mantra'] = {
        description             = 'Party max HP boost',
        level                   = 75,
        recast                  = 600,  -- 10min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Formless Strikes'] = {
        description             = 'Bypass physical immunities',
        level                   = 75,
        recast                  = 600,  -- 10min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Perfect Counter'] = {
        description             = 'Counter rate 100%',
        level                   = 79,
        recast                  = 60,  -- 1min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Impetus'] = {
        description             = 'Attack boost per hit (stacks)',
        level                   = 88,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return MNK_MAINJOB

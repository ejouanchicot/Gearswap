---============================================================================
--- THF Job Abilities - Sub-Job Accessible Module
---============================================================================
--- Thief abilities accessible as subjob (6 total)
---
--- Contents:
---   - Steal (Lv5) - Steal items from enemy
---   - Sneak Attack (Lv15) - Critical hit from behind
---   - Flee (Lv25) - Movement speed boost
---   - Trick Attack (Lv30) - Critical hit, transfer enmity
---   - Mug (Lv35) - Steal gil + HP
---   - Hide (Lv45) - Invisible, reset enmity
---
--- @file thf_subjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @updated 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Thief
---============================================================================

local THF_SUBJOB = {}

THF_SUBJOB.abilities = {
    ['Steal'] = {
        description             = 'Steal items from enemy',
        level                   = 5,
        recast                  = 300,  -- 5min
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Sneak Attack'] = {
        description             = 'Crit from behind, +DEX damage',
        level                   = 15,
        recast                  = 60,  -- 1min
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Flee'] = {
        description             = 'Movement speed +60%',
        level                   = 25,
        recast                  = 300,  -- 5min
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Trick Attack'] = {
        description             = 'Behind ally: Crit, +AGI, transfer enmity',
        level                   = 30,
        recast                  = 60,  -- 1min
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Mug'] = {
        description             = 'Steal gil, drain HP',
        level                   = 35,
        recast                  = 300,  -- 5min
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Hide'] = {
        description             = 'Invisible, reset enmity',
        level                   = 45,
        recast                  = 300,  -- 5min
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

return THF_SUBJOB

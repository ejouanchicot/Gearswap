---============================================================================
--- RNG Job Abilities - Sub-Job Accessible Module
---============================================================================
--- Ranger abilities accessible as subjob (6 total)
---
--- Contents:
---   - Sharpshot (Lv1) - Ranged ACC +40 (1min)
---   - Scavenge (Lv10) - Recover spent ammunition
---   - Camouflage (Lv20) - Invisible, reduced ranged enmity
---   - Barrage (Lv30) - Fire multiple shots
---   - Shadowbind (Lv40) - Root enemy (30s, breaks on damage)
---   - Unlimited Shot (Lv51 - Master Job Only) - Next ranged attack no ammo
---
--- @file rng_subjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Ranger
---============================================================================

local RNG_SUBJOB = {}

RNG_SUBJOB.abilities = {
    ['Sharpshot'] = {
        description             = 'Ranged ACC +40 (1min)',
        level                   = 1,
        recast                  = 300,  -- 5min
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Scavenge'] = {
        description             = 'Recover spent ammunition',
        level                   = 10,
        recast                  = 60,  -- 1min
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Camouflage'] = {
        description             = 'Invisible, reduced ranged enmity',
        level                   = 20,
        recast                  = 300,  -- 5min
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Barrage'] = {
        description             = 'Fire multiple shots (4-13 based on level)',
        level                   = 30,
        recast                  = 300,  -- 5min
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Shadowbind'] = {
        description             = 'Root enemy (30s, breaks on damage)',
        level                   = 40,
        recast                  = 300,  -- 5min
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Unlimited Shot'] = {
        description             = 'Next ranged attack no ammo cost',
        level                   = 51,
        recast                  = 180,  -- 3min (base)
        main_job_only           = false,  -- Master Job Only for subjob access
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return RNG_SUBJOB

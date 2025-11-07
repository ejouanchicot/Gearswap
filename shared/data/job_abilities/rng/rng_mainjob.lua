---============================================================================
--- RNG Job Abilities - Main Job Only Module
---============================================================================
--- Ranger abilities restricted to main job (7 total)
---
--- Contents:
---   - Velocity Shot (Lv45) - Ranged ATK/speed +15%, melee -15%
---   - Flashy Shot (Lv75 Merit) - Next attack +enmity/ACC/damage
---   - Stealth Shot (Lv75 Merit) - Next attack -enmity
---   - Double Shot (Lv79) - 40% chance double damage (90s)
---   - Bounty Shot (Lv87) - Apply TH+2 to target
---   - Decoy Shot (Lv95) - Transfer 80% ranged enmity to party
---   - Hover Shot (Lv95) - Damage/ACC+ per shot from different position
---
--- @file rng_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Ranger
---============================================================================

local RNG_MAINJOB = {}

RNG_MAINJOB.abilities = {
    ['Velocity Shot'] = {
        description             = 'Ranged ATK/speed +15%, melee -15%',
        level                   = 45,
        recast                  = 60,  -- 1min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Flashy Shot'] = {
        description             = 'Next attack +enmity/ACC/damage',
        level                   = 75,
        recast                  = 600,  -- 10min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Stealth Shot'] = {
        description             = 'Next attack -enmity',
        level                   = 75,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Double Shot'] = {
        description             = '40% chance double damage (90s)',
        level                   = 79,
        recast                  = 180,  -- 3min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Bounty Shot'] = {
        description             = 'Apply TH+2 to target',
        level                   = 87,
        recast                  = 60,  -- 1min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Decoy Shot'] = {
        description             = 'Transfer 80% ranged enmity to party',
        level                   = 95,
        recast                  = 180,  -- 3min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Hover Shot'] = {
        description             = 'Damage/ACC+ per shot from different position',
        level                   = 95,
        recast                  = 180,  -- 3min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return RNG_MAINJOB

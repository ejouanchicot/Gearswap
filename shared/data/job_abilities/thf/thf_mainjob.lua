---============================================================================
--- THF Job Abilities - Main Job Only Module
---============================================================================
--- Thief abilities restricted to main job (7 total)
---
--- Contents:
---   - Accomplice (Lv65) - Steal enmity from ally
---   - Collaborator (Lv65) - Transfer enmity to ally
---   - Assassin's Charge (Lv75 Merit) - Force multi-attack
---   - Feint (Lv75 Merit) - Enemy evasion down
---   - Despoil (Lv77) - Steal items + debuff
---   - Conspirator (Lv87) - Party ACC/Subtle Blow boost
---   - Bully (Lv93) - Intimidate target
---
--- @file thf_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @updated 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Thief
---============================================================================

local THF_MAINJOB = {}

THF_MAINJOB.abilities = {
    ['Accomplice'] = {
        description             = 'Steal 50% enmity from ally',
        level                   = 65,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Collaborator'] = {
        description             = 'Transfer 25% enmity to ally',
        level                   = 65,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ["Assassin's Charge"] = {
        description             = 'Force triple/quad attack',
        level                   = 75,
        recast                  = 300,  -- 5min
        main_job_only           = true
    },
    ['Feint'] = {
        description             = 'Enemy evasion -150→-50',
        level                   = 75,
        recast                  = 120,  -- 2min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Despoil'] = {
        description             = 'Steal items, inflict debuff',
        level                   = 77,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Conspirator'] = {
        description             = 'Party ACC+, Subtle Blow+',
        level                   = 87,
        recast                  = 180,  -- 3min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Bully'] = {
        description             = 'Intimidate target',
        level                   = 93,
        recast                  = 180,  -- 3min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

return THF_MAINJOB

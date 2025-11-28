---============================================================================
--- PUP Pet Commands - Sub-Job Accessible Module
---============================================================================
--- Puppetmaster pet commands accessible as subjob (11 total)
---
--- Contents:
---   - Deactivate (Lv1) - Deactivate automaton
---   - Deploy (Lv1) - Orders automaton to attack
---   - Dark Maneuver (Lv1) - MP recovery
---   - Light Maneuver (Lv1) - HP recovery (CHR+)
---   - Earth Maneuver (Lv1) - Physical defense (VIT+)
---   - Wind Maneuver (Lv1) - Evasion/Haste (AGI+)
---   - Fire Maneuver (Lv1) - Physical attack (STR+)
---   - Ice Maneuver (Lv1) - Magic attack/MACC (INT+)
---   - Thunder Maneuver (Lv1) - Accuracy (DEX+)
---   - Water Maneuver (Lv1) - Magic defense (MND+)
---   - Retrieve (Lv10) - Orders automaton to return
---
--- @file pup_pet_commands_subjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Puppetmaster
---============================================================================

local PUP_PET_COMMANDS_SUBJOB = {}

PUP_PET_COMMANDS_SUBJOB.abilities = {
    ['Deactivate'] = {
        description             = 'Deactivate automaton',
        level                   = 1,
        recast                  = 60,  -- 1min
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Deploy'] = {
        description             = 'Orders automaton to attack',
        level                   = 1,
        recast                  = 5,  -- 5s
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Dark Maneuver'] = {
        description             = 'MP recovery',
        level                   = 1,
        recast                  = 10,  -- 10s
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Light Maneuver'] = {
        description             = 'HP recovery (CHR+)',
        level                   = 1,
        recast                  = 10,  -- 10s
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Earth Maneuver'] = {
        description             = 'Physical defense (VIT+)',
        level                   = 1,
        recast                  = 10,  -- 10s
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Wind Maneuver'] = {
        description             = 'Evasion/Haste (AGI+)',
        level                   = 1,
        recast                  = 10,  -- 10s
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Fire Maneuver'] = {
        description             = 'Physical attack (STR+)',
        level                   = 1,
        recast                  = 10,  -- 10s
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Ice Maneuver'] = {
        description             = 'Magic attack/MACC (INT+)',
        level                   = 1,
        recast                  = 10,  -- 10s
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Thunder Maneuver'] = {
        description             = 'Accuracy (DEX+)',
        level                   = 1,
        recast                  = 10,  -- 10s
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Water Maneuver'] = {
        description             = 'Magic defense (MND+)',
        level                   = 1,
        recast                  = 10,  -- 10s
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Retrieve'] = {
        description             = 'Orders automaton to return',
        level                   = 10,
        recast                  = 5,  -- 5s
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return PUP_PET_COMMANDS_SUBJOB

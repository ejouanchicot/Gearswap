---============================================================================
--- WAR Job Abilities - Main Job Only Module
---============================================================================
--- Warrior abilities restricted to main job (5 total)
---
--- Contents:
---   - Retaliation (Lv60) - Counterattack enhancement
---   - Warrior's Charge (Lv75 Merit) - Multi-attack boost
---   - Tomahawk (Lv75 Merit) - Physical resistance down
---   - Restraint (Lv77) - WS damage bonus builder
---   - Blood Rage (Lv87) - Party critical hit boost
---
--- @file war_mainjob.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30
--- @updated 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Warrior
---============================================================================

local WAR_MAINJOB = {}

WAR_MAINJOB.abilities = {
    ['Retaliation'] = {
        description = 'Counterattack 40%',
        level = 60,
        recast = 300,  -- 5 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ["Warrior's Charge"] = {
        description = 'Force double/triple attack',
        level = 75,
        recast = 300,  -- 5 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 320
    },
    ['Tomahawk'] = {
        description = 'Throw: Physical resistance -25%',
        level = 75,
        recast = 180,  -- 3 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 640
    },
    ['Restraint'] = {
        description = 'Build WS damage bonus (max +30%)',
        level = 77,
        recast = 300,  -- 5 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 320
    },
    ['Blood Rage'] = {
        description = 'Party critical hit rate +20%',
        level = 87,
        recast = 300,  -- 5 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 320
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return WAR_MAINJOB

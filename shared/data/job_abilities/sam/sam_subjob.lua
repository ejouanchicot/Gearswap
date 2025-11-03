---============================================================================
--- SAM Job Abilities - Sub-Job Accessible Module
---============================================================================
--- Samurai abilities accessible as subjob (6 total)
---
--- Contents:
---   - Warding Circle (Lv5) - Party resistance vs Demons
---   - Third Eye (Lv15) - Anticipate/Counter attack
---   - Hasso (Lv25) - STR/Haste/ACC boost
---   - Meditate (Lv30) - TP recovery
---   - Seigan (Lv35) - Third Eye enhancement
---   - Sekkanoki (Lv40) - Next WS TP reduction
---
--- @file sam_subjob.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30
--- @updated 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Samurai
---============================================================================

local SAM_SUBJOB = {}

SAM_SUBJOB.abilities = {
    ['Warding Circle'] = {
        description = 'ATK/DEF+ vs Demons (party AoE)',
        level = 5,
        recast = 300,  -- 5 minutes
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Third Eye'] = {
        description = 'Anticipate/Counter next attack',
        level = 15,
        recast = 60,  -- 1 minute
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Hasso'] = {
        description = 'STR/Haste/ACC+ (5min)',
        level = 25,
        recast = 60,  -- 1 minute
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Meditate'] = {
        description = 'Restore TP',
        level = 30,
        recast = 180,  -- 3 minutes
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Seigan'] = {
        description = 'Third Eye enhanced (5min)',
        level = 35,
        recast = 60,  -- 1 minute
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Sekkanoki'] = {
        description = 'Next WS TP cost → 1000',
        level = 40,
        recast = 300,  -- 5 minutes
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return SAM_SUBJOB

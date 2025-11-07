---============================================================================
--- RUN Job Abilities - Sub-Job Accessible Module
---============================================================================
--- Rune Fencer abilities accessible as subjob (14 total)
---
--- Contents:
---   - 8 Runes (Lv5): Ignis, Gelus, Flabra, Tellus, Sulpor, Unda, Lux, Tenebrae
---   - Vallation (Lv10) - Reduce elemental damage by runes
---   - Swordplay (Lv20) - ACC/EVA boost (stacking)
---   - Swipe (Lv25) - Single-target damage (1 rune)
---   - Lunge (Lv25) - Single-target damage (all runes)
---   - Pflug (Lv40) - Enhance elemental status resistance
---   - Valiance (Lv50 - Master Job Only) - Party elemental damage reduction
---
--- @file run_subjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Rune_Fencer
---============================================================================

local RUN_SUBJOB = {}

RUN_SUBJOB.abilities = {
    -- 8 Elemental Runes (all Lv5, 5s recast)
    ['Ignis'] = {
        description             = 'Fire rune, resist ice',
        level                   = 5,
        recast                  = 5,  -- 5s
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Gelus'] = {
        description             = 'Ice rune, resist fire',
        level                   = 5,
        recast                  = 5,  -- 5s
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Flabra'] = {
        description             = 'Wind rune, resist earth',
        level                   = 5,
        recast                  = 5,  -- 5s
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Tellus'] = {
        description             = 'Earth rune, resist wind',
        level                   = 5,
        recast                  = 5,  -- 5s
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Sulpor'] = {
        description             = 'Thunder rune, resist water',
        level                   = 5,
        recast                  = 5,  -- 5s
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Unda'] = {
        description             = 'Water rune, resist thunder',
        level                   = 5,
        recast                  = 5,  -- 5s
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Lux'] = {
        description             = 'Light rune, resist dark',
        level                   = 5,
        recast                  = 5,  -- 5s
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Tenebrae'] = {
        description             = 'Dark rune, resist light',
        level                   = 5,
        recast                  = 5,  -- 5s
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    -- Standard Abilities
    ['Vallation'] = {
        description             = 'Reduce elemental damage by runes',
        level                   = 10,
        recast                  = 180,  -- 3min
        main_job_only           = false,
        cumulative_enmity       = 450,
        volatile_enmity         = 900
    },
    ['Swordplay'] = {
        description             = 'ACC/EVA boost (stacking)',
        level                   = 20,
        recast                  = 300,  -- 5min
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Swipe'] = {
        description             = 'Single-target damage (1 rune)',
        level                   = 25,
        recast                  = 90,  -- 1.5 minutes
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Lunge'] = {
        description             = 'Single-target damage (all runes)',
        level                   = 25,
        recast                  = 180,  -- 3min
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Pflug'] = {
        description             = 'Enhance elemental status resistance',
        level                   = 40,
        recast                  = 180,  -- 3min
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Valiance'] = {
        description             = 'Party elemental damage reduction',
        level                   = 50,
        recast                  = 300,  -- 5min
        main_job_only           = false,  -- Master Job Only for subjob access
        cumulative_enmity       = 450,
        volatile_enmity         = 900
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return RUN_SUBJOB

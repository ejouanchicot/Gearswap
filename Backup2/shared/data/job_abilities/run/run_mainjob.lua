---============================================================================
--- RUN Job Abilities - Main Job Only Module
---============================================================================
--- Rune Fencer abilities restricted to main job (7 total)
---
--- Contents:
---   - Embolden (Lv60) - Next enhancing +50% potency, -50% duration
---   - Vivacious Pulse (Lv65) - Restore HP based on runes
---   - Gambit (Lv70) - Reduce enemy elemental defense (all runes)
---   - Battuta (Lv75 Merit) - Parry rate +40%, counter damage
---   - Rayke (Lv75 Merit) - Reduce enemy elemental resistance
---   - Liement (Lv85) - Absorb elemental damage
---   - One for All (Lv95) - Party Magic Shield (HP × 0.2)
---
--- @file run_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Rune_Fencer
---============================================================================

local RUN_MAINJOB = {}

RUN_MAINJOB.abilities = {
    ['Embolden'] = {
        description             = 'Next enhancing +50% potency, -50% duration',
        level                   = 60,
        recast                  = 600,  -- 10min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Vivacious Pulse'] = {
        description             = 'Restore HP based on runes',
        level                   = 65,
        recast                  = 60,  -- 1min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Gambit'] = {
        description             = 'Reduce enemy elemental defense (all runes)',
        level                   = 70,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Battuta'] = {
        description             = 'Parry rate +40%, counter damage',
        level                   = 75,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 450,
        volatile_enmity         = 900
    },
    ['Rayke'] = {
        description             = 'Reduce enemy elemental resistance',
        level                   = 75,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Liement'] = {
        description             = 'Absorb elemental damage',
        level                   = 85,
        recast                  = 180,  -- 3min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['One for All'] = {
        description             = 'Party Magic Shield (HP × 0.2)',
        level                   = 95,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return RUN_MAINJOB

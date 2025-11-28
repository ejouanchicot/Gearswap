---============================================================================
--- DRG Job Abilities - Main Job Only Module
---============================================================================
--- Dragoon abilities restricted to main job (7 standard abilities)
---
--- Contents:
---   - Call Wyvern (Lv1) - Summon wyvern
---   - Spirit Bond (Lv65) - Take damage for wyvern
---   - Deep Breathing (Lv75 Merit) - Enhance next breath
---   - Angon (Lv75 Merit) - Lower enemy defense
---   - Spirit Jump (Lv77) - Jump with enmity suppression
---   - Soul Jump (Lv85) - High jump with enmity suppression
---   - Dragon Breaker (Lv87) - Debuff dragons
---
--- @file drg_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @updated 2025-10-31
---============================================================================

local DRG_MAINJOB = {}

DRG_MAINJOB.abilities = {
    ['Call Wyvern'] = {
        description             = "Summons wyvern",
        level                   = 1,
        recast                  = 1200,  -- 20min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Spirit Bond'] = {
        description             = "Take damage for wyvern",
        level                   = 65,
        recast                  = 60,  -- 1min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Deep Breathing'] = {
        description             = "Next wyvern breath x2",
        level                   = 75,  -- Merit ability
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Angon'] = {
        description             = "Enemy defense down",
        level                   = 75,  -- Merit ability
        recast                  = 180,  -- 3min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Spirit Jump'] = {
        description             = "Jump, enmity suppression",
        level                   = 77,
        recast                  = 60,  -- 1min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Soul Jump'] = {
        description             = "High jump, enmity suppression",
        level                   = 85,
        recast                  = 120,  -- 2min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Dragon Breaker'] = {
        description             = "Dragon debuff (ACC/EVA/MACC/MEVA/TP down)",
        level                   = 87,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

return DRG_MAINJOB

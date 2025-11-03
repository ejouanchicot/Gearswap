---============================================================================
--- DRK Job Abilities - Main Job Only Module
---============================================================================
--- Dark Knight abilities restricted to main job (5 total)
---
--- Contents:
---   - Dark Seal (Lv75) - Enhance next dark magic
---   - Diabolic Eye (Lv75) - ACC boost, max HP penalty
---   - Nether Void (Lv78) - Enhance next Absorb/Drain
---   - Arcane Crest (Lv87) - Arcana debuff
---   - Scarlet Delirium (Lv95) - Damage to ATK/MATT
---
--- @file drk_mainjob.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30
--- @updated 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Dark_Knight
---============================================================================

local DRK_MAINJOB = {}

DRK_MAINJOB.abilities = {
    ['Dark Seal'] = {
        description = 'Next dark magic MACC+ (1min)',
        level = 75,
        recast = 300,  -- 5 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Diabolic Eye'] = {
        description = 'ACC+20, max HP-15% (3min)',
        level = 75,
        recast = 180,  -- 3 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Nether Void'] = {
        description = 'Next Absorb/Drain +50% (1min)',
        level = 78,
        recast = 300,  -- 5 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Arcane Crest'] = {
        description = 'Arcana: ACC/EVA/MACC/MEVA/TP down',
        level = 87,
        recast = 180,  -- 3 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Scarlet Delirium'] = {
        description = 'Damage taken → ATK/MATT boost (90s)',
        level = 95,
        recast = 180,  -- 3 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DRK_MAINJOB

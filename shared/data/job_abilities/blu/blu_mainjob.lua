---============================================================================
--- BLU Job Abilities - Main Job Only Module
---============================================================================
--- Blue Mage abilities restricted to main job (4 total)
---
--- Contents:
---   - Convergence (Lv75 Merit) - Next magical spell +25% damage, single target
---   - Diffusion (Lv75 Merit) - Next support spell → party AoE
---   - Efflux (Lv83) - Next physical spell +1000 TP bonus
---   - Unbridled Learning (Lv95) - Cast NM-exclusive blue magic (1min)
---
--- @file blu_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Blue_Mage
---============================================================================

local BLU_MAINJOB = {}

BLU_MAINJOB.abilities = {
    ['Convergence'] = {
        description             = 'Next magical spell +25% damage, single target',
        level                   = 75,
        recast                  = 600,  -- 10min
        main_job_only           = true,
        cumulative_enmity       = 1,
        volatile_enmity         = 300
    },
    ['Diffusion'] = {
        description             = 'Next support spell → party AoE',
        level                   = 75,
        recast                  = 600,  -- 10min
        main_job_only           = true,
        cumulative_enmity       = 1,
        volatile_enmity         = 300
    },
    ['Efflux'] = {
        description             = 'Next physical spell +1000 TP bonus',
        level                   = 83,
        recast                  = 180,  -- 3min
        main_job_only           = true,
        cumulative_enmity       = 1,
        volatile_enmity         = 300
    },
    ['Unbridled Learning'] = {
        description             = 'Cast NM-exclusive blue magic (1min)',
        level                   = 95,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 1,
        volatile_enmity         = 300
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_MAINJOB

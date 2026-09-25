---============================================================================
--- SAM Job Abilities - Main Job Only Module
---============================================================================
--- Samurai abilities restricted to main job (6 total)
---
--- Contents:
---   - Konzen-ittai (Lv65) - Readies enemy for a skillchain
---   - Shikikoyo (Lv75 Merit) - Share TP with party
---   - Blade Bash (Lv75 Merit) - Stun attack
---   - Sengikori (Lv77) - Skillchain/magic burst bonus for next WS
---   - Hamanoha (Lv87) - Lowers demons' ACC/EVA/MACC/MEVA/TP gain
---   - Hagakure (Lv95) - Save TP + TP bonus for next WS
---
--- @file shared/data/job_abilities/sam/sam_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Samurai
---============================================================================

local SAM_MAINJOB = {}

SAM_MAINJOB.abilities = {
    ['Konzen-ittai'] = {
        description             = 'Readies enemy for a skillchain',
        level                   = 65,
        recast                  = 180,  -- 3min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Shikikoyo'] = {
        description             = 'Share TP >1000 with party member',
        level                   = 75,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Blade Bash'] = {
        description             = 'Stun attack',
        level                   = 75,
        recast                  = 180,  -- 3min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Sengikori'] = {
        description             = 'Next WS: skillchain and magic burst bonus',
        level                   = 77,
        recast                  = 180,  -- 3min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Hamanoha'] = {
        description             = 'Demons: ACC/EVA/MACC/MEVA/TP down',
        level                   = 87,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Hagakure'] = {
        description             = 'Next WS: Save TP + TP bonus',
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

return SAM_MAINJOB

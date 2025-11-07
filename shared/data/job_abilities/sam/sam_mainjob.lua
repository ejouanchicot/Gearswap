---============================================================================
--- SAM Job Abilities - Main Job Only Module
---============================================================================
--- Samurai abilities restricted to main job (6 total)
---
--- Contents:
---   - Konzen-ittai (Lv65) - TP bonus for WS
---   - Shikikoyo (Lv75 Merit) - Share TP with party
---   - Blade Bash (Lv75 Merit) - Stun attack
---   - Sengikori (Lv77) - Store TP boost
---   - Hamanoha (Lv87) - Zanshin enhancement
---   - Hagakure (Lv95) - Convert Kenki
---
--- @file sam_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @updated 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Samurai
---============================================================================

local SAM_MAINJOB = {}

SAM_MAINJOB.abilities = {
    ['Konzen-ittai'] = {
        description             = 'WS TP bonus',
        level                   = 65,
        recast                  = 300,  -- 5min
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
        description             = 'Store TP boost',
        level                   = 77,
        recast                  = 180,  -- 3min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Hamanoha'] = {
        description             = 'Zanshin +100%',
        level                   = 87,
        recast                  = 180,  -- 3min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Hagakure'] = {
        description             = 'Convert Kenki → HP/MP/TP',
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

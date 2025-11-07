---============================================================================
--- WHM Job Abilities - Main Job Only Module
---============================================================================
--- White Mage abilities restricted to main job (6 total)
---
--- Contents:
---   - Afflatus Solace (Lv40) - Cure grants Stoneskin
---   - Afflatus Misery (Lv40) - Damage boosts spells
---   - Martyr (Lv75 Merit) - Sacrifice HP to heal ally
---   - Devotion (Lv75 Merit) - Sacrifice HP for ally MP
---   - Divine Caress (Lv83) - Status removal grants immunity
---   - Sacrosanctity (Lv95) - Party magic damage reduction
---
--- @file whm_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @updated 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/White_Mage
---============================================================================

local WHM_MAINJOB = {}

WHM_MAINJOB.abilities = {
    ['Afflatus Solace'] = {
        description             = 'Cure → Stoneskin (25% of heal)',
        level                   = 40,
        recast                  = 10,
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Afflatus Misery'] = {
        description             = 'Damage taken → Banish/Cura/Esuna boost',
        level                   = 40,
        recast                  = 10,
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Martyr'] = {
        description             = 'Sacrifice 25% HP → heal ally 50%',
        level                   = 75,
        recast                  = 600,  -- 10min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Devotion'] = {
        description             = 'Sacrifice 25% HP → ally MP',
        level                   = 75,
        recast                  = 600,  -- 10min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Divine Caress'] = {
        description             = 'Next status removal → immunity (3min)',
        level                   = 83,
        recast                  = 60,  -- 1min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Sacrosanctity'] = {
        description             = 'Party magic damage -75%',
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

return WHM_MAINJOB

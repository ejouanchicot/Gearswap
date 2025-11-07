---============================================================================
--- BLM Job Abilities - Main Job Only Module
---============================================================================
--- Black Mage abilities restricted to main job (4 standard abilities)
---
--- Contents:
---   - Mana Wall (Lv76) - 50% damage to MP instead of HP (5min duration)
---   - Cascade (Lv85) - Convert TP to magic damage +10% TP
---   - Enmity Douse (Lv87) - Reset target enmity to minimum
---   - Manawell (Lv95) - Target's next spell costs 0 MP (1min duration)
---
--- @file blm_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Black_Mage
---============================================================================

local BLM_MAINJOB = {}

BLM_MAINJOB.abilities = {

    -------------------------------------------
    -- Mana Wall (Lv76)
    -------------------------------------------
    ['Mana Wall'] = {
        description             = 'Take damage with MP instead of HP',
        level                   = 76,
        recast                  = 600,   -- 10min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },

    -------------------------------------------
    -- Cascade (Lv85)
    -------------------------------------------
    ['Cascade'] = {
        description             = 'Next spell damage +10% TP (consumed)',
        level                   = 85,
        recast                  = 60,    -- 1min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },

    -------------------------------------------
    -- Enmity Douse (Lv87)
    -------------------------------------------
    ['Enmity Douse'] = {
        description             = 'Reduces enmity to 0',
        level                   = 87,
        recast                  = 600,   -- 10min (reducible with Job Points)
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 0
    },

    -------------------------------------------
    -- Manawell (Lv95)
    -------------------------------------------
    ['Manawell'] = {
        description             = 'Next spell costs 0 MP (target)',
        level                   = 95,
        recast                  = 600,   -- 10min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLM_MAINJOB

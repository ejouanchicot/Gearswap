---============================================================================
--- BLM Job Abilities - SP Abilities Module
---============================================================================
--- Black Mage special abilities (2 SP total)
---
--- Contents:
---   - Manafont (SP1, Lv1) - Zero MP cost spells, interruption immunity
---   - Subtle Sorcery (SP2, Lv96) - Lower enmity, +MACC, bypass resists
---
--- @file blm_sp.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Black_Mage
--- @source https://www.bg-wiki.com/ffxi/Category:SP_Ability
---============================================================================

local BLM_SP = {}

BLM_SP.abilities = {

    -------------------------------------------
    -- Manafont (SP1, Lv1)
    -------------------------------------------
    ['Manafont'] = {
        description             = 'Spells cost 0 MP',
        level                   = 1,
        recast                  = 3600,  -- 1hr (SP1)
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },

    -------------------------------------------
    -- Subtle Sorcery (SP2, Lv96)
    -------------------------------------------
    ['Subtle Sorcery'] = {
        description             = 'Enmity- MACC+ bypass resists',
        level                   = 96,
        recast                  = 3600,  -- 1hr (SP2)
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLM_SP

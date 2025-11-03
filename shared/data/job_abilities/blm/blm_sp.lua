---============================================================================
--- BLM Job Abilities - SP Abilities Module
---============================================================================
--- Black Mage special abilities (2 SP total)
---
--- Contents:
---   - Manafont (SP1, Lv1) - Zero MP cost spells, interruption immunity (60s)
---   - Subtle Sorcery (SP2, Lv96) - Lower enmity, +MACC, bypass resists (60s)
---
--- @file blm_sp.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30
--- @source https://www.bg-wiki.com/ffxi/Black_Mage
--- @source https://www.bg-wiki.com/ffxi/Category:SP_Ability
---============================================================================

local BLM_SP = {}

BLM_SP.abilities = {
    ['Manafont'] = {
        description = 'Spells cost 0 MP',
        level = 1,
        recast = 3600, -- 1 hour (SP1)
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Subtle Sorcery'] = {
        description = 'Enmity- MACC+ bypass resists',
        level = 96,
        recast = 3600, -- 1 hour (SP2)
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLM_SP

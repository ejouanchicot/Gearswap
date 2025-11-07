---============================================================================
--- BLU Job Abilities - SP Abilities Module
---============================================================================
--- Blue Mage special abilities (2 SP total)
---
--- Contents:
---   - Azure Lore (SP1, Lv1) - Blue magic enhanced (30s)
---   - Unbridled Wisdom (SP2, Lv96) - Cast Unbridled Learning spells (1min)
---
--- @file blu_sp.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Blue_Mage
--- @source https://www.bg-wiki.com/ffxi/Azure_Lore
--- @source https://www.bg-wiki.com/ffxi/Unbridled_Wisdom
---============================================================================

local BLU_SP = {}

BLU_SP.abilities = {
    ['Azure Lore'] = {
        description             = "Blue magic enhanced (30s)",
        level                   = 1,
        recast                  = 3600,  -- 1hr (SP1)
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Unbridled Wisdom'] = {
        description             = "Cast Unbridled Learning spells (1min)",
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

return BLU_SP

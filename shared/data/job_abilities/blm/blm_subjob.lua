---============================================================================
--- BLM Job Abilities - Sub-Job Accessible Module
---============================================================================
--- Black Mage abilities accessible as subjob (1 ability)
---
--- Contents:
---   - Elemental Seal (Lv15) - Next elemental spell MACC +256
---
--- @file blm_subjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Black_Mage
--- @source https://www.bg-wiki.com/ffxi/Elemental_Seal
---============================================================================

local BLM_SUBJOB = {}

BLM_SUBJOB.abilities = {
    ['Elemental Seal'] = {
        description             = 'Next elemental spell MACC +256',
        level                   = 15,
        recast                  = 600, -- 10min (reducible with merits)
        main_job_only           = false, -- Accessible as subjob
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLM_SUBJOB

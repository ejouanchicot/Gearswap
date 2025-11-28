---============================================================================
--- RDM Job Abilities - Sub-Job Accessible Module
---============================================================================
--- Red Mage abilities accessible as subjob (1 total)
---
--- Contents:
---   - Convert (Lv40) - Swap HP with MP
---
--- @file rdm_subjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Red_Mage
---============================================================================

local RDM_SUBJOB = {}

RDM_SUBJOB.abilities = {
    ['Convert'] = {
        description             = 'Swap HP with MP',
        level                   = 40,
        recast                  = 600,  -- 10min
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return RDM_SUBJOB

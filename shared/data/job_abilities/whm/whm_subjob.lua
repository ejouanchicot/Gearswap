---============================================================================
--- WHM Job Abilities - Sub-Job Accessible Module
---============================================================================
--- White Mage abilities accessible as subjob (1 total)
---
--- Contents:
---   - Divine Seal (Lv15) - Next cure x2 potency
---
--- @file whm_subjob.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30
--- @updated 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/White_Mage
---============================================================================

local WHM_SUBJOB = {}

WHM_SUBJOB.abilities = {
    ['Divine Seal'] = {
        description = 'Next cure x2 potency',
        level = 15,
        recast = 600,  -- 10 minutes
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return WHM_SUBJOB

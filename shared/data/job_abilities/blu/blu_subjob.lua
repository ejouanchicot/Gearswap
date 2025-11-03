---============================================================================
--- BLU Job Abilities - Sub-Job Accessible Module
---============================================================================
--- Blue Mage abilities accessible as subjob (2 total)
---
--- Contents:
---   - Burst Affinity (Lv25) - Magical blue magic can magic burst
---   - Chain Affinity (Lv40) - Physical blue magic can skillchain
---
--- @file blu_subjob.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Blue_Mage
---============================================================================

local BLU_SUBJOB = {}

BLU_SUBJOB.abilities = {
    ['Burst Affinity'] = {
        description = 'Magical blue magic can magic burst',
        level = 25,
        recast = 120,  -- 2 minutes
        main_job_only = false,
        cumulative_enmity = 1,
        volatile_enmity = 300
    },
    ['Chain Affinity'] = {
        description = 'Physical blue magic can skillchain',
        level = 40,
        recast = 120,  -- 2 minutes
        main_job_only = false,
        cumulative_enmity = 1,
        volatile_enmity = 300
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLU_SUBJOB

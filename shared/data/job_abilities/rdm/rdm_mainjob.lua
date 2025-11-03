---============================================================================
--- RDM Job Abilities - Main Job Only Module
---============================================================================
--- Red Mage abilities restricted to main job (3 total)
---
--- Contents:
---   - Composure (Lv50) - Self-enhancing x3 duration, ACC boost
---   - Saboteur (Lv83) - Enfeebling potency/duration x2
---   - Spontaneity (Lv95) - Next spell instant cast
---
--- @file rdm_mainjob.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Red_Mage
---============================================================================

local RDM_MAINJOB = {}

RDM_MAINJOB.abilities = {
    ['Composure'] = {
        description = 'Self-enhancing x3 duration, ACC+',
        level = 50,
        recast = 300,  -- 5 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Saboteur'] = {
        description = 'Enfeebling potency/duration x2 (1min)',
        level = 83,
        recast = 180,  -- 3 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Spontaneity'] = {
        description = 'Next spell instant cast',
        level = 95,
        recast = 60,  -- 1 minute
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return RDM_MAINJOB

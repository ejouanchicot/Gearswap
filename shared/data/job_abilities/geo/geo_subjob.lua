---============================================================================
--- GEO Job Abilities - Sub-Job Accessible Module
---============================================================================
--- Geomancer abilities accessible as subjob (2 total)
---
--- Contents:
---   - Collimated Fervor (Lv40) - Cardinal Chant enhancement
---   - Life Cycle (Lv50) - HP transfer to luopan (Master Job Only)
---
--- @file geo_subjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @updated 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Geomancer
---============================================================================

local GEO_SUBJOB = {}

GEO_SUBJOB.abilities = {
    ['Collimated Fervor'] = {
        description             = 'Next Cardinal Chant +50%',
        level                   = 40,
        recast                  = 300,  -- 5min
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Life Cycle'] = {
        description             = '25% your HP → luopan',
        level                   = 50,
        recast                  = 10,
        main_job_only           = false,  -- Requires Master Levels for subjob (useless without luopan)
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

return GEO_SUBJOB

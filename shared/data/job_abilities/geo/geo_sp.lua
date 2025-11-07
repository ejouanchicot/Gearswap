---============================================================================
--- GEO Job Abilities - SP Abilities Module
---============================================================================
--- Geomancer special abilities (2 SP total)
---
--- Contents:
---   - Bolster (SP1, Lv1) - Double geomancy potency (3min)
---   - Widened Compass (SP2, Lv96) - Double geomancy range (1min)
---
--- @file geo_sp.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Geomancer
--- @source https://www.bg-wiki.com/ffxi/Bolster
--- @source https://www.bg-wiki.com/ffxi/Widened_Compass
---============================================================================

local GEO_SP = {}

GEO_SP.abilities = {
    ['Bolster'] = {
        description             = "Geomancy effects x2 (3min)",
        level                   = 1,
        recast                  = 3600,  -- 1hr (SP1)
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Widened Compass'] = {
        description             = "Geomancy range x2 (1min)",
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

return GEO_SP

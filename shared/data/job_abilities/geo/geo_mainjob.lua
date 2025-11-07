---============================================================================
--- GEO Job Abilities - Main Job Only Module
---============================================================================
--- Geomancer abilities restricted to main job (10 total)
---
--- Contents:
---   - Full Circle (Lv5) - Dismiss luopan, MP recovery
---   - Lasting Emanation (Lv25) - Reduce luopan HP consumption
---   - Ecliptic Attrition (Lv25) - Boost luopan, increase HP drain
---   - Blaze of Glory (Lv60) - Next luopan enhancement
---   - Dematerialize (Lv70) - Luopan invulnerability
---   - Entrust (Lv75) - Indi to party member
---   - Mending Halation (Lv75 Merit) - Dismiss luopan, heal party
---   - Radial Arcana (Lv75 Merit) - Dismiss luopan, restore MP
---   - Theurgic Focus (Lv80) - Enhance next -ra spell
---   - Concentric Pulse (Lv90) - Dismiss luopan, AoE damage
---
--- @file geo_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @updated 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Geomancer
---============================================================================

local GEO_MAINJOB = {}

GEO_MAINJOB.abilities = {
    ['Full Circle'] = {
        description             = 'Dismiss luopan, recover MP',
        level                   = 5,
        recast                  = 15,
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Lasting Emanation'] = {
        description             = 'Luopan HP consumption -7/tick',
        level                   = 25,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Ecliptic Attrition'] = {
        description             = 'Luopan +25%, HP consumption +6/tick',
        level                   = 25,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Blaze of Glory'] = {
        description             = 'Next luopan +50%, -50% HP',
        level                   = 60,
        recast                  = 600,  -- 10min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Dematerialize'] = {
        description             = 'Luopan damage immunity (1min)',
        level                   = 70,
        recast                  = 600,  -- 10min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Entrust'] = {
        description             = 'Next Indi targets party member',
        level                   = 75,
        recast                  = 600,  -- 10min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Mending Halation'] = {
        description             = 'Dismiss luopan, party HP',
        level                   = 75,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Radial Arcana'] = {
        description             = 'Dismiss luopan, party MP',
        level                   = 75,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Theurgic Focus'] = {
        description             = 'Next -ra spell MAB+50',
        level                   = 80,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Concentric Pulse'] = {
        description             = 'Dismiss luopan, AoE damage',
        level                   = 90,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

return GEO_MAINJOB

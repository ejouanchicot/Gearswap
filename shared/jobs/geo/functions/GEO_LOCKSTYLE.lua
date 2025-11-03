---============================================================================
--- GEO Lockstyle Module - Lockstyle Management for Geomancer
---============================================================================
--- Handles lockstyle application and management for Geomancer job.
--- Uses centralized LockstyleManager factory pattern.
---
--- @file jobs/geo/functions/GEO_LOCKSTYLE.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-09
--- @requires utils/lockstyle/lockstyle_manager
---============================================================================

local LockstyleManager = require('shared/utils/lockstyle/lockstyle_manager')

-- Create GEO lockstyle module using factory
return LockstyleManager.create(
    'GEO',                          -- job_code
    'config/geo/GEO_LOCKSTYLE',    -- config_path
    1,                              -- default_lockstyle (number)
    'WHM'                           -- default_subjob (GEO/WHM common)
)

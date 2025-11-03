---============================================================================
--- DNC Lockstyle Module - Lockstyle Management for Dancer
---============================================================================
--- Handles lockstyle selection and management for Dancer job.
--- Now uses centralized LockstyleManager factory pattern.
---
--- @file jobs/dnc/functions/DNC_LOCKSTYLE.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-10-04
--- @requires utils/lockstyle/lockstyle_manager
---============================================================================

local LockstyleManager = require('shared/utils/lockstyle/lockstyle_manager')

-- Create DNC lockstyle module using factory
return LockstyleManager.create(
    'DNC',                          -- job_code
    'config/dnc/DNC_LOCKSTYLE',    -- config_path
    5,                              -- default_lockstyle
    'NIN'                           -- default_subjob
)

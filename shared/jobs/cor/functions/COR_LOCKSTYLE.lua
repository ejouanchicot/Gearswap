---============================================================================
--- COR Lockstyle Module - Lockstyle Management for Corsair
---============================================================================
--- Handles lockstyle selection and management for Corsair job.
--- Uses centralized LockstyleManager factory pattern.
---
--- @file jobs/cor/functions/COR_LOCKSTYLE.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-07
--- @requires utils/lockstyle/lockstyle_manager
---============================================================================

local LockstyleManager = require('shared/utils/lockstyle/lockstyle_manager')

-- Create COR lockstyle module using factory
return LockstyleManager.create(
    'COR',                          -- job_code
    'config/cor/COR_LOCKSTYLE',    -- config_path
    1,                              -- default_lockstyle
    'DNC'                           -- default_subjob
)

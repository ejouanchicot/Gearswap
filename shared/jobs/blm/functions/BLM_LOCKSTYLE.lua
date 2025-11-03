---============================================================================
--- BLM Lockstyle Module - Lockstyle Management for Black Mage
---============================================================================
--- Handles lockstyle application and management for Black Mage job.
--- Uses centralized LockstyleManager factory pattern.
---
--- @file jobs/blm/functions/BLM_LOCKSTYLE.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-15
--- @requires utils/lockstyle/lockstyle_manager
---============================================================================

local LockstyleManager = require('shared/utils/lockstyle/lockstyle_manager')

-- Create BLM lockstyle module using factory
return LockstyleManager.create(
    'BLM',                          -- job_code
    'config/blm/BLM_LOCKSTYLE',    -- config_path
    1,                              -- default_lockstyle (number)
    'SCH'                           -- default_subjob (BLM/SCH common)
)

---============================================================================
--- RDM Lockstyle Module - Lockstyle Management for Red Mage
---============================================================================
--- Handles lockstyle selection and application for Red Mage job.
--- Uses centralized LockstyleManager factory pattern.
---
--- @file jobs/rdm/functions/RDM_LOCKSTYLE.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-12
--- @requires utils/lockstyle/lockstyle_manager
---============================================================================

local LockstyleManager = require('shared/utils/lockstyle/lockstyle_manager')

-- Create RDM lockstyle module using factory
return LockstyleManager.create(
    'RDM',                          -- job_code
    'config/rdm/RDM_LOCKSTYLE',    -- config_path
    1,                              -- default_lockstyle
    'NIN'                           -- default_subjob (RDM/NIN common)
)

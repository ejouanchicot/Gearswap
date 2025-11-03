---============================================================================
--- PUP Lockstyle Module - Lockstyle Management (Factory Pattern)
---============================================================================
--- Handles lockstyle selection and management for Beastmaster job.
--- Uses centralized LockstyleManager factory for consistent behavior.
---
--- Configuration:
---   • Lockstyle definitions: config/pup/PUP_LOCKSTYLE.lua
---   • Default lockstyle: #1
---   • Default subjob: SAM
---   • Automatic subjob-based selection
---
--- @file    jobs/pup/functions/PUP_LOCKSTYLE.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-17
--- @requires utils/lockstyle/lockstyle_manager
---============================================================================
local LockstyleManager = require('shared/utils/lockstyle/lockstyle_manager')

-- Create PUP lockstyle module using factory
-- Exports: select_default_lockstyle(), cancel_pup_lockstyle_operations()
return LockstyleManager.create(
    'PUP',                        -- job_code
    'config/pup/PUP_LOCKSTYLE',   -- config_path
    1,                            -- default_lockstyle
    'SAM'                         -- default_subjob
)

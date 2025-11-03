---============================================================================
--- DRK Lockstyle Module - Lockstyle Management (Factory Pattern)
---============================================================================
--- Handles lockstyle selection and management for Dark Knight job.
--- Uses centralized LockstyleManager factory for consistent behavior.
---
--- Configuration:
---   • Lockstyle definitions: config/drk/DRK_LOCKSTYLE.lua
---   • Default lockstyle: #1
---   • Default subjob: SAM
---   • Automatic subjob-based selection
---
--- @file    DRK_LOCKSTYLE.lua
--- @author  Tetsouo
--- @version 1.0.0 - Factory Pattern
--- @date    Created: 2025-10-23
--- @requires utils/lockstyle/lockstyle_manager
---============================================================================
local LockstyleManager = require('shared/utils/lockstyle/lockstyle_manager')

-- Create DRK lockstyle module using factory
-- Exports: select_default_lockstyle(), cancel_drk_lockstyle_operations()
return LockstyleManager.create(
    'DRK',                          -- job_code
    'config/drk/DRK_LOCKSTYLE',     -- config_path
    1,                              -- default_lockstyle
    'SAM'                           -- default_subjob
)

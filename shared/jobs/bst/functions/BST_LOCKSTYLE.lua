---============================================================================
--- BST Lockstyle Module - Lockstyle Management (Factory Pattern)
---============================================================================
--- Handles lockstyle selection and management for Beastmaster job.
--- Uses centralized LockstyleManager factory for consistent behavior.
---
--- Configuration:
---   • Lockstyle definitions: config/bst/BST_LOCKSTYLE.lua
---   • Default lockstyle: #1
---   • Default subjob: SAM
---   • Automatic subjob-based selection
---
--- @file    jobs/bst/functions/BST_LOCKSTYLE.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-17
--- @requires utils/lockstyle/lockstyle_manager
---============================================================================
local LockstyleManager = require('shared/utils/lockstyle/lockstyle_manager')

-- Create BST lockstyle module using factory
-- Exports: select_default_lockstyle(), cancel_bst_lockstyle_operations()
return LockstyleManager.create(
    'BST',                        -- job_code
    'config/bst/BST_LOCKSTYLE',   -- config_path
    1,                            -- default_lockstyle
    'SAM'                         -- default_subjob
)

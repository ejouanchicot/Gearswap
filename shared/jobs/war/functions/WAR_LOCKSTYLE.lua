---============================================================================
--- WAR Lockstyle Module - Lockstyle Management (Factory Pattern)
---============================================================================
--- Handles lockstyle selection and management for Warrior job.
--- Uses centralized LockstyleManager factory for consistent behavior.
---
--- Configuration:
---   • Lockstyle definitions: config/war/WAR_LOCKSTYLE.lua
---   • Default lockstyle: #4
---   • Default subjob: SAM
---   • Automatic subjob-based selection
---
--- @file    jobs/war/functions/WAR_LOCKSTYLE.lua
--- @author  Tetsouo
--- @version 2.0 - Factory Pattern
--- @date    Created: 2025-09-29
--- @requires utils/lockstyle/lockstyle_manager
---============================================================================
local LockstyleManager = require('shared/utils/lockstyle/lockstyle_manager')

-- Create WAR lockstyle module using factory
-- Exports: select_default_lockstyle(), cancel_war_lockstyle_operations()
return LockstyleManager.create('WAR', -- job_code
'config/war/WAR_LOCKSTYLE', -- config_path
4, -- default_lockstyle
'SAM' -- default_subjob
)

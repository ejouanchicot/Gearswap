---============================================================================
--- RUN Lockstyle Module - Lockstyle Management (Factory Pattern)
---============================================================================
--- Handles lockstyle selection and management for Rune Fencer job.
--- Uses centralized LockstyleManager factory for consistent behavior.
---
--- Configuration:
---   • Lockstyle definitions: config/run/RUN_LOCKSTYLE.lua
---   • Default lockstyle: #3
---   • Default subjob: RUN
---   • Automatic subjob-based selection
---
--- @file    jobs/run/functions/RUN_LOCKSTYLE.lua
--- @author  Tetsouo
--- @version 2.0.0 - Factory Pattern
--- @date    Created: 2025-10-03
--- @requires utils/lockstyle/lockstyle_manager
---============================================================================
local LockstyleManager = require('shared/utils/lockstyle/lockstyle_manager')

-- Create RUN lockstyle module using factory
-- Exports: select_default_lockstyle(), cancel_pld_lockstyle_operations()
return LockstyleManager.create('RUN', -- job_code
'config/run/RUN_LOCKSTYLE', -- config_path
3, -- default_lockstyle
'RUN' -- default_subjob
)

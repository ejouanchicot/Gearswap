---============================================================================
--- BRD Lockstyle Module - Factory Pattern
---============================================================================
--- Applies lockstyle using centralized LockstyleManager factory.
--- Lockstyle varies by subjob (WHM, RDM, NIN, etc.)
---
--- @file jobs/brd/functions/BRD_LOCKSTYLE.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-13
---============================================================================

-- Load lockstyle factory
local LockstyleManager = require('shared/utils/lockstyle/lockstyle_manager')

-- Create BRD lockstyle module using factory
return LockstyleManager.create(
    'BRD', -- job_code
    'config/brd/BRD_LOCKSTYLE', -- config_path
    1, -- default_lockstyle (number)
    'WHM' -- default_subjob
)

---============================================================================
--- SAM Lockstyle Module - Factory Usage
---============================================================================
--- Uses LockstyleManager factory to handle lockstyle operations.
--- @file SAM_LOCKSTYLE.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-21
---============================================================================

local LockstyleManager = require('shared/utils/lockstyle/lockstyle_manager')

return LockstyleManager.create(
    'SAM',                          -- job_code
    'config/sam/SAM_LOCKSTYLE',     -- config_path
    2,                              -- default_lockstyle (number)
    'WAR'                           -- default_subjob
)

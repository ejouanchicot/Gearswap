---============================================================================
--- WHM Lockstyle Module - Factory Pattern Implementation
---============================================================================
--- Uses LockstyleManager factory to provide centralized lockstyle management.
--- Eliminates code duplication and ensures consistency across all jobs.
---
--- Configuration loaded from: config/whm/WHM_LOCKSTYLE.lua
---
--- @file WHM_LOCKSTYLE.lua
--- @author Tetsouo
--- @version 1.0.0
--- @date Created: 2025-10-21
--- @requires shared/utils/lockstyle/lockstyle_manager
---============================================================================

local LockstyleManager = require('shared/utils/lockstyle/lockstyle_manager')

-- Create lockstyle functions using factory pattern
return LockstyleManager.create(
    'WHM',                             -- job_code
    'config/whm/WHM_LOCKSTYLE',        -- config_path
    3,                                  -- default_lockstyle (from Timara: set 3)
    'RDM'                               -- default_subjob
)

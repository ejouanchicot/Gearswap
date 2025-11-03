---============================================================================
--- THF Lockstyle Module - Lockstyle Management (Factory Pattern)
---============================================================================
--- Handles lockstyle selection and application for Thief job using the
--- centralized LockstyleManager factory.
---
--- Features:
---   • Default lockstyle (1) for standard appearance
---   • Subjob-specific lockstyle overrides (configured in THF_LOCKSTYLE.lua)
---   • Automatic subjob detection and application
---   • 8-second delay respect (FFXI server cooldown)
---   • Factory pattern (zero duplication across jobs)
---
--- Dependencies:
---   • LockstyleManager (centralized factory)
---   • config/thf/THF_LOCKSTYLE.lua (lockstyle configuration)
---   • DressUp addon (FFXI lockstyle support)
---
--- @file    jobs/thf/functions/THF_LOCKSTYLE.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-06
---============================================================================

local LockstyleManager = require('shared/utils/lockstyle/lockstyle_manager')

-- Create THF lockstyle module using factory
return LockstyleManager.create(
    'THF',                          -- job_code
    'config/thf/THF_LOCKSTYLE',    -- config_path
    1,                              -- default_lockstyle
    'DNC'                           -- default_subjob
)

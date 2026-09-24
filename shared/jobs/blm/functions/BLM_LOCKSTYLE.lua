---  ═══════════════════════════════════════════════════════════════════════════
---   BLM Lockstyle Module - Lockstyle Management (Factory Pattern)
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles lockstyle selection and management for BLM job.
---   Uses centralized LockstyleManager factory for consistent behavior.
---
---   **PERFORMANCE OPTIMIZATION:**
---   • Lazy-loaded: Module created on first function call
---
---   @file    shared/jobs/blm/functions/BLM_LOCKSTYLE.lua
---   @author  Tetsouo
---   @version 2.1 - Lazy Loading for performance
---   @date    Created: 2025-10-13 | Updated: 2025-11-15
---   @requires shared/utils/lockstyle/lockstyle_manager
---  ═══════════════════════════════════════════════════════════════════════════

-- Lazy loading: Module created on first use
local LockstyleManager = nil
local lockstyle_module = nil

local function get_lockstyle_module()
    if not lockstyle_module then
        if not LockstyleManager then
            LockstyleManager = require('shared/utils/lockstyle/lockstyle_manager')
        end
        -- Character-aware config path (supports Tetsouo, Kaories, Hysoka, etc.)
        local char_name = (player and player.name) or 'Tetsouo'
        lockstyle_module = LockstyleManager.create(
            'BLM',                                            -- job_code
            char_name .. '/config/blm/BLM_LOCKSTYLE',         -- config_path
            1,                                                -- default_lockstyle
            'SAM'                                             -- default_subjob
        )
    end
    return lockstyle_module
end

--- Apply the lockstyle configured for the current subjob.
--- @return any Result of LockstyleManager's select_default_lockstyle
function select_default_lockstyle()
    return get_lockstyle_module().select_default_lockstyle()
end

--- Cancel any pending (delayed) lockstyle operation.
--- @return any Result of LockstyleManager's cancel function
function cancel_blm_lockstyle_operations()
    return get_lockstyle_module().cancel_blm_lockstyle_operations()
end

_G.select_default_lockstyle = select_default_lockstyle
_G.cancel_blm_lockstyle_operations = cancel_blm_lockstyle_operations

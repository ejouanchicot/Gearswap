---============================================================================
--- COR Lockstyle Module - Lockstyle Management (Factory Pattern)
---============================================================================
--- Handles lockstyle selection and management for COR job.
--- Uses centralized LockstyleManager factory for consistent behavior.
---
--- **PERFORMANCE OPTIMIZATION:**
---   • Lazy-loaded: Module created on first function call (saves ~30ms at startup)
---
--- @file    jobs/cor/functions/COR_LOCKSTYLE.lua
--- @author  Tetsouo
--- @version 2.1 - Lazy Loading for performance
--- @date    Created: 2025-10-13 | Updated: 2025-11-15
--- @requires utils/lockstyle/lockstyle_manager
---============================================================================

-- Lazy loading: Module created on first use
local LockstyleManager = nil
local lockstyle_module = nil

local function get_lockstyle_module()
    if not lockstyle_module then
        if not LockstyleManager then
            LockstyleManager = require('shared/utils/lockstyle/lockstyle_manager')
        end
        lockstyle_module = LockstyleManager.create(
            'COR',                           -- job_code
            'config/cor/COR_LOCKSTYLE', -- config_path
            1,                                -- default_lockstyle
            'SAM'                             -- default_subjob
        )
    end
    return lockstyle_module
end

-- Export select_default_lockstyle() to global scope
function select_default_lockstyle()
    return get_lockstyle_module().select_default_lockstyle()
end

-- Export cancel_cor_lockstyle_operations() to global scope
function cancel_cor_lockstyle_operations()
    return get_lockstyle_module().cancel_cor_lockstyle_operations()
end

_G.select_default_lockstyle = select_default_lockstyle
_G.cancel_cor_lockstyle_operations = cancel_cor_lockstyle_operations

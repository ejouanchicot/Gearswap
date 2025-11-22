---============================================================================
--- WAR Lockstyle Module - Lockstyle Management (Factory Pattern)
---============================================================================
--- Handles lockstyle selection and management for Warrior job.
--- Uses centralized LockstyleManager factory for consistent behavior.
---
--- **PERFORMANCE OPTIMIZATION:**
---   • Lazy-loaded: Module created on first function call (saves ~30ms at startup)
---
--- Configuration:
---   • Lockstyle definitions: config/war/WAR_LOCKSTYLE.lua
---   • Default lockstyle: #4
---   • Default subjob: SAM
---   • Automatic subjob-based selection
---
--- @file    jobs/war/functions/WAR_LOCKSTYLE.lua
--- @author  Tetsouo
--- @version 2.1 - Lazy Loading for performance
--- @date    Created: 2025-09-29 | Updated: 2025-11-15
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
            'WAR',                      -- job_code
            'config/war/WAR_LOCKSTYLE', -- config_path
            4,                          -- default_lockstyle
            'SAM'                       -- default_subjob
        )
    end
    return lockstyle_module
end

-- Export select_default_lockstyle() to global scope
function select_default_lockstyle()
    return get_lockstyle_module().select_default_lockstyle()
end

-- Export cancel_war_lockstyle_operations() to global scope
function cancel_war_lockstyle_operations()
    return get_lockstyle_module().cancel_war_lockstyle_operations()
end

_G.select_default_lockstyle = select_default_lockstyle
_G.cancel_war_lockstyle_operations = cancel_war_lockstyle_operations

---  ═══════════════════════════════════════════════════════════════════════════
---   SMN Lockstyle Module - Factory-backed lockstyle management
---  ═══════════════════════════════════════════════════════════════════════════
---   Uses centralized LockstyleManager factory for consistent behavior.
---   Lazy-loaded: module created on first function call.
---
---   @file    shared/jobs/smn/functions/SMN_LOCKSTYLE.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-28
---  ═══════════════════════════════════════════════════════════════════════════

local LockstyleManager = nil
local lockstyle_module = nil

local function get_lockstyle_module()
    if not lockstyle_module then
        if not LockstyleManager then
            LockstyleManager = require('shared/utils/lockstyle/lockstyle_manager')
        end
        lockstyle_module = LockstyleManager.create(
            'SMN',                       -- job_code
            'config/smn/SMN_LOCKSTYLE',  -- config_path
            1,                           -- default_lockstyle
            'WHM'                        -- default_subjob
        )
    end
    return lockstyle_module
end

function select_default_lockstyle()
    return get_lockstyle_module().select_default_lockstyle()
end

function cancel_smn_lockstyle_operations()
    return get_lockstyle_module().cancel_smn_lockstyle_operations()
end

_G.select_default_lockstyle = select_default_lockstyle
_G.cancel_smn_lockstyle_operations = cancel_smn_lockstyle_operations

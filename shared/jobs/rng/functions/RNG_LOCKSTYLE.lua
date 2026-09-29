---  ═══════════════════════════════════════════════════════════════════════════
---   RNG Lockstyle Module - Lockstyle Management (Factory Pattern)
---  ═══════════════════════════════════════════════════════════════════════════
---   LockstyleManager factory, built on first call.
---
---   @file    shared/jobs/rng/functions/RNG_LOCKSTYLE.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---   @requires shared/utils/lockstyle/lockstyle_manager
---  ═══════════════════════════════════════════════════════════════════════════

local LockstyleManager = nil
local lockstyle_module = nil

local function get_lockstyle_module()
    if not lockstyle_module then
        LockstyleManager = LockstyleManager or require('shared/utils/lockstyle/lockstyle_manager')
        lockstyle_module = LockstyleManager.create(
            'RNG',                       -- job_code
            'config/rng/RNG_LOCKSTYLE',  -- config_path
            1,                           -- default_lockstyle
            'WAR'                        -- default_subjob
        )
    end
    return lockstyle_module
end

--- Apply the lockstyle of the current subjob
function select_default_lockstyle()
    return get_lockstyle_module().select_default_lockstyle()
end

--- Cancel pending RNG lockstyle operations (job change)
function cancel_rng_lockstyle_operations()
    return get_lockstyle_module().cancel_rng_lockstyle_operations()
end

_G.select_default_lockstyle = select_default_lockstyle
_G.cancel_rng_lockstyle_operations = cancel_rng_lockstyle_operations

return {
    select_default_lockstyle = select_default_lockstyle,
    cancel_rng_lockstyle_operations = cancel_rng_lockstyle_operations,
}

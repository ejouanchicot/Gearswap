---  ═══════════════════════════════════════════════════════════════════════════
---   Global Probe - catches variables that escaped into _G
---  ═══════════════════════════════════════════════════════════════════════════
---   In Lua, assigning to a name that is neither a local nor a parameter
---   creates a global. It is valid, it compiles, and nothing reports it - so a
---   refactor that turns a shared local into something a helper writes to ends
---   up writing to _G instead, and the caller never sees the value.
---
---   That is not hypothetical: extracting a branch out of the COR roll tracker
---   did exactly this to `is_crooked`, and Crooked Cards silently stopped
---   carrying through a Double-Up. Nothing in the compiler, the call
---   comparison or in-game play showed it - only the numbers in a message were
---   wrong.
---
---   The probe snapshots _G once the systems are up, then reports whatever
---   appeared afterwards. Anything created during play that is not declared in
---   EXPECTED is something nobody meant to create.
---
---   @file    shared/utils/debug/global_probe.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-08-09
---  ═══════════════════════════════════════════════════════════════════════════

local GlobalProbe = {}

-- Globals the project creates on purpose after load. Anything else that turns
-- up is reported. Keep this list short: a name added here stops being checked.
local EXPECTED = {
    -- runtime state the systems publish as they go
    AltJobState = true, AltBuffState = true, AltBuffExpiry = true,
    AUTOMOVE_RUNNING = true, MidcastManagerDebugState = true,
    PrecastDebugState = true, UPDATE_DEBUG = true, AUTOMOVE_DEBUG = true,
    JOBCHANGE_DEBUG = true, WARP_DEBUG = true,
    suppress_cooldown_messages = true,
    -- Mote and GearSwap write these themselves
    sets = true, state = true, player = true, world = true, buffactive = true,
    classes = true, mote_include_version = true,
    -- our own caches
    __require_cache = true, __require_cache_installed = true,
    __require_cache_stats = true, __module_cache = true,
}

--- Remember what _G looked like once everything was loaded.
--- Called by INIT_SYSTEMS at the end of a load.
function GlobalProbe.snapshot()
    local seen = {}
    for k in pairs(_G) do
        seen[k] = true
    end
    _G.__global_baseline = seen
end

--- Globals that appeared since the snapshot and were not declared expected.
--- @return table Sorted list of names
function GlobalProbe.leaks()
    local baseline = rawget(_G, '__global_baseline')
    if not baseline then
        return nil
    end

    local found = {}
    for k, v in pairs(_G) do
        if type(k) == 'string' and not baseline[k] and not EXPECTED[k]
           and k:sub(1, 2) ~= '__' then
            -- A job hook is created when its module loads, which can be after
            -- the snapshot on a lazy path; those are named and legitimate.
            if not k:match('^job_') and not k:match('^user_') then
                found[#found + 1] = k .. ' (' .. type(v) .. ')'
            end
        end
    end
    table.sort(found)
    return found
end

--- Hooks Mote calls by name. A refactor that renames or drops one leaves the
--- job quietly doing nothing at that point in the cycle.
local REQUIRED_HOOKS = {
    'job_precast', 'job_midcast', 'job_post_midcast', 'job_aftercast',
    'job_status_change', 'job_buff_change', 'job_self_command',
}

--- Which of the hooks this job is missing.
--- @return table Names that are not functions right now
function GlobalProbe.missing_hooks()
    local missing = {}
    for _, name in ipairs(REQUIRED_HOOKS) do
        if type(rawget(_G, name)) ~= 'function' then
            missing[#missing + 1] = name
        end
    end
    return missing
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.GlobalProbe = GlobalProbe

return GlobalProbe

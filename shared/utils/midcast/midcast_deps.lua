---  ═══════════════════════════════════════════════════════════════════════════
---   Midcast Dependencies - Shared Lazy Loader
---  ═══════════════════════════════════════════════════════════════════════════
---   Seven jobs need the same two modules at midcast and nothing else:
---   MidcastManager to pick the set, and the enhancing database so an
---   Enhancing spell routes on its family rather than on its name.
---
---   Both are loaded on first call, not at file load, and kept for the rest of
---   the session. The database is large and a job may go a whole session
---   without casting anything that reads it.
---
---   @file    shared/utils/midcast/midcast_deps.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-08-09
---  ═══════════════════════════════════════════════════════════════════════════

local MidcastDeps = {}

local manager = nil
local enhancing = nil
local loaded = false

--- Load, once, the two modules a subjob-magic midcast needs.
--- Either may come back nil: a job that never casts the matching skill still
--- works, and the callers already treat a missing database as "no routing".
--- @return table|nil MidcastManager
--- @return table|nil ENHANCING_MAGIC_DATABASE
function MidcastDeps.load()
    if loaded then
        return manager, enhancing
    end

    local manager_ok, mm = pcall(require, 'shared/utils/midcast/midcast_manager')
    manager = manager_ok and mm or nil

    local enhancing_ok, db = pcall(require, 'shared/data/magic/ENHANCING_MAGIC_DATABASE')
    enhancing = enhancing_ok and db or nil

    loaded = true
    return manager, enhancing
end

return MidcastDeps

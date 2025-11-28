---  ═══════════════════════════════════════════════════════════════════════════
---   GEO Status Module - Player Status Change Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles status changes (Idle, Engaged, Resting, Dead, etc.)
---
---   @file    shared/jobs/geo/functions/GEO_STATUS.lua
---   @author  Tetsouo
---   @version 1.2 - Added DoomManager safety unlock
---   @date    Updated: 2025-11-14
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local DoomManager = nil

--- Handle status change events
--- @param newStatus string New status (Idle, Engaged, Resting, Dead, etc.)
--- @param oldStatus string Previous status
--- @param eventArgs table Event arguments
function job_status_change(newStatus, oldStatus, eventArgs)
    -- Lazy load DoomManager on first status change
    if not DoomManager then
        DoomManager = require('shared/utils/debuff/doom_manager')
    end

    -- Safety: Unlock Doom slots after death (prevents stuck locks after raise)
    DoomManager.handle_status_change(newStatus, oldStatus)

    -- GEO-specific status change logic can be added here
end

-- Export to global scope
_G.job_status_change = job_status_change

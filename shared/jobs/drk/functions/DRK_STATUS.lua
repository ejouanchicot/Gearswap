---  ═══════════════════════════════════════════════════════════════════════════
---   DRK Status Module - Player Status Change Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles status changes (Idle, Engaged, Resting, Dead, etc.)
---
---   @file    shared/jobs/drk/functions/DRK_STATUS.lua
---   @author  Tetsouo
---   @version 1.2 - Added DoomManager safety unlock
---   @date    Created: 2025-10-23 | Updated: 2025-11-14
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local DoomManager = nil

---   Handle status change events
---   @param newStatus string New status (Idle, Engaged, Resting, Dead, etc.)
---   @param oldStatus string Previous status
---   @param eventArgs table Event arguments
function job_status_change(newStatus, oldStatus, eventArgs)
    if not DoomManager then
        local ok, mod = pcall(require, 'shared/utils/debuff/doom_manager')
        if ok then DoomManager = mod end
    end

    -- Safety: Unlock Doom slots after death (prevents stuck locks after raise)
    DoomManager.handle_status_change(newStatus, oldStatus)
end

-- Export to global scope (used by Mote-Include via include())
_G.job_status_change = job_status_change

---  ═══════════════════════════════════════════════════════════════════════════
---   WAR Status Module - Status Change Handling
---  ═══════════════════════════════════════════════════════════════════════════
---   Status change hook for Warrior job: Doom slot safety unlock
---   (death/raise) through DoomManager. Mote-Include does the gear swaps.
---
---   **PERFORMANCE OPTIMIZATION:**
---   • Lazy-loaded: DoomManager loaded on first status change
---
---   @file    shared/jobs/war/functions/WAR_STATUS.lua
---   @author  Tetsouo
---   @version 1.2 - Lazy Loading for performance
---   @date    Updated: 2025-11-15
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local DoomManager = nil

---  ═══════════════════════════════════════════════════════════════════════════
---   STATUS CHANGE HOOK
---  ═══════════════════════════════════════════════════════════════════════════
---   Called when player status changes
---   Mote-Include handles idle/engaged/resting gear swaps; this hook only
---   lets DoomManager unlock Doom slots.
---
---   @param newStatus string New status ("Idle", "Engaged", "Resting", "Dead")
---   @param oldStatus string Previous status
---   @param eventArgs table Event arguments with handled flag
---   @return void
function job_status_change(newStatus, oldStatus, eventArgs)
    -- Lazy load DoomManager on first call
    if not DoomManager then
        local ok, mod = pcall(require, 'shared/utils/debuff/doom_manager')
        if ok then DoomManager = mod end
    end

    -- Safety: Unlock Doom slots after death (prevents stuck locks after raise)
    DoomManager.handle_status_change(newStatus, oldStatus)

end

-- Export to global scope
_G.job_status_change = job_status_change


---  ═══════════════════════════════════════════════════════════════════════════
---   WAR Status Module - Status Change Handling
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles player status changes for Warrior job:
---   • Player status transitions (Idle/Engaged/Resting/Dead)
---   • Combat state detection
---   • Status-based equipment swaps
---   • Doom slot safety unlock (death/raise)
---
---   **PERFORMANCE OPTIMIZATION:**
---   • Lazy-loaded: DoomManager loaded on first status change
---
---   @file    WAR_STATUS.lua
---   @author  Tetsouo
---   @version 1.2 - Lazy Loading for performance
---   @date    Updated: 2025-11-15
---   @requires Tetsouo architecture
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local DoomManager = nil

---  ═══════════════════════════════════════════════════════════════════════════
---   STATUS CHANGE HOOK
---  ═══════════════════════════════════════════════════════════════════════════
---   Called when player status changes
---   Mote-Include automatically handles idle/engaged/resting gear swaps.
---   WAR currently doesn't need custom status change logic.
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


---============================================================================
--- WAR Status Module - Status Change Handling
---============================================================================
--- Handles player status changes for Warrior job:
---   • Player status transitions (Idle/Engaged/Resting/Dead)
---   • Combat state detection
---   • Status-based equipment swaps
---   • Doom slot safety unlock (death/raise)
---
--- **PERFORMANCE OPTIMIZATION:**
---   • Lazy-loaded: DoomManager loaded on first status change (saves ~30ms at startup)
---
--- @file    WAR_STATUS.lua
--- @author  Tetsouo
--- @version 1.2 - Lazy Loading for performance
--- @date    Updated: 2025-11-15
--- @requires Tetsouo architecture
---============================================================================

-- Lazy loading: DoomManager loaded on first status change
local DoomManager = nil

---============================================================================
--- STATUS CHANGE HOOK
---============================================================================
--- Called when player status changes
--- Mote-Include automatically handles idle/engaged/resting gear swaps.
--- WAR currently doesn't need custom status change logic.
---
--- @param newStatus string New status ("Idle", "Engaged", "Resting", "Dead")
--- @param oldStatus string Previous status
--- @param eventArgs table Event arguments with handled flag
--- @return void
function job_status_change(newStatus, oldStatus, eventArgs)
    -- Lazy load DoomManager on first call
    if not DoomManager then
        DoomManager = require('shared/utils/debuff/doom_manager')
    end

    -- Safety: Unlock Doom slots after death (prevents stuck locks after raise)
    DoomManager.handle_status_change(newStatus, oldStatus)

    -- WAR-specific status change logic here
    -- Examples:
    --   • Cancel buffs on death
    --   • Auto-rebuff on resurrection
    --   • Status-specific gear adjustments

    -- Currently: Mote handles all status transitions
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.job_status_change = job_status_change

-- Export as module (for future require() usage)
return {
    job_status_change = job_status_change
}

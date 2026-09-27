---  ═══════════════════════════════════════════════════════════════════════════
---   BRD Movement Management Module
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles movement-based gear management for Bard.
---   Uses centralized AutoMove position tracking for performance.
---
---   @file    shared/jobs/brd/functions/BRD_MOVEMENT.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2025-10-13
---   @requires shared/utils/movement/automove.lua
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   GEAR HOOK
---  ═══════════════════════════════════════════════════════════════════════════

---   Handle equipping gear during movement
---   @param playerStatus string Current player status
---   @param eventArgs table Event arguments
function job_handle_equipping_gear(playerStatus, eventArgs)
    -- CRITICAL: Protect instrument lock - maintain locked instrument throughout cast
    if _G.casting_locked_song and _G.locked_instrument then
        -- Force locked instrument to stay equipped during song cast
        equip({range = _G.locked_instrument})
        return
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- The explicit _G export below was disabled because the hook was meant to stay
-- unregistered (it interfered with the warp ring fix). Note that the
-- `function job_handle_equipping_gear` declaration above already defines it as
-- a global of the job sandbox, so Mote does see it (docs/dev/jobs/brd.md,
-- Known issues).
-- _G.job_handle_equipping_gear = job_handle_equipping_gear

---  ═══════════════════════════════════════════════════════════════════════════
---   BLM Movement Management Module
---  ═══════════════════════════════════════════════════════════════════════════
---   Keeps Twilight Cloak on through an Impact cast (job_handle_equipping_gear).
---   AutoMove tracks movement for every job (INIT_SYSTEMS).
---
---   @file    shared/jobs/blm/functions/BLM_MOVEMENT.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2025-10-15
---   @requires shared/utils/movement/automove.lua
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   GEAR HOOK
---  ═══════════════════════════════════════════════════════════════════════════

---   Handle equipping gear during movement
---   @param playerStatus string Current player status
---   @param eventArgs table Event arguments
function job_handle_equipping_gear(playerStatus, eventArgs)
    -- CRITICAL: Protect Impact body lock - maintain Twilight Cloak throughout cast
    -- (Same pattern as BRD instrument lock for Marsyas)
    if _G.casting_impact and _G.impact_body then
        -- Force Twilight Cloak to stay equipped during Impact cast
        equip({body = _G.impact_body})
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_handle_equipping_gear = job_handle_equipping_gear


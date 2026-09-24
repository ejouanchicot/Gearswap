---  ═══════════════════════════════════════════════════════════════════════════
---   BST Movement Module - Movement Gear Handling
---  ═══════════════════════════════════════════════════════════════════════════
---   Movement hook for Beastmaster. Nothing to do here: AutoMove tracks
---   movement (state.Moving) and SetBuilder.build_idle_set adds sets.MoveSpeed.
---
---   @file    shared/jobs/bst/functions/BST_MOVEMENT.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-17
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   AUTOMOVE INTEGRATION (PERFORMANCE OPTIMIZED - No Startup Cost)
---  ═══════════════════════════════════════════════════════════════════════════
-- AutoMove (if available) handles movement detection. The speed gear
-- (sets.MoveSpeed) is applied in SetBuilder.build_idle_set() while
-- state.Moving is "true".

---  ═══════════════════════════════════════════════════════════════════════════
---   MOVEMENT GEAR HOOK
---  ═══════════════════════════════════════════════════════════════════════════

---   Called when equipping gear (before actual equip)
---   Not needed for BST - SetBuilder handles movement gear in build_idle_set()
---
---   @param playerStatus string Player status ("Idle", "Engaged", etc.)
---   @param eventArgs table Event arguments (not used)
---   @return void
function job_handle_equipping_gear(playerStatus, eventArgs)
    -- Movement gear handled by SetBuilder.build_idle_set()
    -- No additional logic required
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export globally for GearSwap
_G.job_handle_equipping_gear = job_handle_equipping_gear


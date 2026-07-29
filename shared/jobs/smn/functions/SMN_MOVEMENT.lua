---  ═══════════════════════════════════════════════════════════════════════════
---   SMN Movement Module
---  ═══════════════════════════════════════════════════════════════════════════
---   AutoMove (loaded via INIT_SYSTEMS) handles movement gear automatically
---   through state.Moving + sets.MoveSpeed. No SMN-specific logic required.
---
---   @file    shared/jobs/smn/functions/SMN_MOVEMENT.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-28
---  ═══════════════════════════════════════════════════════════════════════════

function job_handle_equipping_gear(playerStatus, eventArgs)
    -- AutoMove handles MoveSpeed swap. No additional logic.
end

_G.job_handle_equipping_gear = job_handle_equipping_gear

---  ═══════════════════════════════════════════════════════════════════════════
---   SMN Movement Module
---  ═══════════════════════════════════════════════════════════════════════════
---   AutoMove (loaded via INIT_SYSTEMS) sets state.Moving and sends
---   `gs c update`; SMN_IDLE lays sets.MoveSpeed over the idle set.
---   No SMN-specific logic required here.
---
---   @file    shared/jobs/smn/functions/SMN_MOVEMENT.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-28
---  ═══════════════════════════════════════════════════════════════════════════

function job_handle_equipping_gear(playerStatus, eventArgs)
    -- MoveSpeed is applied in customize_idle_set (SMN_IDLE). No additional logic.
end

_G.job_handle_equipping_gear = job_handle_equipping_gear

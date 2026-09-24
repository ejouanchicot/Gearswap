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

--- Mote hook called before gear is equipped. Empty: MoveSpeed is applied in
--- customize_idle_set (SMN_IDLE).
--- @param playerStatus string Current player status
--- @param eventArgs table Event arguments
function job_handle_equipping_gear(playerStatus, eventArgs)
end

_G.job_handle_equipping_gear = job_handle_equipping_gear

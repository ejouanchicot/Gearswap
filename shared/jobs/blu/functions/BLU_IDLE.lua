---  ═══════════════════════════════════════════════════════════════════════════
---   BLU Idle Module - Idle State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   customize_idle_set delegates to logic/set_builder.lua: IdleMode, town,
---   weapons, movement speed.
---
---   @file    shared/jobs/blu/functions/BLU_IDLE.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-09-26
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = nil

--- Build the idle set (Mote hook)
--- @param idleSet table The idle set Mote built
--- @return table Modified idle set
function customize_idle_set(idleSet)
    if not SetBuilder then
        SetBuilder = require('shared/jobs/blu/functions/logic/set_builder')
    end
    if not idleSet then
        return {}
    end
    return SetBuilder.build_idle_set(idleSet)
end

_G.customize_idle_set = customize_idle_set

return { customize_idle_set = customize_idle_set }

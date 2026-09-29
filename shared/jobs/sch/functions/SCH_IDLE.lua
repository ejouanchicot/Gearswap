---  ═══════════════════════════════════════════════════════════════════════════
---   SCH Idle Module - Idle State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   customize_idle_set delegates to logic/set_builder.lua: town or
---   HybridMode idle, Sublimation while it charges, weapons, movement speed.
---
---   @file    shared/jobs/sch/functions/SCH_IDLE.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = nil

--- Build the idle set (Mote hook)
--- @param idleSet table The idle set Mote built
--- @return table Modified idle set
function customize_idle_set(idleSet)
    if not SetBuilder then
        SetBuilder = require('shared/jobs/sch/functions/logic/set_builder')
    end
    if not idleSet then
        return {}
    end
    return SetBuilder.build_idle_set(idleSet)
end

_G.customize_idle_set = customize_idle_set

return { customize_idle_set = customize_idle_set }

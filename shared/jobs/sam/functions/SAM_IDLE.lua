---============================================================================
--- SAM Idle Module - Idle Gear Customization
---============================================================================
--- Handles idle state logic for Samurai with dynamic gear selection.
--- Uses SetBuilder for centralized set construction.
--- @file SAM_IDLE.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-21
---============================================================================

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Load set builder (centralized logic)
local SetBuilder = require('shared/jobs/sam/functions/logic/set_builder')

---============================================================================
--- IDLE HOOK
---============================================================================

--- Apply weapon sets and status-based variations to idle configuration
--- @param idleSet table The idle set to customize
--- @return table Modified idle set with current weapon and status gear
function customize_idle_set(idleSet)
    return SetBuilder.build_idle_set(idleSet)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

_G.customize_idle_set = customize_idle_set

local SAM_IDLE = {}
SAM_IDLE.customize_idle_set = customize_idle_set

return SAM_IDLE

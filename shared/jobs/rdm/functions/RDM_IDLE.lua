---============================================================================
--- RDM Idle Module - Idle State Management
---============================================================================
--- Handles all idle state logic for Red Mage job:
--- - Idle set selection based on IdleMode (DT, Refresh, Regain, Evasion)
--- - Movement speed optimization
--- - Town gear management
--- - Dynamic weapon application to idle sets
---
--- @file RDM_IDLE.lua
--- @author Tetsouo
--- @version 2.0 - Logic Extracted to logic/
--- @date Created: 2025-10-12
--- @date Updated: 2025-10-13
--- @requires Tetsouo architecture
---============================================================================

-- Load RDM logic modules
local SetBuilder = require('shared/jobs/rdm/functions/logic/set_builder')

---============================================================================
--- IDLE HOOKS
---============================================================================

--- Apply weapon sets, mode selection, and movement gear to all idle configurations
--- @param idleSet table The idle set to customize
--- @return table Modified idle set with current weapon, mode, and movement gear
function customize_idle_set(idleSet)
    if not idleSet then
        return {}
    end

    return SetBuilder.build_idle_set(idleSet)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Make functions available globally for GearSwap
_G.customize_idle_set = customize_idle_set

-- Also export as module
local RDM_IDLE = {}
RDM_IDLE.customize_idle_set = customize_idle_set

return RDM_IDLE

---============================================================================
--- WHM Idle Module - Idle Gear Customization
---============================================================================
--- Handles idle gear selection for White Mage:
---   • Base idle gear (Refresh/Regen priority)
---   • PDT mode support (defense priority)
---   • Town detection (town-specific idle gear)
---   • Movement speed gear integration
---   • MP recovery optimization
---
--- @file WHM_IDLE.lua
--- @author Tetsouo
--- @version 1.0.0
--- @date Created: 2025-10-21
---============================================================================

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Load set builder (centralized logic)
local SetBuilder = require('shared/jobs/whm/functions/logic/set_builder')

---============================================================================
--- IDLE CUSTOMIZATION HOOK
---============================================================================

--- Customize idle gear based on conditions
--- Called by Mote-Include when idle set is selected.
---
--- Processing order:
---   1. Detect town mode (use town set if in town)
---   2. Apply MP recovery gear if MP < 51%
---   3. Apply movement speed gear if moving
---
--- @param idleSet table The base idle set from whm_sets.lua
--- @return table Modified idle set with customizations applied
function customize_idle_set(idleSet)
    return SetBuilder.build_idle_set(idleSet)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.customize_idle_set = customize_idle_set

-- Export as module
return {
    customize_idle_set = customize_idle_set
}

---============================================================================
--- RUN Idle Module - Idle State Management
---============================================================================
--- Handles all idle state logic for Rune Fencer job:
---   • Idle set selection based on conditions
---   • Movement speed optimization
---   • Dynamic weapon application to idle sets
---   • Town gear management
---
--- Delegates to SetBuilder (logic module) for shared construction logic.
---
--- @file    jobs/run/functions/RUN_IDLE.lua
--- @author  Tetsouo
--- @version 4.0.0 - Logic Extracted to logic/set_builder.lua
--- @date    Created: 2025-10-03 | Updated: 2025-10-06
--- @requires jobs/run/functions/logic/set_builder
---============================================================================
---============================================================================
--- DEPENDENCIES
---============================================================================
-- Load shared set construction logic
local SetBuilder = require('shared/jobs/run/functions/logic/set_builder')

---============================================================================
--- IDLE CUSTOMIZATION HOOK
---============================================================================

--- Apply weapon sets and movement gear to idle configuration
--- Called by Mote-Include when idle set is selected.
---
--- Processing order:
---   1. Apply current weapon set (state.MainWeapon/SubWeapon)
---   2. Apply movement gear if moving
---   3. Apply hybrid mode gear (PDT/MDT)
---
--- @param idleSet table The base idle set from pld_sets.lua
--- @return table Modified idle set with weapon/movement/hybrid gear applied
function customize_idle_set(idleSet)
    if not idleSet then
        return {}
    end

    -- Delegate to SetBuilder for shared logic
    return SetBuilder.build_idle_set(idleSet)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.customize_idle_set = customize_idle_set

-- Export as module (for future require() usage)
return {
    customize_idle_set = customize_idle_set
}

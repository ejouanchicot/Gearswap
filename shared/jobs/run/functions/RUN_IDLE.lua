---============================================================================
--- RUN Idle Module - Idle State Management
---============================================================================
--- Handles all idle state logic for Rune Fencer job:
---   • Idle set selection based on conditions
---   • Movement speed optimization
---   • Dynamic weapon application to idle sets
---   • Dynamic grip application to idle sets
---   • Town gear management
---
--- Delegates to SetBuilder (logic module) for shared construction logic.
---
--- @file    jobs/run/functions/RUN_IDLE.lua
--- @author  Tetsouo
--- @version 5.0.0 - Updated for RUN weapons (Great Swords + Grips)
--- @date    Created: 2025-10-03 | Updated: 2025-11-04
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
---   1. Town detection (use sets.idle.Town if in town)
---   2. Apply current weapon set (state.MainWeapon: Epeolatry/Lionheart/Aettir)
---   3. Apply current grip (state.SubWeapon: Utu/Refined)
---   4. Apply hybrid mode gear (PDT/MDT) if not in town
---   5. Apply movement gear if moving
---
--- @param idleSet table The base idle set from run_sets.lua
--- @return table Modified idle set with weapon/grip/movement/hybrid gear applied
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

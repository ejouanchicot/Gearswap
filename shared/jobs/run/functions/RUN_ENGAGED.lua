---============================================================================
--- RUN Engaged Module - Combat State Management
---============================================================================
--- Handles all engaged (combat) state logic for Rune Fencer job:
---   • Combat set selection based on HybridMode (PDT/MDT)
---   • Dynamic weapon application to engaged sets
---   • Dynamic grip application to engaged sets
---   • Combat state transitions
---
--- Delegates to SetBuilder (logic module) for shared construction logic.
---
--- @file    jobs/run/functions/RUN_ENGAGED.lua
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
--- ENGAGED CUSTOMIZATION HOOK
---============================================================================

--- Apply weapon sets and hybrid mode to engaged configuration
--- Called by Mote-Include when engaged set is selected.
---
--- Processing order:
---   1. Apply current weapon set (state.MainWeapon: Epeolatry/Lionheart/Aettir)
---   2. Apply current grip (state.SubWeapon: Utu/Refined)
---   3. Apply HybridMode (PDT/MDT)
---
--- @param meleeSet table The base engaged set from run_sets.lua
--- @return table Modified engaged set with weapon/grip/hybrid gear applied
function customize_melee_set(meleeSet)
    if not meleeSet then
        return {}
    end

    -- Delegate to SetBuilder for shared logic
    return SetBuilder.build_engaged_set(meleeSet)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.customize_melee_set = customize_melee_set

-- Export as module (for future require() usage)
return {
    customize_melee_set = customize_melee_set
}

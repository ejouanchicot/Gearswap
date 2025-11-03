---============================================================================
--- PLD Engaged Module - Combat State Management
---============================================================================
--- Handles all engaged (combat) state logic for Paladin job:
---   • Combat set selection based on HybridMode (PDT/MDT/Normal)
---   • Dynamic weapon application to engaged sets
---   • XP mode support
---   • Combat state transitions
---
--- Delegates to SetBuilder (logic module) for shared construction logic.
---
--- @file    jobs/pld/functions/PLD_ENGAGED.lua
--- @author  Tetsouo
--- @version 4.0.0 - Logic Extracted to logic/set_builder.lua
--- @date    Created: 2025-10-03 | Updated: 2025-10-06
--- @requires jobs/pld/functions/logic/set_builder
---============================================================================
---============================================================================
--- DEPENDENCIES
---============================================================================
-- Load shared set construction logic
local SetBuilder = require('shared/jobs/pld/functions/logic/set_builder')

---============================================================================
--- ENGAGED CUSTOMIZATION HOOK
---============================================================================

--- Apply weapon sets and movement gear to engaged configuration
--- Called by Mote-Include when engaged set is selected.
---
--- Processing order:
---   1. Apply current weapon set (state.MainWeapon/SubWeapon)
---   2. Apply HybridMode (PDT/MDT/Normal)
---   3. Apply movement gear if moving during combat
---   4. Apply XP mode adjustments if enabled
---
--- @param meleeSet table The base engaged set from pld_sets.lua
--- @return table Modified engaged set with weapon/hybrid/movement gear applied
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

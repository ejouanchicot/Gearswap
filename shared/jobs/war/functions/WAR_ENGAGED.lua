---============================================================================
--- WAR Engaged Module - Combat State Management
---============================================================================
--- Handles all engaged (combat) state logic for Warrior job:
---   • Combat set selection based on HybridMode (PDT/Normal)
---   • Aftermath Lv.3 detection and optimization
---   • Dynamic weapon application to engaged sets
---   • Combat state transitions
---
--- Delegates to SetBuilder (logic module) for shared construction logic.
---
--- @file    WAR_ENGAGED.lua
--- @author  Tetsouo
--- @version 2.0 - Logic Extracted to logic/set_builder.lua
--- @date    Created: 2025-09-29 | Updated: 2025-10-06
--- @requires jobs/war/functions/logic/set_builder
---============================================================================
---============================================================================
--- DEPENDENCIES
---============================================================================
-- Load shared set construction logic
local SetBuilder = require('shared/jobs/war/functions/logic/set_builder')

---============================================================================
--- ENGAGED CUSTOMIZATION HOOK
---============================================================================

--- Apply weapon sets and movement gear to engaged configuration
--- Called by Mote-Include when engaged set is selected.
---
--- Processing order:
---   1. Apply current weapon set (state.MainWeapon)
---   2. Apply HybridMode (PDT/Normal)
---   3. Apply movement gear if moving during combat
---   4. Detect Aftermath Lv.3 and apply AM3 gear if active
---
--- @param meleeSet table The base engaged set from war_sets.lua
--- @return table Modified engaged set with weapon/hybrid/movement/AM3 gear applied
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

---============================================================================
--- RDM Engaged Module - Combat State Management
---============================================================================
--- Handles all engaged state logic for Red Mage job:
--- - Combat set selection based on EngagedMode (DT, Enspell, Refresh, TP)
--- - Dualwield detection and optimization (NIN subjob)
--- - Dynamic weapon application to engaged sets
--- - Combat state transitions
---
--- @file RDM_ENGAGED.lua
--- @author Tetsouo
--- @version 2.0 - Logic Extracted to logic/
--- @date Created: 2025-10-12
--- @date Updated: 2025-10-13
--- @requires Tetsouo architecture
---============================================================================

-- Load RDM logic modules
local SetBuilder = require('shared/jobs/rdm/functions/logic/set_builder')

---============================================================================
--- ENGAGED HOOKS
---============================================================================

--- Apply weapon sets, mode selection, and movement gear to all engaged configurations
--- @param meleeSet table The engaged set to customize
--- @return table Modified engaged set with current weapon, mode, and movement gear
function customize_melee_set(meleeSet)
    if not meleeSet then
        return {}
    end

    return SetBuilder.build_engaged_set(meleeSet)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Make customize_melee_set available globally for GearSwap
_G.customize_melee_set = customize_melee_set

-- Also export as module
local RDM_ENGAGED = {}
RDM_ENGAGED.customize_melee_set = customize_melee_set

return RDM_ENGAGED

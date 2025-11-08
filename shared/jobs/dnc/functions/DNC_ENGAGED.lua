---============================================================================
--- DNC Engaged Module - Combat State Management
---============================================================================
--- Handles all engaged state logic for Dancer job with dynamic gear selection.
---
--- Features:
---   • Combat set selection based on HybridMode (PDT/Normal)
---   • Dynamic weapon application to engaged sets (Mpu Gandring/Demersal)
---   • Combat state transitions (idle >> engaged)
---   • Dual Wield tier optimization (automatic DW cap calculation)
---   • SetBuilder integration for modular set construction
---   • Fan Dance buff integration (20% DT)
---
--- Dependencies:
---   • SetBuilder (logic) - shared engaged set construction
---
--- @file    DNC_ENGAGED.lua
--- @author  Tetsouo
--- @version 2.0 - Logic Extracted to logic/
--- @date    Created: 2025-10-04
--- @date    Updated: 2025-10-06
---============================================================================

-- Load DNC logic modules
local SetBuilder = require('shared/jobs/dnc/functions/logic/set_builder')

---============================================================================
--- ENGAGED HOOKS
---============================================================================

--- Apply weapon sets and movement gear to all engaged configurations
--- @param meleeSet table The engaged set to customize
--- @return table Modified engaged set with current weapon and movement gear
function customize_melee_set(meleeSet)
    -- Validate input
    if not meleeSet then
        return {}
    end

    -- Build complete engaged set using SetBuilder logic
    return SetBuilder.build_engaged_set(meleeSet)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Make customize_melee_set available globally for GearSwap
_G.customize_melee_set = customize_melee_set

-- Also export as module for potential future use
local DNC_ENGAGED = {}
DNC_ENGAGED.customize_melee_set = customize_melee_set

return DNC_ENGAGED

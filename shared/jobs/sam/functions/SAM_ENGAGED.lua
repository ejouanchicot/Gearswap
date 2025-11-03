---============================================================================
--- SAM Engaged Module - Melee Gear Customization
---============================================================================
--- Handles engaged state logic for Samurai with dynamic gear selection.
--- Uses SetBuilder for centralized set construction.
--- @file SAM_ENGAGED.lua
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
--- ENGAGED HOOK
---============================================================================

--- Apply weapon sets, HybridMode, and buff-based variations to engaged configuration
--- @param meleeSet table The engaged set to customize
--- @return table Modified engaged set with current weapon, hybrid mode, and buffs
function customize_melee_set(meleeSet)
    return SetBuilder.build_engaged_set(meleeSet)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

_G.customize_melee_set = customize_melee_set

local SAM_ENGAGED = {}
SAM_ENGAGED.customize_melee_set = customize_melee_set

return SAM_ENGAGED

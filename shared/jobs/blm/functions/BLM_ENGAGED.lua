---============================================================================
--- BLM Engaged Module - Engaged Gear Customization
---============================================================================
--- Handles engaged (melee) gear selection for Black Mage job.
--- Applies set_builder logic for dynamic gear construction.
---
--- @file BLM_ENGAGED.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-15
---============================================================================

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Load set builder (shared logic module)
local set_builder_success, SetBuilder = pcall(require, 'shared/jobs/blm/functions/logic/set_builder')

---============================================================================
--- ENGAGED HOOKS
---============================================================================

function customize_melee_set(meleeSet)
    -- BLM-SPECIFIC ENGAGED CUSTOMIZATION

    -- Use set_builder if available
    if set_builder_success and SetBuilder and SetBuilder.build_engaged_set then
        return SetBuilder.build_engaged_set(meleeSet)
    end

    -- Fallback: return meleeSet as-is
    return meleeSet
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export global for GearSwap (Mote-Include)
_G.customize_melee_set = customize_melee_set

-- Export module
local BLM_ENGAGED = {}
BLM_ENGAGED.customize_melee_set = customize_melee_set

return BLM_ENGAGED

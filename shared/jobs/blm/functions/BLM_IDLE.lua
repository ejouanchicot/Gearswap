---============================================================================
--- BLM Idle Module - Idle Gear Customization
---============================================================================
--- Handles idle gear selection for Black Mage job.
--- Applies set_builder logic for dynamic gear construction.
---
--- @file BLM_IDLE.lua
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
--- IDLE HOOKS
---============================================================================

function customize_idle_set(idleSet)
    -- BLM-SPECIFIC IDLE CUSTOMIZATION

    -- Use set_builder if available
    if set_builder_success and SetBuilder and SetBuilder.build_idle_set then
        return SetBuilder.build_idle_set(idleSet)
    end

    -- Fallback: return idleSet as-is
    return idleSet
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export global for GearSwap (Mote-Include)
_G.customize_idle_set = customize_idle_set

-- Export module
local BLM_IDLE = {}
BLM_IDLE.customize_idle_set = customize_idle_set

return BLM_IDLE

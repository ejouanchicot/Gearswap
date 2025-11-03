---============================================================================
--- COR Idle Module - Idle Gear Management
---============================================================================
--- Handles idle gear customization for Corsair job based on conditions.
--- Customizes idle gear based on buffs, location, time of day, etc.
---
--- @file COR_IDLE.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-07
---============================================================================

-- Load COR logic modules
local SetBuilder = require('shared/jobs/cor/functions/logic/set_builder')

---============================================================================
--- IDLE HOOKS
---============================================================================

--- Customize idle set before it's equipped
--- @param idleSet table The idle equipment set
--- @return table Modified idle set
function customize_idle_set(idleSet)
    if not idleSet then
        return {}
    end

    -- Apply weapon sets, hybrid mode, and refresh gear via SetBuilder
    return SetBuilder.build_idle_set(idleSet)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export global for GearSwap (Mote-Include)
_G.customize_idle_set = customize_idle_set

-- Export module
local COR_IDLE = {}
COR_IDLE.customize_idle_set = customize_idle_set

return COR_IDLE

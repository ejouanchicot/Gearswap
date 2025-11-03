---============================================================================
--- GEO Idle Module - Idle Gear Management
---============================================================================
--- Handles idle gear customization for Geomancer job based on conditions.
--- Customizes idle gear based on buffs, location, pet active, etc.
---
--- @file GEO_IDLE.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-09
---============================================================================

-- Load GEO logic modules
local set_builder_success, SetBuilder = pcall(require, 'shared/jobs/geo/functions/logic/set_builder')
if not set_builder_success then
    SetBuilder = nil
end

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
    if SetBuilder then
        return SetBuilder.build_idle_set(idleSet)
    end

    return idleSet
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export global for GearSwap (Mote-Include)
_G.customize_idle_set = customize_idle_set

-- Export module
local GEO_IDLE = {}
GEO_IDLE.customize_idle_set = customize_idle_set

return GEO_IDLE

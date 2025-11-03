---============================================================================
--- GEO Engaged Module - Combat Gear Management
---============================================================================
--- Handles combat gear customization for Geomancer job based on conditions.
--- Customizes melee gear based on buffs, weapon type, etc.
---
--- @file GEO_ENGAGED.lua
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
--- ENGAGED HOOKS
---============================================================================

--- Customize melee set before it's equipped
--- @param meleeSet table The combat equipment set
--- @return table Modified combat set
function customize_melee_set(meleeSet)
    if not meleeSet then
        return {}
    end

    -- Apply weapon sets, hybrid mode, and DW gear via SetBuilder
    if SetBuilder then
        return SetBuilder.build_engaged_set(meleeSet)
    end

    return meleeSet
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export global for GearSwap (Mote-Include)
_G.customize_melee_set = customize_melee_set

-- Export module
local GEO_ENGAGED = {}
GEO_ENGAGED.customize_melee_set = customize_melee_set

return GEO_ENGAGED

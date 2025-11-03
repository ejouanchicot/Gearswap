---============================================================================
--- WHM Engaged Module - Combat Gear Customization
---============================================================================
--- Handles engaged (melee) gear selection for White Mage:
---   • Base melee gear (rare for WHM but supported)
---   • Weapon lock management (when OffenseMode = 'Melee ON')
---   • Hybrid mode support (PDT during combat)
---
--- Uses SetBuilder for centralized set construction.
--- @file WHM_ENGAGED.lua
--- @author Tetsouo
--- @version 1.0.0
--- @date Created: 2025-10-21
---============================================================================

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Load set builder (centralized logic)
local SetBuilder = require('shared/jobs/whm/functions/logic/set_builder')

---============================================================================
--- ENGAGED CUSTOMIZATION HOOK
---============================================================================

--- Customize engaged gear based on conditions
--- Called by Mote-Include when engaged set is selected.
---
--- @param meleeSet table The base engaged set from whm_sets.lua
--- @return table Modified engaged set
function customize_melee_set(meleeSet)
    return SetBuilder.build_engaged_set(meleeSet)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.customize_melee_set = customize_melee_set

-- Export as module
return {
    customize_melee_set = customize_melee_set
}

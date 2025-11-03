---============================================================================
--- COR Engaged Module - Combat Gear Management
---============================================================================
--- Handles combat gear customization for Corsair job based on conditions.
--- Customizes melee gear based on buffs, weapon type, dual wield, etc.
---
--- @file COR_ENGAGED.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-07
---============================================================================

-- Load COR logic modules
local SetBuilder = require('shared/jobs/cor/functions/logic/set_builder')

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
    return SetBuilder.build_engaged_set(meleeSet)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export global for GearSwap (Mote-Include)
_G.customize_melee_set = customize_melee_set

-- Export module
local COR_ENGAGED = {}
COR_ENGAGED.customize_melee_set = customize_melee_set

return COR_ENGAGED

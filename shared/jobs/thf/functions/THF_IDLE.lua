---============================================================================
--- THF Idle Module - Idle State Management
---============================================================================
--- Handles idle gear selection and customization for Thief job.
---
--- Features:
---   • Dynamic idle set selection (Normal/PDT/Town)
---   • Weapon set application (MainWeapon + SubWeapon states)
---   • Movement speed gear (MoveSpeed set)
---   • Town detection (Adoulin vs regular cities)
---   • SetBuilder integration for modular construction
---
--- Dependencies:
---   • Mote-Include (provides base idle handling)
---   • SetBuilder logic (constructs final idle sets)
---   • sets.idle (base equipment sets)
---
--- @file    jobs/thf/functions/THF_IDLE.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-06
---============================================================================

-- Load THF logic modules
local SetBuilder = require('shared/jobs/thf/functions/logic/set_builder')

---============================================================================
--- IDLE HOOKS
---============================================================================

--- Apply weapon sets and movement gear to all idle configurations
--- @param idleSet table The idle set to customize
--- @return table Modified idle set with current weapon and movement gear
function customize_idle_set(idleSet)
    if not idleSet then
        return {}
    end

    return SetBuilder.build_idle_set(idleSet)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Make functions available globally for GearSwap
_G.customize_idle_set = customize_idle_set

-- Also export as module
local THF_IDLE = {}
THF_IDLE.customize_idle_set = customize_idle_set

return THF_IDLE

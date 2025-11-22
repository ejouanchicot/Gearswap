---============================================================================
--- WAR Idle Module - Idle State Management
---============================================================================
--- Handles all idle state logic for Warrior job:
---   • Idle set selection based on conditions
---   • Movement speed optimization
---   • Dynamic weapon application to idle sets
---   • Town gear management
---
--- **PERFORMANCE OPTIMIZATION:**
---   • Lazy-loaded: SetBuilder loaded on first idle event (saves ~50ms at startup)
---
--- Delegates to SetBuilder (logic module) for shared construction logic.
---
--- @file    WAR_IDLE.lua
--- @author  Tetsouo
--- @version 2.1 - Lazy Loading for performance
--- @date    Created: 2025-09-29 | Updated: 2025-11-15
--- @requires jobs/war/functions/logic/set_builder
---============================================================================
---============================================================================
--- DEPENDENCIES (LAZY LOADING for performance)
---============================================================================
-- SetBuilder loaded on first idle event (saves ~50ms at startup)
local SetBuilder = nil

---============================================================================
--- IDLE CUSTOMIZATION HOOK
---============================================================================

--- Apply weapon sets and movement gear to idle configuration
--- Called by Mote-Include when idle set is selected.
---
--- Processing order:
---   1. Apply current weapon set (state.MainWeapon)
---   2. Apply movement gear if moving
---   3. Detect Aftermath Lv.3 and apply AM3 gear if active
---
--- @param idleSet table The base idle set from war_sets.lua
--- @return table Modified idle set with weapon/movement/AM3 gear applied
function customize_idle_set(idleSet)
    -- Lazy load SetBuilder on first call
    if not SetBuilder then
        SetBuilder = require('shared/jobs/war/functions/logic/set_builder')
    end

    if not idleSet then
        return {}
    end

    -- Delegate to SetBuilder for shared logic
    return SetBuilder.build_idle_set(idleSet)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.customize_idle_set = customize_idle_set

-- Export as module (for future require() usage)
return {
    customize_idle_set = customize_idle_set
}

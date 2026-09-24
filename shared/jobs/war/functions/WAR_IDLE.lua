---  ═══════════════════════════════════════════════════════════════════════════
---   WAR Idle Module - Idle State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles all idle state logic for Warrior job:
---   • Town set, else the HybridMode idle set
---   • Dynamic weapon application to idle sets
---   • Movement speed gear outside town
---
---   **PERFORMANCE OPTIMIZATION:**
---   • Lazy-loaded: SetBuilder loaded on first idle event
---
---   Delegates to SetBuilder (logic module) for shared construction logic.
---
---   @file    shared/jobs/war/functions/WAR_IDLE.lua
---   @author  Tetsouo
---   @version 2.1 - Lazy Loading for performance
---   @date    Created: 2025-09-29 | Updated: 2025-11-15
---   @requires shared/jobs/war/functions/logic/set_builder
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════
-- SetBuilder loaded on first idle event
local SetBuilder = nil

---  ═══════════════════════════════════════════════════════════════════════════
---   IDLE CUSTOMIZATION HOOK
---  ═══════════════════════════════════════════════════════════════════════════

---   Apply weapon sets and movement gear to idle configuration
---   Called by Mote-Include when idle set is selected.
---
---   Processing order (SetBuilder.build_idle_set):
---   1. Town set, else sets.idle[HybridMode], else the base set
---   2. Apply current weapon set (state.MainWeapon)
---   3. Apply movement gear if moving (outside town)
---
---   @param idleSet table The base idle set from war_sets.lua
---   @return table Modified idle set with weapon/movement gear applied
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

-- Export to global scope (used by Mote-Include via include())
_G.customize_idle_set = customize_idle_set


---  ═══════════════════════════════════════════════════════════════════════════
---   RDM Idle Module - Idle State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles all idle state logic for Red Mage job:
---   - Idle set selection based on IdleMode (Refresh, DT)
---   - Town gear (sets.Adoulin / sets.idle.Town)
---   - Weapon application from MainWeapon / SubWeapon
---   - Movement speed gear outside town
---   The logic lives in logic/set_builder.lua.
---
---   @file    shared/jobs/rdm/functions/RDM_IDLE.lua
---   @author  Tetsouo
---   @version 2.1 - Removed dead code + refactored header
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = nil

---  ═══════════════════════════════════════════════════════════════════════════
---   IDLE HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

---   Apply weapon sets, mode selection, and movement gear to all idle configurations
---   @param idleSet table The idle set to customize
---   @return table Idle set for the current IdleMode/town, with weapons and movement gear
function customize_idle_set(idleSet)
    if not SetBuilder then
        SetBuilder = require('shared/jobs/rdm/functions/logic/set_builder')
    end

    if not idleSet then
        return {}
    end

    return SetBuilder.build_idle_set(idleSet)
end

-- Export to global scope (used by Mote-Include via include())
_G.customize_idle_set = customize_idle_set

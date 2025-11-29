---  ═══════════════════════════════════════════════════════════════════════════
---   DRK Idle Module - Idle State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles all idle state logic for Dark Knight job:
---   - Idle set selection based on IdleMode (DT, Refresh, Regain, Evasion)
---   - Movement speed optimization
---   - Town gear management
---   - Dynamic weapon application to idle sets
---
---   @file    shared/jobs/drk/functions/DRK_IDLE.lua
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

--- Apply weapon sets, mode selection, and movement gear to all idle configurations
--- @param idleSet table The idle set to customize
--- @return table Modified idle set with current weapon, mode, and movement gear
function customize_idle_set(idleSet)
    -- Lazy load SetBuilder on first idle
    if not SetBuilder then
        SetBuilder = require('shared/jobs/drk/functions/logic/set_builder')
    end

    if not idleSet then
        return {}
    end

    return SetBuilder.build_idle_set(idleSet)
end

-- Export to global scope (used by Mote-Include via include())
_G.customize_idle_set = customize_idle_set

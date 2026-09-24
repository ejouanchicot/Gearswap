---  ═══════════════════════════════════════════════════════════════════════════
---   GEO Idle Module - Idle State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Mote idle hook for Geomancer. Delegates to SetBuilder.build_idle_set:
---   - sets.luopan.idle while a luopan is out
---   - HybridMode base (sets.idle.PDT / .Normal) otherwise
---   - Town set, weapon sets, then movement gear (outside town)
---
---   @file    shared/jobs/geo/functions/GEO_IDLE.lua
---   @author  Tetsouo
---   @version 2.1 - Removed dead code + refactored header
---   @date    Created: 2025-10-09 | Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = nil

---  ═══════════════════════════════════════════════════════════════════════════
---   IDLE HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

---   Build the idle set (base selection + town + weapons + movement gear)
---   @param idleSet table The idle set Mote selected (only checked for nil)
---   @return table Idle set to wear
function customize_idle_set(idleSet)
    -- Lazy load SetBuilder on first idle
    if not SetBuilder then
        SetBuilder = require('shared/jobs/geo/functions/logic/set_builder')
    end

    if not idleSet then
        return {}
    end

    return SetBuilder.build_idle_set(idleSet)
end

-- Export to global scope (used by Mote-Include via include())
_G.customize_idle_set = customize_idle_set

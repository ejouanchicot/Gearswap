---  ═══════════════════════════════════════════════════════════════════════════
---   COR Idle Module - Idle State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   customize_idle_set (SetBuilder.build_idle_set): town base, weapons, then
---   outside town the PDT overlay (HybridMode), sets.idle.Refresh under 50% MP
---   and movement gear.
---
---   @file    shared/jobs/cor/functions/COR_IDLE.lua
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
---   @return table Modified idle set with current weapon, mode, and movement gear
function customize_idle_set(idleSet)
    -- Lazy load SetBuilder on first idle
    if not SetBuilder then
        SetBuilder = require('shared/jobs/cor/functions/logic/set_builder')
    end

    if not idleSet then
        return {}
    end

    return SetBuilder.build_idle_set(idleSet)
end

-- Export to global scope (used by Mote-Include via include())
_G.customize_idle_set = customize_idle_set

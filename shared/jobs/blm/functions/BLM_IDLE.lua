---  ═══════════════════════════════════════════════════════════════════════════
---   BLM Idle Module - Idle State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   customize_idle_set: takes the idle set Mote selected, then applies the
---   town base, the weapon sets, movement gear outside town and the Mana Wall
---   set (SetBuilder.build_idle_set).
---
---   @file    shared/jobs/blm/functions/BLM_IDLE.lua
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
        SetBuilder = require('shared/jobs/blm/functions/logic/set_builder')
    end

    if not idleSet then
        return {}
    end

    return SetBuilder.build_idle_set(idleSet)
end

-- Export to global scope (used by Mote-Include via include())
_G.customize_idle_set = customize_idle_set

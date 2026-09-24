---  ═══════════════════════════════════════════════════════════════════════════
---   SAM Idle Module - Idle State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   customize_idle_set delegates to logic/set_builder.lua:
---   - HP-based layers (sets.idle.Weak below 50%, sets.idle.Regen below 80%)
---   - HybridMode PDT idle set
---   - Main weapon set
---
---   @file    shared/jobs/sam/functions/SAM_IDLE.lua
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

---   Apply HP layers, HybridMode and weapon to the idle set
---   @param idleSet table The idle set to customize
---   @return table Modified idle set
function customize_idle_set(idleSet)
    -- Lazy load SetBuilder on first idle
    if not SetBuilder then
        SetBuilder = require('shared/jobs/sam/functions/logic/set_builder')
    end

    if not idleSet then
        return {}
    end

    return SetBuilder.build_idle_set(idleSet)
end

-- Export to global scope (used by Mote-Include via include())
_G.customize_idle_set = customize_idle_set

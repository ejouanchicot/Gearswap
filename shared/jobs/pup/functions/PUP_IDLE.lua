---  ═══════════════════════════════════════════════════════════════════════════
---   PUP Idle Module - Idle State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Idle hook for Puppetmaster: delegates to logic/set_builder.lua.
---   NOTE: logic/set_builder.lua does not exist yet (PUP is incomplete), so
---   this require raises on the first idle rebuild.
---
---   @file    shared/jobs/pup/functions/PUP_IDLE.lua
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

---   Build the idle set through SetBuilder.build_idle_set
---   @param idleSet table The idle set to customize
---   @return table Customized idle set
function customize_idle_set(idleSet)
    if not SetBuilder then
        SetBuilder = require('shared/jobs/pup/functions/logic/set_builder')
    end

    if not idleSet then
        return {}
    end

    return SetBuilder.build_idle_set(idleSet)
end

-- Export to global scope (used by Mote-Include via include())
_G.customize_idle_set = customize_idle_set

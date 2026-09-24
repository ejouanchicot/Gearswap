---  ═══════════════════════════════════════════════════════════════════════════
---   WHM Engaged Module - Combat State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   customize_melee_set delegates to logic/set_builder.lua, which returns
---   Mote's engaged set unchanged (WHM rarely melees).
---
---   @file    shared/jobs/whm/functions/WHM_ENGAGED.lua
---   @author  Tetsouo
---   @version 2.1 - Removed dead code + refactored header
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = nil

---  ═══════════════════════════════════════════════════════════════════════════
---   ENGAGED HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

---   Return the engaged set (no WHM-specific layer)
---   @param meleeSet table The engaged set to customize
---   @return table The engaged set
function customize_melee_set(meleeSet)
    -- Lazy load SetBuilder on first engage
    if not SetBuilder then
        SetBuilder = require('shared/jobs/whm/functions/logic/set_builder')
    end

    if not meleeSet then
        return {}
    end

    return SetBuilder.build_engaged_set(meleeSet)
end

-- Export to global scope (used by Mote-Include via include())
_G.customize_melee_set = customize_melee_set

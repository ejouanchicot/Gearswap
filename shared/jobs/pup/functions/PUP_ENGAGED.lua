---  ═══════════════════════════════════════════════════════════════════════════
---   PUP Engaged Module - Combat State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Engaged hook for Puppetmaster: delegates to logic/set_builder.lua.
---   NOTE: logic/set_builder.lua does not exist yet (PUP is incomplete), so
---   this require raises on the first engaged rebuild.
---
---   @file    shared/jobs/pup/functions/PUP_ENGAGED.lua
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

---   Build the engaged set through SetBuilder.build_engaged_set
---   @param meleeSet table The engaged set to customize
---   @return table Customized engaged set
function customize_melee_set(meleeSet)
    if not SetBuilder then
        SetBuilder = require('shared/jobs/pup/functions/logic/set_builder')
    end

    if not meleeSet then
        return {}
    end

    return SetBuilder.build_engaged_set(meleeSet)
end

-- Export to global scope (used by Mote-Include via include())
_G.customize_melee_set = customize_melee_set

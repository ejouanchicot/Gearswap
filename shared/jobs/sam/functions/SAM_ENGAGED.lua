---  ═══════════════════════════════════════════════════════════════════════════
---   SAM Engaged Module - Combat State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   customize_melee_set delegates to logic/set_builder.lua:
---   - Base set: AM3 set, else sets.engaged[HybridMode]
---   - Seigan layer (sets.thirdeye in PDT, sets.seigan otherwise)
---   - Main weapon set, bow set when Yoichinoyumi is equipped
---
---   @file    shared/jobs/sam/functions/SAM_ENGAGED.lua
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

---   Apply base selection, Seigan layer, weapon and bow to the engaged set
---   @param meleeSet table The engaged set to customize
---   @return table Modified engaged set
function customize_melee_set(meleeSet)
    -- Lazy load SetBuilder on first engage
    if not SetBuilder then
        SetBuilder = require('shared/jobs/sam/functions/logic/set_builder')
    end

    if not meleeSet then
        return {}
    end

    return SetBuilder.build_engaged_set(meleeSet)
end

-- Export to global scope (used by Mote-Include via include())
_G.customize_melee_set = customize_melee_set

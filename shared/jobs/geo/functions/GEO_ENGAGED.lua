---  ═══════════════════════════════════════════════════════════════════════════
---   GEO Engaged Module - Combat State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Mote engaged hook for Geomancer. Delegates to SetBuilder.build_engaged_set:
---   - sets.luopan.engaged.DT / .DPS (LuopanMode) while a luopan is out
---   - HybridMode base (sets.engaged.PDT / .Normal) otherwise
---   - Weapon sets (MainWeapon / SubWeapon) applied on top
---
---   @file    shared/jobs/geo/functions/GEO_ENGAGED.lua
---   @author  Tetsouo
---   @version 2.1 - Removed dead code + refactored header
---   @date    Created: 2025-10-09 | Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = nil

---  ═══════════════════════════════════════════════════════════════════════════
---   ENGAGED HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

---   Build the engaged set (base selection + weapons; no movement gear engaged)
---   @param meleeSet table The engaged set Mote selected (only checked for nil)
---   @return table Engaged set to wear
function customize_melee_set(meleeSet)
    -- Lazy load SetBuilder on first engage
    if not SetBuilder then
        SetBuilder = require('shared/jobs/geo/functions/logic/set_builder')
    end

    if not meleeSet then
        return {}
    end

    return SetBuilder.build_engaged_set(meleeSet)
end

-- Export to global scope (used by Mote-Include via include())
_G.customize_melee_set = customize_melee_set

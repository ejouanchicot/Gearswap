---  ═══════════════════════════════════════════════════════════════════════════
---   DNC Engaged Module - Combat State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Engaged set customization for Dancer, delegated to logic/set_builder:
---   - Base set from Saber Dance / Fan Dance buffs and HybridMode
---   - MainWeapon set and SubWeaponOverride
---
---   @file    shared/jobs/dnc/functions/DNC_ENGAGED.lua
---   @author  Tetsouo
---   @version 2.1 - Removed dead code + refactored header
---   @date    Created: 2025-10-04 | Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = nil

---  ═══════════════════════════════════════════════════════════════════════════
---   ENGAGED HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

---   Apply dance/HybridMode base selection and weapon sets to the engaged set
---   @param meleeSet table The engaged set to customize
---   @return table Modified engaged set ({} when meleeSet is nil)
function customize_melee_set(meleeSet)
    if not SetBuilder then
        SetBuilder = require('shared/jobs/dnc/functions/logic/set_builder')
    end

    if not meleeSet then
        return {}
    end

    return SetBuilder.build_engaged_set(meleeSet)
end

-- Export to global scope (used by Mote-Include via include())
_G.customize_melee_set = customize_melee_set

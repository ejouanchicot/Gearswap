---  ═══════════════════════════════════════════════════════════════════════════
---   RDM Engaged Module - Combat State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles all engaged state logic for Red Mage job:
---   - Combat set selection based on EngagedMode (DT, Acc, TP, Enspell)
---   - Dual wield detection from the sub weapon (.DW sets)
---   - Weapon application from MainWeapon / SubWeapon
---   The logic lives in logic/set_builder.lua.
---
---   @file    shared/jobs/rdm/functions/RDM_ENGAGED.lua
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

---   Apply mode selection and weapon sets to the engaged set (no movement gear when engaged)
---   @param meleeSet table The engaged set to customize
---   @return table Engaged set for the current EngagedMode, with the current weapons
function customize_melee_set(meleeSet)
    if not SetBuilder then
        SetBuilder = require('shared/jobs/rdm/functions/logic/set_builder')
    end

    if not meleeSet then
        return {}
    end

    return SetBuilder.build_engaged_set(meleeSet)
end

-- Export to global scope (used by Mote-Include via include())
_G.customize_melee_set = customize_melee_set

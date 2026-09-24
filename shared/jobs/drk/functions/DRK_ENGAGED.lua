---  ═══════════════════════════════════════════════════════════════════════════
---   DRK Engaged Module - Combat State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Engaged set customization for Dark Knight, delegated to logic/set_builder:
---   - Base set: sets.engaged.AM3 (Aftermath Lv.3 + Liberator), sets.engaged.PDT
---     (HybridMode PDT) or sets.engaged
---   - MainWeapon set, then Dark Seal / Nether Void variants
---
---   @file    shared/jobs/drk/functions/DRK_ENGAGED.lua
---   @author  Tetsouo
---   @version 2.1 - Removed dead code + refactored header
---   @date    Created: 2025-10-23 | Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = nil

---  ═══════════════════════════════════════════════════════════════════════════
---   ENGAGED HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

---   Build the engaged set. Mote's meleeSet is only checked for nil: the
---   builder picks its own base from sets.engaged.
---   @param meleeSet table The engaged set chosen by Mote
---   @return table Engaged set to equip ({} when meleeSet is nil)
function customize_melee_set(meleeSet)
    if not SetBuilder then
        local ok, mod = pcall(require, 'shared/jobs/drk/functions/logic/set_builder')
        if ok then SetBuilder = mod end
    end

    if not meleeSet then
        return {}
    end

    local weapon_name = state.MainWeapon and state.MainWeapon.current
    local hybrid_mode = state.HybridMode and state.HybridMode.value

    return SetBuilder.build_engaged_set(weapon_name, hybrid_mode)
end

-- Export to global scope (used by Mote-Include via include())
_G.customize_melee_set = customize_melee_set

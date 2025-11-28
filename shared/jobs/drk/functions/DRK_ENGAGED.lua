---  ═══════════════════════════════════════════════════════════════════════════
---   DRK Engaged Module - Combat State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles all engaged state logic for Red Mage job:
---   - Combat set selection based on EngagedMode (DT, Enspell, Refresh, TP)
---   - Dual wield detection and optimization (NIN subjob)
---   - Dynamic weapon application to engaged sets
---   - Combat state transitions
---
---   @file    shared/jobs/drk/functions/DRK_ENGAGED.lua
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

--- Apply weapon sets, mode selection, and movement gear to all engaged configurations
--- @param meleeSet table The engaged set to customize
--- @return table Modified engaged set with current weapon, mode, and movement gear
function customize_melee_set(meleeSet)
    -- Lazy load SetBuilder on first engage
    if not SetBuilder then
        SetBuilder = require('shared/jobs/drk/functions/logic/set_builder')
    end

    if not meleeSet then
        return {}
    end

    -- Get current weapon and hybrid mode
    local weapon_name = state.MainWeapon and state.MainWeapon.current
    local hybrid_mode = state.HybridMode and state.HybridMode.value

    return SetBuilder.build_engaged_set(weapon_name, hybrid_mode)
end

-- Export to global scope (used by Mote-Include via include())
_G.customize_melee_set = customize_melee_set

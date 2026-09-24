---  ═══════════════════════════════════════════════════════════════════════════
---   DNC Idle Module - Idle State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Idle set customization for Dancer, delegated to logic/set_builder:
---   - Town / Adoulin idle base (BaseSetBuilder)
---   - MainWeapon set and SubWeaponOverride
---   - Movement speed gear outside town
---
---   @file    shared/jobs/dnc/functions/DNC_IDLE.lua
---   @author  Tetsouo
---   @version 2.1 - Removed dead code + refactored header
---   @date    Created: 2025-10-04 | Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = nil

---  ═══════════════════════════════════════════════════════════════════════════
---   IDLE HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

---   Apply town base, weapon sets and movement gear to the idle set
---   @param idleSet table The idle set to customize
---   @return table Modified idle set ({} when idleSet is nil)
function customize_idle_set(idleSet)
    if not SetBuilder then
        SetBuilder = require('shared/jobs/dnc/functions/logic/set_builder')
    end

    if not idleSet then
        return {}
    end

    return SetBuilder.build_idle_set(idleSet)
end

-- Export to global scope (used by Mote-Include via include())
_G.customize_idle_set = customize_idle_set

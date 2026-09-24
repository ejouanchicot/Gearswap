---  ═══════════════════════════════════════════════════════════════════════════
---   DRK Idle Module - Idle State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Idle set customization for Dark Knight, delegated to logic/set_builder:
---   - MainWeapon set applied to the idle set
---   - sets.MoveSpeed while AutoMove reports movement
---
---   @file    shared/jobs/drk/functions/DRK_IDLE.lua
---   @author  Tetsouo
---   @version 2.1 - Removed dead code + refactored header
---   @date    Created: 2025-10-23 | Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = nil

---  ═══════════════════════════════════════════════════════════════════════════
---   IDLE HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

---   Apply weapon set and movement gear to the idle set
---   @param idleSet table The idle set to customize
---   @return table Modified idle set ({} when idleSet is nil)
function customize_idle_set(idleSet)
    if not SetBuilder then
        local ok, mod = pcall(require, 'shared/jobs/drk/functions/logic/set_builder')
        if ok then SetBuilder = mod end
    end

    if not idleSet then
        return {}
    end

    return SetBuilder.build_idle_set(idleSet)
end

-- Export to global scope (used by Mote-Include via include())
_G.customize_idle_set = customize_idle_set

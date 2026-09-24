---  ═══════════════════════════════════════════════════════════════════════════
---   THF Engaged Module - Combat State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   customize_melee_set delegates to logic/set_builder.lua:
---   - Base set: PDTAFM3 (Vajra + Aftermath Lv.3), else sets.engaged[HybridMode]
---   - Weapon sets (MainWeapon/SubWeapon, or AbyWeapon when AbyProc is on)
---   - SA/TA buff overlay, then Treasure Hunter gear per TreasureMode
---
---   @file    shared/jobs/thf/functions/THF_ENGAGED.lua
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

---   Apply base selection, weapons, SA/TA overlay and TH to the engaged set
---   @param meleeSet table The engaged set to customize
---   @return table Modified engaged set
function customize_melee_set(meleeSet)
    -- Lazy load SetBuilder on first engage
    if not SetBuilder then
        SetBuilder = require('shared/jobs/thf/functions/logic/set_builder')
    end

    if not meleeSet then
        return {}
    end

    return SetBuilder.build_engaged_set(meleeSet)
end

-- Export to global scope (used by Mote-Include via include())
_G.customize_melee_set = customize_melee_set

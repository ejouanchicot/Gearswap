---  ═══════════════════════════════════════════════════════════════════════════
---   WAR Engaged Module - Combat State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles all engaged (combat) state logic for Warrior job:
---   • Base set: Kraken Club, stance (SubtleBlow/Hoxne), Aftermath Lv.3,
---     weapon-specific set, then HybridMode
---   • Dynamic weapon application to engaged sets
---
---   Delegates to SetBuilder (logic module) for shared construction logic.
---
---   @file    shared/jobs/war/functions/WAR_ENGAGED.lua
---   @author  Tetsouo
---   @version 2.0 - Logic Extracted to logic/set_builder.lua
---   @date    Created: 2025-09-29 | Updated: 2025-10-06
---   @requires shared/jobs/war/functions/logic/set_builder
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════
-- SetBuilder loaded on first function call
local SetBuilder = nil

---  ═══════════════════════════════════════════════════════════════════════════
---   ENGAGED CUSTOMIZATION HOOK
---  ═══════════════════════════════════════════════════════════════════════════

---   Apply base selection and weapon set to the engaged configuration
---   Called by Mote-Include when engaged set is selected.
---
---   Processing order (SetBuilder.build_engaged_set):
---   1. Select base set (see SetBuilder.select_engaged_base)
---   2. Apply current weapon set (state.MainWeapon)
---
---   @param meleeSet table The base engaged set from war_sets.lua
---   @return table Modified engaged set
function customize_melee_set(meleeSet)
    -- Lazy load SetBuilder on first call
    if not SetBuilder then
        SetBuilder = require('shared/jobs/war/functions/logic/set_builder')
    end

    if not meleeSet then
        return {}
    end

    -- Delegate to SetBuilder for shared logic
    return SetBuilder.build_engaged_set(meleeSet)
end

-- Export to global scope (used by Mote-Include via include())
_G.customize_melee_set = customize_melee_set


---============================================================================
--- DRK Engaged Module - Combat State Management
---============================================================================
--- Handles all engaged (combat) state logic for Dark Knight job:
---   • Aftermath Lv.3 detection and optimization (Liberator Mythic)
---   • Weapon-specific engaged set selection (Caladbolg, Liberator, etc.)
---   • Combat set selection based on HybridMode (PDT/Accu)
---   • Dynamic weapon application to engaged sets
---   • Combat state transitions
---   • Buff anticipation (Dark Seal, Nether Void)
---
--- Weapon-Specific Engaged Sets:
---   • Liberator   - Mythic AM3 crit build (sets.engaged.Liberator.AM3)
---   • Caladbolg   - High STP scythe build
---   • Apocalypse  - Relic Catastrophe spam build
---   • Foenaria    - Great Axe balanced build
---   • Naegling    - 1H sword fast TP build
---   • Loxotic     - 1H club balanced build
---   • Others      - Use base engaged set
---
--- Buff Variants (optional):
---   • .DarkSeal           - Dark Seal active (Dark Magic duration +10%/merit)
---   • .NetherVoid         - Nether Void active (Absorb potency +45%)
---   • .DarkSealNetherVoid - Both buffs active (max Dark Magic effectiveness)
---
--- @file    DRK_ENGAGED.lua
--- @author  Tetsouo
--- @version 4.0.0 - Aftermath Lv.3 Support + SetBuilder Integration
--- @date    Created: 2025-10-23 | Updated: 2025-11-10
--- @requires Tetsouo architecture, drk_set_builder
---============================================================================

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Load DRK set builder (handles AM3 detection + weapon selection)
local DRKSetBuilder = require('shared/jobs/drk/functions/logic/drk_set_builder')

---============================================================================
--- ENGAGED CUSTOMIZATION HOOK
---============================================================================

--- Apply weapon sets, buff variants, and Aftermath Lv.3 detection to engaged configuration
--- Called by Mote-Include when engaged set is selected.
---
--- Delegates to DRKSetBuilder for centralized set construction logic.
---
--- Processing order:
---   1. Aftermath Lv.3 detection (buff 272) + Liberator >> sets.engaged.Liberator.AM3
---   2. Weapon-specific set with HybridMode (e.g., sets.engaged.Liberator.PDT)
---   3. Apply weapon (main/sub slots)
---   4. Apply buff variants (Dark Seal, Nether Void)
---
--- @param meleeSet table The base engaged set from drk_sets.lua (ignored, rebuilt)
--- @return table Complete engaged set with AM3/weapon/hybrid/buff variants applied
function customize_melee_set(meleeSet)
    if not meleeSet then
        return {}
    end

    -- Extract current weapon and hybrid mode
    local weapon_name = state.MainWeapon and state.MainWeapon.current or nil
    local hybrid_mode = state.HybridMode and state.HybridMode.current or 'PDT'

    -- Delegate to DRKSetBuilder for shared logic (AM3 detection + set construction)
    return DRKSetBuilder.build_engaged_set(weapon_name, hybrid_mode)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.customize_melee_set = customize_melee_set

-- Export as module (for future require() usage)
return {
    customize_melee_set = customize_melee_set
}

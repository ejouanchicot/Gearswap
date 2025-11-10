---============================================================================
--- DRK Engaged Module - Combat State Management
---============================================================================
--- Handles all engaged (combat) state logic for Dark Knight job:
---   • Aftermath Lv.3 detection and optimization (Liberator Mythic)
---   • HybridMode support (PDT mode for all weapons)
---   • Dynamic weapon application to engaged sets
---   • Combat state transitions
---   • Buff anticipation (Dark Seal, Nether Void)
---
--- Simplified Engaged Structure (3 sets total):
---   • sets.engaged        - Base DPS set (all weapons, used for Accu mode)
---   • sets.engaged.PDT    - Physical defense mode (all weapons)
---   • sets.engaged.AM3    - Aftermath Lv.3 (Liberator mythic)
---
--- Weapon Application:
---   • Weapons applied separately via sets[weapon_name]
---   • Examples: sets.Liberator, sets.Caladbolg, sets.Naegling, etc.
---
--- Buff Variants (optional):
---   • .DarkSeal           - Dark Seal active (Dark Magic duration +10%/merit)
---   • .NetherVoid         - Nether Void active (Absorb potency +45%)
---   • .DarkSealNetherVoid - Both buffs active (max Dark Magic effectiveness)
---
--- @file    DRK_ENGAGED.lua
--- @author  Tetsouo
--- @version 5.2.0 - Simplified to 3 sets (engaged, engaged.PDT, engaged.AM3)
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

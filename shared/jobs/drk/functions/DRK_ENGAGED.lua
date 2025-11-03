---============================================================================
--- DRK Engaged Module - Combat State Management
---============================================================================
--- Handles all engaged (combat) state logic for Dark Knight job:
---   • Weapon-specific engaged set selection (Caladbolg, Liberator, etc.)
---   • Combat set selection based on HybridMode (PDT/Accu)
---   • Dynamic weapon application to engaged sets
---   • Combat state transitions
---   • Buff anticipation (Dark Seal, Nether Void)
---
--- Weapon-Specific Engaged Sets:
---   • Caladbolg   - High STP scythe build
---   • Liberator   - Mythic AM3 crit build
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
--- @version 3.0.0 - Dark Seal/Nether Void Buff Anticipation
--- @date    Created: 2025-10-23 | Updated: 2025-10-23
--- @requires Tetsouo architecture, drk_buff_anticipation
---============================================================================

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Load DRK buff anticipation logic
local DRKBuffAnticipation = require('shared/jobs/drk/functions/logic/drk_buff_anticipation')

---============================================================================
--- ENGAGED CUSTOMIZATION HOOK
---============================================================================

--- Apply weapon sets, buff variants, and movement gear to engaged configuration
--- Called by Mote-Include when engaged set is selected.
---
--- IMPORTANT: We ignore the meleeSet passed by Mote and rebuild from scratch
--- to ensure weapon-specific sets with HybridMode and buff variants are applied correctly.
---
--- Processing order:
---   1. Select weapon-specific set with HybridMode (e.g., sets.engaged.Loxotic.PDT)
---   2. Fallback to weapon-specific Accu if no HybridMode variant exists
---   3. Apply weapon (main/sub slots)
---   4. Apply buff variants (Dark Seal, Nether Void) via DRKBuffAnticipation
---   5. Movement gear (NOT used in combat - AutoMove blocks it)
---
--- @param meleeSet table The set Mote selected (IGNORED - we rebuild)
--- @return table Modified engaged set with weapon-specific/hybrid/buff variant gear
function customize_melee_set(meleeSet)
    if not meleeSet then
        return {}
    end

    -- Step 1: Select weapon-specific set with HybridMode
    local custom_set = sets.engaged
    local weapon_name = state.MainWeapon and state.MainWeapon.current or nil
    local hybrid_mode = state.HybridMode and state.HybridMode.current or 'PDT'

    if weapon_name then
        local weapon_table = sets.engaged[weapon_name]

        if weapon_table then
            -- Try weapon + hybrid combo first (e.g., sets.engaged.Loxotic.PDT)
            local weapon_hybrid_set = weapon_table[hybrid_mode]

            if weapon_hybrid_set then
                custom_set = weapon_hybrid_set
            else
                -- Fallback to Accu mode for this weapon
                local weapon_accu_set = weapon_table.Accu
                if weapon_accu_set then
                    custom_set = weapon_accu_set
                end
            end
        end
    end

    -- Step 2: Apply weapon (main/sub slots)
    if weapon_name then
        local weapon_set = sets[weapon_name]
        if weapon_set then
            custom_set = set_combine(custom_set, weapon_set)
        end
    end

    -- Step 3: Apply buff variants (Dark Seal, Nether Void)
    -- This checks both buffactive[] and pending flags for instant detection
    if DRKBuffAnticipation then
        custom_set = DRKBuffAnticipation.apply_buff_variants(custom_set, weapon_name, hybrid_mode)
    end

    -- Step 4: Movement gear (NOT used in combat - AutoMove blocks it)
    -- Movement speed gear is only applied during Idle, never during Engaged
    -- AutoMove automatically prevents movement gear swaps when player.status == 'Engaged'

    return custom_set
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

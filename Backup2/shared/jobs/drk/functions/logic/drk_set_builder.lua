---============================================================================
--- DRK Set Builder - Shared Set Construction Logic
---============================================================================
--- Provides centralized set building for engaged states with Aftermath support.
--- Handles:
---   • Aftermath Lv.3 detection for Liberator (sets.engaged.AM3)
---   • PDT mode support (sets.engaged.PDT for all weapons)
---   • Weapon application via weapon sets (sets.Liberator, etc.)
---   • Buff variant integration (Dark Seal, Nether Void)
---
--- Simplified Architecture (3 sets total):
---   • sets.engaged        - Base DPS set (all weapons)
---   • sets.engaged.PDT    - Physical defense mode (all weapons)
---   • sets.engaged.AM3    - Aftermath Lv.3 (Liberator mythic)
---   • Weapons applied separately via sets[weapon_name]
---
--- Used by: DRK_ENGAGED.lua
---
--- @file    jobs/drk/functions/logic/drk_set_builder.lua
--- @author  Tetsouo
--- @version 2.2
--- @date    Created: 2025-11-10 | Updated: 2025-11-10
---============================================================================
local DRKSetBuilder = {}

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Load DRK buff anticipation logic
local DRKBuffAnticipation = require('shared/jobs/drk/functions/logic/drk_buff_anticipation')

-- Load message formatter for error display
local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- AFTERMATH LV.3 DETECTION (ENGAGED)
---============================================================================

--- Select engaged base set with Liberator Aftermath Lv.3 detection
--- Aftermath Lv.3 (buff ID: 272) + Liberator = Use specialized AM3 set
---
--- Priority order:
---   1. Aftermath Lv.3 + Liberator      >> sets.engaged.AM3
---   2. HybridMode = 'PDT'              >> sets.engaged.PDT
---   3. Base fallback (Accu/default)    >> sets.engaged
---
--- @param weapon_name string Current main weapon name
--- @param hybrid_mode string Current HybridMode ('PDT' or 'Accu')
--- @return table Selected engaged set
function DRKSetBuilder.select_engaged_base(weapon_name, hybrid_mode)
    -- PRIORITY 1: Check for Aftermath Lv.3 (buff ID 272) + Liberator
    if buffactive[272] and weapon_name == 'Liberator' then
        if sets.engaged.AM3 then
            return sets.engaged.AM3
        end
    end

    -- PRIORITY 2: PDT mode (only HybridMode with dedicated set)
    if hybrid_mode == 'PDT' and sets.engaged.PDT then
        return sets.engaged.PDT
    end

    -- PRIORITY 3: Base engaged set (used for Accu mode and default)
    return sets.engaged
end

---============================================================================
--- WEAPON APPLICATION
---============================================================================

--- Apply weapon to set (like WAR)
--- Uses weapon sets defined in drk_sets.lua (e.g., sets.Liberator).
--- Falls back gracefully if weapon set not found.
---
--- @param result table Current equipment set
--- @param weapon_name string Weapon to apply
--- @return table Set with weapon applied (or unchanged if no weapon set)
function DRKSetBuilder.apply_weapon(result, weapon_name)
    if not weapon_name then
        return result
    end

    -- Try to use weapon set from drk_sets.lua (sets.Liberator, sets.Caladbolg, etc.)
    local weapon_set = sets[weapon_name]
    if weapon_set then
        local success, combined = pcall(set_combine, result, weapon_set)
        if success then
            return combined
        else
            MessageFormatter.show_error(string.format("Failed to apply weapon set: %s", combined))
        end
    end

    return result
end

---============================================================================
--- BUFF VARIANTS APPLICATION
---============================================================================

--- Apply buff variants (Dark Seal, Nether Void) to engaged set
--- Checks both buffactive[] and pending flags for instant detection.
---
--- @param result table Current equipment set
--- @param weapon_name string Current weapon name
--- @param hybrid_mode string Current HybridMode
--- @return table Set with buff variants applied
function DRKSetBuilder.apply_buff_variants(result, weapon_name, hybrid_mode)
    if DRKBuffAnticipation then
        return DRKBuffAnticipation.apply_buff_variants(result, weapon_name, hybrid_mode)
    end
    return result
end

---============================================================================
--- ENGAGED SET BUILDER (PUBLIC API)
---============================================================================

--- Build complete engaged set with all DRK logic (like WAR)
--- Processing order:
---   1. Select base (Aftermath Lv.3 detection + HybridMode)
---   2. Apply weapon (main/sub slots)
---   3. Apply buff variants (Dark Seal, Nether Void)
---
--- @param weapon_name string Current main weapon name
--- @param hybrid_mode string Current HybridMode ('PDT' or 'Accu')
--- @return table Complete engaged set with all modifications applied
function DRKSetBuilder.build_engaged_set(weapon_name, hybrid_mode)
    -- Step 1: Select base set (AM3 detection + HybridMode)
    local result = DRKSetBuilder.select_engaged_base(weapon_name, hybrid_mode)

    -- Step 2: Apply weapon (overwrites main/sub like WAR)
    result = DRKSetBuilder.apply_weapon(result, weapon_name)

    -- Step 3: Apply buff variants (Dark Seal, Nether Void)
    result = DRKSetBuilder.apply_buff_variants(result, weapon_name, hybrid_mode)

    return result
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return DRKSetBuilder

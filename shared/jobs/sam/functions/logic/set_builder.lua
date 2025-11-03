---============================================================================
--- Set Builder - Shared Set Construction Logic (SAM)
---============================================================================
--- Provides centralized set building for both engaged and idle states.
--- Handles:
---   • Aftermath Lv.3 detection and specialized gear application
---   • Weapon selection and set application
---   • HP-based idle variations (Weak, Regen)
---   • Seigan/Third Eye buff handling
---   • Bow (Yoichinoyumi) handling
---   • HybridMode support (PDT/Normal)
---
--- Used by: SAM_IDLE.lua and SAM_ENGAGED.lua
---
--- @file    jobs/sam/functions/logic/set_builder.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-21
---============================================================================
local SetBuilder = {}

---============================================================================
--- IDLE SET CONSTRUCTION
---============================================================================

--- Build idle set with HP-based variations and HybridMode
--- Priority:
---   1. Weak (HP < 50%) → sets.idle.Weak
---   2. Regen (HP < 80%) → sets.idle.Regen
---   3. HybridMode (PDT) → sets.idle.PDT
---   4. Apply weapon
---
--- @param base_set table Base idle set from sam_sets.lua
--- @return table Complete idle set with all modifications
function SetBuilder.build_idle_set(base_set)
    if not base_set then
        return {}
    end

    local result = base_set

    -- Priority 1: Weak status (HP/MP critically low)
    if player then
        if player.hpp < 50 and sets.idle and sets.idle.Weak then
            result = set_combine(result, sets.idle.Weak)
        -- Priority 2: Regen (HP < 80%)
        elseif player.hpp < 80 and sets.idle and sets.idle.Regen then
            result = set_combine(result, sets.idle.Regen)
        end
    end

    -- Priority 3: HybridMode (PDT override)
    if state and state.HybridMode and state.HybridMode.value == 'PDT' then
        if sets.idle and sets.idle.PDT then
            result = set_combine(result, sets.idle.PDT)
        end
    end

    -- Priority 4: Apply main weapon (includes sub weapon in set)
    if state and state.MainWeapon and sets[state.MainWeapon.value] then
        result = set_combine(result, sets[state.MainWeapon.value])
    end

    return result
end

---============================================================================
--- ENGAGED SET CONSTRUCTION
---============================================================================

--- Build engaged set with Seigan/Third Eye buff handling
--- Priority:
---   1. Seigan buff → thirdeye set (PDT) or seigan set (Normal)
---   2. Apply weapon
---   3. Bow equipped (Yoichinoyumi) → bow set
---
--- @param base_set table Base engaged set from sam_sets.lua
--- @return table Complete engaged set with all modifications
function SetBuilder.build_engaged_set(base_set)
    if not base_set then
        return {}
    end

    local result = base_set

    -- Priority 1: Seigan buff handling
    if buffactive and buffactive['Seigan'] then
        if state and state.HybridMode and state.HybridMode.value == 'PDT' then
            -- PDT mode + Seigan → Third Eye set (defensive)
            if sets.thirdeye then
                result = set_combine(result, sets.thirdeye)
            end
        else
            -- Normal mode + Seigan → Seigan set (balanced)
            if sets.seigan then
                result = set_combine(result, sets.seigan)
            end
        end
    end

    -- Priority 2: Apply current main weapon (includes sub weapon in set)
    if state and state.MainWeapon and sets[state.MainWeapon.value] then
        result = set_combine(result, sets[state.MainWeapon.value])
    end

    -- Priority 3: Bow equipped handling (Yoichinoyumi)
    if player and player.equipment and player.equipment.range == 'Yoichinoyumi' then
        if sets.bow then
            result = set_combine(result, sets.bow)
        end
    end

    return result
end

---============================================================================
--- AFTERMATH LV.3 DETECTION (FUTURE EXPANSION)
---============================================================================

--- Select engaged base set with Aftermath Lv.3 detection
--- Aftermath Lv.3 (buff ID: 272) + Weapon with AM3 = Use specialized AM3 set
---
--- Priority order:
---   1. Aftermath Lv.3 + Masamune/Kogarasumaru → sets.engaged.AM3
---   2. HybridMode (PDT/Normal) → sets.engaged[HybridMode]
---   3. Fallback → base_set
---
--- @param base_set table Base engaged set from sam_sets.lua
--- @return table Selected engaged set (AM3 if conditions met, otherwise hybrid/base)
function SetBuilder.select_engaged_base(base_set)
    -- Check for Aftermath Lv.3 (buff ID 272) + Mythic/Empyrean weapon
    if buffactive[272] then
        local am3_weapons = {
            ['Masamune'] = true,
            ['Kogarasumaru'] = true
        }

        if state.MainWeapon and am3_weapons[state.MainWeapon.current] then
            if sets.engaged.AM3 then
                return sets.engaged.AM3
            end
        end
    end

    -- Normal HybridMode logic (PDT or Normal)
    if state.HybridMode and state.HybridMode.current then
        local hybrid_set = sets.engaged[state.HybridMode.current]
        if hybrid_set then
            return hybrid_set
        end
    end

    return base_set
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return SetBuilder

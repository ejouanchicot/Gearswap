---============================================================================
--- Set Builder - Shared Equipment Set Construction Logic (Logic Module)
---============================================================================
--- Provides centralized logic for building engaged and idle sets with dynamic
--- gear selection based on buffs and conditions.
---
--- Features:
---   • Aftermath Lv.3 detection (engaged only - Vajra REMA bonus)
---   • Town detection (idle only - Adoulin vs regular cities)
---   • Weapon set application (MainWeapon + SubWeapon states)
---   • Abyssea proc mode (AbyProc toggle + AbyWeapon selection)
---   • Movement gear application (idle only, never in combat)
---   • HybridMode integration (PDT/Normal sets)
---   • Error handling with MessageFormatter
---   • Modular set augmentation (base → weapon → movement → final)
---
--- Dependencies:
---   • MessageFormatter (error display for set_combine failures)
---   • sets.engaged (base engaged sets with .PDTAFM3 variant)
---   • sets.idle (base idle sets with .Town variant)
---   • sets.Adoulin (Adoulin city-specific set)
---   • sets.MoveSpeed (movement speed gear)
---   • state.MainWeapon, state.SubWeapon, state.AbyProc, state.AbyWeapon
---
--- @file    jobs/thf/functions/logic/set_builder.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-06
---============================================================================

local SetBuilder = {}

-- Load base set builder (universal functions)
local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')

-- Load dependencies
local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- AFTERMATH LV.3 DETECTION (ENGAGED)
---============================================================================

--- Select engaged base set with Aftermath Lv.3 detection
--- Aftermath Lv.3 (buff ID 272) + Vajra = Use PDTAFM3 set
--- @param base_set table Base engaged set
--- @return table Selected engaged set (PDTAFM3 if conditions met, otherwise base)
function SetBuilder.select_engaged_base(base_set)
    -- Check for Aftermath Lv.3 (buff ID 272) + Vajra
    if buffactive[272] and state.MainWeapon and state.MainWeapon.current == 'Vajra' then
        -- Use specialized Aftermath Lv.3 set (works for both PDT and Normal modes)
        if sets.engaged.PDTAFM3 then
            return sets.engaged.PDTAFM3
        end
    elseif state.HybridMode and state.HybridMode.current then
        -- Normal HybridMode logic (PDT or Normal)
        local hybrid_set = sets.engaged[state.HybridMode.current]
        if hybrid_set then
            return hybrid_set
        end
    end

    return base_set
end

---============================================================================
--- WEAPON APPLICATION
---============================================================================

--- Apply main and sub weapons to set
--- Uses weapon sets defined in thf_sets.lua if available
--- If AbyProc mode is true, uses AbyWeapon instead of MainWeapon/SubWeapon
--- @param result table Current equipment set
--- @return table Set with weapons applied
function SetBuilder.apply_weapon(result)
    -- Check if Abyssea Proc mode is active (boolean toggle)
    if state.AbyProc and state.AbyProc.value then
        -- Use Abyssea weapon set (already includes main + sub)
        if state.AbyWeapon and state.AbyWeapon.current then
            local aby_weapon_set = sets[state.AbyWeapon.current]
            if aby_weapon_set then
                local success, combined = pcall(set_combine, result, aby_weapon_set)
                if success then
                    result = combined
                else
                    MessageFormatter.show_error(string.format("Failed to apply Aby weapon: %s", combined))
                end
            end
        end
    else
        -- Normal weapon logic (MainWeapon + SubWeapon)
        -- Apply main weapon
        if state.MainWeapon and state.MainWeapon.current then
            local main_set = sets[state.MainWeapon.current]
            if main_set then
                local success, combined = pcall(set_combine, result, main_set)
                if success then
                    result = combined
                else
                    MessageFormatter.show_error(string.format("Failed to apply main weapon: %s", combined))
                end
            end
        end

        -- Apply sub weapon
        if state.SubWeapon and state.SubWeapon.current then
            local sub_set = sets[state.SubWeapon.current]
            if sub_set then
                local success, combined = pcall(set_combine, result, sub_set)
                if success then
                    result = combined
                else
                    MessageFormatter.show_error(string.format("Failed to apply sub weapon: %s", combined))
                end
            end
        end
    end

    return result
end

---============================================================================
--- MOVEMENT SPEED (INHERITED FROM BASE)
---============================================================================

-- Inherit universal movement function from BaseSetBuilder
SetBuilder.apply_movement = BaseSetBuilder.apply_movement


---============================================================================
--- TOWN DETECTION (INHERITED FROM BASE)
---============================================================================

-- Inherit universal town detection function from BaseSetBuilder
SetBuilder.select_idle_base = BaseSetBuilder.select_idle_base_town

---============================================================================
--- ENGAGED SET BUILDER
---============================================================================

--- Build complete engaged set with all THF logic
--- @param base_set table Base engaged set
--- @return table Complete engaged set
function SetBuilder.build_engaged_set(base_set)
    if not base_set then
        return {}
    end

    -- Step 1: Select base set (Aftermath Lv.3 detection + HybridMode)
    local result = SetBuilder.select_engaged_base(base_set)

    -- Step 2: Apply weapon
    result = SetBuilder.apply_weapon(result)

    return result
end

---============================================================================
--- IDLE SET BUILDER
---============================================================================

--- Build complete idle set with all THF logic
--- @param base_set table Base idle set
--- @return table Complete idle set
function SetBuilder.build_idle_set(base_set)
    if not base_set then
        return {}
    end

    -- Step 1: Town detection - use town set as base
    local result, in_town = SetBuilder.select_idle_base(base_set)

    -- Step 2: Apply weapon (applies to both town and non-town)
    result = SetBuilder.apply_weapon(result)

    -- Step 3: Early return if in town (weapons already applied)
    if in_town then
        return result
    end

    -- Step 4: Apply movement speed
    result = SetBuilder.apply_movement(result)

    return result
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return SetBuilder

---============================================================================
--- Set Builder - Shared Set Construction Logic (RUN)
---============================================================================
--- Provides centralized set building for both engaged and idle states.
--- Handles complex RUN-specific gear logic:
---   • Main weapon selection (Epeolatry, Lycurgos - Great Sword/Great Axe)
---   • Grip selection (Utu Grip, Refined Grip +1) - Great Swords only
---   • HybridMode application (PDT/MDT)
---   • Movement speed gear
---   • Town detection and town gear
---
--- Features:
---   • Shared logic for both idle and engaged
---   • Safe pcall for set_combine operations
---   • Modular functions for easy maintenance
---
--- @file    jobs/run/functions/logic/set_builder.lua
--- @author  Tetsouo
--- @version 2.1.0 - Fixed Lycurgos Great Axe support (sub=empty)
--- @date    Created: 2025-10-06 | Updated: 2025-11-11
---============================================================================
local SetBuilder = {}

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Load base set builder (universal functions)
local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')

-- Load message formatter for error display
local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- WEAPON/SHIELD APPLICATION
---============================================================================

--- Apply main weapon to set
--- Uses weapon sets defined in run_sets.lua (sets.Epeolatry, sets.Lycurgos, etc.)
--- @param result table Current equipment set
--- @return table Set with main weapon applied
function SetBuilder.apply_weapon(result)
    if not state.MainWeapon or not state.MainWeapon.current then
        return result
    end

    -- Use sets.* directly (defined in run_sets.lua)
    local weapon_set = sets[state.MainWeapon.current]
    if weapon_set then
        result = set_combine(result, weapon_set)
    end

    return result
end

--- Apply sub weapon (grip) to set
--- Uses grip sets defined in run_sets.lua (sets.Utu, sets.Refined)
--- Great Swords are 2-handed but can use grips
--- NOTE: Great Axes (Lycurgos) cannot use grips - skip grip application
--- @param result table Current equipment set
--- @return table Set with grip applied
function SetBuilder.apply_grip(result)
    -- Skip grip application for Great Axes (Lycurgos)
    if state.MainWeapon and state.MainWeapon.current == 'Lycurgos' then
        -- DEBUG: Confirm Lycurgos is detected and grip is skipped
        if _G.DEBUG_RUN_WEAPONS then
            MessageFormatter.show_debug('RUN SetBuilder', 'Lycurgos detected - skipping grip application')
        end
        return result
    end

    -- Use SubWeapon state (sets.Utu, sets.Refined)
    if state.SubWeapon and state.SubWeapon.current then
        local grip_set = sets[state.SubWeapon.current]
        if grip_set then
            if _G.DEBUG_RUN_WEAPONS then
                MessageFormatter.show_debug('RUN SetBuilder', 'Applying grip: ' .. state.SubWeapon.current)
            end
            result = set_combine(result, grip_set)
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

--- Build complete engaged set with all RUN logic
--- @param base_set table Base engaged set
--- @return table Complete engaged set
function SetBuilder.build_engaged_set(base_set)
    if not base_set then
        return {}
    end

    local result = base_set

    -- Step 1: Apply HybridMode FIRST (PDT/MDT)
    if state.HybridMode and state.HybridMode.value then
        local hybrid_set = nil
        if state.HybridMode.value == 'PDT' and sets.engaged.PDT then
            hybrid_set = sets.engaged.PDT
        elseif state.HybridMode.value == 'MDT' and sets.engaged.MDT then
            hybrid_set = sets.engaged.MDT
        end

        if hybrid_set then
            result = set_combine(result, hybrid_set)
        end
    end

    -- Step 2: Apply main weapon (AFTER hybrid to ensure weapon takes priority)
    result = SetBuilder.apply_weapon(result)

    -- Step 3: Apply grip (skipped for Lycurgos)
    result = SetBuilder.apply_grip(result)

    return result
end

---============================================================================
--- IDLE SET BUILDER
---============================================================================

--- Build complete idle set with all RUN logic
--- @param base_set table Base idle set
--- @return table Complete idle set
function SetBuilder.build_idle_set(base_set)
    if not base_set then
        return {}
    end

    -- Step 1: Town detection - use town set as base
    local result, in_town = SetBuilder.select_idle_base(base_set)

    -- Step 2: Apply HybridMode FIRST (PDT/MDT) outside of town
    if not in_town and state.HybridMode and state.HybridMode.value then
        local hybrid_set = nil
        if state.HybridMode.value == 'PDT' and sets.idle.PDT then
            hybrid_set = sets.idle.PDT
        elseif state.HybridMode.value == 'MDT' and sets.idle.MDT then
            hybrid_set = sets.idle.MDT
        end

        if hybrid_set then
            result = set_combine(result, hybrid_set)
        end
    end

    -- Step 3: Apply main weapon (AFTER hybrid to ensure weapon takes priority)
    result = SetBuilder.apply_weapon(result)

    -- Step 4: Apply grip (skipped for Lycurgos)
    result = SetBuilder.apply_grip(result)

    -- Step 5: Early return if in town (weapons/grips already applied)
    if in_town then
        return result
    end

    -- Step 6: Apply movement speed
    result = SetBuilder.apply_movement(result)

    return result
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return SetBuilder

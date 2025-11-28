---============================================================================
--- COR Set Builder - Shared Equipment Set Construction Logic
---============================================================================
--- Provides shared logic for building engaged and idle sets with:
--- - Town/Adoulin detection (idle only)
--- - Weapon set application (main/sub/range)
--- - Movement gear application
--- - Hybrid mode support (PDT)
---
--- @file jobs/cor/functions/logic/set_builder.lua
--- @author Tetsouo
--- @version 2.0
--- @date Updated: 2025-10-08 (Refactored to modular architecture)
---============================================================================

local SetBuilder = {}

-- Load base set builder (universal functions)
local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')

-- Load message formatter for error reporting
local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- TOWN DETECTION (INHERITED FROM BASE)
---============================================================================

-- Inherit universal town detection function from BaseSetBuilder
SetBuilder.select_idle_base = BaseSetBuilder.select_idle_base_town

---============================================================================
--- SET AUGMENTATION
---============================================================================

--- Apply weapon sets to result (main+sub conditional on DW subjob, range separate)
--- COR only uses sub weapon if subjob = NIN or DNC (dual wield jobs)
--- For other subjobs (SCH, etc.), only main weapon is applied
--- @param result table Current equipment set
--- @return table Modified set with weapons applied
function SetBuilder.apply_weapon(result)
    if not result then
        return {}
    end

    -- Check if we should use dual wield (subjob = NIN or DNC)
    local use_dual_wield = false
    if player and player.sub_job then
        use_dual_wield = (player.sub_job == 'NIN' or player.sub_job == 'DNC')
    end

    -- Apply main weapon
    if state.MainWeapon and state.MainWeapon.current then
        local weapon_set = sets[state.MainWeapon.current]
        if weapon_set then
            if use_dual_wield then
                -- DW subjob: Apply full weapon set (main+sub)
                local success, combined = pcall(set_combine, result, weapon_set)
                if success then
                    result = combined
                else
                    MessageFormatter.show_error(string.format("Failed to apply weapon set: %s", combined))
                end
            else
                -- Non-DW subjob: Apply ONLY main weapon (skip sub)
                local main_only = { main = weapon_set.main }
                local success, combined = pcall(set_combine, result, main_only)
                if success then
                    result = combined
                else
                    MessageFormatter.show_error(string.format("Failed to apply main weapon: %s", combined))
                end
            end
        end
    end

    -- Apply range weapon separately (COR ranged focus)
    if state.RangeWeapon and state.RangeWeapon.current then
        local weapon_set = sets[state.RangeWeapon.current]
        if weapon_set then
            local success, combined = pcall(set_combine, result, weapon_set)
            if success then
                result = combined
            else
                MessageFormatter.show_error(string.format("Failed to apply range weapon: %s", combined))
            end
        end
    end

    return result
end

--- Apply movement speed gear to result (inherited from BaseSetBuilder)
SetBuilder.apply_movement = BaseSetBuilder.apply_movement


---============================================================================
--- COMPLETE SET BUILDERS
---============================================================================

--- Build complete engaged set (base selection + PDT + DW + weapons + movement)
--- @param base_set table Base engaged set from Mote
--- @return table Complete engaged set
function SetBuilder.build_engaged_set(base_set)
    if not base_set then
        return {}
    end

    -- Step 1: Start with base set
    local result = base_set

    -- Step 2: Apply Hybrid mode (PDT)
    if state.HybridMode and state.HybridMode.value == 'PDT' then
        if sets.engaged.PDT then
            local success, combined = pcall(set_combine, result, sets.engaged.PDT)
            if success then
                result = combined
            end
        end
    end

    -- Step 3: Apply Dual Wield gear if /NIN
    if player and player.sub_job == 'NIN' then
        if sets.engaged.DW then
            local success, combined = pcall(set_combine, result, sets.engaged.DW)
            if success then
                result = combined
            end
        end
    end

    -- Step 4: Apply weapon sets from states (main+sub together, range separate)
    result = SetBuilder.apply_weapon(result)

    return result
end

--- Build complete idle set (town detection + weapons + PDT + Refresh + movement)
--- @param base_set table Base idle set from Mote
--- @return table Complete idle set
function SetBuilder.build_idle_set(base_set)
    if not base_set then
        return {}
    end

    -- Step 1: Town/Adoulin detection - use town set as base
    local result, in_town = SetBuilder.select_idle_base(base_set)

    -- Step 2: Apply weapon sets from states (applies to both town and non-town)
    result = SetBuilder.apply_weapon(result)

    -- Step 3: Early return if in town (weapons already applied)
    if in_town then
        return result
    end

    -- Step 4: Apply Hybrid mode (PDT)
    if state.HybridMode and state.HybridMode.value == 'PDT' then
        if sets.idle.PDT then
            local success, combined = pcall(set_combine, result, sets.idle.PDT)
            if success then
                result = combined
            end
        end
    end

    -- Step 5: Apply Refresh gear if MP low
    if player and player.mpp and player.mpp < 50 then
        if sets.idle.Refresh then
            local success, combined = pcall(set_combine, result, sets.idle.Refresh)
            if success then
                result = combined
            end
        end
    end

    -- Step 6: Apply movement speed
    result = SetBuilder.apply_movement(result)

    return result
end

---============================================================================
--- BUFF-BASED SET MODIFICATIONS
---============================================================================

--- Apply buff-specific gear modifications
--- @param current_set table Current equipment set
--- @param buff_name string Buff name
--- @return table Modified set
function SetBuilder.apply_buff_gear(current_set, buff_name)
    if not current_set or not buff_name then
        return current_set
    end

    -- Doom gear
    if buff_name == "Doom" and sets.buff.Doom then
        return set_combine(current_set, sets.buff.Doom)
    end

    return current_set
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return SetBuilder

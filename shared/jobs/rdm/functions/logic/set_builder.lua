---============================================================================
--- Set Builder - Shared Set Construction Logic (RDM)
---============================================================================
--- Provides centralized set building for both engaged and idle states.
--- Handles weapon selection (MainWeapon/SubWeapon), mode detection (IdleMode,
--- EngagedMode), town detection, and movement speed.
---
--- @file jobs/rdm/functions/logic/set_builder.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-13
---============================================================================

local SetBuilder = {}

-- Load base set builder (universal functions)
local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')

-- Load dependencies
local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- MODE SELECTION (IDLE)
---============================================================================

--- Select idle base set based on IdleMode state
--- @param base_set table Base idle set
--- @return table Selected idle set based on IdleMode (DT, Refresh, Regain, Evasion)
function SetBuilder.select_idle_base(base_set)
    -- Use IdleMode state to select idle set (DT, Refresh, Regain, Evasion)
    if state.IdleMode and state.IdleMode.current then
        local mode = state.IdleMode.current

        -- Select set based on IdleMode
        if sets.idle and sets.idle[mode] then
            return sets.idle[mode]
        end
    end

    -- Legacy support for HybridMode = PDT
    if state.HybridMode and state.HybridMode.current == 'PDT' then
        if sets.idle and sets.idle.PDT then
            return sets.idle.PDT
        end
    end

    return base_set
end

---============================================================================
--- MODE SELECTION (ENGAGED)
---============================================================================

--- Select engaged base set based on EngagedMode state
--- @param base_set table Base engaged set
--- @return table Selected engaged set based on EngagedMode (DT, Enspell, Refresh, TP)
function SetBuilder.select_engaged_base(base_set)
    -- Use EngagedMode state to select engaged set (DT, Enspell, Refresh, TP)
    if state.EngagedMode and state.EngagedMode.current then
        local mode = state.EngagedMode.current

        -- Select set based on EngagedMode
        if sets.engaged and sets.engaged[mode] then
            return sets.engaged[mode]
        end
    end

    -- Legacy support for HybridMode = PDT
    if state.HybridMode and state.HybridMode.current == 'PDT' then
        if sets.engaged and sets.engaged.PDT then
            return sets.engaged.PDT
        end
    end

    return base_set
end

---============================================================================
--- WEAPON APPLICATION
---============================================================================

--- Apply main weapon and sub weapon to set (separately)
--- Uses weapon sets defined in rdm_sets.lua (sets['Crocea Mors'], sets['Genmei Shield'], etc.)
--- Note: CombatMode weapon locking is handled by disable()/enable() in job_update()
--- @param result table Current equipment set
--- @return table Set with weapons applied
function SetBuilder.apply_weapon(result)
    if not result then
        return {}
    end

    -- If CombatMode is On, don't apply weapon states (keep manual equipment)
    if state.CombatMode and state.CombatMode.current == "On" then
        return result
    end

    -- Apply main weapon (Crocea Mors, Naegling, Daybreak)
    if state.MainWeapon and state.MainWeapon.current then
        local weapon_set = sets[state.MainWeapon.current]
        if weapon_set then
            local success, combined = pcall(set_combine, result, weapon_set)
            if success then
                result = combined
            else
                MessageFormatter.show_error(string.format("Failed to apply MainWeapon set: %s", combined))
            end
        end
    end

    -- Apply sub weapon (Colada, Tauret, Ammurapi Shield, Genmei Shield)
    if state.SubWeapon and state.SubWeapon.current then
        local sub_set = sets[state.SubWeapon.current]
        if sub_set then
            local success, combined = pcall(set_combine, result, sub_set)
            if success then
                result = combined
            else
                MessageFormatter.show_error(string.format("Failed to apply SubWeapon set: %s", combined))
            end
        end
    end

    return result
end

---============================================================================
--- DUALWIELD DETECTION
---============================================================================

--- Apply Dualwield gear if NIN subjob
--- @param result table Current equipment set
--- @return table Set with Dualwield applied
function SetBuilder.apply_dualwield(result)
    -- Check for Dualwield subjob (NIN) - override with DW pieces
    if player and player.sub_job == 'NIN' then
        if sets.engaged and sets.engaged.DW then
            local success, combined = pcall(set_combine, result, sets.engaged.DW)
            if success then
                return combined
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
-- RDM doesn't use sets.Adoulin, so BaseSetBuilder will fallback to sets.idle.Town for all cities
SetBuilder.check_town = BaseSetBuilder.select_idle_base_town

---============================================================================
--- ENGAGED SET BUILDER
---============================================================================

--- Build complete engaged set with all RDM logic
--- @param base_set table Base engaged set
--- @return table Complete engaged set
function SetBuilder.build_engaged_set(base_set)
    if not base_set then
        return {}
    end

    -- Step 1: Select base set based on EngagedMode
    local result = SetBuilder.select_engaged_base(base_set)

    -- Step 2: Apply weapon (MainWeapon state)
    result = SetBuilder.apply_weapon(result)

    -- Step 3: Apply Dualwield gear if NIN subjob
    result = SetBuilder.apply_dualwield(result)

    return result
end

---============================================================================
--- IDLE SET BUILDER
---============================================================================

--- Build complete idle set with all RDM logic
--- @param base_set table Base idle set
--- @return table Complete idle set
function SetBuilder.build_idle_set(base_set)
    if not base_set then
        return {}
    end

    -- Step 1: Select base set based on IdleMode
    local result = SetBuilder.select_idle_base(base_set)

    -- Step 2: Town detection - use town set if in town
    local town_result, in_town = SetBuilder.check_town(result)
    result = town_result

    -- Step 3: Apply weapon (applies to both town and non-town)
    result = SetBuilder.apply_weapon(result)

    -- Step 4: Apply movement speed (if not in town)
    if not in_town then
        result = SetBuilder.apply_movement(result)
    end

    return result
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return SetBuilder

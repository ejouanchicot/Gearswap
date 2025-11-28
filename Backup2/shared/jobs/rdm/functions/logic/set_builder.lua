---  ═══════════════════════════════════════════════════════════════════════════
---   Set Builder - Shared Set Construction Logic (RDM)
---  ═══════════════════════════════════════════════════════════════════════════
---   Provides centralized set building for both engaged and idle states.
---   Handles weapon selection (MainWeapon/SubWeapon), mode detection (IdleMode,
---   EngagedMode), town detection, and movement speed.
---
---   @file    shared/jobs/rdm/functions/logic/set_builder.lua
---   @author  Tetsouo
---   @version 1.1 - Refactored with new header style
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = {}

-- Load base set builder (universal functions)
local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')

-- Load dependencies
local MessageFormatter = require('shared/utils/messages/message_formatter')

---  ═══════════════════════════════════════════════════════════════════════════
---   MODE SELECTION (IDLE)
---  ═══════════════════════════════════════════════════════════════════════════

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

---  ═══════════════════════════════════════════════════════════════════════════
---   MODE SELECTION (ENGAGED)
---  ═══════════════════════════════════════════════════════════════════════════

--- Select engaged base set based on EngagedMode state and shield detection
--- @param base_set table Base engaged set
--- @return table Selected engaged set based on EngagedMode and shield status
function SetBuilder.select_engaged_base(base_set)
    -- Use EngagedMode state to select engaged set (DT, Enspell, Refresh, TP)
    if state.EngagedMode and state.EngagedMode.current then
        local mode = state.EngagedMode.current

        -- Detect shield/single wield vs dual wield
        -- Priority: SubWeapon state > player.equipment (handles gear changes correctly)
        local sub_weapon = nil
        if state.SubWeapon and state.SubWeapon.current and state.SubWeapon.current ~= 'None' then
            sub_weapon = state.SubWeapon.current
        else
            sub_weapon = player.equipment and player.equipment.sub or nil
        end

        local has_shield = SetBuilder.has_shield_equipped(sub_weapon)

        if has_shield then
            -- Shield OR single wield >> use normal sets
            if sets.engaged and sets.engaged[mode] then
                return sets.engaged[mode]
            end
        else
            -- Dual wield (2 weapons) >> use .DW sets
            if sets.engaged and sets.engaged[mode] and sets.engaged[mode].DW then
                return sets.engaged[mode].DW
            end

            -- Fallback: .DW set doesn't exist, use normal set
            if sets.engaged and sets.engaged[mode] then
                return sets.engaged[mode]
            end
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

---  ═══════════════════════════════════════════════════════════════════════════
---   WEAPON APPLICATION
---  ═══════════════════════════════════════════════════════════════════════════

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

---  ═══════════════════════════════════════════════════════════════════════════
---   SHIELD DETECTION (WAR Fencer Model)
---  ═══════════════════════════════════════════════════════════════════════════

--- Detect if sub weapon is a shield OR single wield
--- Uses sets.shields table to determine if player is using:
--- - Shield (1 weapon + shield) >> use normal sets
--- - Single wield (1 weapon + empty) >> use normal sets
--- - Dual wield (2 weapons) >> use .DW sets
--- @param sub_weapon string Current sub weapon name from state.SubWeapon or player.equipment.sub
--- @return boolean True if shield OR single wield (use normal sets)
function SetBuilder.has_shield_equipped(sub_weapon)
    -- Safety checks: nil or empty string = error >> default to single wield
    if not sub_weapon or sub_weapon == "" then
        return true  -- Normal sets (fallback single wield)
    end

    -- Empty = single wield (1 weapon) >> normal sets
    if sub_weapon == "empty" then
        return true  -- Normal sets (not dual wield)
    end

    -- Iterate through shields table
    if sets.shields then
        for _, shield in ipairs(sets.shields) do
            if sub_weapon == shield then
                return true  -- Shield found >> normal sets
            end
        end
    end

    -- Dual wield (2 weapons)
    return false  -- Dual wield (2 weapons) >> .DW sets
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MOVEMENT SPEED (INHERITED FROM BASE)
---  ═══════════════════════════════════════════════════════════════════════════

-- Inherit universal movement function from BaseSetBuilder
SetBuilder.apply_movement = BaseSetBuilder.apply_movement


---  ═══════════════════════════════════════════════════════════════════════════
---   TOWN DETECTION (INHERITED FROM BASE)
---  ═══════════════════════════════════════════════════════════════════════════

-- Inherit universal town detection function from BaseSetBuilder
-- RDM doesn't use sets.Adoulin, so BaseSetBuilder will fallback to sets.idle.Town for all cities
SetBuilder.check_town = BaseSetBuilder.select_idle_base_town

---  ═══════════════════════════════════════════════════════════════════════════
---   ENGAGED SET BUILDER
---  ═══════════════════════════════════════════════════════════════════════════

--- Build complete engaged set with all RDM logic
--- @param base_set table Base engaged set
--- @return table Complete engaged set
function SetBuilder.build_engaged_set(base_set)
    if not base_set then
        return {}
    end

    -- Step 1: Select base set based on EngagedMode and shield detection
    -- This now handles both normal sets (shield/single wield) and .DW sets (dual wield)
    local result = SetBuilder.select_engaged_base(base_set)

    -- Step 2: Apply weapon (MainWeapon state)
    result = SetBuilder.apply_weapon(result)

    -- Note: Dual wield detection is now handled in select_engaged_base()
    -- Old apply_dualwield() function removed (was NIN subjob only)

    return result
end

---  ═══════════════════════════════════════════════════════════════════════════
---   IDLE SET BUILDER
---  ═══════════════════════════════════════════════════════════════════════════

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

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return SetBuilder

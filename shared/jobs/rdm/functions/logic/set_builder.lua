---  ═══════════════════════════════════════════════════════════════════════════
---   Set Builder - Shared Set Construction Logic (RDM)
---  ═══════════════════════════════════════════════════════════════════════════
---   Provides centralized set building for both engaged and idle states.
---   Handles weapon selection (MainWeapon/SubWeapon), mode detection (IdleMode,
---   EngagedMode, legacy HybridMode PDT), shield vs dual-wield detection,
---   town detection, and movement speed.
---
---   @file    shared/jobs/rdm/functions/logic/set_builder.lua
---   @author  Tetsouo
---   @version 1.1 - Refactored with new header style
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = {}

-- Load base set builder (universal functions)
local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')
local WeaponResolver = require('shared/utils/equipment/weapon_resolver')

-- Load dependencies
local MessageFormatter = require('shared/utils/messages/message_formatter')

---  ═══════════════════════════════════════════════════════════════════════════
---   MODE SELECTION (IDLE)
---  ═══════════════════════════════════════════════════════════════════════════

---   Select idle base set based on IdleMode state
---   @param base_set table Base idle set
---   @return table sets.idle[IdleMode] (Refresh, DT) when defined, else sets.idle.PDT under HybridMode PDT, else base_set
function SetBuilder.select_idle_base(base_set)
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

---   Select engaged base set based on EngagedMode state and shield detection
---   @param base_set table Base engaged set
---   @return table Selected engaged set based on EngagedMode and shield status
function SetBuilder.select_engaged_base(base_set)
    -- EngagedMode values: DT, Acc, TP, Enspell
    if state.EngagedMode and state.EngagedMode.current then
        local mode = state.EngagedMode.current

        local offhand = SetBuilder.offhand_item()
        local has_shield = SetBuilder.has_shield_equipped(offhand)
        local dw_set = not has_shield and sets.engaged and sets.engaged[mode] and sets.engaged[mode].DW
        require('shared/utils/debug/trace_log').log('ENGAGED', 'off hand %s -> %s -> sets.engaged.%s%s',
            tostring(offhand), has_shield and 'single wield' or 'dual wield', tostring(mode), dw_set and '.DW' or '')

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

---   Apply main weapon and sub weapon to set (separately)
---   Uses the weapon sets of rdm_sets.lua, keyed by state value (sets['Naegling'], sets['Genmei'], etc.)
---   Note: CombatMode weapon locking is handled by disable()/enable() in job_update()
---   @param result table Current equipment set
---   @return table Set with weapons applied
function SetBuilder.apply_weapon(result)
    if not result then
        return {}
    end

    -- If CombatMode is On, don't apply weapon states (keep manual equipment)
    if state.CombatMode and state.CombatMode.current == "On" then
        return result
    end

    -- Apply main weapon (WeaponResolver.set_for('main', state.MainWeapon.current))
    if state.MainWeapon and state.MainWeapon.current then
        local weapon_set = WeaponResolver.set_for('main', state.MainWeapon.current)
        if weapon_set then
            local success, combined = pcall(set_combine, result, weapon_set)
            if success then
                result = combined
            else
                MessageFormatter.show_error(string.format("Failed to apply MainWeapon set: %s", combined))
            end
        end
    end

    -- Apply sub weapon (WeaponResolver.set_for('sub', state.SubWeapon.current))
    if state.SubWeapon and state.SubWeapon.current then
        local sub_set = WeaponResolver.set_for('sub', state.SubWeapon.current)
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

---   Item name of the off hand the engaged set is for. While Combat Mode
---   locks the weapons, the SubWeapon state can change without the gear
---   following it: the worn item is the truth then. Otherwise the state's
---   value, through the set it names (sets['Genmei'] = {sub = 'Genmei Shield'}).
---   @return string|nil
function SetBuilder.offhand_item()
    local worn = player and player.equipment and player.equipment.sub or nil
    local value = state.SubWeapon and state.SubWeapon.current
    if (state.CombatMode and state.CombatMode.current == 'On') or not value or value == 'None' then
        return worn
    end
    local set = WeaponResolver.set_for('sub', value)
    local item = type(set) == 'table' and set.sub or nil
    if type(item) == 'table' then item = item.name end
    return type(item) == 'string' and item or value
end

---   Detect if sub weapon is a shield OR single wield
---   - Nothing in the off hand >> normal sets
---   - A weapon with a combat skill (game item list) >> .DW sets
---   - A shield or a grip >> normal sets
---   - A name the game does not know: sets.shields decides (old behaviour)
---   @param sub_weapon string|nil Off-hand item name
---   @return boolean True if shield OR single wield (use normal sets)
function SetBuilder.has_shield_equipped(sub_weapon)
    if not sub_weapon or sub_weapon == "" or sub_weapon == "empty" then
        return true
    end

    local dual = WeaponResolver.is_offhand_weapon(sub_weapon)
    if dual ~= nil then return not dual end

    -- Unknown name: the character's own shield list
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

-- Returns sets.Adoulin in the Adoulin cities when it exists (the RDM sets define it),
-- sets.idle.Town in the other cities, plus a second value telling whether the player is in town.
SetBuilder.check_town = BaseSetBuilder.select_idle_base_town

---  ═══════════════════════════════════════════════════════════════════════════
---   ENGAGED SET BUILDER
---  ═══════════════════════════════════════════════════════════════════════════

---   Build complete engaged set with all RDM logic
---   @param base_set table Base engaged set
---   @return table Complete engaged set
function SetBuilder.build_engaged_set(base_set)
    if not base_set then
        return {}
    end

    -- Step 1: Select base set based on EngagedMode and shield detection (normal or .DW)
    local result = SetBuilder.select_engaged_base(base_set)

    -- Step 2: Apply weapons (MainWeapon / SubWeapon states)
    result = SetBuilder.apply_weapon(result)

    return result
end

---  ═══════════════════════════════════════════════════════════════════════════
---   IDLE SET BUILDER
---  ═══════════════════════════════════════════════════════════════════════════

---   Build complete idle set with all RDM logic
---   @param base_set table Base idle set
---   @return table Complete idle set
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

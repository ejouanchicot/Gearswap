---============================================================================
--- Set Builder - Shared Set Construction Logic (BRD)
---============================================================================
--- Provides centralized set building for both engaged and idle states.
--- Handles mode detection (IdleMode), town detection, and movement speed.
---
--- @file jobs/brd/functions/logic/set_builder.lua
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
--- MODE SELECTION (IDLE) - WITH TOWN PRIORITY
---============================================================================

--- Select idle base set with Town detection AND IdleMode support
--- Priority order:
---   1. In town                     >> sets.idle.Town
---   2. IdleMode (Refresh/DT/Regen) >> sets.idle[IdleMode]
---   3. Fallback                    >> base_set
---
--- @param base_set table Base idle set
--- @return table Selected idle set
--- @return boolean True if in town
function SetBuilder.select_idle_base(base_set)
    -- Check town first (highest priority)
    local town_set, in_town = BaseSetBuilder.select_idle_base_town(base_set)
    if in_town then
        return town_set, true
    end

    -- IdleMode logic (Refresh, DT, Regen)
    if state.IdleMode and state.IdleMode.current then
        local mode = state.IdleMode.current
        if sets.idle and sets.idle[mode] then
            return sets.idle[mode], false
        end
    end

    -- Fallback to base
    return base_set, false
end

---============================================================================
--- MODE SELECTION (ENGAGED)
---============================================================================

--- Select engaged base set with Kraken Club detection and EngagedMode
--- Kraken Club detection takes highest priority for specialized multi-attack set.
---
--- Priority order:
---   1. Kraken Club in sub-weapon    >> sets.engaged.PDTKC
---   2. EngagedMode (STP/Acc/DT/SB)  >> sets.engaged[EngagedMode]
---   3. Fallback                      >> base_set
---
--- @param base_set table Base engaged set
--- @return table Selected engaged set (PDTKC if Kraken Club equipped, otherwise EngagedMode/base)
function SetBuilder.select_engaged_base(base_set)
    -- PRIORITY 1: Check for Kraken Club in sub-weapon slot
    if player and player.equipment and player.equipment.sub then
        local sub_weapon = player.equipment.sub
        if sub_weapon == 'Kraken Club' and sets.engaged.PDTKC then
            return sets.engaged.PDTKC
        end
    end

    -- PRIORITY 2: Use EngagedMode state to select engaged set (STP, Acc, DT, SB)
    if state.EngagedMode and state.EngagedMode.current then
        local mode = state.EngagedMode.current

        -- Select set based on EngagedMode
        if sets.engaged and sets.engaged[mode] then
            return sets.engaged[mode]
        end
    end

    return base_set
end

---============================================================================
--- WEAPON APPLICATION
---============================================================================

--- Apply main weapon to set
--- Uses weapon sets defined in brd_sets.lua (sets.Naegling, etc.)
--- @param result table Current equipment set
--- @return table Set with main weapon applied
function SetBuilder.apply_main_weapon(result)
    if not state.MainWeapon or not state.MainWeapon.current then
        return result
    end

    -- Try to use weapon set from brd_sets.lua (sets.Naegling, sets.Twashtar, etc.)
    local weapon_set = sets[state.MainWeapon.current]
    if weapon_set then
        local success, combined = pcall(set_combine, result, weapon_set)
        if success then
            return combined
        else
            MessageFormatter.show_error(string.format('Failed to apply main weapon: %s', combined))
        end
    end

    return result
end

--- Apply sub weapon to set
--- Uses weapon sets defined in brd_sets.lua (sets.Demersal, sets.Genmei, etc.)
--- @param result table Current equipment set
--- @return table Set with sub weapon applied
function SetBuilder.apply_sub_weapon(result)
    if not state.SubWeapon or not state.SubWeapon.current then
        return result
    end

    -- Try to use weapon set from brd_sets.lua (sets.Demersal, sets.Genmei, sets.Centovente)
    local weapon_set = sets[state.SubWeapon.current]
    if weapon_set then
        local success, combined = pcall(set_combine, result, weapon_set)
        if success then
            return combined
        else
            MessageFormatter.show_error(string.format('Failed to apply sub weapon: %s', combined))
        end
    end

    return result
end

--- Apply both main and sub weapons
--- @param result table Current equipment set
--- @return table Set with weapons applied
function SetBuilder.apply_weapons(result)
    result = SetBuilder.apply_main_weapon(result)
    result = SetBuilder.apply_sub_weapon(result)
    return result
end

---============================================================================
--- MOVEMENT SPEED (INHERITED FROM BASE)
---============================================================================

-- Inherit universal movement function from BaseSetBuilder
SetBuilder.apply_movement = BaseSetBuilder.apply_movement

---============================================================================
--- ENGAGED SET BUILDER
---============================================================================

--- Build complete engaged set with all BRD logic
--- @param base_set table Base engaged set
--- @return table Complete engaged set
function SetBuilder.build_engaged_set(base_set)
    if not base_set then
        return {}
    end

    -- Step 1: Select base set based on EngagedMode
    local result = SetBuilder.select_engaged_base(base_set)

    -- Step 2: Apply weapons (MainWeapon + SubWeapon)
    result = SetBuilder.apply_weapons(result)

    -- Step 3: Apply movement speed (BRD can move while singing)
    result = SetBuilder.apply_movement(result)

    return result
end

---============================================================================
--- IDLE SET BUILDER
---============================================================================

--- Build complete idle set with all BRD logic
--- Processing order:
---   1. Town detection (use town set as base if in safe zone)
---   2. Apply weapons (applies to both town and non-town)
---   3. Apply movement speed (non-town only)
---
--- @param base_set table Base idle set
--- @return table Complete idle set
function SetBuilder.build_idle_set(base_set)
    if not base_set then
        return {}
    end

    -- Step 1: Town detection + Mode selection (select_idle_base does BOTH now)
    local result, in_town = SetBuilder.select_idle_base(base_set)

    -- Step 2: Apply weapons (applies to both town and non-town)
    result = SetBuilder.apply_weapons(result)

    -- Step 3: Early return if in town (skip movement gear)
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

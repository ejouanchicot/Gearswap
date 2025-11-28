---============================================================================
--- GEO Set Builder - Shared Equipment Set Construction Logic
---============================================================================
--- Provides shared logic for building engaged and idle sets with:
--- - Luopan detection (sets.me.* vs sets.luopan.*)
--- - Town/Adoulin detection (idle only)
--- - Weapon set application (Idris)
--- - Movement gear application
---
--- GEO has two distinct set configurations:
---   sets.me.*     - No Luopan active (focus: refresh, defense)
---   sets.luopan.* - Luopan active (focus: Pet DT-, Pet Regen)
---
--- @file jobs/geo/functions/logic/set_builder.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-09
---============================================================================

local SetBuilder = {}

-- Load base set builder (universal functions)
local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')

-- Load message formatter for error reporting
local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- SET AUGMENTATION
---============================================================================

--- Apply weapon sets to result
--- GEO uses main weapon + sub weapon (shield)
--- Note: Combat Mode locking is handled via disable() in job_update()
--- @param result table Current equipment set
--- @return table Modified set with weapons applied
function SetBuilder.apply_weapon(result)
    if not result then
        return {}
    end

    -- Apply main weapon (Idris)
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

    -- Apply sub weapon (Genmei Shield)
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

--- Apply movement speed gear to result (inherited from BaseSetBuilder)
SetBuilder.apply_movement = BaseSetBuilder.apply_movement


---============================================================================
--- COMPLETE SET BUILDERS
---============================================================================

--- Build complete engaged set (base selection + LuopanMode + weapons + movement)
--- @param base_set table Base engaged set from Mote (ignored - we use sets.me/luopan)
--- @return table Complete engaged set
function SetBuilder.build_engaged_set(base_set)
    -- Step 1: Select base set based on Luopan status
    local result
    if pet and pet.isvalid then
        -- Luopan active - check LuopanMode state
        if state.LuopanMode and state.LuopanMode.current then
            local mode = state.LuopanMode.current

            -- Select set based on LuopanMode (DT or DPS)
            if mode == 'DT' and sets.luopan.engaged.DT then
                result = sets.luopan.engaged.DT
            elseif mode == 'DPS' and sets.luopan.engaged.DPS then
                result = sets.luopan.engaged.DPS
            else
                -- Fallback to DT if state invalid
                result = sets.luopan.engaged.DT or sets.me.engaged or {}
            end
        else
            -- No LuopanMode state - fallback to DT
            result = sets.luopan.engaged.DT or sets.me.engaged or {}
        end
    else
        -- No Luopan - use standard engaged set
        result = sets.me.engaged or {}
    end

    -- Step 2: Apply weapon sets from states (Idris)
    result = SetBuilder.apply_weapon(result)

    return result
end

--- Build complete idle set (Luopan detection + town detection + weapons + movement)
--- @param base_set table Base idle set from Mote (ignored - we use sets.me/luopan)
--- @return table Complete idle set
function SetBuilder.build_idle_set(base_set)
    -- Step 1: Select base set based on Luopan status (MOST IMPORTANT)
    local result
    if pet and pet.isvalid then
        -- Luopan active - use pet survival set (Pet DT, Pet Regen priority)
        result = sets.luopan.idle or sets.me.idle or {}
    else
        -- No Luopan - use standard idle set
        result = sets.me.idle or {}
    end

    -- Step 2: Town detection - use town set if in town (inherited from BaseSetBuilder)
    -- Note: Town gear overrides Luopan gear (safety priority in cities)
    local town_result, in_town = BaseSetBuilder.select_idle_base_town(result)
    result = town_result

    -- Step 3: Apply weapon sets from states (Idris)
    result = SetBuilder.apply_weapon(result)

    -- Step 4: Apply movement speed (if not in town)
    if not in_town then
        result = SetBuilder.apply_movement(result)
    end

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

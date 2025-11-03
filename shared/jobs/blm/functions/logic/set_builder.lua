---============================================================================
--- BLM Set Builder - Complete Equipment Set Construction Logic
---============================================================================
--- Provides comprehensive logic for building engaged and idle sets with:
--- - HybridMode detection (PDT/Normal)
--- - Town/Adoulin detection (idle only)
--- - Weapon set application (MainWeapon/SubWeapon)
--- - Movement gear application
--- - Dynamic MP-Based Sets (High/Low MP gear selection)
--- - Magic Burst Integration (specialized burst mode equipment)
--- - Manawall Support (emergency buff equipment)
---
--- @file jobs/blm/functions/logic/set_builder.lua
--- @author Tetsouo
--- @version 2.0 (Merged with SET_CUSTOMIZATION.lua)
--- @date Created: 2025-10-15 | Migrated: 2025-10-15
---============================================================================

local SetBuilder = {}

-- Load base set builder (universal functions)
local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')

-- Load message formatter for error reporting
local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- CONSTANTS AND CONFIGURATION
---============================================================================

--- BLM job constants for MP conservation and set selection
--- @type table<string, number> Constants for BLM functionality
local BLM_CONSTANTS = {
    LOW_MP_THRESHOLD = 1000, -- MP threshold for switching to conservation gear
}

---============================================================================
--- DYNAMIC MP-BASED SET MANAGEMENT
---============================================================================

--- Get dynamic elemental magic set based on MP and casting mode
--- Returns appropriate equipment set without mutating global sets
--- @param castingMode string Current casting mode ('Normal' or other for MagicBurst)
--- @param currentMP number Player's current MP value
--- @return table Equipment set for current conditions
function SetBuilder.get_dynamic_elemental_set(castingMode, currentMP)
    -- Validate that dynamic sets are available
    if not blm_dynamic_sets then
        -- Fallback to regular sets if dynamic sets not configured
        if castingMode == 'Normal' then
            return sets and sets.midcast and sets.midcast['Elemental Magic'] or {}
        else
            return sets and sets.midcast and sets.midcast['Elemental Magic'] and
                sets.midcast['Elemental Magic'].MagicBurst or {}
        end
    end

    -- Select appropriate set based on MP threshold and casting mode
    if currentMP < BLM_CONSTANTS.LOW_MP_THRESHOLD then
        return castingMode == 'Normal' and blm_dynamic_sets.normalSetLowMP or blm_dynamic_sets.magicBurstSetLowMP
    else
        return castingMode == 'Normal' and blm_dynamic_sets.normalSetHighMP or blm_dynamic_sets.magicBurstSetHighMP
    end
end

--- Apply MP-based gear optimization to current sets
--- Gets appropriate gear set based on current MP and casting mode without mutating global sets
function SetBuilder.SaveMP()
    -- Validate required state and player data
    if not player or not player.mp then
        MessageFormatter.show_error("player.mp must not be nil")
        return
    end

    if not state or not state.CastingMode or not state.CastingMode.value then
        MessageFormatter.show_error("state.CastingMode.value must not be nil")
        return
    end

    -- Get appropriate set without mutating global sets
    local dynamicSet = SetBuilder.get_dynamic_elemental_set(state.CastingMode.value, player.mp)

    -- Ensure sets structure exists
    if not sets then
        sets = {}
    end
    if not sets.midcast then
        sets.midcast = {}
    end

    -- Apply the set based on casting mode
    if state.CastingMode.value == 'Normal' then
        sets.midcast['Elemental Magic'] = dynamicSet
    else
        if not sets.midcast['Elemental Magic'] then
            sets.midcast['Elemental Magic'] = {}
        end
        sets.midcast['Elemental Magic'].MagicBurst = dynamicSet
    end
end

---============================================================================
--- SET AUGMENTATION
---============================================================================

--- Apply weapon sets to result
--- BLM uses main weapon + sub weapon
--- Note: Combat Mode locking is handled via disable() in job_update()
--- @param result table Current equipment set
--- @return table Modified set with weapons applied
function SetBuilder.apply_weapon(result)
    if not result then
        return {}
    end

    -- Apply main weapon
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

    -- Apply sub weapon
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

--- Build complete engaged set (base selection + HybridMode + weapons + movement)
--- @param base_set table Base engaged set from Mote
--- @return table Complete engaged set
function SetBuilder.build_engaged_set(base_set)
    -- Step 1: Use base set from Mote (already includes HybridMode)
    local result = base_set or sets.engaged.Normal or {}

    -- Step 2: Apply weapon sets from states
    result = SetBuilder.apply_weapon(result)

    return result
end

--- Build complete idle set (HybridMode + town detection + weapons + movement + buffs)
--- @param base_set table Base idle set from Mote
--- @return table Complete idle set
function SetBuilder.build_idle_set(base_set)
    -- Step 1: Use base set from Mote (already includes HybridMode)
    local result = base_set or sets.idle.Normal or {}

    -- Step 2: Town detection - use town set as base (inherited from BaseSetBuilder)
    local town_result, in_town = BaseSetBuilder.select_idle_base_town(result)
    result = town_result

    -- Step 3: Apply weapon sets from states
    result = SetBuilder.apply_weapon(result)

    -- Step 4: Apply movement speed (if not in town)
    if not in_town then
        result = SetBuilder.apply_movement(result)
    end

    -- Step 5: Apply BLM-specific buff gear (Manawall)
    if buffactive and buffactive['Mana Wall'] and sets.buff and sets.buff['Mana Wall'] then
        local success, combined = pcall(set_combine, result, sets.buff['Mana Wall'])
        if success then
            result = combined
        end
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

    -- Mana Wall gear
    if buff_name == "Mana Wall" and sets.buff and sets.buff['Mana Wall'] then
        return set_combine(current_set, sets.buff['Mana Wall'])
    end

    return current_set
end

--- Get all currently relevant buff modifications for BLM
--- @param baseSet table Base equipment set
--- @return table Set with all relevant buff modifications applied
function SetBuilder.apply_all_buff_sets(baseSet)
    local modifiedSet = baseSet or {}

    -- Apply Mana Wall set if buff is active
    if sets and sets.buff and sets.buff['Mana Wall'] then
        modifiedSet = SetBuilder.apply_buff_gear(modifiedSet, 'Mana Wall')
    end

    -- Apply Doom set if buff is active
    if sets and sets.buff and sets.buff.Doom then
        modifiedSet = SetBuilder.apply_buff_gear(modifiedSet, 'Doom')
    end

    return modifiedSet
end

---============================================================================
--- SET VALIDATION AND UTILITIES
---============================================================================

--- Validate that required dynamic sets are configured
--- @return boolean true if dynamic sets are properly configured
function SetBuilder.validate_dynamic_sets()
    if not blm_dynamic_sets then
        return false
    end

    local required_sets = {
        'normalSetLowMP',
        'magicBurstSetLowMP',
        'normalSetHighMP',
        'magicBurstSetHighMP'
    }

    for _, setName in ipairs(required_sets) do
        if not blm_dynamic_sets[setName] then
            return false
        end
    end

    return true
end

--- Get current MP threshold status
--- @return string 'low' or 'high' based on current MP
function SetBuilder.get_mp_status()
    if not player or not player.mp then
        return 'unknown'
    end

    return player.mp < BLM_CONSTANTS.LOW_MP_THRESHOLD and 'low' or 'high'
end

--- Get recommended set name for current conditions
--- @param castingMode string Current casting mode
--- @param currentMP number Current MP value (optional, uses player.mp if not provided)
--- @return string Recommended set name
function SetBuilder.get_recommended_set_name(castingMode, currentMP)
    local mp = currentMP or (player and player.mp) or 0
    local mpStatus = mp < BLM_CONSTANTS.LOW_MP_THRESHOLD and 'Low' or 'High'
    local modeStatus = castingMode == 'Normal' and 'normal' or 'magicBurst'

    return modeStatus .. 'Set' .. mpStatus .. 'MP'
end

--- Update MP threshold configuration
--- @param newThreshold number New MP threshold value
function SetBuilder.update_mp_threshold(newThreshold)
    if type(newThreshold) == 'number' and newThreshold > 0 then
        BLM_CONSTANTS.LOW_MP_THRESHOLD = newThreshold
        return true
    end
    return false
end

--- Get current MP threshold value
--- @return number Current MP threshold
function SetBuilder.get_mp_threshold()
    return BLM_CONSTANTS.LOW_MP_THRESHOLD
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return SetBuilder

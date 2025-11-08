---============================================================================
--- Set Builder - Shared Equipment Set Construction Logic (Logic Module)
---============================================================================
--- Provides shared logic for building engaged and idle sets with dynamic gear
--- selection based on buffs and conditions.
---
--- Features:
---   • Saber Dance variant selection (engaged only - optimized for -50% DW requirement)
---   • Fan Dance variant selection (engaged only - 30% gear + 20% buff = 50% cap)
---   • Town detection (idle only - Adoulin vs regular cities)
---   • Weapon set application (MainWeapon state >> equipment combo)
---   • Movement gear application (idle only, never in combat)
---   • HybridMode integration (PDT/Normal/FanDance/SaberDance sets)
---   • Error handling with MessageFormatter
---   • Modular set augmentation (weapon >> movement >> final)
---
--- @file    jobs/dnc/functions/logic/set_builder.lua
--- @author  Tetsouo
--- @version 1.1 - Saber Dance Support
--- @date    Created: 2025-10-06
--- @date    Updated: 2025-10-19
---============================================================================

local SetBuilder = {}

-- Load base set builder (universal functions)
local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')

-- Load message formatter for error reporting
local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- BASE SET SELECTION
---============================================================================

--- Select base engaged set based on HybridMode, Saber Dance, and Fan Dance buffs
--- NOTE: Saber Dance and Fan Dance are MUTUALLY EXCLUSIVE (one overwrites the other)
--- Saber Dance: -50% DW requirement, optimize for Haste/STP/Multi-Attack
--- Fan Dance: +20% DT, allowing lighter gear (30% + 20% = 50% cap)
--- @param base_set table Base engaged set from Mote
--- @return table Selected engaged set
function SetBuilder.select_engaged_base(base_set)
    local has_saber_dance = buffactive and buffactive['Saber Dance']
    local has_fan_dance = buffactive and buffactive['Fan Dance']

    -- Debug: uncomment to track buff states
    -- Debug disabled (use debug logging if needed)

    -- Priority 1: Saber Dance active (mutually exclusive with Fan Dance)
    if has_saber_dance and sets.engaged.SaberDance then
        -- Check if in PDT mode
        if state.HybridMode and state.HybridMode.current == 'PDT' then
            -- Saber Dance + PDT
            if sets.engaged.SaberDance.PDT then
                return sets.engaged.SaberDance.PDT
            end
        end

        -- Saber Dance only (Normal mode)
        return sets.engaged.SaberDance
    end

    -- Priority 2: Fan Dance active (only if Saber Dance not active)
    if state.HybridMode and state.HybridMode.current == 'PDT' then
        -- Fan Dance active: use FanDance set (30% equipment + 20% buff = 50% cap)
        if has_fan_dance and sets.engaged.FanDance then
            return sets.engaged.FanDance
        else
            -- No Fan Dance: use regular PDT set (50% equipment = 50% cap)
            return sets.engaged.PDT
        end
    elseif state.HybridMode and state.HybridMode.current then
        -- Other hybrid modes (Normal, etc.)
        local hybrid_set = sets.engaged[state.HybridMode.current]
        if hybrid_set then
            return hybrid_set
        end
    end

    -- No hybrid mode or not found, use base set
    return base_set
end

--- Select base idle set with town/Adoulin detection (inherited from BaseSetBuilder)
SetBuilder.select_idle_base = BaseSetBuilder.select_idle_base_town

---============================================================================
--- SET AUGMENTATION
---============================================================================

--- Apply weapon set to result
--- Combines current set with MainWeapon set (main + sub + ammo combo)
--- Then applies SubWeaponOverride if enabled
--- @param result table Current equipment set
--- @return table Modified set with weapon applied
function SetBuilder.apply_weapon(result)
    -- Step 1: Apply main weapon set (main + sub + ammo)
    if state.MainWeapon and state.MainWeapon.current then
        local weapon_set = sets[state.MainWeapon.current]
        if weapon_set then
            local success, combined = pcall(set_combine, result, weapon_set)
            if success then
                result = combined
            else
                MessageFormatter.show_error(string.format("Failed to apply weapon set: %s", combined))
                return result
            end
        end
    end

    -- Step 2: Apply SubWeaponOverride if enabled (overrides sub from weapon set)
    if state.SubWeaponOverride and state.SubWeaponOverride.current ~= 'Off' then
        local override_name = state.SubWeaponOverride.current
        local override_set = sets[override_name]

        if override_set and override_set.sub then
            -- Only override the sub weapon slot
            result.sub = override_set.sub
        else
            MessageFormatter.show_warning(string.format("SubWeaponOverride '%s' has no sub weapon defined", override_name))
        end
    end

    return result
end

--- Apply movement speed gear to result (inherited from BaseSetBuilder)
SetBuilder.apply_movement = BaseSetBuilder.apply_movement


---============================================================================
--- COMPLETE SET BUILDERS
---============================================================================

--- Build complete engaged set (base selection + weapon)
--- @param base_set table Base engaged set from Mote
--- @return table Complete engaged set
function SetBuilder.build_engaged_set(base_set)
    local result = SetBuilder.select_engaged_base(base_set)
    result = SetBuilder.apply_weapon(result)
    return result
end

--- Build complete idle set (town detection + weapon + movement)
--- @param base_set table Base idle set from Mote
--- @return table Complete idle set
function SetBuilder.build_idle_set(base_set)
    local result, in_town = SetBuilder.select_idle_base(base_set)
    result = SetBuilder.apply_weapon(result)

    -- Early return if in town (weapons already applied, no movement gear)
    if in_town then
        return result
    end

    -- Apply movement gear if not in town
    result = SetBuilder.apply_movement(result)
    return result
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return SetBuilder

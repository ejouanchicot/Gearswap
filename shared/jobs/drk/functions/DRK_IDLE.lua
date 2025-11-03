---============================================================================
--- DRK Idle Module - Idle State Management
---============================================================================
--- Handles all idle state logic for Dark Knight job:
---   • Idle set selection based on conditions
---   • Movement speed optimization
---   • Dynamic weapon application to idle sets
---   • Town gear management
---
--- @file    DRK_IDLE.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-10-23
--- @requires Tetsouo architecture
---============================================================================

---============================================================================
--- IDLE CUSTOMIZATION HOOK
---============================================================================

--- Apply weapon sets and movement gear to idle configuration
--- Called by Mote-Include when idle set is selected.
---
--- Processing order:
---   1. Apply current weapon set (state.MainWeapon/SubWeapon)
---   2. Apply movement gear if moving
---   3. Apply hybrid mode gear (PDT/Normal)
---
--- @param idleSet table The base idle set from drk_sets.lua
--- @return table Modified idle set with weapon/movement/hybrid gear applied
function customize_idle_set(idleSet)
    if not idleSet then
        return {}
    end

    -- Start with BASE idle set (ignore HybridMode set passed by Mote)
    -- This ensures weapon sets are applied correctly
    local custom_set = sets.idle

    -- Step 1: Apply weapon FIRST
    if state.MainWeapon and state.MainWeapon.current then
        local weapon_set = sets[state.MainWeapon.current]
        if weapon_set then
            custom_set = set_combine(custom_set, weapon_set)
        end
    end

    -- Step 2: Apply HybridMode (PDT/Normal) AFTER weapons
    -- Filter out main/sub to preserve weapons
    if state.HybridMode and state.HybridMode.current then
        local hybrid_set = sets.idle[state.HybridMode.current]
        if hybrid_set then
            local hybrid_no_weapons = {}
            for slot, item in pairs(hybrid_set) do
                if slot ~= 'main' and slot ~= 'sub' then
                    hybrid_no_weapons[slot] = item
                end
            end
            custom_set = set_combine(custom_set, hybrid_no_weapons)
        end
    end

    -- Step 3: Apply movement gear
    if state.Moving and state.Moving.value == 'true' then
        -- Use sets.MoveSpeed (AutoMove standard)
        if sets.MoveSpeed then
            custom_set = set_combine(custom_set, sets.MoveSpeed)
        end
    end

    return custom_set
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.customize_idle_set = customize_idle_set

-- Export as module (for future require() usage)
return {
    customize_idle_set = customize_idle_set
}

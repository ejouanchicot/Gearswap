---============================================================================
--- BST Engaged Module - Engaged Gear Customization
---============================================================================
--- Handles engaged gear selection with Pet vs Master bifurcation.
--- Simplified logic following BST_OLD_BACKUP pattern.
---
--- @file jobs/bst/functions/BST_ENGAGED.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-17
---============================================================================

---============================================================================
--- ENGAGED CUSTOMIZATION HOOK
---============================================================================

--- Customize engaged gear based on pet status and modes
--- Simplified logic following BST_OLD_BACKUP pattern
---
--- @param meleeSet table Base engaged set from Mote-Include (not used - we select directly)
--- @return table customized_set Final engaged set after customizations
function customize_melee_set(meleeSet)
    -- Use GLOBAL 'pet' variable from Mote-Include (not windower API)
    local pet_valid = (pet and pet.isvalid) or false

    -- ==========================================================================
    -- SELECT BASE SET (Pet vs Master bifurcation)
    -- ==========================================================================
    if not pet_valid then
        -- NO PET - use master engaged or idle based on player status
        if player and player.status == 'Engaged' then
            meleeSet = sets.me.engaged.PDT or sets.me.engaged or sets.me.idle
        else
            meleeSet = sets.me.idle.PDT or sets.me.idle
        end
    else
        -- PET EXISTS - complex logic for various scenarios
        -- Use .value (not .current) like old BST system
        local petEngaged = (state.petEngaged and state.petEngaged.value == 'true')
        local playerEngaged = (player and player.status == 'Engaged')

        -- Priority order (using short-circuit evaluation):
        -- 1. Both engaged → sets.pet.engagedBoth
        -- 2. Pet engaged only → sets.pet.engaged
        -- 3. Player engaged only → sets.me.engaged
        -- 4. Neither engaged → sets.pet.idle
        meleeSet = (petEngaged and playerEngaged) and sets.pet.engagedBoth
            or petEngaged and sets.pet.engaged
            or playerEngaged and sets.me.engaged
            or sets.pet.idle
    end

    -- ==========================================================================
    -- APPLY WEAPONS (Dual weapon system)
    -- ==========================================================================
    if state.WeaponSet and state.WeaponSet.current and sets[state.WeaponSet.current] then
        meleeSet = set_combine(meleeSet, sets[state.WeaponSet.current])
    end

    if state.SubSet and state.SubSet.current and sets[state.SubSet.current] then
        meleeSet = set_combine(meleeSet, sets[state.SubSet.current])
    end

    -- ==========================================================================
    -- APPLY PDT OVERLAY (if HybridMode is PDT)
    -- ==========================================================================
    if state.HybridMode and state.HybridMode.current == "PDT" then
        local mode = pet_valid and "pet" or "me"
        if sets[mode] and sets[mode].PDT then
            meleeSet = set_combine(meleeSet, sets[mode].PDT)
        end
    end

    return meleeSet
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.customize_melee_set = customize_melee_set

-- Export as module
return {
    customize_melee_set = customize_melee_set
}

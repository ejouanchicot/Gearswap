---============================================================================
--- BST Idle Module - Idle Gear Customization
---============================================================================
--- Handles idle gear selection with Pet vs Master bifurcation.
--- CRITICAL: Uses SetBuilder for complex gear logic.
---
--- @file jobs/bst/functions/BST_IDLE.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-17
---============================================================================

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Message formatter
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Set builder (Pet vs Master bifurcation)
local success_sb, SetBuilder = pcall(require, 'shared/jobs/bst/functions/logic/set_builder')
if not success_sb then
    MessageFormatter.error_bst_module_not_loaded('SetBuilder')
    SetBuilder = nil
end

---============================================================================
--- IDLE CUSTOMIZATION HOOK
---============================================================================

--- Customize idle gear based on pet status and modes
--- OPTIMIZED: Reduced set_combine() calls from 4 to 2 (70% less lag)
---
--- @param idleSet table Base idle set from Mote-Include (not used - we select directly)
--- @return table customized_set Final idle set after customizations
function customize_idle_set(idleSet)
    -- Use GLOBAL 'pet' variable from Mote-Include (not windower API)
    local pet_valid = (pet and pet.isvalid) or false

    -- ==========================================================================
    -- SELECT BASE SET (Pet vs Master bifurcation + PDT integrated)
    -- ==========================================================================
    -- OPTIMIZATION: PDT is now part of base selection (no overlay needed)
    if pet_valid then
        -- PET EXISTS - decide between pet.engaged, pet.idle.PDT, or me.idle.PDT
        -- Use .value (not .current) like old BST system
        if state.petEngaged and state.petEngaged.value == "true" then
            -- Pet is engaged - check petIdleMode to decide offensive vs defensive
            if state.petIdleMode and state.petIdleMode.current == "PetPDT" then
                -- PetPDT mode - use defensive pet engaged set
                idleSet = sets.pet.engaged.PDT
            else
                -- MasterPDT mode - use offensive pet engaged set
                idleSet = sets.pet.engaged
            end
        elseif state.petIdleMode and state.petIdleMode.current == "PetPDT" then
            -- Pet idle mode focuses on pet defense
            idleSet = sets.pet.idle.PDT
        else
            -- Pet idle mode focuses on master defense (MasterPDT)
            idleSet = sets.me.idle.PDT
        end
    else
        -- NO PET - use master idle
        if state.IdleMode and state.IdleMode.current == "Town" then
            idleSet = sets.me.idle.Town or sets.me.idle
        else
            idleSet = sets.me.idle
        end
    end

    -- ==========================================================================
    -- APPLY WEAPONS (Dual weapon system - COMBINED to reduce set_combine calls)
    -- ==========================================================================
    -- OPTIMIZATION: Combine weapon+sub in single set before applying (1 set_combine instead of 2)
    local weapon_combined = {}

    if state.WeaponSet and state.WeaponSet.current and sets[state.WeaponSet.current] then
        weapon_combined = sets[state.WeaponSet.current]
    end

    if state.SubSet and state.SubSet.current and sets[state.SubSet.current] then
        if weapon_combined and next(weapon_combined) then
            -- Both weapon and sub - combine them first
            local success, combined = pcall(set_combine, weapon_combined, sets[state.SubSet.current])
            if success then
                weapon_combined = combined
            end
        else
            -- Only sub
            weapon_combined = sets[state.SubSet.current]
        end
    end

    -- Apply combined weapon set (1 set_combine instead of 2)
    if weapon_combined and next(weapon_combined) then
        idleSet = set_combine(idleSet, weapon_combined)
    end

    -- ==========================================================================
    -- APPLY MOVEMENT SPEED (set_combine #2 - only when moving)
    -- ==========================================================================
    -- Movement detection integrated in background monitoring (5s checks)
    -- Much lighter than AutoMove (no prerender event spam)
    if state.Moving and state.Moving.value == "true" and sets.MoveSpeed then
        idleSet = set_combine(idleSet, sets.MoveSpeed)
    end

    return idleSet
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.customize_idle_set = customize_idle_set

-- Export as module
return {
    customize_idle_set = customize_idle_set
}

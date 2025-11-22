---============================================================================
--- BST Set Builder - Pet vs Master Gear Bifurcation
---============================================================================
--- Handles complex gear logic with Pet vs Master bifurcation.
--- CRITICAL MODULE: Determines whether to use pet or master gear based on pet.isvalid.
---
--- @file jobs/bst/functions/logic/set_builder.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-17
---============================================================================

local SetBuilder = {}

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Load pet manager (for pet_valid cache)
local PetManager = require('shared/jobs/bst/functions/logic/pet_manager')

---============================================================================
--- IDLE SET BUILDER (Pet vs Master Bifurcation)
---============================================================================

--- Build idle set with Pet vs Master bifurcation
--- CRITICAL LOGIC:
---   • If pet valid >> Use pet sets (pet.idle or pet.engaged based on petEngaged state)
---   • If no pet >> Use master sets (me.idle with town detection)
---   • ALWAYS apply: WeaponSet, SubSet, HybridMode, Movement
---
--- @param base_idle_set table Base idle set from sets.me.idle
--- @return table final_set Final idle set after all customizations
function SetBuilder.build_idle_set(base_idle_set)
    -- Use GLOBAL pet from Mote-Include (cached, no API call)
    local pet = _G.pet

    -- Update pet mode cache
    PetManager.update_pet_mode(pet)
    local pet_mode = PetManager.get_pet_mode()

    local final_set = base_idle_set

    ---========================================================================
    --- BIFURCATION 1: Pet Valid or Not
    ---========================================================================

    if pet_mode.pet_valid then
        -- ====================================================================
        -- PET ACTIVE - Use pet sets
        -- ====================================================================

        -- Check if pet is engaged (STRING comparison!)
        if state.petEngaged and state.petEngaged.value == "true" then
            -- Pet is engaged - use pet engaged set
            final_set = sets.pet.engaged or sets.pet.idle or base_idle_set

            -- Apply pet engaged PDT if HybridMode is PDT
            if state.HybridMode and state.HybridMode.value == "PDT" then
                if sets.pet.engaged and sets.pet.engaged.PDT then
                    final_set = set_combine(final_set, sets.pet.engaged.PDT)
                elseif sets.pet.PDT then
                    final_set = set_combine(final_set, sets.pet.PDT)
                end
            end
        else
            -- Pet is idle - check petIdleMode
            if state.petIdleMode and state.petIdleMode.value == "PetPDT" then
                -- Focus on pet PDT
                final_set = sets.pet.idle.PDT or sets.pet.idle or base_idle_set

                -- Apply pet idle PDT overlay if HybridMode is PDT (only in PetPDT mode)
                if state.HybridMode and state.HybridMode.value == "PDT" then
                    if sets.pet.idle and sets.pet.idle.PDT then
                        final_set = set_combine(final_set, sets.pet.idle.PDT)
                    elseif sets.pet.PDT then
                        final_set = set_combine(final_set, sets.pet.PDT)
                    end
                end
            else
                -- Focus on master PDT (MasterPDT mode)
                final_set = sets.me.idle.PDT or sets.me.idle or base_idle_set

                -- Apply master PDT overlay if HybridMode is PDT (only in MasterPDT mode)
                if state.HybridMode and state.HybridMode.value == "PDT" then
                    if sets.me.idle and sets.me.idle.PDT then
                        final_set = set_combine(final_set, sets.me.idle.PDT)
                    elseif sets.me.PDT then
                        final_set = set_combine(final_set, sets.me.PDT)
                    end
                end
            end
        end

    else
        -- ====================================================================
        -- NO PET - Use master sets
        -- ====================================================================

        -- Check if in town
        if state.IdleMode and state.IdleMode.value == "Town" then
            final_set = sets.me.idle.Town or sets.me.idle or base_idle_set
        else
            final_set = sets.me.idle or base_idle_set
        end

        -- Apply master PDT if HybridMode is PDT
        if state.HybridMode and state.HybridMode.value == "PDT" then
            if sets.me.idle and sets.me.idle.PDT then
                final_set = set_combine(final_set, sets.me.idle.PDT)
            elseif sets.me.PDT then
                final_set = set_combine(final_set, sets.me.PDT)
            end
        end
    end

    ---========================================================================
    --- ALWAYS APPLY: Dual Weapon System (Pet or No Pet)
    ---========================================================================

    if state.WeaponSet and state.WeaponSet.value and sets[state.WeaponSet.value] then
        final_set = set_combine(final_set, sets[state.WeaponSet.value])
    end

    if state.SubSet and state.SubSet.value and sets[state.SubSet.value] then
        final_set = set_combine(final_set, sets[state.SubSet.value])
    end

    ---========================================================================
    --- ALWAYS APPLY: Movement Speed (Pet or No Pet)
    ---========================================================================

    if state.Moving and state.Moving.value == "true" and sets.MoveSpeed then
        final_set = set_combine(final_set, sets.MoveSpeed)
    end

    return final_set
end

---============================================================================
--- ENGAGED SET BUILDER (Pet vs Master Bifurcation)
---============================================================================

--- Build engaged set with Pet vs Master bifurcation
--- CRITICAL LOGIC (3 CASES):
---   • Case 1: BOTH master AND pet engaged >> Use engagedBoth sets
---   • Case 2: Pet engaged ONLY (master idle) >> Use pet engaged sets
---   • Case 3: Master engaged ONLY (no pet OR pet idle) >> Use master engaged sets
---   • ALWAYS apply: WeaponSet, SubSet, HybridMode
---
--- @param base_engaged_set table Base engaged set from sets.me.engaged
--- @return table final_set Final engaged set after all customizations
function SetBuilder.build_engaged_set(base_engaged_set)
    -- Use GLOBAL pet and player from Mote-Include (cached, no API call)
    local pet = _G.pet
    local player = _G.player

    -- Update pet mode cache
    PetManager.update_pet_mode(pet)
    local pet_mode = PetManager.get_pet_mode()

    local final_set = base_engaged_set

    -- Check if pet is engaged (STRING comparison!)
    local pet_is_engaged = state.petEngaged and state.petEngaged.value == "true"

    -- Check if master is engaged
    local master_is_engaged = player and player.status == 'Engaged'

    ---========================================================================
    --- BIFURCATION: 3-Way Split (Both / Pet Only / Master Only)
    ---========================================================================

    if master_is_engaged and pet_mode.pet_valid and pet_is_engaged then
        -- ====================================================================
        -- CASE 1: BOTH MASTER AND PET ENGAGED - Use engagedBoth sets
        -- ====================================================================

        final_set = sets.pet.engagedBoth or sets.me.engaged or base_engaged_set

        -- Apply engagedBoth PDT if HybridMode is PDT
        if state.HybridMode and state.HybridMode.value == "PDT" then
            if sets.pet.engagedBoth and sets.pet.engagedBoth.PDT then
                final_set = set_combine(final_set, sets.pet.engagedBoth.PDT)
            elseif sets.pet.PDT then
                final_set = set_combine(final_set, sets.pet.PDT)
            end
        end

    elseif pet_mode.pet_valid and pet_is_engaged then
        -- ====================================================================
        -- CASE 2: PET ENGAGED ONLY (master idle) - Use pet engaged sets
        -- ====================================================================

        final_set = sets.pet.engaged or base_engaged_set

        -- Apply pet engaged PDT if HybridMode is PDT
        if state.HybridMode and state.HybridMode.value == "PDT" then
            if sets.pet.engaged and sets.pet.engaged.PDT then
                final_set = set_combine(final_set, sets.pet.engaged.PDT)
            elseif sets.pet.PDT then
                final_set = set_combine(final_set, sets.pet.PDT)
            end
        end

    else
        -- ====================================================================
        -- CASE 3: MASTER ENGAGED ONLY (no pet OR pet idle) - Use master sets
        -- ====================================================================

        final_set = sets.me.engaged or base_engaged_set

        -- Apply master engaged PDT if HybridMode is PDT
        if state.HybridMode and state.HybridMode.value == "PDT" then
            if sets.me.engaged and sets.me.engaged.PDT then
                final_set = set_combine(final_set, sets.me.engaged.PDT)
            elseif sets.me.PDT then
                final_set = set_combine(final_set, sets.me.PDT)
            end
        end
    end

    ---========================================================================
    --- ALWAYS APPLY: Dual Weapon System
    ---========================================================================

    if state.WeaponSet and state.WeaponSet.value and sets[state.WeaponSet.value] then
        final_set = set_combine(final_set, sets[state.WeaponSet.value])
    end

    if state.SubSet and state.SubSet.value and sets[state.SubSet.value] then
        final_set = set_combine(final_set, sets[state.SubSet.value])
    end

    return final_set
end

---============================================================================
--- UTILITY FUNCTIONS
---============================================================================

--- Check if should use pet sets (pet valid)
--- @return boolean use_pet_sets True if pet sets should be used
function SetBuilder.should_use_pet_sets()
    local pet = windower.ffxi.get_mob_by_target('pet')
    PetManager.update_pet_mode(pet)
    local pet_mode = PetManager.get_pet_mode()
    return pet_mode.pet_valid
end

--- Check if pet is engaged (STRING comparison!)
--- @return boolean is_engaged True if pet is engaged
function SetBuilder.is_pet_engaged()
    if not state or not state.petEngaged then
        return false
    end

    -- STRING comparison!
    return state.petEngaged.current == "true"
end

--- Get current pet mode focus ("pet" or "master")
--- Used for determining which PDT overlay to apply
--- @return string mode "pet" or "master"
function SetBuilder.get_current_mode()
    local pet = windower.ffxi.get_mob_by_target('pet')
    PetManager.update_pet_mode(pet)
    local pet_mode = PetManager.get_pet_mode()

    if pet_mode.pet_valid then
        return "pet"
    else
        return "master"
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return SetBuilder

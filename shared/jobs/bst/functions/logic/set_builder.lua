---  ═══════════════════════════════════════════════════════════════════════════
---   BST Set Builder - Pet vs Master Gear Bifurcation
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles complex gear logic with Pet vs Master bifurcation.
---   CRITICAL MODULE: Determines whether to use pet or master gear based on pet.isvalid.
---
---   @file    jobs/bst/functions/logic/set_builder.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-17
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES
---  ═══════════════════════════════════════════════════════════════════════════

-- Load pet manager (for pet_valid cache)
local PetManager = require('shared/jobs/bst/functions/logic/pet_manager')

-- Town detection (pure, no set coupling) - BST uses nested sets.me.idle.Town
local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')

---  ═══════════════════════════════════════════════════════════════════════════
---   IDLE SET BUILDER (Pet vs Master Bifurcation)
---  ═══════════════════════════════════════════════════════════════════════════

--- Is the hybrid mode asking for damage taken gear?
local function wants_pdt()
    return state.HybridMode ~= nil and state.HybridMode.value == "PDT"
end

--- The PDT overlay for a group of sets, preferring the specific one.
---
--- Written out four times before, once per branch, always the same shape:
--- take sets.<group>.<situation>.PDT if it exists, otherwise the group's
--- catch-all PDT. A job that only defines sets.pet.PDT still gets covered in
--- every pet situation, which is the point of the fallback.
--- @param specific table|nil e.g. sets.pet.engaged
--- @param fallback table|nil e.g. sets.pet.PDT
--- @return table|nil Set to combine, nil when neither exists
local function pdt_overlay(specific, fallback)
    if specific and specific.PDT then
        return specific.PDT
    end
    return fallback
end

--- Combine the PDT overlay in, if the mode calls for one and one exists.
local function with_pdt(final_set, specific, fallback)
    if not wants_pdt() then
        return final_set
    end
    local overlay = pdt_overlay(specific, fallback)
    return overlay and set_combine(final_set, overlay) or final_set
end

--- Idle gear while a pet is out.
---
--- Three situations, and which one wins is a choice the player makes with
--- PetIdleMode: protect the pet, or protect yourself. Engaged always protects
--- the pet, because that is what is being hit.
--- @param base_idle_set table Fallback when nothing more specific is defined
--- @return table
local function idle_with_pet(base_idle_set)
    -- String comparison: Mote states hold "true", not true.
    if state.PetEngaged and state.PetEngaged.value == "true" then
        local final_set = sets.pet.engaged or sets.pet.idle or base_idle_set
        return with_pdt(final_set, sets.pet.engaged, sets.pet.PDT)
    end

    if state.PetIdleMode and state.PetIdleMode.value == "PetPDT" then
        local final_set = sets.pet.idle.PDT or sets.pet.idle or base_idle_set
        return with_pdt(final_set, sets.pet.idle, sets.pet.PDT)
    end

    -- MasterPDT: the pet is out but the player is the one being protected.
    local final_set = sets.me.idle.PDT or sets.me.idle or base_idle_set
    return with_pdt(final_set, sets.me.idle, sets.me.PDT)
end

--- Idle gear with no pet: the master's own sets, nothing else.
--- @param base_idle_set table Fallback when sets.me.idle is not defined
--- @return table
local function idle_without_pet(base_idle_set)
    local final_set = sets.me.idle or base_idle_set
    return with_pdt(final_set, sets.me.idle, sets.me.PDT)
end

--- Overlays that apply whatever the pet is doing.
--- @return table
local function apply_common_overlays(final_set)
    if state.WeaponSet and state.WeaponSet.value and sets[state.WeaponSet.value] then
        final_set = set_combine(final_set, sets[state.WeaponSet.value])
    end

    if state.SubSet and state.SubSet.value and sets[state.SubSet.value] then
        final_set = set_combine(final_set, sets[state.SubSet.value])
    end

    if state.Moving and state.Moving.value == "true" and sets.MoveSpeed then
        final_set = set_combine(final_set, sets.MoveSpeed)
    end

    -- Town feet go on last and regardless: in a city the movement bonus is
    -- worth more than whatever that slot was holding, pet out or not, moving
    -- or standing.
    if BaseSetBuilder.is_in_town() and sets.me and sets.me.idle
        and sets.me.idle.Town and sets.me.idle.Town.feet then
        final_set = set_combine(final_set, { feet = sets.me.idle.Town.feet })
    end

    return final_set
end

function SetBuilder.build_idle_set(base_idle_set)
    -- Mote caches the pet globally, so this costs nothing.
    local pet = _G.pet
    PetManager.update_pet_mode(pet)
    local pet_mode = PetManager.get_pet_mode()

    local final_set = pet_mode.pet_valid
                      and idle_with_pet(base_idle_set)
                      or idle_without_pet(base_idle_set)

    return apply_common_overlays(final_set)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   ENGAGED SET BUILDER (Pet vs Master Bifurcation)
---  ═══════════════════════════════════════════════════════════════════════════

---   Build engaged set with Pet vs Master bifurcation
---   CRITICAL LOGIC (3 CASES):
---   • Case 1: BOTH master AND pet engaged >> Use engagedBoth sets
---   • Case 2: Pet engaged ONLY (master idle) >> Use pet engaged sets
---   • Case 3: Master engaged ONLY (no pet OR pet idle) >> Use master engaged sets
---   • ALWAYS apply: WeaponSet, SubSet, HybridMode
---
---   @param base_engaged_set table Base engaged set from sets.me.engaged
---   @return table final_set Final engaged set after all customizations
function SetBuilder.build_engaged_set(base_engaged_set)
    -- Use GLOBAL pet and player from Mote-Include (cached, no API call)
    local pet = _G.pet
    local player = _G.player

    -- Update pet mode cache
    PetManager.update_pet_mode(pet)
    local pet_mode = PetManager.get_pet_mode()

    local final_set = base_engaged_set

    -- Check if pet is engaged (STRING comparison!)
    local pet_is_engaged = state.PetEngaged and state.PetEngaged.value == "true"

    -- Check if master is engaged
    local master_is_engaged = player and player.status == 'Engaged'

    ---══════════════════════════════════════════════════════════════════════════
    --- BIFURCATION: 3-Way Split (Both / Pet Only / Master Only)
    ---══════════════════════════════════════════════════════════════════════════

    if master_is_engaged and pet_mode.pet_valid and pet_is_engaged then
        -- ══════════════════════════════════════════════════════════════════════════
        -- CASE 1: BOTH MASTER AND PET ENGAGED - Use engagedBoth sets
        -- ══════════════════════════════════════════════════════════════════════════

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
        -- ══════════════════════════════════════════════════════════════════════════
        -- CASE 2: PET ENGAGED ONLY (master idle) - Use pet engaged sets
        -- ══════════════════════════════════════════════════════════════════════════

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
        -- ══════════════════════════════════════════════════════════════════════════
        -- CASE 3: MASTER ENGAGED ONLY (no pet OR pet idle) - Use master sets
        -- ══════════════════════════════════════════════════════════════════════════

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

    ---══════════════════════════════════════════════════════════════════════════
    --- ALWAYS APPLY: Dual Weapon System
    ---══════════════════════════════════════════════════════════════════════════

    if state.WeaponSet and state.WeaponSet.value and sets[state.WeaponSet.value] then
        final_set = set_combine(final_set, sets[state.WeaponSet.value])
    end

    if state.SubSet and state.SubSet.value and sets[state.SubSet.value] then
        final_set = set_combine(final_set, sets[state.SubSet.value])
    end

    return final_set
end

---  ═══════════════════════════════════════════════════════════════════════════
---   UTILITY FUNCTIONS
---  ═══════════════════════════════════════════════════════════════════════════

---   Check if should use pet sets (pet valid)
---   @return boolean use_pet_sets True if pet sets should be used
function SetBuilder.should_use_pet_sets()
    local pet = windower.ffxi.get_mob_by_target('pet')
    PetManager.update_pet_mode(pet)
    local pet_mode = PetManager.get_pet_mode()
    return pet_mode.pet_valid
end

---   Check if pet is engaged (STRING comparison!)
---   @return boolean is_engaged True if pet is engaged
function SetBuilder.is_pet_engaged()
    if not state or not state.PetEngaged then
        return false
    end

    -- STRING comparison!
    return state.PetEngaged.current == "true"
end

---   Get current pet mode focus ("pet" or "master")
---   Used for determining which PDT overlay to apply
---   @return string mode "pet" or "master"
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

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return SetBuilder

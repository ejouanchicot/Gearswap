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

--- The chosen main and sub weapon sets, which apply in every situation.
--- @return table
local function apply_weapon_sets(final_set)
    if state.WeaponSet and state.WeaponSet.value and sets[state.WeaponSet.value] then
        final_set = set_combine(final_set, sets[state.WeaponSet.value])
    end

    if state.SubSet and state.SubSet.value and sets[state.SubSet.value] then
        final_set = set_combine(final_set, sets[state.SubSet.value])
    end

    return final_set
end

--- Overlays that apply whatever the pet is doing.
--- @return table
local function apply_common_overlays(final_set)
    final_set = apply_weapon_sets(final_set)

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

--- Melee gear, chosen by who is actually fighting.
---
--- Three situations and they are not interchangeable. engagedBoth is for when
--- master and pet are both fighting: it is a mix, built to keep both of them
--- viable rather than favouring either. Pet-only is the master standing there
--- while the pet works, and master-only covers no pet at all as well as a pet
--- that is merely following.
--- @param base_engaged_set table Fallback when nothing more specific exists
--- @param pet_valid boolean Whether a pet is actually out
--- @return table
local function engaged_for_situation(base_engaged_set, pet_valid)
    -- String comparison: Mote states hold "true", not true.
    local pet_engaged = state.PetEngaged and state.PetEngaged.value == "true"
    local master_engaged = _G.player and _G.player.status == 'Engaged'

    if master_engaged and pet_valid and pet_engaged then
        local final_set = sets.pet.engagedBoth or sets.me.engaged or base_engaged_set
        return with_pdt(final_set, sets.pet.engagedBoth, sets.pet.PDT)
    end

    if pet_valid and pet_engaged then
        local final_set = sets.pet.engaged or base_engaged_set
        return with_pdt(final_set, sets.pet.engaged, sets.pet.PDT)
    end

    local final_set = sets.me.engaged or base_engaged_set
    return with_pdt(final_set, sets.me.engaged, sets.me.PDT)
end

function SetBuilder.build_engaged_set(base_engaged_set)
    PetManager.update_pet_mode(_G.pet)
    local pet_mode = PetManager.get_pet_mode()

    return apply_weapon_sets(
        engaged_for_situation(base_engaged_set, pet_mode.pet_valid))
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

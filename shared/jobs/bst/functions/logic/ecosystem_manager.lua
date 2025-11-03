---============================================================================
--- BST Ecosystem Manager - Dynamic State Management
---============================================================================
--- Manages ecosystem and species cycling with DYNAMIC state recreation.
--- CRITICAL MODULE: Handles dynamic state.species and state.ammoSet recreation.
---
--- @file jobs/bst/functions/logic/ecosystem_manager.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-17
---============================================================================

local EcosystemManager = {}

---============================================================================
--- DEPENDENCIES
---============================================================================

-- NOTE: BSTBeastPetData loaded from _G (set in character main file during get_sets())
-- DO NOT cache it at module load time - access _G.BSTBeastPetData directly in functions

-- Load message formatter
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Load Windower resources for item lookups
local res = require('resources')

---============================================================================
--- ECOSYSTEM MANAGEMENT
---============================================================================

--- Change ecosystem (cycle through 7 ecosystems)
--- CRITICAL: Recreates state.species and state.ammoSet dynamically
--- @return string ecosystem Current ecosystem name
--- @return number num_species Number of species available
function EcosystemManager.change_ecosystem()
    if not state or not state.ecosystem then
        return nil, 0
    end

    -- Cycle to next ecosystem
    state.ecosystem:cycle()
    local eco = state.ecosystem.value

    -- STEP 1: Get species list for this ecosystem
    local species_list = _G.BSTBeastPetData.get_species_for_ecosystem(eco)

    -- STEP 2: RECREATE state.species dynamically
    if #species_list > 0 then
        state.species = M{description = "Species", unpack(species_list)}
    else
        state.species = M{description = "Species", "None"}
    end

    -- STEP 3: Get ALL pets for this ecosystem
    local pets_list = _G.BSTBeastPetData.get_pets_for_ecosystem(eco)

    -- STEP 4: RECREATE state.ammoSet dynamically
    if #pets_list > 0 then
        state.ammoSet = M{description = "ammo", unpack(pets_list)}
    else
        state.ammoSet = M{description = "ammo", "None"}
    end

    -- STEP 5: Schedule broth equipping (0.1s delay for state to stabilize)
    coroutine.schedule(function()
        EcosystemManager.equip_pet_broth()
    end, 0.1)

    -- STEP 6: Display message (show number of SPECIES, not pets)
    MessageFormatter.show_bst_ecosystem_change(eco, #species_list)

    -- STEP 7: Update UI if available
    if _G.KeybindUI and _G.KeybindUI.update then
        _G.KeybindUI.update()
    end

    return eco, #species_list
end

--- Change species (cycle through species for current ecosystem)
--- CRITICAL: Recreates state.ammoSet dynamically based on species
--- @return string species Current species name
--- @return number num_jugs Number of jugs in inventory for this species
function EcosystemManager.change_species()
    if not state or not state.ecosystem or not state.species then
        return nil, 0
    end

    -- Cycle to next species
    state.species:cycle()
    local species = state.species.value
    local eco = state.ecosystem.value

    -- Get pets for this specific species in current ecosystem
    local pets_list = _G.BSTBeastPetData.get_pets_for_species(eco, species)

    -- RECREATE state.ammoSet dynamically for this species
    if #pets_list > 0 then
        state.ammoSet = M{description = "ammo", unpack(pets_list)}
    else
        state.ammoSet = M{description = "ammo", "None"}
    end

    -- Schedule broth equipping (0.1s delay)
    coroutine.schedule(function()
        EcosystemManager.equip_pet_broth()
    end, 0.1)

    -- Count jugs in inventory for this species
    local jug_count = EcosystemManager.count_species_jugs(eco, species)

    -- Display message (show number of JUGS in inventory)
    MessageFormatter.show_bst_species_change(species, jug_count)

    -- Update UI
    if _G.KeybindUI and _G.KeybindUI.update then
        _G.KeybindUI.update()
    end

    return species, jug_count
end

---============================================================================
--- BROTH EQUIPPING
---============================================================================

--- Equip broth for current ammoSet pet
--- Uses equipment sets (sets["Pet Name (Species)"]) created in bst_sets.lua
--- @return void
function EcosystemManager.equip_pet_broth()
    if not state or not state.ammoSet then
        return
    end

    local current_pet = state.ammoSet.current
    if not current_pet or current_pet == "None" then
        return
    end

    -- Check if set exists for this pet
    if not sets or not sets[current_pet] then
        MessageFormatter.show_error('No equipment set found for: ' .. tostring(current_pet))
        return
    end

    -- Equip broth (only ammo slot)
    equip(sets[current_pet])

    -- Get broth name for message
    local pet_data = _G.BSTBeastPetData.pets[current_pet]
    if pet_data and pet_data.broth then
        MessageFormatter.show_bst_broth_equip(current_pet, pet_data.broth)
    end
end

--- Cycle ammoSet (cycle through pets for current ecosystem/species)
--- Called when user cycles ammoSet state directly
--- @return void
function EcosystemManager.cycle_ammo()
    if not state or not state.ammoSet then
        return
    end

    -- Cycle to next pet
    state.ammoSet:cycle()

    -- Schedule broth equipping (0.1s delay)
    coroutine.schedule(function()
        EcosystemManager.equip_pet_broth()
    end, 0.1)

    -- Update UI
    if _G.KeybindUI and _G.KeybindUI.update then
        _G.KeybindUI.update()
    end
end

---============================================================================
--- INVENTORY COUNTING
---============================================================================

--- Count jugs in inventory for a specific species
--- @param ecosystem string Ecosystem name
--- @param species string Species name
--- @return number count Total count of jugs for this species in inventory
function EcosystemManager.count_species_jugs(ecosystem, species)
    local total_count = 0

    -- Get all pets for this species
    local pets_list = _G.BSTBeastPetData.get_pets_for_species(ecosystem, species)

    -- Get all storage containers
    local items = windower.ffxi.get_items()
    if not items then
        return 0
    end

    -- Build set of broth names for this species
    local broth_set = {}
    for _, pet_name in ipairs(pets_list) do
        local pet_data = _G.BSTBeastPetData.pets[pet_name]
        if pet_data and pet_data.broth then
            broth_set[pet_data.broth:lower()] = true
        end
    end

    -- Storage containers to search (inventory + all wardrobes)
    local storage_containers = {
        'inventory',
        'wardrobe',
        'wardrobe2',
        'wardrobe3',
        'wardrobe4',
        'wardrobe5',
        'wardrobe6',
        'wardrobe7',
        'wardrobe8'
    }

    -- Search all storage containers
    for _, container_name in ipairs(storage_containers) do
        local container = items[container_name]
        if container then
            -- Each container has 80 slots
            for i = 1, 80 do
                local item = container[i]
                if item and item.id and item.id ~= 0 and item.count then
                    -- Get item name from resources
                    local item_info = res.items[item.id]
                    if item_info and item_info.en then
                        local item_name = item_info.en
                        if broth_set[item_name:lower()] then
                            total_count = total_count + item.count
                        end
                    end
                end
            end
        end
    end

    return total_count
end

---============================================================================
--- INITIALIZATION
---============================================================================

--- Initialize ecosystem system (called in job_setup via coroutine)
--- Creates initial species and ammoSet states based on default ecosystem
--- @return void
function EcosystemManager.initialize()
    if not state or not state.ecosystem then
        MessageFormatter.show_error('Cannot initialize ecosystem manager - state.ecosystem not found')
        return
    end

    -- Validate BSTBeastPetData loaded
    if not _G.BSTBeastPetData or not _G.BSTBeastPetData.get_species_for_ecosystem then
        MessageFormatter.show_error('Cannot initialize ecosystem manager - BSTBeastPetData not loaded')
        return
    end

    -- Get default ecosystem
    local eco = state.ecosystem.value

    -- Get species list
    local species_list = _G.BSTBeastPetData.get_species_for_ecosystem(eco)

    -- Create state.species
    if #species_list > 0 then
        state.species = M{description = "Species", unpack(species_list)}
    else
        state.species = M{description = "Species", "None"}
    end

    -- Get pets list
    local pets_list = _G.BSTBeastPetData.get_pets_for_ecosystem(eco)

    -- Create state.ammoSet (alphabetically sorted by get_pets_for_ecosystem)
    if #pets_list > 0 then
        state.ammoSet = M{description = "ammo", unpack(pets_list)}
    else
        state.ammoSet = M{description = "ammo", "None"}
    end

    -- Equip initial broth
    coroutine.schedule(function()
        EcosystemManager.equip_pet_broth()
    end, 0.2)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return EcosystemManager

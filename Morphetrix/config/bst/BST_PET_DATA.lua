---============================================================================
--- FFXI GearSwap Data Module - Beastmaster Jug Pet Database
---============================================================================
--- Comprehensive database of all BST jug pets with their associated broth,
--- species classification, ecosystem categorization, and job specializations.
--- This data drives the intelligent pet selection and ecosystem management
--- systems for optimal Beastmaster performance.
---
--- Database includes 25+ jug pets across all ecosystems:
--- • **Aquan Ecosystem** - Fish, Crab species with tank/DD specializations
--- • **Amorph Ecosystem** - Acuex, Slime, Leech, Slug with diverse roles
--- • **Beast Ecosystem** - Tiger, Sheep, Rabbit, Raaz with combat focus
--- • **Bird Ecosystem** - Colibri, Hippogryph, Tulfaire with hybrid abilities
--- • **Lizard Ecosystem** - Lizard, Eft species with warrior specializations
--- • **Plantoid Ecosystem** - Funguar, Mandragora with support capabilities
--- • **Vermin Ecosystem** - Chapuli, Ladybug, Fly, Beetle, and specialist pets
---
--- Each entry contains: broth requirement, species type, ecosystem category,
--- and job specialization for intelligent pet selection algorithms.
---
--- @file config/bst/BST_PET_DATA.lua
--- @author Morphetrix
--- @version 2.0
--- @date Created: 2023-07-10 | Modified: 2025-10-17
--- @requires BST job configuration
---
--- @usage
---   local BSTBeastPetData = require('config/bst/BST_PET_DATA')
---   local pet_info = BSTBeastPetData.pets[pet_name]
---
--- @see jobs/bst/functions/logic/ecosystem_manager.lua for ecosystem management
---============================================================================

local BSTBeastPetData = {}

-- Core pet database (25 essential pets)
BSTBeastPetData.pets = {
    ['Jovial Edwin (Crab)'] = {broth = 'Pungent Broth', species = 'Crab', ecosystem = 'Aquan', job = 'PLD'},
    ['Amiable Roche (Fish)'] = {broth = 'Airy Broth', species = 'Fish', ecosystem = 'Aquan', job = 'WAR'},
    ['Fluffy Bredo (Acuex)'] = {broth = 'Venomous Broth', species = 'Acuex', ecosystem = 'Amorph', job = 'DRK'},
    ['Sultry Patrice (Slime)'] = {broth = 'Putrescent Broth', species = 'Slime', ecosystem = 'Amorph', job = 'WAR'},
    ['Fatso Fargann (Leech)'] = {broth = 'C. Plasma Broth', species = 'Leech', ecosystem = 'Amorph', job = 'WAR'},
    ['Generous Arthur (Slug)'] = {broth = 'Dire Broth', species = 'Slug', ecosystem = 'Amorph', job = 'WAR'},
    ['Blackbeard Randy (Tiger)'] = {broth = 'Meaty Broth', species = 'Tiger', ecosystem = 'Beast', job = 'WAR'},
    ['Rhyming Shizuna (Sheep)'] = {broth = 'Lyrical Broth', species = 'Sheep', ecosystem = 'Beast', job = 'WAR'},
    ['Pondering Peter (Rabbit)'] = {broth = 'Vis. Broth', species = 'Rabbit', ecosystem = 'Beast', job = 'WAR'},
    ['Vivacious Vickie (Raaz)'] = {broth = 'Tant. Broth', species = 'Raaz', ecosystem = 'Beast', job = 'MNK'},
    ['Choral Leera (Colibri)'] = {broth = 'Glazed Broth', species = 'Colibri', ecosystem = 'Bird', job = 'NIN/RDM'},
    ['Daring Roland (Hippogryph)'] = {
        broth = 'Feculent Broth',
        species = 'Hippogryph',
        ecosystem = 'Bird',
        job = 'THF/BLM'
    },
    ['Swooping Zhivago (Tulfaire)'] = {broth = 'Windy Greens', species = 'Tulfaire', ecosystem = 'Bird', job = 'WAR'},
    ['Warlike Patrick (Lizard)'] = {broth = 'Livid Broth', species = 'Lizard', ecosystem = 'Lizard', job = 'WAR'},
    ['Suspicious Alice (Eft)'] = {broth = 'Furious Broth', species = 'Eft', ecosystem = 'Lizard', job = 'WAR'},
    ['Brainy Waluis (Funguar)'] = {broth = 'Crumbly Soil', species = 'Funguar', ecosystem = 'Plantoid', job = 'WAR'},
    ['Sweet Caroline (Mandragora)'] = {
        broth = 'Aged Humus',
        species = 'Mandragora',
        ecosystem = 'Plantoid',
        job = 'MNK'
    },
    ['Bouncing Bertha (Chapuli)'] = {broth = 'Bubbly Broth', species = 'Chapuli', ecosystem = 'Vermin', job = 'WAR'},
    ['Threestar Lynn (Ladybug)'] = {broth = 'Muddy Broth', species = 'Ladybug', ecosystem = 'Vermin', job = 'THF'},
    ['Headbreaker Ken (Fly)'] = {broth = 'Blackwater Broth', species = 'Fly', ecosystem = 'Vermin', job = 'WAR'},
    ['Energized Sefina (Beetle)'] = {broth = 'Gassy Sap', species = 'Beetle', ecosystem = 'Vermin', job = 'WAR'},
    ['Anklebiter Jedd (Diremite)'] = {
        broth = 'Crackling Broth',
        species = 'Diremite',
        ecosystem = 'Vermin',
        job = 'DRK/BLM'
    },
    ['Left-Handed Yoko (Mosquito)'] = {
        broth = 'Heavenly Broth',
        species = 'Mosquito',
        ecosystem = 'Vermin',
        job = 'DRK'
    },
    ['Cursed Annabelle (Antlion)'] = {broth = 'Creepy Broth', species = 'Antlion', ecosystem = 'Vermin', job = 'WAR'},
    ['Weevil Familiar (Weevil)'] = {broth = 'T. Pristine Sap', species = 'Weevil', ecosystem = 'Vermin', job = 'THF'}
}

---============================================================================
--- ECOSYSTEM ORGANIZATION (FOR EFFICIENT LOOKUP)
---============================================================================

BSTBeastPetData.ecosystems = {}

-- Initialize ecosystem tables
local ecosystem_list = {'All', 'Aquan', 'Amorph', 'Beast', 'Bird', 'Lizard', 'Plantoid', 'Vermin'}
for _, eco in ipairs(ecosystem_list) do
    BSTBeastPetData.ecosystems[eco] = {}
end

-- Populate ecosystems from pets table
for pet_name, pet_info in pairs(BSTBeastPetData.pets) do
    local eco = pet_info.ecosystem
    if eco and BSTBeastPetData.ecosystems[eco] then
        BSTBeastPetData.ecosystems[eco][pet_name] = pet_info
    end
    -- Also add to "All" ecosystem
    BSTBeastPetData.ecosystems['All'][pet_name] = pet_info
end

---============================================================================
--- SPECIES EXTRACTION (FOR DYNAMIC STATE CREATION)
---============================================================================

--- Get list of unique species for an ecosystem
--- @param ecosystem string Ecosystem name ("Aquan", "Beast", etc.)
--- @return table species_list Array of unique species names (in definition order)
function BSTBeastPetData.get_species_for_ecosystem(ecosystem)
    local species_set = {}
    local species_list = {}

    if not BSTBeastPetData.ecosystems[ecosystem] then
        return species_list
    end

    -- Collect unique species IN DEFINITION ORDER (not alphabetical)
    -- This ensures species state matches the first pet in ammoSet state
    for pet_name, pet_data in pairs(BSTBeastPetData.pets) do
        if pet_data.ecosystem == ecosystem and not species_set[pet_data.species] then
            species_set[pet_data.species] = true
            table.insert(species_list, pet_data.species)
        end
    end

    return species_list
end

--- Get list of all pets for an ecosystem
--- @param ecosystem string Ecosystem name ("Aquan", "Beast", etc.)
--- @return table pets_list Array of pet names (in definition order)
function BSTBeastPetData.get_pets_for_ecosystem(ecosystem)
    local pets_list = {}

    if not BSTBeastPetData.ecosystems[ecosystem] then
        return pets_list
    end

    -- Collect all pet names IN DEFINITION ORDER (not alphabetical)
    -- This ensures pet order matches species order
    for pet_name, pet_data in pairs(BSTBeastPetData.pets) do
        if pet_data.ecosystem == ecosystem then
            table.insert(pets_list, pet_name)
        end
    end

    return pets_list
end

--- Get list of pets for a specific species in an ecosystem
--- @param ecosystem string Ecosystem name ("Aquan", "Beast", etc.)
--- @param species string Species name ("Fish", "Tiger", etc.)
--- @return table pets_list Array of pet names (in definition order)
function BSTBeastPetData.get_pets_for_species(ecosystem, species)
    local pets_list = {}

    if not BSTBeastPetData.ecosystems[ecosystem] then
        return pets_list
    end

    -- Collect pets matching species IN DEFINITION ORDER
    for pet_name, pet_data in pairs(BSTBeastPetData.pets) do
        if pet_data.ecosystem == ecosystem and pet_data.species == species then
            table.insert(pets_list, pet_name)
        end
    end

    return pets_list
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return BSTBeastPetData

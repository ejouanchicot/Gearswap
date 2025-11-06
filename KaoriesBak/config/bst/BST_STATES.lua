---============================================================================
--- BST States Configuration
---============================================================================
--- State definitions for Beastmaster job.
--- Loaded by user_setup() in Kaories_BST.lua
---
--- @file config/bst/BST_STATES.lua
--- @author Kaories
--- @version 1.0
--- @date Created: 2025-10-17
---============================================================================

local BSTStates = {}

--- Configure all BST states
function BSTStates.configure()
    -- Auto pet engage (ON/OFF)
    state.AutoPetEngage = M{['description']='AutoPetEngage', 'Off', 'On'}
    state.AutoPetEngage:set('On')

    -- Pet idle mode (MasterPDT/PetPDT focus)
    state.petIdleMode = M{['description']='PetIdleMode', 'MasterPDT', 'PetPDT'}
    state.petIdleMode:set('MasterPDT')

    -- Ecosystem (7 ecosystems)
    state.ecosystem = M{
        ['description']='Ecosystem',
        'Aquan', 'Beast', 'Amorph', 'Bird', 'Lizard', 'Plantoid', 'Vermin'
    }
    state.ecosystem:set('Aquan')

    -- Pet engaged state (STRINGS not booleans!)
    state.petEngaged = M{['description']='petEngaged', 'false', 'true'}
    state.petEngaged:set('false')

    -- Weapon set (main weapon)
    state.WeaponSet = M{['description']='Weapon', 'Aymur', 'Tauret'}
    state.WeaponSet:set('Aymur')

    -- Sub set (sub/shield)
    state.SubSet = M{['description']='Sub', "Agwu's Axe", 'Adapa Shield', 'Diamond Aspis'}
    state.SubSet:set("Agwu's Axe")

    -- Hybrid mode (PDT/Normal)
    state.HybridMode = M{['description']='Hybrid Mode', 'PDT', 'Normal'}
    state.HybridMode:set('PDT')
end

return BSTStates

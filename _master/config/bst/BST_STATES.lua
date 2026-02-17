---============================================================================
--- BST States Configuration
---============================================================================
--- State definitions for Beastmaster job.
--- Loaded by user_setup() in Tetsouo_BST.lua
---
--- @file config/bst/BST_STATES.lua
--- @author Tetsouo
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
    state.SubSet = M{['description']='Sub', "Agwu's Axe", 'Adapa Shield', 'Diamond Aspis', 'Kraken Club'}
    state.SubSet:set("Agwu's Axe")

    -- Hybrid mode (PDT/Normal)
    state.HybridMode = M{['description']='Hybrid Mode', 'PDT', 'Normal'}
    state.HybridMode:set('PDT')

    -- Moving state (manual toggle - no auto-detection for performance)
    -- Note: AutoMove is disabled for BST to reduce overhead
    -- Toggle manually if you want movement speed gear: //gs c toggle Moving
    state.Moving = M{['description']='Moving', 'false', 'true'}
    state.Moving:set('false')

    -- ========================================
    -- FAST CAST (WATCHDOG SYSTEM)
    -- ========================================

    --- FastCast: Fast Cast % for watchdog timeout calculation
    --- Set this to your total Fast Cast % from gear/traits
    --- Formula: adjusted_cast = base_cast × (1 - FC%/100)
    --- Cap: 80% maximum (FFXI mechanics)
    state.FastCast = M {
        ['description'] = 'Fast Cast %',
        0, 10, 20, 30, 40, 50, 60, 70, 80
    }
    state.FastCast:set(0)  -- Default: 0% (adjust based on your gear)
end

return BSTStates

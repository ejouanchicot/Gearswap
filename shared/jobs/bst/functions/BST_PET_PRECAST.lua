---============================================================================
--- BST Pet Precast Module - Pet Ability Precast Handling
---============================================================================
--- Handles precast gear for pet abilities (Call Beast, Reward, Ready Moves, etc.)
--- This is a SPECIAL hook called ONLY for pet-related abilities.
---
--- @file jobs/bst/functions/BST_PET_PRECAST.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-18
---============================================================================

---============================================================================
--- PET PRECAST HOOK
---============================================================================

--- Called before pet abilities (Call Beast, Reward, Ready Moves, etc.)
--- @param spell table Spell/ability data
--- @return void
function job_pet_precast(spell)
    local name = spell.name
    local set

    -- ==========================================================================
    -- SPECIAL PET ABILITIES
    -- ==========================================================================

    if name == 'Reward' then
        -- Reward set (Pet Food Theta equipped)
        set = sets.precast.JA['Reward']

    elseif name == 'Killer Instinct' then
        set = sets.precast.JA['Killer Instinct']

    elseif name == 'Spur' then
        set = sets.precast.JA['Spur']

    -- ==========================================================================
    -- READY MOVES (Default handling)
    -- ==========================================================================
    elseif player.status ~= 'Engaged' then
        -- Player idle - use Misc Idle set
        set = sets.precast.JA['Misc Idle']
    else
        -- Player engaged - use Default set
        set = sets.precast.JA['Default']
    end

    -- Equip set if found
    if set then
        equip(set)
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.job_pet_precast = job_pet_precast

-- Export as module
return {
    job_pet_precast = job_pet_precast
}

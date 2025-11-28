---============================================================================
--- PUP Pet Midcast Module - Ready Move Midcast Handling
---============================================================================
--- Handles midcast gear for Ready Moves (pet TP moves).
--- This is a SPECIAL hook called ONLY for pet abilities during midcast.
---
--- @file jobs/pup/functions/PUP_PET_MIDCAST.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-18
---============================================================================

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Ready move categorizer
local success_rmc, ReadyMoveCategorizer = pcall(require, 'shared/jobs/pup/functions/logic/ready_move_categorizer')
if not success_rmc then
    ReadyMoveCategorizer = nil
end

---============================================================================
--- PET MIDCAST HOOK
---============================================================================

--- Called during pet ability midcast (specifically for Ready Moves)
--- @param spell table Spell/ability data
--- @return void
function job_pet_midcast(spell)
    local name = spell.name

    -- ==========================================================================
    -- SKIP NON-READY MOVES (Call Beast, Bestial Loyalty, Reward, etc.)
    -- ==========================================================================
    if name == 'Call Beast' or name == 'Bestial Loyalty' or
       name == 'Reward' or name == 'Killer Instinct' or name == 'Spur' then
        return  -- Don't override precast set for these abilities
    end

    -- ==========================================================================
    -- READY MOVES - 4 CATEGORIES
    -- ==========================================================================

    -- Get category from categorizer
    local category = nil
    if ReadyMoveCategorizer then
        category = ReadyMoveCategorizer.get_category(name)
    end

    -- Check if player is engaged (for _ww variants with weapon)
    local player_engaged = (player and player.status == "Engaged")

    -- Equip appropriate set based on category
    if category == "Physical" and sets.midcast.pet_physical_moves then
        equip(sets.midcast.pet_physical_moves)

    elseif category == "PhysicalMulti" and sets.midcast.pet_physicalMulti_moves then
        equip(sets.midcast.pet_physicalMulti_moves)

    elseif category == "MagicAtk" then
        -- Choose between normal and _ww (with weapon) variant
        local set = player_engaged
            and sets.midcast.pet_magicAtk_moves_ww
            or sets.midcast.pet_magicAtk_moves
        if set then
            equip(set)
        end

    elseif category == "MagicAcc" then
        -- Choose between normal and _ww (with weapon) variant
        local set = player_engaged
            and sets.midcast.pet_magicAcc_moves_ww
            or sets.midcast.pet_magicAcc_moves
        if set then
            equip(set)
        end

    else
        -- Fallback to physical set if category unknown
        if sets.midcast.pet_physical_moves then
            equip(sets.midcast.pet_physical_moves)
        end
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.job_pet_midcast = job_pet_midcast

-- Export as module
return {
    job_pet_midcast = job_pet_midcast
}

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

local MessageFormatter = nil

--- Called before pet abilities (Ready Moves, Reward, Spur, etc.)
--- This is the LAST precast hook (executes after Mote-Include)
--- @param spell table Spell/ability data
--- @return void
function job_pet_precast(spell)
    if _G.BST_DEBUG_PRECAST then
        if not MessageFormatter then
            MessageFormatter = require('shared/utils/messages/message_formatter')
        end
        MessageFormatter.show_debug('PET_PRECAST', '========================================')
        MessageFormatter.show_debug('PET_PRECAST', 'Called for: ' .. (spell.name or 'unknown'))
        MessageFormatter.show_debug('PET_PRECAST', '========================================')
    end

    local set = nil
    local set_name = nil

    -- ==========================================================================
    -- READY MOVES - All use same Sic set (Gleti's Breeches)
    -- ==========================================================================
    if spell.bst_is_ready_move then
        -- Flag set by job_precast = this is a Ready Move
        set = sets.precast.JA['Sic']
        set_name = "Sic"
        if _G.BST_DEBUG_PRECAST then
            MessageFormatter.show_debug('PET_PRECAST', 'Ready Move detected - equipping Sic set')
        end

    -- ==========================================================================
    -- OTHER PET ABILITIES (non-Ready Moves)
    -- ==========================================================================
    elseif spell.name == 'Reward' then
        set = sets.precast.JA['Reward']
        set_name = "Reward"

    elseif spell.name == 'Killer Instinct' then
        set = sets.precast.JA['Killer Instinct']
        set_name = "Killer Instinct"

    elseif spell.name == 'Spur' then
        set = sets.precast.JA['Spur']
        set_name = "Spur"
    end

    -- BEFORE equip
    if set_name and _G.BST_DEBUG_PRECAST then
        local eq_before = player.equipment
        MessageFormatter.show_debug('PET_PRECAST', 'BEFORE equip - legs: ' .. (eq_before.legs or 'empty'))
    end

    -- Equip set if found
    if set then
        equip(set)
        if _G.BST_DEBUG_PRECAST then
            MessageFormatter.show_debug('PET_PRECAST', 'Equipped set: ' .. set_name)

            -- Check AFTER equip (may be buffered)
            coroutine.schedule(function()
                local eq_after = player.equipment
                MessageFormatter.show_debug('PET_PRECAST', 'AFTER 0.1s - legs: ' .. (eq_after.legs or 'empty'))
            end, 0.1)
        end
    elseif _G.BST_DEBUG_PRECAST then
        MessageFormatter.show_debug('PET_PRECAST', 'No set found for: ' .. (spell.name or 'unknown'))
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

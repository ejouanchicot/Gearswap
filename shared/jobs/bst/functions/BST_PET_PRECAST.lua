---  ═══════════════════════════════════════════════════════════════════════════
---   BST Pet Precast Module - Pet Ability Precast Handling
---  ═══════════════════════════════════════════════════════════════════════════
---   Precast gear for pet abilities (Reward, Killer Instinct, Spur, Ready Moves).
---   NOTE: neither the GearSwap engine nor Mote-Include has a pet_precast
---   event, so nothing calls job_pet_precast and this file never runs its
---   hook. BST_PRECAST.job_precast equips the Sic set for Ready moves itself.
---
---   @file    shared/jobs/bst/functions/BST_PET_PRECAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-18
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local MessageFormatter = nil

---  ═══════════════════════════════════════════════════════════════════════════
---   PET PRECAST HOOK
---  ═══════════════════════════════════════════════════════════════════════════

---   Intended to run before pet abilities (Ready Moves, Reward, Spur, etc.);
---   never called (see file header)
---   @param spell table Spell/ability data
---   @return void
function job_pet_precast(spell)
    if _G.BST_DEBUG_PRECAST then
        if not MessageFormatter then
            local mod_ok, mod = pcall(require, 'shared/utils/messages/message_formatter')
            if not mod_ok then mod = nil end
            MessageFormatter = mod
        end
        MessageFormatter.show_debug('PET_PRECAST', '========================================')
        MessageFormatter.show_debug('PET_PRECAST', 'Called for: ' .. (spell.name or 'unknown'))
        MessageFormatter.show_debug('PET_PRECAST', '========================================')
    end

    local set = nil
    local set_name = nil

    -- ══════════════════════════════════════════════════════════════════════════
    -- READY MOVES - All use same Sic set (Gleti's Breeches)
    -- ══════════════════════════════════════════════════════════════════════════
    if spell.bst_is_ready_move then
        -- Flag set by job_precast = this is a Ready Move
        set = sets.precast.JA['Sic']
        set_name = "Sic"
        if _G.BST_DEBUG_PRECAST then
            MessageFormatter.show_debug('PET_PRECAST', 'Ready Move detected - equipping Sic set')
        end

    -- ══════════════════════════════════════════════════════════════════════════
    -- OTHER PET ABILITIES (non-Ready Moves)
    -- ══════════════════════════════════════════════════════════════════════════
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

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export globally for GearSwap
_G.job_pet_precast = job_pet_precast

-- Module table for require() compatibility (parity with _G export above)
return {
    job_pet_precast = job_pet_precast,
}


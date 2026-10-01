---  ═══════════════════════════════════════════════════════════════════════════
---   BST Pet Manager - Pet Tracking & Auto-Engage
---  ═══════════════════════════════════════════════════════════════════════════
---   Manages pet status tracking, auto-engage system, and ready moves caching.
---   Uses multiple cache layers for performance (1.0s, 0.5s, 30s).
---
---   @file    shared/jobs/bst/functions/logic/pet_manager.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2025-10-17
---  ═══════════════════════════════════════════════════════════════════════════

local PetManager = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES
---  ═══════════════════════════════════════════════════════════════════════════

-- Load resources for ability lookups
local res = require('resources')

-- Load message formatter
local MessageFormatter = require('shared/utils/messages/message_formatter')

---  ═══════════════════════════════════════════════════════════════════════════
---   PERFORMANCE CACHING (2 LAYERS)
---  ═══════════════════════════════════════════════════════════════════════════

-- Cache Layer 1: Pet Mode (1.0s duration)
local cached_pet_mode = {
    pet_valid = false,
    pet_id = nil,
    timestamp = 0
}
local PET_MODE_CACHE_DURATION = 1.0  -- Increased from 0.1s (pet rarely appears/disappears)

-- Cache Layer 2: Ready Moves (30s duration - Ready Moves only change when pet changes)
local ready_moves_cache = {
    moves = {},
    timestamp = 0
}
local READY_MOVES_CACHE_DURATION = 30.0  -- Increased from 10.0s (moves rarely change)

---  ═══════════════════════════════════════════════════════════════════════════
---   PET MODE TRACKING
---  ═══════════════════════════════════════════════════════════════════════════

---   Update pet mode cache (pet_valid, pet_id)
---   @param pet table|nil Pet object (_G.pet or windower.ffxi.get_mob_by_target('pet'))
---   @return void
function PetManager.update_pet_mode(pet)
    local current_time = os.clock()

    -- Check cache validity
    if current_time - cached_pet_mode.timestamp < PET_MODE_CACHE_DURATION then
        return  -- Use cached data
    end

    -- Update cache
    cached_pet_mode.pet_valid = pet and pet.isvalid or false
    cached_pet_mode.pet_id = pet and pet.id or nil
    cached_pet_mode.timestamp = current_time
end

---   Get cached pet mode
---   @return table cached_pet_mode {pet_valid, pet_id, timestamp}
function PetManager.get_pet_mode()
    return cached_pet_mode
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PET AUTO-ENGAGE SYSTEM
---  ═══════════════════════════════════════════════════════════════════════════

---   Disengage pet
---   @return void
function PetManager.disengage_pet()
    windower.send_command('input /pet "Heel" <me>')
    MessageFormatter.show_bst_pet_disengage()

    -- Update PetEngaged state (STRING!)
    if state and state.PetEngaged then
        state.PetEngaged:set('false')
    end
end

---   Manually engage pet (force engage regardless of conditions)
---   @return void
function PetManager.engage_pet()
    windower.send_command('input /pet "Fight" <t>')
    MessageFormatter.show_bst_pet_engage()

    -- Update PetEngaged state (STRING!)
    if state and state.PetEngaged then
        state.PetEngaged:set('true')
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   READY MOVES MANAGEMENT
---  ═══════════════════════════════════════════════════════════════════════════

---   Update ready moves cache (pet abilities)
---   @param force_refresh boolean Skip cache if true
---   @return table ready_moves Array of {id, name, element, mp_cost}
function PetManager.update_ready_moves(force_refresh)
    local current_time = os.clock()

    -- Check cache validity
    if not force_refresh and
       current_time - ready_moves_cache.timestamp < READY_MOVES_CACHE_DURATION then
        return ready_moves_cache.moves
    end

    local ready_moves = {}
    local pet = _G.pet or windower.ffxi.get_mob_by_target('pet')

    -- Check if pet exists
    if not pet or not pet.id or pet.id == 0 then
        ready_moves_cache.moves = {}
        ready_moves_cache.timestamp = current_time
        return ready_moves_cache.moves
    end

    -- Get CURRENT player abilities (includes pet Ready Moves dynamically)
    local player_abilities = windower.ffxi.get_abilities()

    if player_abilities and player_abilities.job_abilities then
        -- Job abilities contain Ready Moves when pet is active
        for _, ability_id in ipairs(player_abilities.job_abilities) do
            -- Look up ability name in resources
            if res and res.job_abilities[ability_id] then
                local ability_data = res.job_abilities[ability_id]

                -- Filter ONLY Ready Moves (type == 'Monster' for BST)
                -- This excludes Blood Pacts (SMN), Ninjutsu, etc.
                -- Ready Moves also typically have ID >= 640
                if ability_data.type == 'Monster' and ability_id >= 640 and ability_id < 900 then
                    table.insert(ready_moves, {
                        id = ability_id,
                        name = ability_data.en,
                        element = ability_data.element,
                        mp_cost = ability_data.mp_cost or 0
                    })
                end
            end
        end

        -- Sort by ability ID (FFXI order)
        table.sort(ready_moves, function(a, b) return a.id < b.id end)
    end

    -- Update cache
    ready_moves_cache.moves = ready_moves
    ready_moves_cache.timestamp = current_time

    return ready_moves
end

---   Get ready moves (with caching)
---   @return table ready_moves Array of {id, name, element, mp_cost}
function PetManager.get_ready_moves()
    return PetManager.update_ready_moves(false)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return PetManager

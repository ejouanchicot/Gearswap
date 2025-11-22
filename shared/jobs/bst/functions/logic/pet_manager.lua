---============================================================================
--- BST Pet Manager - Pet Tracking & Auto-Engage
---============================================================================
--- Manages pet status tracking, auto-engage system, and ready moves caching.
--- Uses multiple cache layers for performance (0.1s, 0.1s, 5s).
---
--- @file jobs/bst/functions/logic/pet_manager.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-17
---============================================================================

local PetManager = {}

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Load resources for ability lookups
local res = require('resources')

-- Load message formatter
local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- PERFORMANCE CACHING (3 LAYERS)
---============================================================================

-- Cache Layer 1: Pet Mode (0.1s duration)
local cached_pet_mode = {
    pet_valid = false,
    pet_id = nil,
    timestamp = 0
}
local PET_MODE_CACHE_DURATION = 1.0  -- Increased from 0.1s (pet rarely appears/disappears)

-- Cache Layer 2: Pet Status (0.5s duration)
local pet_status_cache = {
    status = nil,
    timestamp = 0,
    pet_id = nil
}
local PET_STATUS_CACHE_DURATION = 0.5  -- Increased from 0.1s (status changes aren't instant)

-- Cache Layer 3: Ready Moves (30s duration - Ready Moves only change when pet changes)
local ready_moves_cache = {
    moves = {},
    timestamp = 0
}
local READY_MOVES_CACHE_DURATION = 30.0  -- Increased from 10.0s (moves rarely change)

---============================================================================
--- PET MODE TRACKING
---============================================================================

--- Update pet mode cache (pet_valid, pet_id)
--- @param pet table Pet object from windower.ffxi.get_mob_by_target('pet')
--- @return void
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

--- Get cached pet mode
--- @return table cached_pet_mode {pet_valid, pet_id, timestamp}
function PetManager.get_pet_mode()
    return cached_pet_mode
end

--- Check if pet is valid (uses cache)
--- @param pet table Pet object (optional, will fetch if nil)
--- @return boolean is_valid True if pet is valid
function PetManager.is_pet_valid(pet)
    if not pet then
        pet = windower.ffxi.get_mob_by_target('pet')
    end

    PetManager.update_pet_mode(pet)
    return cached_pet_mode.pet_valid
end

---============================================================================
--- PET STATUS TRACKING
---============================================================================

--- Get pet status (Idle or Engaged) with caching
--- @param pet table Pet object (optional, will fetch if nil)
--- @return string status "Idle", "Engaged", or nil
function PetManager.get_pet_status(pet)
    if not pet then
        pet = windower.ffxi.get_mob_by_target('pet')
    end

    if not pet or not pet.isvalid then
        return nil
    end

    local current_time = os.clock()
    local pet_id = pet.id

    -- Check cache validity (same pet + within cache duration)
    if pet_status_cache.pet_id == pet_id and
       current_time - pet_status_cache.timestamp < PET_STATUS_CACHE_DURATION then
        return pet_status_cache.status
    end

    -- Update cache
    pet_status_cache.status = pet.status
    pet_status_cache.timestamp = current_time
    pet_status_cache.pet_id = pet_id

    return pet.status
end

---============================================================================
--- PET AUTO-ENGAGE SYSTEM
---============================================================================

--- Check and auto-engage pet if conditions met
--- CONDITIONS:
---   1. AutoPetEngage state is 'On'
---   2. Player is Engaged
---   3. Pet is valid
---   4. Pet is NOT already engaged (state.petEngaged == "false" - STRING!)
---
--- @param pet table Pet object (optional, will fetch if nil)
--- @return boolean engaged True if pet was engaged, false otherwise
function PetManager.check_and_engage_pet(pet)
    -- Condition 1: Auto-engage enabled
    if not state or not state.AutoPetEngage or state.AutoPetEngage.current ~= 'On' then
        return false
    end

    -- Condition 2: Player is engaged
    if not player or player.status ~= 'Engaged' then
        return false
    end

    -- Condition 3: Pet is valid
    if not pet then
        pet = _G.pet
    end

    -- Check pet validity by ID (if pet has an ID, it's valid)
    if not pet or not pet.id or pet.id == 0 then
        return false
    end

    -- Condition 4: Pet is NOT already engaged
    -- Try both .current and .value for compatibility
    local petEngaged_value = state.petEngaged and (state.petEngaged.value or state.petEngaged.current) or nil

    if not state.petEngaged or (petEngaged_value ~= 'false' and petEngaged_value ~= false) then
        return false
    end

    -- All conditions met - engage pet
    send_command('input /pet "Fight" <t>')
    MessageFormatter.show_bst_pet_engage()

    -- Update petEngaged state
    if state.petEngaged then
        state.petEngaged:set('true')
    end

    return true
end

--- Disengage pet
--- @return void
function PetManager.disengage_pet()
    send_command('input /pet "Heel" <me>')
    MessageFormatter.show_bst_pet_disengage()

    -- Update petEngaged state (STRING!)
    if state and state.petEngaged then
        state.petEngaged:set('false')
    end
end

--- Manually engage pet (force engage regardless of conditions)
--- @return void
function PetManager.engage_pet()
    send_command('input /pet "Fight" <t>')
    MessageFormatter.show_bst_pet_engage()

    -- Update petEngaged state (STRING!)
    if state and state.petEngaged then
        state.petEngaged:set('true')
    end
end

---============================================================================
--- READY MOVES MANAGEMENT
---============================================================================

--- Update ready moves cache (pet abilities)
--- @param force_refresh boolean Skip cache if true
--- @return table ready_moves Array of {id, name, element, mp_cost}
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

--- Get ready moves (with caching)
--- @return table ready_moves Array of {id, name, element, mp_cost}
function PetManager.get_ready_moves()
    return PetManager.update_ready_moves(false)
end

---============================================================================
--- PET STATUS MONITORING (for auto-engage)
---============================================================================

-- Debouncing: Prevent spam of gs c update (expensive operation)
local last_monitor_time = 0
local MONITOR_DEBOUNCE = 1.0  -- Don't update more than once per 1.0s (matches monitoring interval)

--- Monitor pet status changes and update state.petEngaged
--- Called periodically (e.g., in time change event)
--- Uses GLOBAL 'pet' variable from Mote-Include via _G
--- @return void
function PetManager.monitor_pet_status()
    -- DEBOUNCING: Skip if called too recently (prevents lag spikes)
    local current_time = os.clock()
    if current_time - last_monitor_time < MONITOR_DEBOUNCE then
        return  -- Too soon, skip
    end
    last_monitor_time = current_time

    -- Access GLOBAL 'pet' variable from Mote-Include via _G (require() modules don't have direct access)
    local pet = _G.pet

    if not pet or not pet.isvalid then
        -- No pet - ensure petEngaged is "false" (STRING!)
        if state and state.petEngaged and state.petEngaged.value ~= "false" then
            state.petEngaged:set('false')
        end
        return
    end

    -- Check if status is number 1 OR string "Engaged"
    if pet.status == 1 or pet.status == "Engaged" then
        -- Pet is Engaged - ensure petEngaged is "true" (STRING!)
        if state and state.petEngaged and state.petEngaged.value ~= "true" then
            state.petEngaged:set('true')
            return true -- State changed
        end
    else
        -- Pet is Idle - ensure petEngaged is "false" (STRING!)
        if state and state.petEngaged and state.petEngaged.value ~= "false" then
            state.petEngaged:set('false')
            return true -- State changed
        end
    end

    return false -- No state change
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return PetManager
